import 'package:memoirly/domain/entities/journal_entry.dart';
import 'package:memoirly/domain/repositories/journal_repository.dart';

class CreateEntryUseCase {
  CreateEntryUseCase(this._repository);

  final JournalRepository _repository;

  Future<void> call(JournalEntry entry) => _repository.create(entry);
}
