import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:patres/models/bookmark.dart';
import 'package:patres/models/highlight.dart';

/// SQLite database service for offline storage of reading progress,
/// bookmarks, and highlights.
class DatabaseService {
  DatabaseService({Database? database}) : _database = database;

  static const _databaseName = 'patres.db';
  static const _databaseVersion = 1;

  Database? _database;

  Future<Database> get database async {
    return _database ??= await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
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

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
