import 'package:flutter_test/flutter_test.dart';
import 'package:patres/models/bookmark.dart';
import 'package:patres/models/highlight.dart';
import 'package:patres/services/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late DatabaseService dbService;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
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
        },
      ),
    );
    dbService = DatabaseService(database: db);
  });

  tearDown(() async {
    await dbService.close();
  });

  group('DatabaseService', () {
    group('reading progress', () {
      test('returns 0 for unknown text', () async {
        expect(await dbService.getLastChapter('unknown'), 0);
      });

      test('saves and retrieves last chapter', () async {
        await dbService.saveLastChapter('augustyn', 5);
        expect(await dbService.getLastChapter('augustyn'), 5);
      });

      test('overwrites last chapter on update', () async {
        await dbService.saveLastChapter('augustyn', 3);
        await dbService.saveLastChapter('augustyn', 7);
        expect(await dbService.getLastChapter('augustyn'), 7);
      });
    });

    group('scroll positions', () {
      test('returns 0.0 for unknown position', () async {
        expect(await dbService.getScrollPosition('unknown', 0), 0.0);
      });

      test('saves and retrieves scroll position', () async {
        await dbService.saveScrollPosition('augustyn', 2, 350.5);
        expect(await dbService.getScrollPosition('augustyn', 2), 350.5);
      });

      test('overwrites scroll position on update', () async {
        await dbService.saveScrollPosition('augustyn', 0, 100.0);
        await dbService.saveScrollPosition('augustyn', 0, 200.0);
        expect(await dbService.getScrollPosition('augustyn', 0), 200.0);
      });

      test('keeps separate positions per chapter', () async {
        await dbService.saveScrollPosition('augustyn', 0, 100.0);
        await dbService.saveScrollPosition('augustyn', 1, 200.0);
        expect(await dbService.getScrollPosition('augustyn', 0), 100.0);
        expect(await dbService.getScrollPosition('augustyn', 1), 200.0);
      });
    });

    group('bookmarks', () {
      test('returns empty list for unknown text', () async {
        expect(await dbService.getBookmarks('unknown'), isEmpty);
      });

      test('inserts and retrieves bookmark', () async {
        final bookmark = Bookmark(
          textId: 'augustyn',
          chapterIndex: 3,
          timestamp: DateTime.utc(2026, 4, 3),
          note: 'Great passage',
          scrollPosition: 150.0,
        );
        final id = await dbService.insertBookmark(bookmark);
        expect(id, greaterThan(0));

        final bookmarks = await dbService.getBookmarks('augustyn');
        expect(bookmarks.length, 1);
        expect(bookmarks.first.id, id);
        expect(bookmarks.first.textId, 'augustyn');
        expect(bookmarks.first.chapterIndex, 3);
        expect(bookmarks.first.note, 'Great passage');
        expect(bookmarks.first.scrollPosition, 150.0);
      });

      test('deletes bookmark by id', () async {
        final id = await dbService.insertBookmark(Bookmark(
          textId: 'augustyn',
          chapterIndex: 0,
          timestamp: DateTime.utc(2026, 1, 1),
        ));
        await dbService.deleteBookmark(id);
        expect(await dbService.getBookmarks('augustyn'), isEmpty);
      });

      test('deletes bookmark by chapter', () async {
        await dbService.insertBookmark(Bookmark(
          textId: 'augustyn',
          chapterIndex: 2,
          timestamp: DateTime.utc(2026, 1, 1),
        ));
        await dbService.insertBookmark(Bookmark(
          textId: 'augustyn',
          chapterIndex: 5,
          timestamp: DateTime.utc(2026, 1, 2),
        ));

        await dbService.deleteBookmarkByChapter('augustyn', 2);

        final bookmarks = await dbService.getBookmarks('augustyn');
        expect(bookmarks.length, 1);
        expect(bookmarks.first.chapterIndex, 5);
      });
    });

    group('highlights', () {
      test('returns empty list for unknown text', () async {
        expect(await dbService.getHighlights('unknown'), isEmpty);
      });

      test('inserts and retrieves highlight', () async {
        const highlight = Highlight(
          textId: 'augustyn',
          chapterIndex: 1,
          paragraphIndex: 4,
        );
        await dbService.insertHighlight(highlight);

        final highlights = await dbService.getHighlights('augustyn');
        expect(highlights.length, 1);
        expect(highlights.first.textId, 'augustyn');
        expect(highlights.first.chapterIndex, 1);
        expect(highlights.first.paragraphIndex, 4);
        expect(highlights.first.id, isNotNull);
      });

      test('ignores duplicate highlights', () async {
        const highlight = Highlight(
          textId: 'augustyn',
          chapterIndex: 1,
          paragraphIndex: 4,
        );
        await dbService.insertHighlight(highlight);
        await dbService.insertHighlight(highlight);

        final highlights = await dbService.getHighlights('augustyn');
        expect(highlights.length, 1);
      });

      test('deletes highlight by composite key', () async {
        await dbService.insertHighlight(const Highlight(
          textId: 'augustyn',
          chapterIndex: 0,
          paragraphIndex: 2,
        ));
        await dbService.insertHighlight(const Highlight(
          textId: 'augustyn',
          chapterIndex: 0,
          paragraphIndex: 5,
        ));

        await dbService.deleteHighlight('augustyn', 0, 2);

        final highlights = await dbService.getHighlights('augustyn');
        expect(highlights.length, 1);
        expect(highlights.first.paragraphIndex, 5);
      });
    });
  });
}
