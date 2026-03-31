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
    this.imagePaths = const [],
    this.contentColorArgb,
  });

  final String id;
  final String userId;
  final String title;
  final String content;
  final DateTime createdAt;
  final String? mood;
  final List<String> tags;
  /// Local filesystem paths to images attached to this entry.
  final List<String> imagePaths;
  /// When set, body text is shown in this color in the reader (ARGB, 32-bit).
  final int? contentColorArgb;

  int get wordCount {
    if (content.trim().isEmpty) return 0;
    return content.trim().split(RegExp(r'\s+')).length;
  }

  String get searchableText {
    final lowerTags = tags.map((e) => e.toLowerCase()).toList();
    final t = lowerTags.join(' ');
    final hashTags = lowerTags.map((e) => '#$e').join(' ');
    return '${title.toLowerCase()} ${content.toLowerCase()} $t $hashTags';
  }

  JournalEntry copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    DateTime? createdAt,
    String? mood,
    List<String>? tags,
    List<String>? imagePaths,
    int? contentColorArgb,
    bool clearMood = false,
    bool clearContentColor = false,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      mood: clearMood ? null : (mood ?? this.mood),
      tags: tags ?? this.tags,
      imagePaths: imagePaths ?? this.imagePaths,
      contentColorArgb:
          clearContentColor ? null : (contentColorArgb ?? this.contentColorArgb),
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        content,
        createdAt,
        mood,
        tags,
        imagePaths,
        contentColorArgb,
      ];
}
