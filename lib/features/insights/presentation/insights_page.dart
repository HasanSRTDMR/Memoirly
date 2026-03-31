import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memoirly/core/di/providers.dart';
import 'package:memoirly/core/localization/app_localizations.dart';
import 'package:memoirly/core/localization/mood_localizations.dart';
import 'package:memoirly/core/theme/app_colors.dart';
import 'package:memoirly/core/widgets/archive_app_bar.dart';
import 'package:memoirly/domain/entities/journal_entry.dart';

class InsightsPage extends ConsumerWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final entriesAsync = ref.watch(journalEntriesStreamProvider);
    final useCase = ref.watch(computeInsightsUseCaseProvider);

    return Scaffold(
      appBar: ArchiveAppBar(onMenu: () {}),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (_, __) => Center(child: Text(l.errorGeneric)),
        data: (entries) {
          final weekly = useCase.fromEntries(entries);
          final moods = useCase.moodDistributionAll(entries);
          final topTags = _topTags(entries);
          final maxBar = weekly.entriesPerWeekday.fold<int>(
            1,
            (a, b) => b > a ? b : a,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
            children: [
              Text(
                l.weeklyOverview,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 6),
              Text(
                l.weeklyWroteDays(weekly.daysWritten),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l.weeklyConsistency,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l.moodRhythm,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontFamily: 'Newsreader',
                                fontStyle: FontStyle.italic,
                                fontSize: 22,
                              ),
                        ),
                        Text(
                          l.last7Days,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 140,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(7, (i) {
                          final h = maxBar == 0
                              ? 0.0
                              : weekly.entriesPerWeekday[i] / maxBar;
                          final labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: FractionallySizedBox(
                                        heightFactor: h.clamp(0.05, 1.0),
                                        widthFactor: 1,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            color: i == 3
                                                ? AppColors.primary
                                                : AppColors.secondaryContainer
                                                    .withValues(alpha: 0.45),
                                            borderRadius:
                                                BorderRadius.circular(999),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    labels[i],
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(fontSize: 9),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: l.volume,
                      subtitle: l.avgWordsPerDay,
                      value: '${weekly.avgWordsPerDay}',
                      suffix: l.words,
                      miniBars: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: l.themes,
                      subtitle: l.frequentlyTagged,
                      chips: topTags,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                l.totalEntries,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Text(
                '${entries.length}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              if (moods.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  l.moodDistribution,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: moods.entries.map((e) {
                    return Chip(
                      label: Text('${moodLabel(l, e.key)} · ${e.value}'),
                      backgroundColor: AppColors.secondaryContainer,
                      side: BorderSide.none,
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 40,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.format_quote_rounded,
                        size: 36, color: AppColors.outlineVariant),
                    const SizedBox(height: 12),
                    Text(
                      '"The soul should always stand ajar, ready to welcome the ecstatic experience."',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontFamily: 'Newsreader',
                            fontStyle: FontStyle.italic,
                            fontSize: 20,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '— Emily Dickinson',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<MapEntry<String, int>> _topTags(List<JournalEntry> entries) {
    final m = <String, int>{};
    for (final e in entries) {
      for (final t in e.tags) {
        final s = t.toLowerCase();
        m[s] = (m[s] ?? 0) + 1;
      }
    }
    final list = m.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return list.take(8).toList();
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.subtitle,
    this.value,
    this.suffix,
    this.miniBars = false,
    this.chips,
  });

  final String title;
  final String subtitle;
  final String? value;
  final String? suffix;
  final bool miniBars;
  final List<MapEntry<String, int>>? chips;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontFamily: 'Newsreader',
                  fontStyle: FontStyle.italic,
                  fontSize: 20,
                ),
          ),
          Text(subtitle, style: Theme.of(context).textTheme.labelSmall),
          if (miniBars) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 56,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(
                  5,
                  (i) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Container(
                        height: [16.0, 28.0, 22.0, 40.0, 32.0][i],
                        decoration: BoxDecoration(
                          color: i == 3
                              ? AppColors.primary
                              : AppColors.outlineVariant
                                  .withValues(alpha: 0.25 + i * 0.08),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value ?? '0',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 32,
                      ),
                ),
                const SizedBox(width: 6),
                Text(
                  suffix ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ),
          ],
          if (chips != null && chips!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: chips!.map((e) {
                return Chip(
                  label: Text(
                    e.key.toUpperCase(),
                    style: const TextStyle(fontSize: 9, letterSpacing: 1),
                  ),
                  backgroundColor: AppColors.secondaryContainer,
                  side: BorderSide.none,
                  padding: EdgeInsets.zero,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
