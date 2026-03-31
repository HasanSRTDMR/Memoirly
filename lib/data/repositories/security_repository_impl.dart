import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:memoirly/domain/repositories/security_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLockEnabled = 'memoirly_lock_enabled';
const _kBioEnabled = 'memoirly_bio_enabled';
const _kPinHashKey = 'memoirly_pin_hash_v1';

class SecurityRepositoryImpl implements SecurityRepository {
  SecurityRepositoryImpl(this._prefs, this._secure);

  final SharedPreferences _prefs;
  final FlutterSecureStorage _secure;

  final _lock = StreamController<bool>.broadcast();
  final _bio = StreamController<bool>.broadcast();

  bool _sessionUnlocked = false;

  @override
  bool get isSessionUnlocked => _sessionUnlocked;

  @override
  void setSessionUnlocked(bool unlocked) {
    _sessionUnlocked = unlocked;
  }

  @override
  Stream<bool> watchLockEnabled() async* {
    yield _prefs.getBool(_kLockEnabled) ?? false;
    yield* _lock.stream;
  }

  @override
  Future<void> setLockEnabled(bool enabled) async {
    await _prefs.setBool(_kLockEnabled, enabled);
    if (!enabled) _sessionUnlocked = true;
    _lock.add(enabled);
  }

  @override
  Stream<bool> watchBiometricEnabled() async* {
    yield _prefs.getBool(_kBioEnabled) ?? false;
    yield* _bio.stream;
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs.setBool(_kBioEnabled, enabled);
    _bio.add(enabled);
  }

  String _hash(String pin) =>
      sha256.convert(utf8.encode(pin)).toString();

  @override
  Future<bool> hasPin() async {
    final v = await _secure.read(key: _kPinHashKey);
    return v != null && v.isNotEmpty;
  }

  @override
  Future<void> setPin(String pin) async {
    await _secure.write(key: _kPinHashKey, value: _hash(pin));
  }

  @override
  Future<void> clearPin() async {
    await _secure.delete(key: _kPinHashKey);
  }

  @override
  Future<bool> verifyPin(String pin) async {
    final stored = await _secure.read(key: _kPinHashKey);
    if (stored == null) return false;
    return stored == _hash(pin);
  }
}
