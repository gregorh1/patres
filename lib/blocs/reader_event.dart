import 'package:equatable/equatable.dart';

sealed class ReaderEvent extends Equatable {
  const ReaderEvent();

  @override
  List<Object?> get props => [];
}

class ReaderLoadRequested extends ReaderEvent {
  const ReaderLoadRequested({required this.textId});
  final String textId;

  @override
  List<Object?> get props => [textId];
}

class ReaderChapterChanged extends ReaderEvent {
  const ReaderChapterChanged({required this.chapterIndex});
  final int chapterIndex;

  @override
  List<Object?> get props => [chapterIndex];
}

class ReaderFontSizeChanged extends ReaderEvent {
  const ReaderFontSizeChanged({required this.fontSizeIndex});
  final int fontSizeIndex;

  @override
  List<Object?> get props => [fontSizeIndex];
}

class ReaderFontFamilyChanged extends ReaderEvent {
  const ReaderFontFamilyChanged({required this.fontFamily});
  final String fontFamily;

  @override
  List<Object?> get props => [fontFamily];
}

class ReaderScrollPositionSaved extends ReaderEvent {
  const ReaderScrollPositionSaved({required this.position});
  final double position;

  @override
  List<Object?> get props => [position];
}

class ReaderBookmarkToggled extends ReaderEvent {
  const ReaderBookmarkToggled({this.note, this.scrollPosition = 0.0});
  final String? note;
  final double scrollPosition;

  @override
  List<Object?> get props => [note, scrollPosition];
}

class ReaderBookmarkRemoved extends ReaderEvent {
  const ReaderBookmarkRemoved({required this.index});
  final int index;

  @override
  List<Object?> get props => [index];
}

class ReaderHighlightToggled extends ReaderEvent {
  const ReaderHighlightToggled({required this.paragraphIndex});
  final int paragraphIndex;

  @override
  List<Object?> get props => [paragraphIndex];
}
