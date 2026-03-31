import 'package:memoirly/domain/entities/journal_entry.dart';

abstract class JournalRepository {
  Stream<List<JournalEntry>> watchEntries();

  Future<List<JournalEntry>> getEntriesForDay(DateTime day);

  Future<JournalEntry?> getById(String id);

  Future<void> create(JournalEntry entry);

  Future<void> update(JournalEntry entry);

  Future<void> delete(String id);

  /// Clears all entries for the current user (local or remote).
  Future<void> clearAll();
}
