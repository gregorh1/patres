import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patres/blocs/reader_event.dart';
import 'package:patres/blocs/reader_state.dart';
import 'package:patres/models/bookmark.dart';
import 'package:patres/models/highlight.dart';
import 'package:patres/services/reader_storage_service.dart';
import 'package:patres/services/text_service.dart';

class ReaderBloc extends Bloc<ReaderEvent, ReaderState> {
  ReaderBloc({
    required this.textService,
    required this.storageService,
  }) : super(const ReaderState()) {
    on<ReaderLoadRequested>(_onLoadRequested);
    on<ReaderChapterChanged>(_onChapterChanged);
    on<ReaderFontSizeChanged>(_onFontSizeChanged);
    on<ReaderFontFamilyChanged>(_onFontFamilyChanged);
    on<ReaderScrollPositionSaved>(_onScrollPositionSaved);
    on<ReaderBookmarkToggled>(_onBookmarkToggled);
    on<ReaderBookmarkRemoved>(_onBookmarkRemoved);
    on<ReaderHighlightToggled>(_onHighlightToggled);
  }

  final TextService textService;
  final ReaderStorageService storageService;

  Future<void> _onLoadRequested(
    ReaderLoadRequested event,
    Emitter<ReaderState> emit,
  ) async {
    emit(state.copyWith(status: ReaderStatus.loading, textId: event.textId));
    try {
      final textContent = await textService.loadText(event.textId);
      final fontSizeIndex = await storageService.getFontSizeIndex();
      final fontFamily = await storageService.getFontFamily();
      final lastChapter = await storageService.getLastChapter(event.textId);
      final chapter = lastChapter.clamp(0, textContent.chapters.length - 1);
      final scrollPosition =
          await storageService.getScrollPosition(event.textId, chapter);
      final bookmarks = await storageService.getBookmarks(event.textId);
      final highlights = await storageService.getHighlights(event.textId);

      emit(state.copyWith(
        status: ReaderStatus.loaded,
        textContent: textContent,
        currentChapter: chapter,
        fontSizeIndex: fontSizeIndex,
        fontFamily: fontFamily,
        scrollPosition: scrollPosition,
        bookmarks: bookmarks,
        highlights: highlights,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ReaderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onChapterChanged(
    ReaderChapterChanged event,
    Emitter<ReaderState> emit,
  ) async {
    final scrollPosition = await storageService.getScrollPosition(
        state.textId, event.chapterIndex);
    emit(state.copyWith(
      currentChapter: event.chapterIndex,
      scrollPosition: scrollPosition,
    ));
    await storageService.saveLastChapter(state.textId, event.chapterIndex);
  }

  Future<void> _onFontSizeChanged(
    ReaderFontSizeChanged event,
    Emitter<ReaderState> emit,
  ) async {
    emit(state.copyWith(fontSizeIndex: event.fontSizeIndex));
    await storageService.saveFontSizeIndex(event.fontSizeIndex);
  }

  Future<void> _onFontFamilyChanged(
    ReaderFontFamilyChanged event,
    Emitter<ReaderState> emit,
  ) async {
    emit(state.copyWith(fontFamily: event.fontFamily));
    await storageService.saveFontFamily(event.fontFamily);
  }

  Future<void> _onScrollPositionSaved(
    ReaderScrollPositionSaved event,
    Emitter<ReaderState> emit,
  ) async {
    await storageService.saveScrollPosition(
      state.textId,
      state.currentChapter,
      event.position,
    );
  }

  Future<void> _onBookmarkToggled(
    ReaderBookmarkToggled event,
    Emitter<ReaderState> emit,
  ) async {
    final existingIndex = state.bookmarks
        .indexWhere((b) => b.chapterIndex == state.currentChapter);

    List<Bookmark> newBookmarks;
    if (existingIndex >= 0) {
      newBookmarks = List.of(state.bookmarks)..removeAt(existingIndex);
    } else {
      newBookmarks = [
        ...state.bookmarks,
        Bookmark(
          chapterIndex: state.currentChapter,
          timestamp: DateTime.now(),
          note: event.note,
          scrollPosition: event.scrollPosition,
        ),
      ];
    }

    emit(state.copyWith(bookmarks: newBookmarks));
    await storageService.saveBookmarks(state.textId, newBookmarks);
  }

  Future<void> _onBookmarkRemoved(
    ReaderBookmarkRemoved event,
    Emitter<ReaderState> emit,
  ) async {
    final newBookmarks = List.of(state.bookmarks)..removeAt(event.index);
    emit(state.copyWith(bookmarks: newBookmarks));
    await storageService.saveBookmarks(state.textId, newBookmarks);
  }

  Future<void> _onHighlightToggled(
    ReaderHighlightToggled event,
    Emitter<ReaderState> emit,
  ) async {
    final existingIndex = state.highlights.indexWhere((h) =>
        h.chapterIndex == state.currentChapter &&
        h.paragraphIndex == event.paragraphIndex);

    List<Highlight> newHighlights;
    if (existingIndex >= 0) {
      newHighlights = List.of(state.highlights)..removeAt(existingIndex);
    } else {
      newHighlights = [
        ...state.highlights,
        Highlight(
          chapterIndex: state.currentChapter,
          paragraphIndex: event.paragraphIndex,
        ),
      ];
    }

    emit(state.copyWith(highlights: newHighlights));
    await storageService.saveHighlights(state.textId, newHighlights);
  }
}
