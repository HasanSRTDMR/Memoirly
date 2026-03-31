import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memoirly/domain/entities/journal_entry.dart';

class JournalEntryModel {
  const JournalEntryModel({
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

  JournalEntry toEntity() => JournalEntry(
        id: id,
        userId: userId,
        title: title,
        content: content,
        createdAt: createdAt,
        mood: mood,
        tags: tags,
      );

  factory JournalEntryModel.fromEntity(JournalEntry e) => JournalEntryModel(
        id: e.id,
        userId: e.userId,
        title: e.title,
        content: e.content,
        createdAt: e.createdAt,
        mood: e.mood,
        tags: e.tags,
      );

  factory JournalEntryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String userId,
  ) {
    final d = doc.data() ?? {};
    return JournalEntryModel(
      id: doc.id,
      userId: userId,
      title: d['title'] as String? ?? '',
      content: d['content'] as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      mood: d['mood'] as String?,
      tags: (d['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'content': content,
        'createdAt': Timestamp.fromDate(createdAt),
        'mood': mood,
        'tags': tags,
      };

  factory JournalEntryModel.fromJson(Map<String, dynamic> json) {
    return JournalEntryModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      mood: json['mood'] as String?,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'mood': mood,
        'tags': tags,
      };
}
