import 'package:equatable/equatable.dart';

class Highlight extends Equatable {
  const Highlight({
    this.id,
    this.textId = '',
    required this.chapterIndex,
    required this.paragraphIndex,
  });

  final int? id;
  final String textId;
  final int chapterIndex;
  final int paragraphIndex;

  Highlight copyWith({
    int? id,
    String? textId,
    int? chapterIndex,
    int? paragraphIndex,
  }) {
    return Highlight(
      id: id ?? this.id,
      textId: textId ?? this.textId,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      paragraphIndex: paragraphIndex ?? this.paragraphIndex,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'textId': textId,
        'chapterIndex': chapterIndex,
        'paragraphIndex': paragraphIndex,
      };

  factory Highlight.fromJson(Map<String, dynamic> json) => Highlight(
        id: json['id'] as int?,
        textId: json['textId'] as String? ?? '',
        chapterIndex: json['chapterIndex'] as int,
        paragraphIndex: json['paragraphIndex'] as int,
      );

  @override
  List<Object?> get props => [id, textId, chapterIndex, paragraphIndex];
}
