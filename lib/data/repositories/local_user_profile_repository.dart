import 'dart:async';
import 'dart:convert';

import 'package:memoirly/domain/entities/user_profile.dart';
import 'package:memoirly/domain/repositories/user_profile_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kFirst = 'memoirly_profile_first_name';
const _kLast = 'memoirly_profile_last_name';
const _kEmail = 'memoirly_profile_email';
const _kPhone = 'memoirly_profile_phone';
const _kHistory = 'memoirly_display_name_history_json';

class LocalUserProfileRepository implements UserProfileRepository {
  LocalUserProfileRepository(this._prefs);

  final SharedPreferences _prefs;

  final _profile = StreamController<UserProfile>.broadcast();

  UserProfile _read() {
    return UserProfile(
      firstName: _prefs.getString(_kFirst) ?? '',
      lastName: _prefs.getString(_kLast) ?? '',
      email: _prefs.getString(_kEmail) ?? '',
      phone: _prefs.getString(_kPhone) ?? '',
    );
  }

  @override
  Stream<UserProfile> watchProfile() async* {
    yield _read();
    yield* _profile.stream;
  }

  void _appendNameHistoryIfNeeded(UserProfile previous) {
    if (previous.firstName.trim().isEmpty && previous.lastName.trim().isEmpty) {
      return;
    }
    final raw = _prefs.getString(_kHistory);
    final list = <Map<String, dynamic>>[];
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        for (final e in decoded) {
          if (e is Map<String, dynamic>) list.add(e);
        }
      }
    }
    list.add({
      'firstName': previous.firstName,
      'lastName': previous.lastName,
      'recordedAt': DateTime.now().toUtc().toIso8601String(),
    });
    _prefs.setString(_kHistory, jsonEncode(list));
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    final nf = profile.firstName.trim();
    final nl = profile.lastName.trim();
    final ne = profile.email.trim();
    final np = profile.phone.trim();
    final cur = _read();
    final nameChanged = cur.firstName != nf || cur.lastName != nl;
    final otherChanged = cur.email != ne || cur.phone != np;
    if (!nameChanged && !otherChanged) return;

    if (nameChanged) {
      _appendNameHistoryIfNeeded(cur);
    }
    await _prefs.setString(_kFirst, nf);
    await _prefs.setString(_kLast, nl);
    await _prefs.setString(_kEmail, ne);
    await _prefs.setString(_kPhone, np);
    _profile.add(_read());
  }
}
