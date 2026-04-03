import 'package:equatable/equatable.dart';

class Bookmark extends Equatable {
  const Bookmark({
    required this.chapterIndex,
    required this.timestamp,
    this.note,
    this.scrollPosition = 0.0,
  });

  final int chapterIndex;
  final DateTime timestamp;
  final String? note;
  final double scrollPosition;

  Map<String, dynamic> toJson() => {
        'chapterIndex': chapterIndex,
        'timestamp': timestamp.toIso8601String(),
        'note': note,
        'scrollPosition': scrollPosition,
      };

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
        chapterIndex: json['chapterIndex'] as int,
        timestamp: DateTime.parse(json['timestamp'] as String),
        note: json['note'] as String?,
        scrollPosition:
            (json['scrollPosition'] as num?)?.toDouble() ?? 0.0,
      );

  @override
  List<Object?> get props => [chapterIndex, timestamp, note, scrollPosition];
}
