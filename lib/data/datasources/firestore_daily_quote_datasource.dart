import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:memoirly/domain/entities/daily_quote.dart';

/// Reads `dailyQuotes/{yyyy-MM-dd}` (local calendar day).
///
/// Firestore document fields:
/// - `textEn` (string, required)
/// - `textTr` (string, required)
/// - `author` (string, optional)
///
/// Rules example (read-only for clients):
/// `match /dailyQuotes/{id} { allow read: if true; allow write: if false; }`
class FirestoreDailyQuoteDatasource {
  FirestoreDailyQuoteDatasource(this._db);

  final FirebaseFirestore _db;

  static String documentIdForLocalDate(DateTime localNow) {
    final d = DateTime(localNow.year, localNow.month, localNow.day);
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  Future<DailyQuote> fetchQuoteForToday() async {
    if (Firebase.apps.isEmpty) {
      return DailyQuote.fallback;
    }
    final id = documentIdForLocalDate(DateTime.now());
    try {
      final snap = await _db
          .collection('dailyQuotes')
          .doc(id)
          .get(const GetOptions(source: Source.serverAndCache));
      if (!snap.exists) {
        return DailyQuote.fallback;
      }
      final data = snap.data();
      if (data == null) return DailyQuote.fallback;

      final en = (data['textEn'] as String?)?.trim();
      final tr = (data['textTr'] as String?)?.trim();
      if (en == null || tr == null || en.isEmpty || tr.isEmpty) {
        return DailyQuote.fallback;
      }
      final author = (data['author'] as String?)?.trim();
      return DailyQuote(
        textEn: en,
        textTr: tr,
        author: author?.isEmpty ?? true ? null : author,
      );
    } catch (e, st) {
      debugPrint('FirestoreDailyQuoteDatasource: $e\n$st');
      return DailyQuote.fallback;
    }
  }
}
