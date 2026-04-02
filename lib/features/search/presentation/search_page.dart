import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:memoirly/core/constants/mood_keys.dart';
import 'package:memoirly/core/di/providers.dart';
import 'package:memoirly/core/error/journal_stream_error.dart';
import 'package:memoirly/core/localization/app_localizations.dart';
import 'package:memoirly/core/localization/mood_localizations.dart';
import 'package:memoirly/core/theme/app_colors.dart';
import 'package:memoirly/core/widgets/archive_app_bar.dart';
import 'package:memoirly/domain/entities/journal_entry.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';
  String? _moodFilter;
  DateTime? _dayFilter;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      setState(() => _query = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final entriesAsync = ref.watch(journalEntriesStreamProvider);
    final useCase = ref.watch(computeInsightsUseCaseProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: ArchiveAppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            child: Center(
              child: Text(
                l.explore,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontFamily: 'Newsreader',
                      fontStyle: FontStyle.italic,
                      fontSize: 20,
                    ),
              ),
            ),
          ),
        ],
      ),
      body: entriesAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, _) => JournalStreamErrorView(
          message: describeJournalStreamError(e, l),
        ),
        data: (entries) {
          final filtered = useCase.search(
            entries,
            query: _query,
            moodFilter: _moodFilter,
            dayFilter: _dayFilter,
          );
          final recent = entries.take(4).toList();

          return LayoutBuilder(
            builder: (context, c) {
              final pad = c.maxWidth < 360 ? 16.0 : 24.0;
              return ListView(
                padding: EdgeInsets.fromLTRB(pad, 8, pad, 120),
                children: [
                  TextField(
                    controller: _controller,
                    onChanged: _onChanged,
                    cursorColor: Theme.of(context).colorScheme.onSurface,
                    decoration: InputDecoration(
                      hintText: l.searchYourThoughts,
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.onSurface
                          : AppColors.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      hintStyle:
                          Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant
                                    .withValues(alpha: 0.7),
                              ),
                    ),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.sell_outlined, size: 16),
                            const SizedBox(width: 6),
                            Text(l.tags),
                          ],
                        ),
                        selected: false,
                        onSelected: (_) async {
                          final t = await showModalBottomSheet<String>(
                            context: context,
                            builder: (ctx) => ListView(
                              children: [
                                ListTile(
                                  title: Text(l.clearFilters),
                                  onTap: () => Navigator.pop(ctx, ''),
                                ),
                                ..._topTags(entries).map(
                                  (tag) => ListTile(
                                    title: Text('#$tag'),
                                    onTap: () => Navigator.pop(ctx, tag),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (t != null && t.isNotEmpty) {
                            setState(() => _controller.text = '#$t ');
                          }
                        },
                      ),
                      FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.mood_rounded, size: 16),
                            const SizedBox(width: 6),
                            Text(l.mood),
                          ],
                        ),
                        selected: _moodFilter != null,
                        onSelected: (_) async {
                          final m = await showModalBottomSheet<String>(
                            context: context,
                            builder: (ctx) => ListView(
                              children: [
                                ListTile(
                                  title: Text(l.clearFilters),
                                  onTap: () => Navigator.pop(ctx, '__clear'),
                                ),
                                ...kMoodKeys.map(
                                  (k) => ListTile(
                                    title: Text(moodLabel(l, k)),
                                    onTap: () => Navigator.pop(ctx, k),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (m == '__clear') {
                            setState(() => _moodFilter = null);
                          } else if (m != null) {
                            setState(() => _moodFilter = m);
                          }
                        },
                      ),
                      FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_month_rounded, size: 16),
                            const SizedBox(width: 6),
                            Text(l.date),
                          ],
                        ),
                        selected: _dayFilter != null,
                        onSelected: (_) async {
                          final now = DateTime.now();
                          final d = await showDatePicker(
                            context: context,
                            initialDate: _dayFilter ?? now,
                            firstDate: DateTime(now.year - 5),
                            lastDate: DateTime(now.year + 1),
                          );
                          setState(() => _dayFilter = d);
                        },
                      ),
                      TextButton(
                        onPressed: () => setState(() {
                          _moodFilter = null;
                          _dayFilter = null;
                          _controller.clear();
                          _query = '';
                        }),
                        child: Text(l.clearFilters),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  if (filtered.isEmpty &&
                      (_query.isNotEmpty ||
                          _moodFilter != null ||
                          _dayFilter != null))
                    Column(
                      children: [
                        Icon(
                          Icons.auto_stories_outlined,
                          size: 72,
                          color: AppColors.surfaceDim.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l.silenceInLibrary,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontSize: 26,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l.noSearchResults,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    )
                  else if (filtered.isNotEmpty)
                    ...filtered.map(
                      (e) => _SearchResultCard(
                        entry: e,
                        locale: locale,
                        isDark: isDark,
                        onTap: () => context.push('/entry/${e.id}'),
                      ),
                    )
                  else ...[
                    Text(
                      l.recentExplorations,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontFamily: 'Newsreader',
                            fontStyle: FontStyle.italic,
                            fontSize: 22,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ...recent.map(
                      (e) => _SearchResultCard(
                        entry: e,
                        locale: locale,
                        isDark: isDark,
                        onTap: () => context.push('/entry/${e.id}'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  Text(
                    l.popularMoods,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: kMoodKeys.take(6).map((k) {
                      return ActionChip(
                        label: Text(moodLabel(l, k)),
                        onPressed: () => setState(() => _moodFilter = k),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  List<String> _topTags(List<JournalEntry> entries) {
    final m = <String, int>{};
    for (final e in entries) {
      for (final t in e.tags) {
        m[t] = (m[t] ?? 0) + 1;
      }
    }
    final list = m.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return list.map((e) => e.key).take(12).toList();
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.entry,
    required this.locale,
    required this.onTap,
    required this.isDark,
  });

  final JournalEntry entry;
  final String locale;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat.yMMMd(locale).format(entry.createdAt);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: isDark ? AppColors.onSurface : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      date,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const Icon(Icons.star_outline_rounded, size: 18),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  entry.title.isNotEmpty ? entry.title : entry.content,
                  maxLines: 3,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontFamily: 'Newsreader',
                        fontStyle: FontStyle.normal,
                        fontSize: 18,
                      ),
                ),
                if (entry.tags.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: entry.tags
                        .take(4)
                        .map(
                          (t) => Text(
                            '#$t',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: AppColors.secondary,
                                  fontSize: 9,
                                ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
