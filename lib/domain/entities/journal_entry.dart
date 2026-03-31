import 'package:equatable/equatable.dart';

class JournalEntry extends Equatable {
  const JournalEntry({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
    this.mood,
    this.tags = const [],
  });

  final String id;
  final String userId;
  final String title;
  final String content;
  final DateTime createdAt;
  final String? mood;
  final List<String> tags;

  int get wordCount {
    if (content.trim().isEmpty) return 0;
    return content.trim().split(RegExp(r'\s+')).length;
  }

  String get searchableText {
    final t = tags.map((e) => e.toLowerCase()).join(' ');
    return '${title.toLowerCase()} ${content.toLowerCase()} $t';
  }

  JournalEntry copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    DateTime? createdAt,
    String? mood,
    List<String>? tags,
    bool clearMood = false,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      mood: clearMood ? null : (mood ?? this.mood),
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props =>
      [id, userId, title, content, createdAt, mood, tags];
}
