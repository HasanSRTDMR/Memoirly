import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:memoirly/domain/repositories/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kOnboarding = 'memoirly_onboarding_done';
const _kTheme = 'memoirly_theme_mode';
const _kLocale = 'memoirly_locale';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;

  final _onboarding = StreamController<bool>.broadcast();
  final _theme = StreamController<ThemeMode>.broadcast();
  final _locale = StreamController<Locale>.broadcast();

  @override
  Stream<bool> watchOnboardingCompleted() async* {
    yield _prefs.getBool(_kOnboarding) ?? false;
    yield* _onboarding.stream;
  }

  @override
  Future<void> setOnboardingCompleted(bool value) async {
    await _prefs.setBool(_kOnboarding, value);
    _onboarding.add(value);
  }

  ThemeMode _readTheme() {
    final v = _prefs.getString(_kTheme);
    switch (v) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  @override
  Stream<ThemeMode> watchThemeMode() async* {
    yield _readTheme();
    yield* _theme.stream;
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    final s = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
    };
    await _prefs.setString(_kTheme, s);
    _theme.add(mode);
  }

  Locale _defaultLocale() {
    final lang = PlatformDispatcher.instance.locale.languageCode;
    return lang == 'tr' ? const Locale('tr') : const Locale('en');
  }

  Locale _readLocale() {
    final code = _prefs.getString(_kLocale);
    if (code == null || code.isEmpty) return _defaultLocale();
    if (code.contains('_')) {
      final parts = code.split('_');
      return Locale(parts[0], parts[1]);
    }
    final loc = Locale(code);
    if (loc.languageCode == 'tr' || loc.languageCode == 'en') {
      return Locale(loc.languageCode);
    }
    return _defaultLocale();
  }

  @override
  Stream<Locale> watchLocaleOverride() async* {
    yield _readLocale();
    yield* _locale.stream;
  }

  @override
  Future<void> setLocaleOverride(Locale locale) async {
    final code =
        locale.countryCode != null && locale.countryCode!.isNotEmpty
            ? '${locale.languageCode}_${locale.countryCode}'
            : locale.languageCode;
    await _prefs.setString(_kLocale, code);
    _locale.add(locale);
  }
}
