import 'package:intl/intl.dart';

class JournalEntry {
  final String id;
  final String ambienceId;
  final String ambienceTitle;
  final String mood;
  final String text;
  final DateTime createdAt;

  const JournalEntry({
    required this.id,
    required this.ambienceId,
    required this.ambienceTitle,
    required this.mood,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'ambienceId': ambienceId,
        'ambienceTitle': ambienceTitle,
        'mood': mood,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };

  factory JournalEntry.fromMap(Map<dynamic, dynamic> map) {
    return JournalEntry(
      id: map['id'] as String,
      ambienceId: map['ambienceId'] as String,
      ambienceTitle: map['ambienceTitle'] as String,
      mood: map['mood'] as String,
      text: map['text'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  String get firstLine {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return '';
    final firstLine = trimmed.split('\n').first.trim();
    return firstLine.length > 90 ? '${firstLine.substring(0, 90)}…' : firstLine;
  }

  String get formattedDate =>
      DateFormat('MMM d, yyyy • h:mm a').format(createdAt);
}
