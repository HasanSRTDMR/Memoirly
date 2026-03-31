import 'package:memoirly/domain/entities/journal_entry.dart';
import 'package:memoirly/domain/repositories/journal_repository.dart';

class WatchEntriesUseCase {
  WatchEntriesUseCase(this._repository);

  final JournalRepository _repository;

  Stream<List<JournalEntry>> call() => _repository.watchEntries();
}
