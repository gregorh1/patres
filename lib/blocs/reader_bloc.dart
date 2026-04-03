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
    on<ReaderLanguageSwitchRequested>(_onLanguageSwitchRequested);
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
      final savedChapter = await storageService.getLastChapter(event.textId);
      final chapter = (event.initialChapter ?? savedChapter)
          .clamp(0, textContent.chapters.length - 1);
      final scrollPosition =
          await storageService.getScrollPosition(event.textId, chapter);
      final bookmarks = await storageService.getBookmarks(event.textId);
      final highlights = await storageService.getHighlights(event.textId);

      // Find alternate language versions by matching titleOriginal
      final alternateLanguageIds = await _findAlternateLanguages(
          event.textId, textContent.titleOriginal);

      emit(state.copyWith(
        status: ReaderStatus.loaded,
        textContent: textContent,
        currentChapter: chapter,
        fontSizeIndex: fontSizeIndex,
        fontFamily: fontFamily,
        scrollPosition: scrollPosition,
        bookmarks: bookmarks,
        highlights: highlights,
        alternateLanguageIds: alternateLanguageIds,
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

    if (existingIndex >= 0) {
      final existing = state.bookmarks[existingIndex];
      await storageService.deleteBookmarkByChapter(
          state.textId, state.currentChapter);
      final newBookmarks = List.of(state.bookmarks)..removeAt(existingIndex);
      emit(state.copyWith(bookmarks: newBookmarks));
    } else {
      final bookmark = Bookmark(
        textId: state.textId,
        chapterIndex: state.currentChapter,
        timestamp: DateTime.now(),
        note: event.note,
        scrollPosition: event.scrollPosition,
      );
      final id = await storageService.insertBookmark(bookmark);
      final newBookmarks = [
        ...state.bookmarks,
        bookmark.copyWith(id: id),
      ];
      emit(state.copyWith(bookmarks: newBookmarks));
    }
  }

  Future<void> _onBookmarkRemoved(
    ReaderBookmarkRemoved event,
    Emitter<ReaderState> emit,
  ) async {
    final bookmark = state.bookmarks[event.index];
    if (bookmark.id != null) {
      await storageService.deleteBookmark(bookmark.id!);
    }
    final newBookmarks = List.of(state.bookmarks)..removeAt(event.index);
    emit(state.copyWith(bookmarks: newBookmarks));
  }

  Future<void> _onHighlightToggled(
    ReaderHighlightToggled event,
    Emitter<ReaderState> emit,
  ) async {
    final existingIndex = state.highlights.indexWhere((h) =>
        h.chapterIndex == state.currentChapter &&
        h.paragraphIndex == event.paragraphIndex);

    if (existingIndex >= 0) {
      await storageService.deleteHighlight(
          state.textId, state.currentChapter, event.paragraphIndex);
      final newHighlights = List.of(state.highlights)
        ..removeAt(existingIndex);
      emit(state.copyWith(highlights: newHighlights));
    } else {
      final highlight = Highlight(
        textId: state.textId,
        chapterIndex: state.currentChapter,
        paragraphIndex: event.paragraphIndex,
      );
      await storageService.insertHighlight(highlight);
      // Re-fetch to get the id assigned by SQLite
      final highlights = await storageService.getHighlights(state.textId);
      emit(state.copyWith(highlights: highlights));
    }
  }

  Future<void> _onLanguageSwitchRequested(
    ReaderLanguageSwitchRequested event,
    Emitter<ReaderState> emit,
  ) async {
    // Reload with the alternate text ID
    add(ReaderLoadRequested(textId: event.targetTextId));
  }

  Future<Map<String, String>> _findAlternateLanguages(
      String currentId, String? titleOriginal) async {
    if (titleOriginal == null || titleOriginal.isEmpty) return {};
    try {
      final manifest = await textService.loadManifest();
      final alternates = <String, String>{};
      for (final entry in manifest) {
        if (entry.titleOriginal == titleOriginal) {
          alternates[entry.language] = entry.id;
        }
      }
      return alternates;
    } catch (_) {
      return {};
    }
  }
}
