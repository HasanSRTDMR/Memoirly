import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoirly/app/app_router.dart';
import 'package:memoirly/app/memoirly_app.dart';
import 'package:memoirly/core/config/app_backend.dart';
import 'package:memoirly/core/di/providers.dart';
import 'package:memoirly/data/repositories/local_auth_repository.dart';
import 'package:memoirly/data/repositories/local_journal_repository.dart';
import 'package:memoirly/data/repositories/settings_repository_impl.dart';
import 'package:memoirly/domain/repositories/security_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _NoopSecurityRepo implements SecurityRepository {
  @override
  Future<void> clearPin() async {}

  @override
  Future<bool> hasPin() async => false;

  @override
  bool get isSessionUnlocked => true;

  @override
  void setSessionUnlocked(bool unlocked) {}

  @override
  Future<void> setLockEnabled(bool enabled) async {}

  @override
  Future<void> setPin(String pin) async {}

  @override
  Stream<bool> watchLockEnabled() => Stream.value(false);

  @override
  Future<bool> verifyPin(String pin) async => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App loads shell when onboarding done', (tester) async {
    SharedPreferences.setMockInitialValues({'memoirly_onboarding_done': true});
    final prefs = await SharedPreferences.getInstance();
    final auth = LocalAuthRepository(prefs);
    await auth.signInAnonymously();
    final uid = await auth.getCurrentUserId() ?? 't';
    final journal = LocalJournalRepository(prefs, userId: uid);
    final settings = SettingsRepositoryImpl(prefs);
    await settings.setOnboardingCompleted(true);
    final security = _NoopSecurityRepo();

    final router = createAppRouter(initialLocation: '/home');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appBackendProvider.overrideWithValue(AppBackend.local),
          authRepositoryProvider.overrideWithValue(auth),
          journalRepositoryProvider.overrideWithValue(journal),
          settingsRepositoryProvider.overrideWithValue(settings),
          securityRepositoryProvider.overrideWithValue(security),
        ],
        child: MemoirlyApp(router: router),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
