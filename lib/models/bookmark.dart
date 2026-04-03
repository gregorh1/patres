import 'package:equatable/equatable.dart';

class Bookmark extends Equatable {
  const Bookmark({
    this.id,
    this.textId = '',
    required this.chapterIndex,
    required this.timestamp,
    this.note,
    this.scrollPosition = 0.0,
  });

  final int? id;
  final String textId;
  final int chapterIndex;
  final DateTime timestamp;
  final String? note;
  final double scrollPosition;

  Bookmark copyWith({
    int? id,
    String? textId,
    int? chapterIndex,
    DateTime? timestamp,
    String? note,
    double? scrollPosition,
  }) {
    return Bookmark(
      id: id ?? this.id,
      textId: textId ?? this.textId,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
      scrollPosition: scrollPosition ?? this.scrollPosition,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'textId': textId,
        'chapterIndex': chapterIndex,
        'timestamp': timestamp.toIso8601String(),
        'note': note,
        'scrollPosition': scrollPosition,
      };

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
        id: json['id'] as int?,
        textId: json['textId'] as String? ?? '',
        chapterIndex: json['chapterIndex'] as int,
        timestamp: DateTime.parse(json['timestamp'] as String),
        note: json['note'] as String?,
        scrollPosition:
            (json['scrollPosition'] as num?)?.toDouble() ?? 0.0,
      );

  @override
  List<Object?> get props =>
      [id, textId, chapterIndex, timestamp, note, scrollPosition];
}
