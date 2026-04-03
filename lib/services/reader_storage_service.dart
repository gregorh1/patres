import 'package:shared_preferences/shared_preferences.dart';

import 'package:patres/models/bookmark.dart';
import 'package:patres/models/highlight.dart';
import 'package:patres/services/database_service.dart';

/// Persists reader preferences (SharedPreferences) and reading data (SQLite).
class ReaderStorageService {
  ReaderStorageService({
    SharedPreferences? prefs,
    required this.databaseService,
  }) : _prefs = prefs;

  SharedPreferences? _prefs;
  final DatabaseService databaseService;

  Future<SharedPreferences> get _preferences async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  // --- Font settings (SharedPreferences) ---

  Future<int> getFontSizeIndex() async {
    final prefs = await _preferences;
    return prefs.getInt('reader_font_size') ?? 1;
  }

  Future<void> saveFontSizeIndex(int index) async {
    final prefs = await _preferences;
    await prefs.setInt('reader_font_size', index);
  }

  Future<String> getFontFamily() async {
    final prefs = await _preferences;
    return prefs.getString('reader_font_family') ?? 'Lora';
  }

  Future<void> saveFontFamily(String family) async {
    final prefs = await _preferences;
    await prefs.setString('reader_font_family', family);
  }

  // --- Reading progress (SQLite) ---

  Future<double> getScrollPosition(String textId, int chapter) async {
    return databaseService.getScrollPosition(textId, chapter);
  }

  Future<void> saveScrollPosition(
      String textId, int chapter, double position) async {
    await databaseService.saveScrollPosition(textId, chapter, position);
  }

  Future<int> getLastChapter(String textId) async {
    return databaseService.getLastChapter(textId);
  }

  Future<void> saveLastChapter(String textId, int chapter) async {
    await databaseService.saveLastChapter(textId, chapter);
  }

  // --- Bookmarks (SQLite) ---

  Future<List<Bookmark>> getBookmarks(String textId) async {
    return databaseService.getBookmarks(textId);
  }

  Future<void> saveBookmarks(String textId, List<Bookmark> bookmarks) async {
    // This method kept for backward compatibility with ReaderBloc.
    // Individual insert/delete operations are preferred.
  }

  Future<int> insertBookmark(Bookmark bookmark) async {
    return databaseService.insertBookmark(bookmark);
  }

  Future<void> deleteBookmark(int id) async {
    await databaseService.deleteBookmark(id);
  }

  Future<void> deleteBookmarkByChapter(String textId, int chapterIndex) async {
    await databaseService.deleteBookmarkByChapter(textId, chapterIndex);
  }

  // --- Highlights (SQLite) ---

  Future<List<Highlight>> getHighlights(String textId) async {
    return databaseService.getHighlights(textId);
  }

  Future<void> saveHighlights(
      String textId, List<Highlight> highlights) async {
    // This method kept for backward compatibility with ReaderBloc.
    // Individual insert/delete operations are preferred.
  }

  Future<void> insertHighlight(Highlight highlight) async {
    await databaseService.insertHighlight(highlight);
  }

  Future<void> deleteHighlight(
      String textId, int chapterIndex, int paragraphIndex) async {
    await databaseService.deleteHighlight(textId, chapterIndex, paragraphIndex);
  }
}
