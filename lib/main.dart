import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:memoirly/app/app_router.dart';
import 'package:memoirly/app/memoirly_app.dart';
import 'package:memoirly/core/config/app_backend.dart';
import 'package:memoirly/core/di/providers.dart';
import 'package:memoirly/data/repositories/firebase_auth_repository.dart';
import 'package:memoirly/data/repositories/firebase_journal_repository.dart';
import 'package:memoirly/data/repositories/local_auth_repository.dart';
import 'package:memoirly/data/repositories/local_journal_repository.dart';
import 'package:memoirly/data/repositories/security_repository_impl.dart';
import 'package:memoirly/data/repositories/settings_repository_impl.dart';
import 'package:memoirly/domain/repositories/auth_repository.dart';
import 'package:memoirly/domain/repositories/journal_repository.dart';
import 'package:memoirly/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  late final AuthRepository authRepo;
  late final JournalRepository journalRepo;
  var backend = AppBackend.local;

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    final firebaseAuth = FirebaseAuth.instance;
    authRepo = FirebaseAuthRepository(firebaseAuth);
    await authRepo.signInAnonymously();
    journalRepo = FirebaseJournalRepository(
      firestore: FirebaseFirestore.instance,
      userIdResolver: authRepo.getCurrentUserId,
    );
    backend = AppBackend.firebase;
  } catch (e, st) {
    debugPrint('Firebase unavailable, using local backend: $e\n$st');
    authRepo = LocalAuthRepository(prefs);
    await authRepo.signInAnonymously();
    final uid = await authRepo.getCurrentUserId() ?? 'local';
    journalRepo = LocalJournalRepository(prefs, userId: uid);
    backend = AppBackend.local;
  }

  final settingsRepo = SettingsRepositoryImpl(prefs);
  const secureStorage = FlutterSecureStorage();
  final securityRepo = SecurityRepositoryImpl(prefs, secureStorage);

  final onboardingDone =
      await settingsRepo.watchOnboardingCompleted().first;
  final initialLocation = onboardingDone ? '/home' : '/onboarding';
  final router = createAppRouter(initialLocation: initialLocation);

  runApp(
    ProviderScope(
      overrides: [
        appBackendProvider.overrideWithValue(backend),
        authRepositoryProvider.overrideWithValue(authRepo),
        journalRepositoryProvider.overrideWithValue(journalRepo),
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        securityRepositoryProvider.overrideWithValue(securityRepo),
      ],
      child: MemoirlyApp(router: router),
    ),
  );
}
