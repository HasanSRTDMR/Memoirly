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
import 'package:memoirly/domain/usecases/insights/compute_insights_usecase.dart';

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
          final overallMood = useCase.overallMoodValence(entries);
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
              _MoodValenceCard(l: l, overall: overallMood),
              const SizedBox(height: 16),
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
                              const SizedBox(height: 10),
                              Text(
                                l.writingByDayHint,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      height: 1.35,
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
                      wordsChartHint: l.wordsPerDayChartHint,
                      value: '${weekly.avgWordsPerDay}',
                      suffix: l.words,
                      wordsPerWeekday: weekly.wordsPerWeekday,
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
                        wordsChartHint: l.wordsPerDayChartHint,
                        value: '${weekly.avgWordsPerDay}',
                        suffix: l.words,
                        wordsPerWeekday: weekly.wordsPerWeekday,
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

String _moodTonePhrase(AppLocalizations l, double v) {
  if (v >= 0.42) return l.moodTonePhraseVeryPositive;
  if (v >= 0.12) return l.moodTonePhrasePositive;
  if (v > -0.12) return l.moodTonePhraseBalanced;
  if (v > -0.45) return l.moodTonePhraseDifficult;
  return l.moodTonePhraseHeavy;
}

/// Sentiment icon scale (same icons as write screen mood row), low → high score.
class _MoodEmojiMeter extends StatelessWidget {
  const _MoodEmojiMeter({required this.score});

  static const _icons = <IconData>[
    Icons.sentiment_very_dissatisfied,
    Icons.sentiment_dissatisfied,
    Icons.sentiment_neutral,
    Icons.sentiment_satisfied,
    Icons.sentiment_very_satisfied,
  ];

  final int score;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final iconColor = scheme.onSurfaceVariant;
    final t = (score / 100.0).clamp(0.0, 1.0);
    const thumbSize = 14.0;
    const trackH = 10.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final thumbLeft = t * (w - thumbSize);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                for (final icon in _icons)
                  Expanded(
                    child: Icon(
                      icon,
                      size: 22,
                      color: iconColor,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 18,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 4,
                    child: Container(
                      height: trackH,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: scheme.surfaceContainerHighest
                            .withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 4,
                    child: SizedBox(
                      width: w * t,
                      height: trackH,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: thumbLeft,
                    top: 2,
                    child: Container(
                      width: thumbSize,
                      height: thumbSize,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: scheme.surface,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: scheme.shadow.withValues(alpha: 0.12),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MoodValenceCard extends StatelessWidget {
  const _MoodValenceCard({
    required this.l,
    required this.overall,
  });

  final AppLocalizations l;
  final OverallMoodValence overall;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
      ),
      child: overall.averageValence == null
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.sentiment_neutral_rounded,
                  size: 36,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.moodValenceEmpty,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontFamily: 'Newsreader',
                          fontStyle: FontStyle.italic,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.moodValenceEmptyBody,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.moodValenceTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontFamily: 'Newsreader',
                    fontStyle: FontStyle.italic,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l.moodValenceSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                _MoodEmojiMeter(score: overall.toneScoreOutOf100!),
                const SizedBox(height: 10),
                Text(
                  l.moodValenceSample(overall.entriesWithMood),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _moodTonePhrase(l, overall.averageValence!),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
              ],
            ),
    );
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
    this.wordsChartHint,
    this.value,
    this.suffix,
    this.wordsPerWeekday,
    this.chips,
  });

  final String title;
  final String subtitle;
  final String? wordsChartHint;
  final String? value;
  final String? suffix;
  final List<int>? wordsPerWeekday;
  final List<MapEntry<String, int>>? chips;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxWords = wordsPerWeekday == null || wordsPerWeekday!.isEmpty
        ? 0
        : wordsPerWeekday!.reduce((a, b) => a > b ? a : b);
    final peakWordDay = maxWords > 0
        ? wordsPerWeekday!.indexWhere((w) => w == maxWords)
        : -1;

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
            style: theme.textTheme.titleLarge?.copyWith(
                  fontFamily: 'Newsreader',
                  fontStyle: FontStyle.italic,
                  fontSize: 20,
                ),
          ),
          Text(subtitle, style: theme.textTheme.labelSmall),
          if (wordsChartHint != null && wordsChartHint!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              wordsChartHint!,
              style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
            ),
          ],
          if (wordsPerWeekday != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 56,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(7, (i) {
                  final w = i < wordsPerWeekday!.length
                      ? wordsPerWeekday![i]
                      : 0;
                  final ratio =
                      maxWords == 0 ? 0.0 : w / maxWords;
                  final isPeak = peakWordDay >= 0 && i == peakWordDay;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: w == 0
                            ? const SizedBox.shrink()
                            : FractionallySizedBox(
                                heightFactor:
                                    (ratio < 0.12 ? 0.12 : ratio)
                                        .clamp(0.0, 1.0),
                                widthFactor: 1,
                                alignment: Alignment.bottomCenter,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: isPeak
                                        ? AppColors.primary
                                        : AppColors.secondaryContainer
                                            .withValues(alpha: 0.55),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value ?? '0',
                  style: theme.textTheme.headlineMedium?.copyWith(
                        fontSize: 32,
                      ),
                ),
                const SizedBox(width: 6),
                Text(
                  suffix ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
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
