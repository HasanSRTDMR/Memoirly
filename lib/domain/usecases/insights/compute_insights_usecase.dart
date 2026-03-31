import 'package:collection/collection.dart';
import 'package:memoirly/domain/entities/journal_entry.dart';

class WeeklyInsight {
  const WeeklyInsight({
    required this.daysWritten,
    required this.totalWords,
    required this.avgWordsPerDay,
    required this.moodCounts,
    required this.tagCounts,
    required this.entriesPerWeekday,
  });

  final int daysWritten;
  final int totalWords;
  final int avgWordsPerDay;
  final Map<String, int> moodCounts;
  final Map<String, int> tagCounts;
  /// 0 = Monday ... 6 = Sunday (DateTime.weekday order)
  final List<int> entriesPerWeekday;
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
    final avg = weekEntries.isEmpty
        ? 0
        : (totalWords / 7).round();

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

    return WeeklyInsight(
      daysWritten: daysWithEntries,
      totalWords: totalWords,
      avgWordsPerDay: avg,
      moodCounts: moodCounts,
      tagCounts: tagCounts,
      entriesPerWeekday: perDay,
    );
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
