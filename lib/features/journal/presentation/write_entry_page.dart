import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:memoirly/core/constants/mood_keys.dart';
import 'package:memoirly/core/di/providers.dart';
import 'package:memoirly/core/localization/app_localizations.dart';
import 'package:memoirly/core/localization/mood_localizations.dart';
import 'package:memoirly/core/theme/app_colors.dart';
import 'package:memoirly/domain/entities/journal_entry.dart';
import 'package:uuid/uuid.dart';

class WriteEntryPage extends ConsumerStatefulWidget {
  const WriteEntryPage({super.key, this.entryId, this.initialMoodKey});

  final String? entryId;
  final String? initialMoodKey;

  @override
  ConsumerState<WriteEntryPage> createState() => _WriteEntryPageState();
}

class _WriteEntryPageState extends ConsumerState<WriteEntryPage> {
  late final TextEditingController _title;
  late final TextEditingController _body;
  late final TextEditingController _tags;
  int _sentiment = 2;
  String? _moodKey;
  bool _hydrated = false;
  bool _listenersAttached = false;
  Timer? _saveDebounce;
  String? _draftEntryId;
  bool _persistInFlight = false;
  DateTime? _lastSavedAt;
  DateTime? _entryCreatedAt;
  Completer<bool>? _persistCoalescer;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController();
    _body = TextEditingController();
    _tags = TextEditingController();
    _moodKey = widget.initialMoodKey;
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    if (_listenersAttached) {
      _title.removeListener(_scheduleDebouncedSave);
      _body.removeListener(_scheduleDebouncedSave);
      _tags.removeListener(_scheduleDebouncedSave);
    }
    _title.dispose();
    _body.dispose();
    _tags.dispose();
    super.dispose();
  }

  bool get _formReady => widget.entryId == null || _hydrated;

  bool get _meaningfulContent {
    return _title.text.trim().isNotEmpty ||
        _body.text.trim().isNotEmpty ||
        _parseTags(_tags.text).isNotEmpty;
  }

  List<String> _parseTags(String raw) {
    final re = RegExp(r'#([\w-]+)');
    return re
        .allMatches(raw)
        .map((m) => m.group(1)!.toLowerCase())
        .toSet()
        .toList();
  }

  void _ensureListeners() {
    if (_listenersAttached) return;
    _listenersAttached = true;
    _title.addListener(_scheduleDebouncedSave);
    _body.addListener(_scheduleDebouncedSave);
    _tags.addListener(_scheduleDebouncedSave);
  }

  void _scheduleDebouncedSave() {
    if (!_formReady || !mounted) return;
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      unawaited(_persist(showErrorSnack: false));
    });
  }

  /// Coalesces overlapping persist calls (debounce + back + Done).
  Future<bool> _persist({required bool showErrorSnack}) async {
    if (_persistCoalescer != null) {
      return _persistCoalescer!.future;
    }
    final c = Completer<bool>();
    _persistCoalescer = c;

    var ok = false;
    try {
      ok = await _persistOnce(showErrorSnack: showErrorSnack);
    } catch (e, st) {
      debugPrint('WriteEntryPage._persist: $e\n$st');
      ok = false;
    } finally {
      if (!c.isCompleted) c.complete(ok);
      _persistCoalescer = null;
    }
    return c.future;
  }

  Future<bool> _persistOnce({required bool showErrorSnack}) async {
    if (!mounted || !_formReady) return true;

    final shouldWrite = widget.entryId != null ||
        _draftEntryId != null ||
        _meaningfulContent;
    if (!shouldWrite) return true;

    final l = AppLocalizations.of(context);
    final auth = ref.read(authRepositoryProvider);
    final uid = await auth.getCurrentUserId();
    if (uid == null) {
      if (showErrorSnack && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.authError)),
        );
      }
      return false;
    }

    if (mounted) setState(() => _persistInFlight = true);
    try {
      final tags = _parseTags(_tags.text);
      final mood = _moodKey ?? moodDisplayKeyFromIndex(_sentiment);
      var id = widget.entryId ?? _draftEntryId;
      id ??= const Uuid().v4();
      // Pin id before the first async write so retries/debounce reuse the same doc.
      if (widget.entryId == null && _draftEntryId == null && _meaningfulContent) {
        if (mounted) setState(() => _draftEntryId = id);
      }

      JournalEntry? existing;
      try {
        existing = await ref.read(journalRepositoryProvider).getById(id);
      } catch (e, st) {
        debugPrint('WriteEntry getById: $e\n$st');
        existing = null;
      }
      final resolvedCreated =
          existing?.createdAt ?? _entryCreatedAt ?? DateTime.now();
      _entryCreatedAt ??= resolvedCreated;
      final createdAt = resolvedCreated;

      final entry = JournalEntry(
        id: id,
        userId: uid,
        title: _title.text.trim(),
        content: _body.text.trim(),
        createdAt: createdAt,
        mood: mood,
        tags: tags,
      );

      // Repository `update` is upsert-safe (Firestore merge-set, local list upsert).
      await ref.read(updateEntryUseCaseProvider).call(entry);

      if (mounted) {
        setState(() => _lastSavedAt = DateTime.now());
      }
      return true;
    } catch (e, st) {
      debugPrint('WriteEntryPage._persistOnce: $e\n$st');
      if (showErrorSnack && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.errorGeneric)),
        );
      }
      return false;
    } finally {
      if (mounted) setState(() => _persistInFlight = false);
    }
  }

  Future<void> _handleLeave() async {
    _saveDebounce?.cancel();
    try {
      await _persist(showErrorSnack: true);
    } catch (e, st) {
      debugPrint('WriteEntryPage._handleLeave: $e\n$st');
    }
    if (!mounted) return;
    // Always leave on back — a failed save must not trap the user.
    context.pop();
  }

  Future<void> _onDone() async {
    _saveDebounce?.cancel();
    final ok = await _persist(showErrorSnack: true);
    if (!mounted) return;
    if (ok) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final id = widget.entryId;
    if (id != null && !_hydrated) {
      final async = ref.watch(entryByIdProvider(id));
      return async.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator.adaptive()),
        ),
        error: (_, __) => Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
          ),
          body: Center(child: Text(l.errorGeneric)),
        ),
        data: (e) {
          if (e == null) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.pop(),
                ),
              ),
              body: Center(child: Text(l.errorGeneric)),
            );
          }
          if (!_hydrated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || _hydrated) return;
              setState(() {
                _title.text = e.title;
                _body.text = e.content;
                _tags.text = e.tags.map((t) => '#$t').join(' ');
                _moodKey = e.mood ?? _moodKey;
                _entryCreatedAt = e.createdAt;
                _hydrated = true;
              });
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator.adaptive()),
            );
          }
          return _form(context, l, locale);
        },
      );
    }

    return _form(context, l, locale);
  }

  Widget _form(
    BuildContext context,
    AppLocalizations l,
    String locale,
  ) {
    _ensureListeners();

    final now = DateTime.now();
    final header = DateFormat.yMMMMd(locale).format(now);
    final sub = DateFormat.EEEE(locale).format(now);

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final bottomPad = 200.0 + bottomInset;
    final theme = Theme.of(context);
    final hintStyle = theme.textTheme.labelSmall?.copyWith(
      color: AppColors.onSurfaceVariant.withValues(alpha: 0.75),
    );

    Widget? status;
    if (_persistInFlight) {
      status = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              l.entrySaving,
              style: theme.textTheme.labelSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    } else if (_lastSavedAt != null &&
        (widget.entryId != null || _draftEntryId != null)) {
      status = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_done_rounded,
            size: 18,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.85),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              l.entrySaved,
              style: theme.textTheme.labelSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    } else if (widget.entryId == null) {
      status = Text(
        l.entryAutoSaveHint,
        style: hintStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.end,
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        unawaited(_handleLeave());
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => unawaited(_handleLeave()),
          ),
          title: Text(
            widget.entryId != null ? l.edit : l.newEntry,
            style: theme.appBarTheme.titleTextStyle,
          ),
          actions: [
            if (status != null)
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 4),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * 0.36,
                    ),
                    child: status,
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.check_rounded),
              tooltip: l.doneClose,
              onPressed: () => unawaited(_onDone()),
            ),
          ],
        ),
        body: Stack(
          children: [
            ListView(
              padding: EdgeInsets.fromLTRB(24, 16, 24, bottomPad),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            header,
                            style:
                                Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontFamily: 'Manrope',
                                      fontStyle: FontStyle.normal,
                                      fontWeight: FontWeight.w800,
                                    ),
                          ),
                          Text(
                            '${DateFormat.jm(locale).format(now)} · $sub',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.edit_note_rounded,
                      color: AppColors.outlineVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _title,
                  decoration: InputDecoration(
                    hintText: l.titleHint,
                    border: InputBorder.none,
                  ),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextField(
                  controller: _body,
                  maxLines: null,
                  minLines: 12,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 22,
                        height: 1.8,
                      ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Material(
                color: AppColors.surfaceContainerLow.withValues(alpha: 0.96),
                elevation: 12,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomInset),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(36),
                        border: Border.all(
                          color: AppColors.surfaceVariant.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  l.mood,
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: List.generate(5, (i) {
                                        final sel = _sentiment == i;
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(right: 6),
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                _sentiment = i;
                                                _moodKey =
                                                    moodDisplayKeyFromIndex(i);
                                              });
                                              _scheduleDebouncedSave();
                                            },
                                            borderRadius:
                                                BorderRadius.circular(999),
                                            child: CircleAvatar(
                                              radius: 20,
                                              backgroundColor: sel
                                                  ? AppColors.secondaryContainer
                                                  : Colors.transparent,
                                              child: Icon(
                                                [
                                                  Icons.sentiment_very_satisfied,
                                                  Icons.sentiment_satisfied,
                                                  Icons.sentiment_neutral,
                                                  Icons.sentiment_dissatisfied,
                                                  Icons
                                                      .sentiment_very_dissatisfied,
                                                ][i],
                                                size: 22,
                                                color: AppColors.onSurface,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            TextField(
                              controller: _tags,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.sell_outlined,
                                  size: 20,
                                  color: AppColors.outlineVariant,
                                ),
                                hintText: l.addTags,
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: kMoodKeys.take(5).map((k) {
                                return ActionChip(
                                  label: Text(moodLabel(l, k)),
                                  onPressed: () {
                                    setState(() => _moodKey = k);
                                    _scheduleDebouncedSave();
                                  },
                                  side: BorderSide.none,
                                  backgroundColor: _moodKey == k
                                      ? AppColors.tertiaryContainer
                                      : AppColors.surfaceContainerHigh,
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
