import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:memoirly/core/constants/mood_keys.dart';
import 'package:memoirly/core/di/providers.dart';
import 'package:memoirly/core/error/journal_stream_error.dart'
    show JournalStreamErrorView, describeJournalStreamError;
import 'package:memoirly/core/localization/app_localizations.dart';
import 'package:memoirly/core/localization/mood_localizations.dart';
import 'package:memoirly/core/theme/app_colors.dart';
import 'package:memoirly/core/widgets/archive_app_bar.dart';
import 'package:memoirly/core/widgets/writing_fab.dart';
import 'package:memoirly/domain/entities/journal_entry.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  String _greeting(AppLocalizations l, DateTime now) {
    final h = now.hour;
    if (h < 12) return l.goodMorning;
    if (h < 17) return l.goodAfternoon;
    return l.goodEvening;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();
    final dateStr = DateFormat.yMMMMEEEEd(locale).format(now);
    final entriesAsync = ref.watch(journalEntriesStreamProvider);

    return Scaffold(
      appBar: const ArchiveAppBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: WritingFab(
        heroTag: 'memoirly_fab_home',
        onPressed: () => context.push('/write'),
      ),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, _) => JournalStreamErrorView(
              message: describeJournalStreamError(e, l),
            ),
        data: (entries) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final hPad = constraints.maxWidth < 360 ? 16.0 : 24.0;
              return ListView(
                padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 120),
                children: [
                  Text(
                    dateStr.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _greeting(l, now),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 28),
                  _StartWritingCard(
                    onStart: () => context.push('/write'),
                    l: l,
                  ),
                  const SizedBox(height: 28),
                  Text(
                    l.reflectToday,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: kMoodKeys.take(6).length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        final key = kMoodKeys[i];
                        return _MoodChip(
                          label: moodLabel(l, key),
                          filled: i == 0 || i == 1 || i == 4,
                          onTap: () => context.push('/write?mood=$key'),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    l.recentArchive,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 16),
                  if (entries.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Text(
                        l.emptyJournal,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  else
                    ...entries.take(12).map(
                          (e) => _RecentEntryTile(
                            entry: e,
                            l: l,
                            locale: locale,
                            onTap: () => context.push('/entry/${e.id}'),
                          ),
                        ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _StartWritingCard extends StatelessWidget {
  const _StartWritingCard({required this.onStart, required this.l});

  final VoidCallback onStart;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 48,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryContainer.withValues(alpha: 0.25),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.captureThoughts,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 26,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                l.captureThoughtsBody,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDim],
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onStart,
                    borderRadius: BorderRadius.circular(999),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 12,
                      ),
                      child: Text(
                        l.startWriting,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.onPrimary,
                              letterSpacing: 1,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoodChip extends StatelessWidget {
  const _MoodChip({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = filled
        ? AppColors.secondaryContainer
        : AppColors.surfaceContainerHigh;
    final fg = filled
        ? AppColors.onSecondaryContainer
        : AppColors.onSurfaceVariant;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: fg,
                ),
          ),
        ),
      ),
    );
  }
}

class _RecentEntryTile extends StatelessWidget {
  const _RecentEntryTile({
    required this.entry,
    required this.l,
    required this.locale,
    required this.onTap,
  });

  final JournalEntry entry;
  final AppLocalizations l;
  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.jm(locale).format(entry.createdAt);
    final preview = entry.content.trim().isEmpty
        ? '…'
        : entry.content.replaceAll('\n', ' ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Text(
                  _emojiFor(entry),
                  style: const TextStyle(fontSize: 22),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 2,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          entry.title.isNotEmpty ? entry.title : l.newEntry,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontFamily: 'Newsreader',
                                fontStyle: FontStyle.italic,
                                fontSize: 20,
                              ),
                        ),
                      ),
                      Text(
                        time,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 9,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                  if (entry.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: entry.tags
                          .take(4)
                          .map(
                            (t) => Text(
                              '#$t'.toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppColors.primary,
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
          ],
        ),
      ),
    );
  }
}

String _emojiFor(JournalEntry e) {
  final m = e.mood;
  if (m == null) return '📔';
  const map = {
    'peaceful': '🌿',
    'grateful': '🙏',
    'anxious': '😰',
    'productive': '⚡',
    'reflective': '💭',
    'serene': '🌙',
  };
  return map[m] ?? '📓';
}
