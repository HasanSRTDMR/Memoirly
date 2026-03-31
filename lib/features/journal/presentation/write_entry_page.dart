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
    _title.dispose();
    _body.dispose();
    _tags.dispose();
    super.dispose();
  }

  List<String> _parseTags(String raw) {
    final re = RegExp(r'#([\w-]+)');
    return re
        .allMatches(raw)
        .map((m) => m.group(1)!.toLowerCase())
        .toSet()
        .toList();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final auth = ref.read(authRepositoryProvider);
    final uid = await auth.getCurrentUserId();
    if (uid == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.authError)),
        );
      }
      return;
    }

    final tags = _parseTags(_tags.text);
    final mood = _moodKey ?? moodDisplayKeyFromIndex(_sentiment);
    final id = widget.entryId ?? const Uuid().v4();
    final existing = widget.entryId != null
        ? await ref.read(journalRepositoryProvider).getById(id)
        : null;
    final createdAt = existing?.createdAt ?? DateTime.now();

    final entry = JournalEntry(
      id: id,
      userId: uid,
      title: _title.text.trim(),
      content: _body.text.trim(),
      createdAt: createdAt,
      mood: mood,
      tags: tags,
    );

    try {
      if (widget.entryId != null) {
        await ref.read(updateEntryUseCaseProvider).call(entry);
      } else {
        await ref.read(createEntryUseCaseProvider).call(entry);
      }
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.errorGeneric)),
        );
      }
    }
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
    final now = DateTime.now();
    final header = DateFormat.yMMMMd(locale).format(now);
    final sub = DateFormat.EEEE(locale).format(now);

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final bottomPad = 200.0 + bottomInset;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l.newEntry,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                l.autoSaving,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
          TextButton(
            onPressed: _save,
            child: Text(l.save),
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
                    Icons.cloud_done_outlined,
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
                                          onTap: () => setState(() {
                                            _sentiment = i;
                                            _moodKey =
                                                moodDisplayKeyFromIndex(i);
                                          }),
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
                                onPressed: () => setState(() => _moodKey = k),
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
    );
  }
}
