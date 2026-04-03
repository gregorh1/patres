import 'package:equatable/equatable.dart';

class SearchResult extends Equatable {
  const SearchResult({
    required this.textId,
    required this.bookTitle,
    required this.bookAuthor,
    required this.chapterIndex,
    required this.chapterTitle,
    required this.snippet,
  });

  final String textId;
  final String bookTitle;
  final String bookAuthor;
  final int chapterIndex;
  final String chapterTitle;

  /// Context snippet with match markers: <b>matched text</b>
  final String snippet;

  @override
  List<Object?> get props =>
      [textId, bookTitle, bookAuthor, chapterIndex, chapterTitle, snippet];
}
