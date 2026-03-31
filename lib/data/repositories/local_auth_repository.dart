import 'dart:async';

import 'package:memoirly/domain/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

const _kLocalUid = 'memoirly_local_uid_v1';

/// Offline user id stored in preferences (no Firebase).
class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository(this._prefs);

  final SharedPreferences _prefs;
  final _uidCtrl = StreamController<String?>.broadcast();

  String? _cached;

  String _ensureUid() {
    _cached ??= _prefs.getString(_kLocalUid);
    if (_cached == null || _cached!.isEmpty) {
      _cached = const Uuid().v4();
      _prefs.setString(_kLocalUid, _cached!);
    }
    return _cached!;
  }

  @override
  Stream<String?> watchUserId() async* {
    yield _ensureUid();
    yield* _uidCtrl.stream;
  }

  @override
  Future<String?> getCurrentUserId() async => _ensureUid();

  @override
  Future<void> signInAnonymously() async {
    _ensureUid();
    _uidCtrl.add(_cached);
  }

  @override
  Future<void> signInWithGoogle() async =>
      throw UnimplementedError('Use Firebase backend for social login');

  @override
  Future<void> signInWithApple() async =>
      throw UnimplementedError('Use Firebase backend for social login');

  @override
  Future<void> signOut() async {
    await _prefs.remove(_kLocalUid);
    _cached = null;
    _uidCtrl.add(null);
  }
}
