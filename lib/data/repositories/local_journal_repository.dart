import 'dart:async';
import 'dart:convert';

import 'package:memoirly/data/models/journal_entry_model.dart';
import 'package:memoirly/domain/entities/journal_entry.dart';
import 'package:memoirly/domain/repositories/journal_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kEntriesKey = 'memoirly_journal_entries_v1';

/// Persists journal JSON in [SharedPreferences]. Used when Firebase is unavailable.
class LocalJournalRepository implements JournalRepository {
  LocalJournalRepository(this._prefs, {required this.userId});

  final SharedPreferences _prefs;
  final String userId;

  final _updates = StreamController<List<JournalEntry>>.broadcast();

  List<JournalEntry> _readAll() {
    final raw = _prefs.getString(_kEntriesKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => JournalEntryModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ).toEntity())
        .where((e) => e.userId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> _writeAll(List<JournalEntry> entries) async {
    final allRaw = _prefs.getString(_kEntriesKey);
    List<dynamic> all = [];
    if (allRaw != null && allRaw.isNotEmpty) {
      all = jsonDecode(allRaw) as List<dynamic>;
    }
    final others = all
        .map((e) => JournalEntryModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ).toEntity())
        .where((e) => e.userId != userId)
        .map((e) => JournalEntryModel.fromEntity(e).toJson())
        .toList();
    final mine = entries.map((e) => JournalEntryModel.fromEntity(e).toJson()).toList();
    await _prefs.setString(_kEntriesKey, jsonEncode([...others, ...mine]));
  }

  void _notify() {
    if (!_updates.isClosed) _updates.add(_readAll());
  }

  @override
  Stream<List<JournalEntry>> watchEntries() {
    return Stream<List<JournalEntry>>.multi((c) {
      c.add(_readAll());
      final sub = _updates.stream.listen(c.add);
      c.onCancel = () => sub.cancel();
    });
  }

  @override
  Future<List<JournalEntry>> getEntriesForDay(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return _readAll().where((e) {
      return !e.createdAt.isBefore(start) && e.createdAt.isBefore(end);
    }).toList();
  }

  @override
  Future<JournalEntry?> getById(String id) async {
    try {
      return _readAll().firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> create(JournalEntry entry) async {
    final list = _readAll();
    list.removeWhere((e) => e.id == entry.id);
    list.add(entry);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    await _writeAll(list);
    _notify();
  }

  @override
  Future<void> update(JournalEntry entry) async {
    final list = _readAll();
    final i = list.indexWhere((e) => e.id == entry.id);
    if (i >= 0) {
      list[i] = entry;
    } else {
      list.add(entry);
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    await _writeAll(list);
    _notify();
  }

  @override
  Future<void> delete(String id) async {
    final list = _readAll()..removeWhere((e) => e.id == id);
    await _writeAll(list);
    _notify();
  }

  @override
  Future<void> clearAll() async {
    final allRaw = _prefs.getString(_kEntriesKey);
    if (allRaw == null || allRaw.isEmpty) return;
    final list = (jsonDecode(allRaw) as List<dynamic>)
        .map((e) => JournalEntryModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ).toEntity())
        .where((e) => e.userId != userId)
        .map((e) => JournalEntryModel.fromEntity(e).toJson())
        .toList();
    await _prefs.setString(_kEntriesKey, jsonEncode(list));
    _notify();
  }
}
