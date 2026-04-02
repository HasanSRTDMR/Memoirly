import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:memoirly/core/constants/entry_list_emoji.dart';
import 'package:memoirly/core/constants/mood_keys.dart';
import 'package:memoirly/core/di/providers.dart';
import 'package:memoirly/core/localization/app_localizations.dart';
import 'package:memoirly/core/localization/mood_localizations.dart';
import 'package:memoirly/domain/entities/journal_entry.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
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
  final List<String> _imagePaths = [];
  int? _contentColorArgb;
  /// Ana sayfa emoji seçimi; null veya eski ikon anahtarı = Otomatik (ruh hâli).
  String? _cardEmoji;

  /// Extra scroll padding so the body field stays above the bottom composer.
  static const double _composerScrollReserve = 200;

  static const List<int?> _inkArgbChoices = [
    null,
    0xFF2D3432,
    0xFF5B6150,
    0xFF6C5C4D,
    0xFF4A6572,
    0xFF6D4C41,
    0xFF2E5E4E,
    0xFF5D4037,
  ];

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
      _tags.removeListener(_onTagsChanged);
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
        _parseTags(_tags.text).isNotEmpty ||
        _imagePaths.isNotEmpty;
  }

  List<String> _parseTags(String raw) {
    final fromHash = RegExp(r'#([^\s#,]+)')
        .allMatches(raw)
        .map((m) => m.group(1)!.toLowerCase().trim())
        .where((s) => s.isNotEmpty);
    final fromCommas = raw
        .split(RegExp(r'[,\n;]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .map((s) => s.startsWith('#') ? s.substring(1) : s)
        .map((s) => s.toLowerCase().trim())
        .where((s) => s.isNotEmpty);
    return {...fromHash, ...fromCommas}.toList();
  }

  void _onTagsChanged() {
    _scheduleDebouncedSave();
    if (mounted) setState(() {});
  }

  void _ensureListeners() {
    if (_listenersAttached) return;
    _listenersAttached = true;
    _title.addListener(_scheduleDebouncedSave);
    _body.addListener(_scheduleDebouncedSave);
    _tags.addListener(_onTagsChanged);
  }

  Future<void> _pickImage() async {
    final l = AppLocalizations.of(context);
    try {
      final picker = ImagePicker();
      final x = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 82,
        maxWidth: 1600,
      );
      if (x == null || !mounted) return;

      final dir = await getApplicationDocumentsDirectory();
      final sub = Directory(p.join(dir.path, 'journal_images'));
      if (!await sub.exists()) await sub.create(recursive: true);
      final name = '${const Uuid().v4()}.jpg';
      final dest = File(p.join(sub.path, name));
      await File(x.path).copy(dest.path);
      if (!mounted) return;
      setState(() => _imagePaths.add(dest.path));
      _scheduleDebouncedSave();
    } on PlatformException catch (e, st) {
      debugPrint('WriteEntryPage._pickImage PlatformException: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.imagePickerError)),
      );
    } catch (e, st) {
      debugPrint('WriteEntryPage._pickImage: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.errorGeneric)),
      );
    }
  }

  void _removeImageAt(int index) {
    if (index < 0 || index >= _imagePaths.length) return;
    setState(() => _imagePaths.removeAt(index));
    _scheduleDebouncedSave();
  }

  Widget _buildImageThumb(int index) {
    final scheme = Theme.of(context).colorScheme;
    final path = _imagePaths[index];
    final file = File(path);
    final exists = file.existsSync();
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 72,
              height: 72,
              child: exists
                  ? Image.file(
                      file,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => ColoredBox(
                        color: scheme.surfaceContainerHigh,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ColoredBox(
                      color: scheme.surfaceContainerHigh,
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
            ),
          ),
          Positioned(
            top: -4,
            right: -4,
            child: Material(
              color: scheme.surfaceContainerLowest,
              shape: const CircleBorder(),
              elevation: 1,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _removeImageAt(index),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close_rounded, size: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
        imagePaths: List<String>.from(_imagePaths),
        contentColorArgb: _contentColorArgb,
        cardEmoji: _cardEmoji,
      );

      // Repository `update` is upsert-safe (Firestore merge-set, local list upsert).
      await ref.read(updateEntryUseCaseProvider).call(entry);

      // So detail screen and the next open of this editor see fresh data, not a
      // cached [entryByIdProvider] result from before the save.
      ref.invalidate(entryByIdProvider(id));

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
                _imagePaths
                  ..clear()
                  ..addAll(e.imagePaths);
                _contentColorArgb = e.contentColorArgb;
                _cardEmoji = e.cardEmoji;
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

    final viewPaddingBottom = MediaQuery.paddingOf(context).bottom;
    /// Reserve space when scrolling focused fields (legacy overlay height).
    final fieldScrollPadBottom = 24.0 + viewPaddingBottom;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final onSurface = cs.onSurface;
    final hintStyle = theme.textTheme.labelSmall?.copyWith(
          color: cs.onSurfaceVariant.withValues(alpha: 0.85),
        ) ??
        TextStyle(
          color: cs.onSurfaceVariant.withValues(alpha: 0.85),
          fontSize: 10,
        );
    final bodyInkColor = _contentColorArgb != null
        ? Color(_contentColorArgb!)
        : onSurface;
    final parsedTags = _parseTags(_tags.text);
    final archiveListAutoSelected = !isPickedArchiveListEmoji(_cardEmoji);

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
            color: cs.onSurfaceVariant.withValues(alpha: 0.85),
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
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                    Icon(
                      Icons.edit_note_rounded,
                      color: cs.outlineVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton.filledTonal(
                      onPressed: _pickImage,
                      tooltip: l.addImage,
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            for (var i = 0; i < _imagePaths.length; i++)
                              _buildImageThumb(i),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      l.textColor,
                      style: theme.textTheme.labelSmall,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _inkArgbChoices.map((argb) {
                            final selected = _contentColorArgb == argb;
                            final circle = Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: argb != null
                                    ? Color(argb)
                                    : cs.surfaceContainerHigh,
                                border: Border.all(
                                  color: selected
                                      ? cs.primary
                                      : cs.outlineVariant
                                          .withValues(alpha: 0.5),
                                  width: selected ? 2 : 1,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: argb == null
                                  ? Icon(
                                      Icons.format_color_reset_rounded,
                                      size: 14,
                                      color:
                                          onSurface.withValues(alpha: 0.7),
                                    )
                                  : null,
                            );
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                onTap: () {
                                  setState(() => _contentColorArgb = argb);
                                  _scheduleDebouncedSave();
                                },
                                customBorder: const CircleBorder(),
                                child: argb == null
                                    ? Tooltip(
                                        message: l.textColorDefault,
                                        child: circle,
                                      )
                                    : circle,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      l.archiveListIcon,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                onTap: () {
                                  setState(() => _cardEmoji = null);
                                  _scheduleDebouncedSave();
                                },
                                borderRadius: BorderRadius.circular(999),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: archiveListAutoSelected
                                          ? cs.primary
                                          : cs.outlineVariant
                                              .withValues(alpha: 0.5),
                                      width: archiveListAutoSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Text(
                                    l.archiveListIconAuto,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: archiveListAutoSelected
                                          ? cs.primary
                                          : cs.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            for (final emoji in kArchiveListEmojiChoices)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: InkWell(
                                  onTap: () {
                                    setState(() => _cardEmoji = emoji);
                                    _scheduleDebouncedSave();
                                  },
                                  customBorder: const CircleBorder(),
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _cardEmoji == emoji
                                            ? cs.primary
                                            : cs.outlineVariant
                                                .withValues(alpha: 0.5),
                                        width: _cardEmoji == emoji ? 2 : 1,
                                      ),
                                    ),
                                    child: themedArchiveListEmoji(
                                      emoji,
                                      color: archiveEmojiModulateColor(
                                        cs,
                                        emphasized: _cardEmoji == emoji,
                                      ),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _title,
                  cursorColor: onSurface,
                  scrollPadding: EdgeInsets.only(
                    bottom: fieldScrollPadBottom + _composerScrollReserve,
                  ),
                  decoration: InputDecoration(
                    hintText: l.titleHint,
                    border: InputBorder.none,
                    filled: false,
                    hintStyle: hintStyle,
                  ),
                  style: theme.textTheme.titleMedium?.copyWith(color: onSurface),
                ),
                TextField(
                  controller: _body,
                  maxLines: null,
                  minLines: 12,
                  keyboardType: TextInputType.multiline,
                  cursorColor: bodyInkColor,
                  scrollPadding: EdgeInsets.only(
                    bottom: fieldScrollPadBottom + _composerScrollReserve,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    filled: false,
                    hintStyle: hintStyle,
                  ),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 22,
                    height: 1.8,
                    color: bodyInkColor,
                  ),
                ),
                ],
              ),
            ),
            Material(
                color: cs.surfaceContainerLow.withValues(alpha: 0.96),
                elevation: 12,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(36),
                        border: Border.all(
                          color: cs.outlineVariant.withValues(alpha: 0.35),
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
                                  style: theme.textTheme.labelSmall,
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
                                                  ? cs.secondaryContainer
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
                                                color: theme.colorScheme.onSurface,
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
                            if (parsedTags.isNotEmpty) ...[
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: parsedTags
                                      .map(
                                        (t) => Chip(
                                          label: Text(
                                            '#$t',
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(fontSize: 11),
                                          ),
                                          visualDensity: VisualDensity.compact,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          backgroundColor:
                                              cs.secondaryContainer
                                                  .withValues(alpha: 0.65),
                                          side: BorderSide.none,
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            TextField(
                              controller: _tags,
                              cursorColor: onSurface,
                              scrollPadding: const EdgeInsets.only(bottom: 8),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.sell_outlined,
                                  size: 20,
                                  color: cs.outlineVariant,
                                ),
                                hintText: l.addTags,
                                border: InputBorder.none,
                                filled: false,
                                isDense: true,
                                hintStyle:
                                    hintStyle.copyWith(fontSize: 12),
                                hintMaxLines: 2,
                              ),
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(color: onSurface, fontSize: 14),
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
                                      ? cs.tertiaryContainer
                                      : cs.surfaceContainerHigh,
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
          ],
        ),
      ),
    );
  }
}
