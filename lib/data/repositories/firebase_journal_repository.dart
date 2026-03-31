import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memoirly/data/models/journal_entry_model.dart';
import 'package:memoirly/domain/entities/journal_entry.dart';
import 'package:memoirly/domain/repositories/journal_repository.dart';

class FirebaseJournalRepository implements JournalRepository {
  FirebaseJournalRepository({
    required FirebaseFirestore firestore,
    required this.userIdResolver,
  }) : _db = firestore;

  final FirebaseFirestore _db;
  final Future<String?> Function() userIdResolver;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('journalEntries');

  @override
  Stream<List<JournalEntry>> watchEntries() async* {
    String? uid = await userIdResolver();
    if (uid == null) {
      yield [];
      return;
    }
    yield* _col(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) => JournalEntryModel.fromFirestore(d, uid).toEntity())
            .toList());
  }

  @override
  Future<List<JournalEntry>> getEntriesForDay(DateTime day) async {
    final uid = await userIdResolver();
    if (uid == null) return [];
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    try {
      final snap = await _col(uid)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('createdAt', isLessThan: Timestamp.fromDate(end))
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs
          .map((d) => JournalEntryModel.fromFirestore(d, uid).toEntity())
          .toList();
    } catch (_) {
      final all = await _col(uid).orderBy('createdAt', descending: true).get();
      return all.docs
          .map((d) => JournalEntryModel.fromFirestore(d, uid).toEntity())
          .where((e) {
            return !e.createdAt.isBefore(start) && e.createdAt.isBefore(end);
          })
          .toList();
    }
  }

  @override
  Future<JournalEntry?> getById(String id) async {
    final uid = await userIdResolver();
    if (uid == null) return null;
    final doc = await _col(uid).doc(id).get();
    if (!doc.exists) return null;
    return JournalEntryModel.fromFirestore(doc, uid).toEntity();
  }

  @override
  Future<void> create(JournalEntry entry) async {
    final uid = await userIdResolver();
    if (uid == null) throw StateError('No user');
    final model = JournalEntryModel.fromEntity(entry);
    await _col(uid).doc(model.id).set(model.toFirestore());
  }

  @override
  Future<void> update(JournalEntry entry) async {
    final uid = await userIdResolver();
    if (uid == null) throw StateError('No user');
    final model = JournalEntryModel.fromEntity(entry);
    await _col(uid).doc(model.id).update(model.toFirestore());
  }

  @override
  Future<void> delete(String id) async {
    final uid = await userIdResolver();
    if (uid == null) return;
    await _col(uid).doc(id).delete();
  }

  @override
  Future<void> clearAll() async {
    final uid = await userIdResolver();
    if (uid == null) return;
    final batch = _db.batch();
    final snap = await _col(uid).get();
    for (final d in snap.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
  }
}
