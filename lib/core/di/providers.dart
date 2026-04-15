import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memoirly/core/config/app_backend.dart';
import 'package:memoirly/data/datasources/firestore_daily_quote_datasource.dart';
import 'package:memoirly/domain/entities/daily_quote.dart';
import 'package:memoirly/domain/entities/journal_entry.dart';
import 'package:memoirly/domain/entities/user_profile.dart';
import 'package:memoirly/domain/repositories/auth_repository.dart';
import 'package:memoirly/domain/repositories/journal_repository.dart';
import 'package:memoirly/domain/repositories/security_repository.dart';
import 'package:memoirly/domain/repositories/settings_repository.dart';
import 'package:memoirly/domain/repositories/user_profile_repository.dart';
import 'package:memoirly/domain/usecases/auth/sign_in_anonymous_usecase.dart';
import 'package:memoirly/domain/usecases/insights/compute_insights_usecase.dart';
import 'package:memoirly/domain/usecases/journal/create_entry_usecase.dart';
import 'package:memoirly/domain/usecases/journal/delete_entry_usecase.dart';
import 'package:memoirly/domain/usecases/journal/update_entry_usecase.dart';
import 'package:memoirly/domain/usecases/journal/watch_entries_usecase.dart';

final appBackendProvider = Provider<AppBackend>(
  (ref) => throw UnimplementedError('Override appBackendProvider in main'),
);

final journalRepositoryProvider = Provider<JournalRepository>(
  (ref) => throw UnimplementedError('Override journalRepositoryProvider'),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => throw UnimplementedError('Override authRepositoryProvider'),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => throw UnimplementedError('Override settingsRepositoryProvider'),
);

final userProfileRepositoryProvider = Provider<UserProfileRepository>(
  (ref) => throw UnimplementedError('Override userProfileRepositoryProvider'),
);

final securityRepositoryProvider = Provider<SecurityRepository>(
  (ref) => throw UnimplementedError('Override securityRepositoryProvider'),
);

final watchEntriesUseCaseProvider = Provider<WatchEntriesUseCase>(
  (ref) => WatchEntriesUseCase(ref.watch(journalRepositoryProvider)),
);

final createEntryUseCaseProvider = Provider<CreateEntryUseCase>(
  (ref) => CreateEntryUseCase(ref.watch(journalRepositoryProvider)),
);

final updateEntryUseCaseProvider = Provider<UpdateEntryUseCase>(
  (ref) => UpdateEntryUseCase(ref.watch(journalRepositoryProvider)),
);

final deleteEntryUseCaseProvider = Provider<DeleteEntryUseCase>(
  (ref) => DeleteEntryUseCase(ref.watch(journalRepositoryProvider)),
);

final signInAnonymousUseCaseProvider = Provider<SignInAnonymousUseCase>(
  (ref) => SignInAnonymousUseCase(ref.watch(authRepositoryProvider)),
);

final computeInsightsUseCaseProvider = Provider<ComputeInsightsUseCase>(
  (ref) => const ComputeInsightsUseCase(),
);

final journalEntriesStreamProvider =
    StreamProvider<List<JournalEntry>>((ref) {
  return ref.watch(watchEntriesUseCaseProvider).call();
});

final userProfileStreamProvider = StreamProvider<UserProfile>((ref) {
  return ref.watch(userProfileRepositoryProvider).watchProfile();
});

/// Single-entry fetch for detail/edit; autoDispose + invalidate after saves keeps
/// text in sync with the live journal stream.
final entryByIdProvider =
    FutureProvider.autoDispose.family<JournalEntry?, String>((ref, id) async {
  return ref.read(journalRepositoryProvider).getById(id);
});

/// Quote of the day from Firestore `dailyQuotes/{yyyy-MM-dd}` (local date).
/// Uses [DailyQuote.fallback] when Firebase is off, offline, or doc missing.
final dailyQuoteProvider = FutureProvider.autoDispose<DailyQuote>((ref) async {
  if (Firebase.apps.isEmpty) {
    return DailyQuote.fallback;
  }
  final ds = FirestoreDailyQuoteDatasource(FirebaseFirestore.instance);
  return ds.fetchQuoteForToday();
});
