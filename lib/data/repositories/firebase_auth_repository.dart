import 'package:firebase_auth/firebase_auth.dart';
import 'package:memoirly/domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final FirebaseAuth _auth;

  @override
  Stream<String?> watchUserId() =>
      _auth.authStateChanges().map((u) => u?.uid);

  @override
  Future<String?> getCurrentUserId() async => _auth.currentUser?.uid;

  @override
  Future<void> signInAnonymously() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    throw UnimplementedError(
      'Wire google_sign_in + OAuth flow; see docs/DEVELOPER_GUIDE.md',
    );
  }

  @override
  Future<void> signInWithApple() async {
    throw UnimplementedError(
      'Wire sign_in_with_apple; see docs/DEVELOPER_GUIDE.md',
    );
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
