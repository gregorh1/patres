import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:patres/models/bookmark.dart';
import 'package:patres/models/highlight.dart';

/// Persists reader preferences, scroll positions, bookmarks, and highlights.
class ReaderStorageService {
  ReaderStorageService({SharedPreferences? prefs}) : _prefs = prefs;

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  // Font settings

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

  // Scroll position

  Future<double> getScrollPosition(String textId, int chapter) async {
    final prefs = await _preferences;
    return prefs.getDouble('scroll_${textId}_$chapter') ?? 0.0;
  }

  Future<void> saveScrollPosition(
      String textId, int chapter, double position) async {
    final prefs = await _preferences;
    await prefs.setDouble('scroll_${textId}_$chapter', position);
  }

  // Last chapter

  Future<int> getLastChapter(String textId) async {
    final prefs = await _preferences;
    return prefs.getInt('last_chapter_$textId') ?? 0;
  }

  Future<void> saveLastChapter(String textId, int chapter) async {
    final prefs = await _preferences;
    await prefs.setInt('last_chapter_$textId', chapter);
  }

  // Bookmarks

  Future<List<Bookmark>> getBookmarks(String textId) async {
    final prefs = await _preferences;
    final raw = prefs.getString('bookmarks_$textId');
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Bookmark.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveBookmarks(String textId, List<Bookmark> bookmarks) async {
    final prefs = await _preferences;
    final raw = jsonEncode(bookmarks.map((b) => b.toJson()).toList());
    await prefs.setString('bookmarks_$textId', raw);
  }

  // Highlights

  Future<List<Highlight>> getHighlights(String textId) async {
    final prefs = await _preferences;
    final raw = prefs.getString('highlights_$textId');
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Highlight.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveHighlights(
      String textId, List<Highlight> highlights) async {
    final prefs = await _preferences;
    final raw = jsonEncode(highlights.map((h) => h.toJson()).toList());
    await prefs.setString('highlights_$textId', raw);
  }
}
