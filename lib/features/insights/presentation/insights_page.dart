import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:memoirly/core/di/providers.dart';
import 'package:memoirly/core/error/journal_stream_error.dart';
import 'package:memoirly/core/localization/app_localizations.dart';
import 'package:memoirly/core/localization/mood_localizations.dart';
import 'package:memoirly/core/theme/app_colors.dart';
import 'package:memoirly/core/widgets/archive_app_bar.dart';
import 'package:memoirly/domain/entities/daily_quote.dart';
import 'package:memoirly/domain/entities/journal_entry.dart';

class InsightsPage extends ConsumerWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final entriesAsync = ref.watch(journalEntriesStreamProvider);
    final useCase = ref.watch(computeInsightsUseCaseProvider);

    return Scaffold(
      appBar: const ArchiveAppBar(),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, _) => JournalStreamErrorView(
              message: describeJournalStreamError(e, l),
            ),
        data: (entries) {
          final weekly = useCase.fromEntries(entries);
          final moods = useCase.moodDistributionAll(entries);
          final topTags = _topTags(entries);
          final maxBar = weekly.entriesPerWeekday.fold<int>(
            0,
            (a, b) => b > a ? b : a,
          );
          final quoteAsync = ref.watch(dailyQuoteProvider);
          final locale = Localizations.localeOf(context).toString();
          final weekEnd = weekly.weekStart.add(const Duration(days: 6));
          final rangeLabel =
              '${DateFormat.yMMMd(locale).format(weekly.weekStart)} – ${DateFormat.yMMMd(locale).format(weekEnd)}';
          final now = DateTime.now();
          final todayNorm = DateTime(now.year, now.month, now.day);
          int? peakDayIndex;
          if (maxBar > 0) {
            for (var i = 0; i < 7; i++) {
              if (weekly.entriesPerWeekday[i] != maxBar) continue;
              final day = weekly.weekStart.add(Duration(days: i));
              final d = DateTime(day.year, day.month, day.day);
              if (d == todayNorm) {
                peakDayIndex = i;
                break;
              }
            }
            if (peakDayIndex == null) {
              final idx =
                  weekly.entriesPerWeekday.indexWhere((c) => c == maxBar);
              peakDayIndex = idx >= 0 ? idx : null;
            }
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final pad = constraints.maxWidth < 360 ? 16.0 : 24.0;
              return ListView(
                padding: EdgeInsets.fromLTRB(pad, 8, pad, 120),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.moodRhythm,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontFamily: 'Newsreader',
                                      fontStyle: FontStyle.italic,
                                      fontSize: 22,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                rangeLabel,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      height: 1.25,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l.last7Days,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                letterSpacing: 0.6,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 168,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: List.generate(7, (i) {
                          final count = weekly.entriesPerWeekday[i];
                          final day = weekly.weekStart.add(Duration(days: i));
                          final ratio =
                              maxBar == 0 ? 0.0 : count / maxBar;
                          final isPeak =
                              peakDayIndex != null && i == peakDayIndex;
                          final dayNorm =
                              DateTime(day.year, day.month, day.day);
                          final isToday = dayNorm == todayNorm;
                          final theme = Theme.of(context);
                          final onVar = theme.colorScheme.onSurfaceVariant;

                          return Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: count == 0
                                          ? const SizedBox.shrink()
                                          : FractionallySizedBox(
                                              heightFactor: (ratio < 0.12
                                                      ? 0.12
                                                      : ratio)
                                                  .clamp(0.0, 1.0),
                                              widthFactor: 1,
                                              alignment:
                                                  Alignment.bottomCenter,
                                              child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                  color: isPeak
                                                      ? AppColors.primary
                                                      : AppColors
                                                          .secondaryContainer
                                                          .withValues(
                                                          alpha: isToday
                                                              ? 0.72
                                                              : 0.48,
                                                        ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          999),
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${day.day}',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    DateFormat.E(locale).format(day),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontSize: 9,
                                      color: onVar,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
              if (constraints.maxWidth < 520)
                Column(
                  children: [
                    _StatCard(
                      title: l.volume,
                      subtitle: l.avgWordsPerDay,
                      value: '${weekly.avgWordsPerDay}',
                      suffix: l.words,
                      miniBars: true,
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      title: l.themes,
                      subtitle: l.frequentlyTagged,
                      chips: topTags,
                    ),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
              quoteAsync.when(
                loading: () => const _DailyQuoteCard.loading(),
                error: (_, __) => _DailyQuoteCard(quote: DailyQuote.fallback),
                data: (q) => _DailyQuoteCard(quote: q),
              ),
            ],
              );
            },
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

class _DailyQuoteCard extends StatelessWidget {
  const _DailyQuoteCard({required this.quote});

  const _DailyQuoteCard.loading() : quote = null;

  final DailyQuote? quote;

  bool get _isLoading => quote == null;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.08),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: _isLoading
          ? SizedBox(
              height: 120,
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                ),
              ),
            )
          : Column(
              children: [
                Icon(
                  Icons.format_quote_rounded,
                  size: 36,
                  color: scheme.outlineVariant,
                ),
                const SizedBox(height: 12),
                Text(
                  '"${quote!.textForLocale(Localizations.localeOf(context))}"',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontFamily: 'Newsreader',
                        fontStyle: FontStyle.italic,
                        fontSize: 20,
                        color: scheme.onSurface,
                      ),
                ),
                if (quote!.author != null && quote!.author!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    '— ${quote!.author}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ],
            ),
    );
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
      width: double.infinity,
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
