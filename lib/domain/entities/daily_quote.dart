import 'package:flutter/material.dart';

/// Quote of the day from Firestore [dailyQuotes] or [DailyQuote.fallback].
class DailyQuote {
  const DailyQuote({
    required this.textEn,
    required this.textTr,
    this.author,
  });

  final String textEn;
  final String textTr;
  final String? author;

  /// Shown when Firestore is unavailable, document missing, or fields invalid.
  static const DailyQuote fallback = DailyQuote(
    textEn:
        'The soul should always stand ajar, ready to welcome the ecstatic experience.',
    textTr:
        'Ruh her zaman aralanmış olmalı; coşkulu deneyimi karşılamaya hazır beklemeli.',
    author: 'Emily Dickinson',
  );

  String textForLocale(Locale? locale) =>
      locale?.languageCode == 'tr' ? textTr : textEn;
}
