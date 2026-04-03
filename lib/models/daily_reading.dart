import 'package:equatable/equatable.dart';

class DailyReading extends Equatable {
  const DailyReading({
    required this.textId,
    required this.chapterIndex,
    required this.paragraphIndex,
    required this.quote,
    required this.author,
  });

  final String textId;
  final int chapterIndex;
  final int paragraphIndex;
  final String quote;
  final String author;

  factory DailyReading.fromJson(Map<String, dynamic> json) {
    return DailyReading(
      textId: json['textId'] as String,
      chapterIndex: json['chapterIndex'] as int,
      paragraphIndex: json['paragraphIndex'] as int,
      quote: json['quote'] as String,
      author: json['author'] as String,
    );
  }

  @override
  List<Object?> get props =>
      [textId, chapterIndex, paragraphIndex, quote, author];
}
