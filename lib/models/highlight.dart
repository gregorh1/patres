import 'package:equatable/equatable.dart';

class Highlight extends Equatable {
  const Highlight({
    required this.chapterIndex,
    required this.paragraphIndex,
  });

  final int chapterIndex;
  final int paragraphIndex;

  Map<String, dynamic> toJson() => {
        'chapterIndex': chapterIndex,
        'paragraphIndex': paragraphIndex,
      };

  factory Highlight.fromJson(Map<String, dynamic> json) => Highlight(
        chapterIndex: json['chapterIndex'] as int,
        paragraphIndex: json['paragraphIndex'] as int,
      );

  @override
  List<Object?> get props => [chapterIndex, paragraphIndex];
}
