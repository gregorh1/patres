import 'package:equatable/equatable.dart';
import 'package:patres/models/bookmark.dart';
import 'package:patres/models/highlight.dart';
import 'package:patres/models/text_content.dart';

enum ReaderStatus { initial, loading, loaded, error }

class ReaderState extends Equatable {
  const ReaderState({
    this.status = ReaderStatus.initial,
    this.textContent,
    this.textId = '',
    this.currentChapter = 0,
    this.fontSizeIndex = 1,
    this.fontFamily = 'Lora',
    this.scrollPosition = 0.0,
    this.bookmarks = const [],
    this.highlights = const [],
    this.errorMessage,
  });

  final ReaderStatus status;
  final TextContent? textContent;
  final String textId;
  final int currentChapter;
  final int fontSizeIndex; // 0=small, 1=medium, 2=large, 3=XL, 4=XXL
  final String fontFamily;
  final double scrollPosition;
  final List<Bookmark> bookmarks;
  final List<Highlight> highlights;
  final String? errorMessage;

  static const fontSizes = [14.0, 17.0, 20.0, 24.0, 28.0];
  static const fontSizeLabels = ['S', 'M', 'L', 'XL', 'XXL'];

  double get fontSize => fontSizes[fontSizeIndex.clamp(0, 4)];

  double get readingProgress {
    if (textContent == null || textContent!.chapters.isEmpty) return 0;
    return (currentChapter + 1) / textContent!.chapters.length;
  }

  bool get isCurrentChapterBookmarked {
    return bookmarks.any((b) => b.chapterIndex == currentChapter);
  }

  bool isParagraphHighlighted(int paragraphIndex) {
    return highlights.any((h) =>
        h.chapterIndex == currentChapter &&
        h.paragraphIndex == paragraphIndex);
  }

  ReaderState copyWith({
    ReaderStatus? status,
    TextContent? textContent,
    String? textId,
    int? currentChapter,
    int? fontSizeIndex,
    String? fontFamily,
    double? scrollPosition,
    List<Bookmark>? bookmarks,
    List<Highlight>? highlights,
    String? errorMessage,
  }) {
    return ReaderState(
      status: status ?? this.status,
      textContent: textContent ?? this.textContent,
      textId: textId ?? this.textId,
      currentChapter: currentChapter ?? this.currentChapter,
      fontSizeIndex: fontSizeIndex ?? this.fontSizeIndex,
      fontFamily: fontFamily ?? this.fontFamily,
      scrollPosition: scrollPosition ?? this.scrollPosition,
      bookmarks: bookmarks ?? this.bookmarks,
      highlights: highlights ?? this.highlights,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        textContent,
        textId,
        currentChapter,
        fontSizeIndex,
        fontFamily,
        scrollPosition,
        bookmarks,
        highlights,
        errorMessage,
      ];
}
