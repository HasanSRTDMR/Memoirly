abstract class AuthRepository {
  Stream<String?> watchUserId();

  Future<String?> getCurrentUserId();

  Future<void> signInAnonymously();

  /// Reserved for Google / Apple — implement in [FirebaseAuthRepository].
  Future<void> signInWithGoogle();

  Future<void> signInWithApple();

  Future<void> signOut();
}
