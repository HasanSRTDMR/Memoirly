import 'dart:convert';

import 'package:memoirly/domain/entities/journal_entry.dart';
import 'package:uuid/uuid.dart';

/// Round-trip for Memoirly TXT export (--- / title / ISO date / body).
abstract final class JournalTxtCodec {
  static String exportEntries(List<JournalEntry> entries) {
    final buffer = StringBuffer();
    for (final e in entries) {
      buffer.writeln('---');
      buffer.writeln(e.title);
      buffer.writeln(e.createdAt.toIso8601String());
      buffer.writeln(e.content);
      buffer.writeln();
    }
    return buffer.toString();
  }

  /// Parses TXT from [exportEntries]. Returns new entries with fresh ids.
  static List<JournalEntry> parseForImport(String text, String userId) {
    final lines = const LineSplitter().convert(text);
    final out = <JournalEntry>[];
    var i = 0;
    while (i < lines.length) {
      if (lines[i].trim() != '---') {
        i++;
        continue;
      }
      i++;
      if (i >= lines.length) break;
      final title = lines[i++];
      if (i >= lines.length) break;
      final dateLine = lines[i++];
      final created = DateTime.tryParse(dateLine);
      if (created == null) continue;

      final contentBuf = StringBuffer();
      while (i < lines.length && lines[i].trim() != '---') {
        if (contentBuf.isNotEmpty) contentBuf.writeln();
        contentBuf.write(lines[i]);
        i++;
      }
      final content = contentBuf.toString().replaceAll(RegExp(r'\s+$'), '');
      out.add(
        JournalEntry(
          id: const Uuid().v4(),
          userId: userId,
          title: title,
          content: content,
          createdAt: created,
        ),
      );
    }
    return out;
  }
}
