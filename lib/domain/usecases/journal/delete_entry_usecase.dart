import 'package:memoirly/domain/repositories/journal_repository.dart';

class DeleteEntryUseCase {
  DeleteEntryUseCase(this._repository);

  final JournalRepository _repository;

  Future<void> call(String id) => _repository.delete(id);
}
