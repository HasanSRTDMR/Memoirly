import 'package:flutter/material.dart';

abstract class SettingsRepository {
  Stream<bool> watchOnboardingCompleted();

  Future<void> setOnboardingCompleted(bool value);

  Stream<ThemeMode> watchThemeMode();

  Future<void> setThemeMode(ThemeMode mode);

  /// null = follow system locale
  Stream<Locale?> watchLocaleOverride();

  Future<void> setLocaleOverride(Locale? locale);
}
