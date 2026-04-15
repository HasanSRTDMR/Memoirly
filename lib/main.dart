import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:memoirly/app/app_router.dart';
import 'package:memoirly/app/memoirly_app.dart';
import 'package:memoirly/core/config/app_backend.dart';
import 'package:memoirly/core/di/providers.dart';
import 'package:memoirly/data/repositories/firebase_auth_repository.dart';
import 'package:memoirly/data/repositories/firebase_journal_repository.dart';
import 'package:memoirly/data/repositories/firebase_user_profile_repository.dart';
import 'package:memoirly/data/repositories/local_auth_repository.dart';
import 'package:memoirly/data/repositories/local_journal_repository.dart';
import 'package:memoirly/data/repositories/local_user_profile_repository.dart';
import 'package:memoirly/data/repositories/security_repository_impl.dart';
import 'package:memoirly/data/repositories/settings_repository_impl.dart';
import 'package:memoirly/domain/repositories/auth_repository.dart';
import 'package:memoirly/domain/repositories/journal_repository.dart';
import 'package:memoirly/domain/repositories/user_profile_repository.dart';
import 'package:memoirly/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fails when Firestore is not provisioned, rules block reads, or server is unreachable.
///
/// Must use [Source.server]: default `.get()` can succeed from an empty local cache
/// even when the project has no Firestore database, so the app would wrongly stay
/// on [FirebaseJournalRepository] and every real read/write would then fail.
Future<bool> _journalFirestoreProbe(String uid) async {
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('journalEntries')
        .limit(1)
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 12));
    return true;
  } on TimeoutException catch (e) {
    debugPrint('Firestore probe timeout: $e');
    return false;
  } catch (e, st) {
    debugPrint('Firestore probe failed (using local archive): $e\n$st');
    return false;
  }
}

Future<void> _applyImmersiveSticky() {
  return SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _applyImmersiveSticky();
  SystemChrome.setSystemUIChangeCallback((systemOverlaysAreVisible) async {
    if (systemOverlaysAreVisible) {
      await _applyImmersiveSticky();
    }
  });
  final prefs = await SharedPreferences.getInstance();

  late final AuthRepository authRepo;
  late final JournalRepository journalRepo;
  late final UserProfileRepository profileRepo;
  var backend = AppBackend.local;

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    final firebaseAuth = FirebaseAuth.instance;
    // Do not assign [authRepo] until Firestore probe passes — otherwise [catch]
    // cannot replace it ([late final] allows only one assignment).
    final firebaseAuthRepo = FirebaseAuthRepository(firebaseAuth);
    await firebaseAuthRepo.signInAnonymously();
    final uid = await firebaseAuthRepo.getCurrentUserId();
    if (uid == null) {
      throw StateError('Anonymous sign-in returned no user id');
    }
    if (!await _journalFirestoreProbe(uid)) {
      throw StateError('Firestore not usable for this project or device');
    }
    authRepo = firebaseAuthRepo;
    journalRepo = FirebaseJournalRepository(
      firestore: FirebaseFirestore.instance,
      userIdResolver: authRepo.getCurrentUserId,
    );
    profileRepo = FirebaseUserProfileRepository(
      firestore: FirebaseFirestore.instance,
      userIdResolver: authRepo.getCurrentUserId,
    );
    backend = AppBackend.firebase;
  } catch (e, st) {
    debugPrint('Firebase cloud journal unavailable, using local backend: $e\n$st');
    authRepo = LocalAuthRepository(prefs);
    await authRepo.signInAnonymously();
    final uid = await authRepo.getCurrentUserId() ?? 'local';
    journalRepo = LocalJournalRepository(prefs, userId: uid);
    profileRepo = LocalUserProfileRepository(prefs);
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
        userProfileRepositoryProvider.overrideWithValue(profileRepo),
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        securityRepositoryProvider.overrideWithValue(securityRepo),
      ],
      child: MemoirlyApp(router: router),
    ),
  );
}
