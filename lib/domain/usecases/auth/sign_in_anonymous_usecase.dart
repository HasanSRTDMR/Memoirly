import 'package:memoirly/domain/repositories/auth_repository.dart';

class SignInAnonymousUseCase {
  SignInAnonymousUseCase(this._auth);

  final AuthRepository _auth;

  Future<void> call() => _auth.signInAnonymously();
}
