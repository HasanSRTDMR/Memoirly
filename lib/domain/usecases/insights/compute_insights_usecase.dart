import 'package:collection/collection.dart';
import 'package:memoirly/core/constants/mood_valence.dart';
import 'package:memoirly/domain/entities/journal_entry.dart';

/// Time window for mood average (and reusable entry filters).
enum InsightPeriod {
  today,
  week,
  month,
  year,
}

/// Aggregate mood tone from all entries that have a known mood key.
class OverallMoodValence {
  const OverallMoodValence._({
    required this.averageValence,
    required this.entriesWithMood,
  });

  const OverallMoodValence.none()
      : averageValence = null,
        entriesWithMood = 0;

  factory OverallMoodValence.fromEntries(List<JournalEntry> all) {
    var sum = 0.0;
    var n = 0;
    for (final e in all) {
      final v = moodValenceForKey(e.mood);
      if (v == null) continue;
      sum += v;
      n++;
    }
    if (n == 0) {
      return const OverallMoodValence.none();
    }
    return OverallMoodValence._(
      averageValence: sum / n,
      entriesWithMood: n,
    );
  }

  /// Average in [-1, 1], or null if no scored moods.
  final double? averageValence;

  /// Entries that contributed (had a known mood).
  final int entriesWithMood;

  /// 0 = very heavy tone, 50 ≈ neutral, 100 = very bright.
  int? get toneScoreOutOf100 {
    final v = averageValence;
    if (v == null) return null;
    return ((v + 1) / 2 * 100).round().clamp(0, 100);
  }
}

class WeeklyInsight {
  const WeeklyInsight({
    required this.weekStart,
    required this.daysWritten,
    required this.totalWords,
    required this.avgWordsPerDay,
    required this.moodCounts,
    required this.tagCounts,
    required this.entriesPerWeekday,
    required this.wordCountsPerEntry,
    required this.avgWordsPerEntry,
  });

  /// Monday 00:00 local date for the insight week (same range as [entriesPerWeekday]).
  final DateTime weekStart;
  final int daysWritten;
  final int totalWords;
  final int avgWordsPerDay;
  final Map<String, int> moodCounts;
  final Map<String, int> tagCounts;
  /// 0 = Monday ... 6 = Sunday (DateTime.weekday order)
  final List<int> entriesPerWeekday;

  /// This week’s entries, oldest → newest; each value is that entry’s word count.
  final List<int> wordCountsPerEntry;

  /// Mean word count per entry this week (0 if no entries).
  final int avgWordsPerEntry;
}

class ComputeInsightsUseCase {
  const ComputeInsightsUseCase();

  WeeklyInsight fromEntries(List<JournalEntry> all, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final start = n.subtract(Duration(days: n.weekday - 1));
    final weekStart = DateTime(start.year, start.month, start.day);
    final weekEnd = weekStart.add(const Duration(days: 7));

    final weekEntries = all.where((e) {
      return !e.createdAt.isBefore(weekStart) && e.createdAt.isBefore(weekEnd);
    }).toList();

    final daysWithEntries = weekEntries
        .map((e) => DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day))
        .toSet()
        .length;

    final totalWords = weekEntries.fold<int>(0, (a, b) => a + b.wordCount);
    final avg = daysWithEntries == 0
        ? 0
        : (totalWords / daysWithEntries).round();

    final moodCounts = <String, int>{};
    for (final e in weekEntries) {
      final m = e.mood;
      if (m != null && m.isNotEmpty) {
        moodCounts[m] = (moodCounts[m] ?? 0) + 1;
      }
    }

    final tagCounts = <String, int>{};
    for (final e in weekEntries) {
      for (final t in e.tags) {
        final k = t.toLowerCase();
        tagCounts[k] = (tagCounts[k] ?? 0) + 1;
      }
    }

    final perDay = List<int>.filled(7, 0);
    for (final e in weekEntries) {
      final wd = e.createdAt.weekday - 1;
      if (wd >= 0 && wd < 7) perDay[wd]++;
    }

    final sortedByTime = [...weekEntries]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final wordCountsPerEntry =
        sortedByTime.map((e) => e.wordCount).toList();
    final avgPerEntry = wordCountsPerEntry.isEmpty
        ? 0
        : (wordCountsPerEntry.fold<int>(0, (a, b) => a + b) /
                wordCountsPerEntry.length)
            .round();

    return WeeklyInsight(
      weekStart: weekStart,
      daysWritten: daysWithEntries,
      totalWords: totalWords,
      avgWordsPerDay: avg,
      moodCounts: moodCounts,
      tagCounts: tagCounts,
      entriesPerWeekday: perDay,
      wordCountsPerEntry: wordCountsPerEntry,
      avgWordsPerEntry: avgPerEntry,
    );
  }

  /// Entries whose [JournalEntry.createdAt] falls in [period] (local calendar).
  List<JournalEntry> entriesInPeriod(
    List<JournalEntry> all,
    InsightPeriod period, {
    DateTime? now,
  }) {
    final n = now ?? DateTime.now();
    final startOfToday = DateTime(n.year, n.month, n.day);
    final DateTime start;
    final DateTime endExclusive;
    if (period == InsightPeriod.today) {
      start = startOfToday;
      endExclusive = startOfToday.add(const Duration(days: 1));
    } else if (period == InsightPeriod.week) {
      final ws = n.subtract(Duration(days: n.weekday - 1));
      start = DateTime(ws.year, ws.month, ws.day);
      endExclusive = start.add(const Duration(days: 7));
    } else if (period == InsightPeriod.month) {
      start = DateTime(n.year, n.month, 1);
      endExclusive = DateTime(n.year, n.month + 1, 1);
    } else {
      start = DateTime(n.year, 1, 1);
      endExclusive = DateTime(n.year + 1, 1, 1);
    }
    return all
        .where((e) =>
            !e.createdAt.isBefore(start) && e.createdAt.isBefore(endExclusive))
        .toList();
  }

  Map<String, int> moodDistributionAll(List<JournalEntry> all) {
    final m = <String, int>{};
    for (final e in all) {
      final mood = e.mood;
      if (mood != null && mood.isNotEmpty) {
        m[mood] = (m[mood] ?? 0) + 1;
      }
    }
    return m;
  }

  List<JournalEntry> search(
    List<JournalEntry> all, {
    required String query,
    String? moodFilter,
    DateTime? dayFilter,
  }) {
    final q = query.trim().toLowerCase();
    return all.where((e) {
      if (dayFilter != null) {
        final d = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
        final t = DateTime(dayFilter.year, dayFilter.month, dayFilter.day);
        if (d != t) return false;
      }
      if (moodFilter != null && moodFilter.isNotEmpty) {
        if (e.mood?.toLowerCase() != moodFilter.toLowerCase()) return false;
      }
      if (q.isEmpty) return true;
      return e.searchableText.contains(q);
    }).sortedByCompare((e) => e.createdAt, (a, b) => b.compareTo(a));
  }
}
