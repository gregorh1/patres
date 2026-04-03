import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:patres/models/bookmark.dart';
import 'package:patres/models/highlight.dart';
import 'package:patres/models/search_result.dart';

/// Thrown when FTS5 full-text search is not available on this device.
class SearchUnavailableException implements Exception {
  const SearchUnavailableException();

  @override
  String toString() => 'SearchUnavailableException: FTS5 is not available';
}

/// SQLite database service for offline storage of reading progress,
/// bookmarks, highlights, and full-text search index.
class DatabaseService {
  DatabaseService({Database? database}) : _database = database;

  /// Creates a service with FTS marked as unavailable. Used for testing.
  DatabaseService.withFtsUnavailable({Database? database})
      : _database = database,
        _ftsAvailable = false;

  static const _databaseName = 'patres.db';
  static const _databaseVersion = 2;

  Database? _database;
  bool _ftsAvailable = true;

  /// Whether FTS5 full-text search tables were created successfully.
  bool get isFtsAvailable => _ftsAvailable;

  Future<Database> get database async {
    return _database ??= await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, _databaseName);
    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE reading_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text_id TEXT NOT NULL,
        last_chapter INTEGER NOT NULL DEFAULT 0,
        updated_at TEXT NOT NULL,
        UNIQUE(text_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE scroll_positions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text_id TEXT NOT NULL,
        chapter_index INTEGER NOT NULL,
        position REAL NOT NULL DEFAULT 0.0,
        UNIQUE(text_id, chapter_index)
      )
    ''');

    await db.execute('''
      CREATE TABLE bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text_id TEXT NOT NULL,
        chapter_index INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        note TEXT,
        scroll_position REAL NOT NULL DEFAULT 0.0
      )
    ''');

    await db.execute('''
      CREATE TABLE highlights (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text_id TEXT NOT NULL,
        chapter_index INTEGER NOT NULL,
        paragraph_index INTEGER NOT NULL,
        UNIQUE(text_id, chapter_index, paragraph_index)
      )
    ''');

    await db.execute(
        'CREATE INDEX idx_bookmarks_text ON bookmarks(text_id)');
    await db.execute(
        'CREATE INDEX idx_highlights_text ON highlights(text_id)');
    await db.execute(
        'CREATE INDEX idx_reading_progress_text ON reading_progress(text_id)');

    await _createSearchTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createSearchTables(db);
    }
  }

  Future<void> _createSearchTables(Database db) async {
    try {
      await db.execute('''
        CREATE VIRTUAL TABLE IF NOT EXISTS search_fts USING fts5(
          title,
          content,
          text_id UNINDEXED,
          chapter_index UNINDEXED,
          book_title UNINDEXED,
          book_author UNINDEXED,
          tokenize='unicode61 remove_diacritics 2'
        )
      ''');
    } catch (_) {
      _ftsAvailable = false;
    }
  }

  // --- Reading Progress ---

  Future<int> getLastChapter(String textId) async {
    final db = await database;
    final result = await db.query(
      'reading_progress',
      columns: ['last_chapter'],
      where: 'text_id = ?',
      whereArgs: [textId],
    );
    if (result.isEmpty) return 0;
    return result.first['last_chapter'] as int;
  }

  Future<void> saveLastChapter(String textId, int chapter) async {
    final db = await database;
    await db.insert(
      'reading_progress',
      {
        'text_id': textId,
        'last_chapter': chapter,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // --- Scroll Positions ---

  Future<double> getScrollPosition(String textId, int chapter) async {
    final db = await database;
    final result = await db.query(
      'scroll_positions',
      columns: ['position'],
      where: 'text_id = ? AND chapter_index = ?',
      whereArgs: [textId, chapter],
    );
    if (result.isEmpty) return 0.0;
    return (result.first['position'] as num).toDouble();
  }

  Future<void> saveScrollPosition(
      String textId, int chapter, double position) async {
    final db = await database;
    await db.insert(
      'scroll_positions',
      {
        'text_id': textId,
        'chapter_index': chapter,
        'position': position,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // --- Bookmarks ---

  Future<List<Bookmark>> getBookmarks(String textId) async {
    final db = await database;
    final result = await db.query(
      'bookmarks',
      where: 'text_id = ?',
      whereArgs: [textId],
      orderBy: 'timestamp DESC',
    );
    return result
        .map((row) => Bookmark(
              id: row['id'] as int,
              textId: row['text_id'] as String,
              chapterIndex: row['chapter_index'] as int,
              timestamp: DateTime.parse(row['timestamp'] as String),
              note: row['note'] as String?,
              scrollPosition:
                  (row['scroll_position'] as num?)?.toDouble() ?? 0.0,
            ))
        .toList();
  }

  Future<int> insertBookmark(Bookmark bookmark) async {
    final db = await database;
    return db.insert('bookmarks', {
      'text_id': bookmark.textId,
      'chapter_index': bookmark.chapterIndex,
      'timestamp': bookmark.timestamp.toIso8601String(),
      'note': bookmark.note,
      'scroll_position': bookmark.scrollPosition,
    });
  }

  Future<void> deleteBookmark(int id) async {
    final db = await database;
    await db.delete('bookmarks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteBookmarkByChapter(String textId, int chapterIndex) async {
    final db = await database;
    await db.delete(
      'bookmarks',
      where: 'text_id = ? AND chapter_index = ?',
      whereArgs: [textId, chapterIndex],
    );
  }

  // --- Highlights ---

  Future<List<Highlight>> getHighlights(String textId) async {
    final db = await database;
    final result = await db.query(
      'highlights',
      where: 'text_id = ?',
      whereArgs: [textId],
    );
    return result
        .map((row) => Highlight(
              id: row['id'] as int,
              textId: row['text_id'] as String,
              chapterIndex: row['chapter_index'] as int,
              paragraphIndex: row['paragraph_index'] as int,
            ))
        .toList();
  }

  Future<void> insertHighlight(Highlight highlight) async {
    final db = await database;
    await db.insert(
      'highlights',
      {
        'text_id': highlight.textId,
        'chapter_index': highlight.chapterIndex,
        'paragraph_index': highlight.paragraphIndex,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> deleteHighlight(
      String textId, int chapterIndex, int paragraphIndex) async {
    final db = await database;
    await db.delete(
      'highlights',
      where: 'text_id = ? AND chapter_index = ? AND paragraph_index = ?',
      whereArgs: [textId, chapterIndex, paragraphIndex],
    );
  }

  // --- Full-Text Search ---

  void _ensureFtsAvailable() {
    if (!_ftsAvailable) throw const SearchUnavailableException();
  }

  Future<bool> isSearchIndexed() async {
    final db = await database;
    _ensureFtsAvailable();
    final result = await db.rawQuery('SELECT COUNT(*) as cnt FROM search_fts');
    final count = result.first['cnt'] as int;
    return count > 0;
  }

  Future<void> clearSearchIndex() async {
    final db = await database;
    _ensureFtsAvailable();
    await db.execute("DELETE FROM search_fts");
  }

  Future<void> insertSearchEntry({
    required String textId,
    required int chapterIndex,
    required String chapterTitle,
    required String bookTitle,
    required String bookAuthor,
    required String content,
  }) async {
    final db = await database;
    _ensureFtsAvailable();
    await db.insert('search_fts', {
      'title': chapterTitle,
      'content': content,
      'text_id': textId,
      'chapter_index': chapterIndex,
      'book_title': bookTitle,
      'book_author': bookAuthor,
    });
  }

  Future<List<SearchResult>> search(String query, {int limit = 50}) async {
    if (query.trim().isEmpty) return [];

    final db = await database;
    _ensureFtsAvailable();

    // Escape FTS5 special characters and build query
    final escaped = _escapeFtsQuery(query.trim());

    final results = await db.rawQuery('''
      SELECT
        text_id,
        book_title,
        book_author,
        chapter_index,
        title,
        snippet(search_fts, 1, '<b>', '</b>', '…', 40) as snippet
      FROM search_fts
      WHERE search_fts MATCH ?
      ORDER BY rank
      LIMIT ?
    ''', [escaped, limit]);

    return results
        .map((row) => SearchResult(
              textId: row['text_id'] as String,
              bookTitle: row['book_title'] as String,
              bookAuthor: row['book_author'] as String,
              chapterIndex: row['chapter_index'] as int,
              chapterTitle: row['title'] as String,
              snippet: row['snippet'] as String,
            ))
        .toList();
  }

  /// Escapes special FTS5 characters and wraps each term with * for prefix matching.
  String _escapeFtsQuery(String query) {
    // Remove FTS5 operators and special chars
    final cleaned =
        query.replaceAll(RegExp(r'["\*\(\)\-\+\^]'), ' ').trim();
    if (cleaned.isEmpty) return '""';

    final terms = cleaned.split(RegExp(r'\s+'));
    // Use prefix matching for each term
    return terms.map((t) => '"$t" *').join(' ');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
