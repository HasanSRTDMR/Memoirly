import 'package:memoirly/domain/entities/journal_entry.dart';
import 'package:memoirly/domain/repositories/journal_repository.dart';

class UpdateEntryUseCase {
  UpdateEntryUseCase(this._repository);

  final JournalRepository _repository;

  Future<void> call(JournalEntry entry) => _repository.update(entry);
}
