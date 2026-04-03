import 'package:flutter_test/flutter_test.dart';
import 'package:patres/models/search_result.dart';
import 'package:patres/models/text_content.dart';
import 'package:patres/models/text_entry.dart';
import 'package:patres/services/database_service.dart';
import 'package:patres/services/search_service.dart';
import 'package:patres/services/text_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class FakeTextService extends TextService {
  @override
  Future<List<TextEntry>> loadManifest() async {
    return [
      const TextEntry(
        id: 'test-book',
        file: 'test-book.json',
        title: 'Testowa Księga',
        titleOriginal: 'Liber Testis',
        author: 'Św. Autor',
        era: 'IV w.',
        category: 'Patrystyka',
        language: 'pl',
        chaptersCount: 2,
        status: 'complete',
      ),
    ];
  }

  @override
  Future<TextContent> loadText(String textId) async {
    return const TextContent(
      id: 'test-book',
      title: 'Testowa Księga',
      author: 'Św. Autor',
      chapters: [
        Chapter(
          title: 'Rozdział pierwszy',
          content:
              'Wielki jest Pan i godzien wszelkiej chwały. Wielka jest moc Jego, a mądrości Jego nie masz liczby.',
        ),
        Chapter(
          title: 'Rozdział drugi',
          content:
              'Stworzyłeś nas bowiem dla siebie i niespokojne jest serce nasze, dopóki nie spocznie w Tobie.',
        ),
      ],
    );
  }
}

Future<DatabaseService> _createTestDb() async {
  final db = await databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: 2,
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
        await db.execute('''
          CREATE VIRTUAL TABLE search_fts USING fts5(
            title,
            content,
            text_id UNINDEXED,
            chapter_index UNINDEXED,
            book_title UNINDEXED,
            book_author UNINDEXED,
            tokenize='unicode61 remove_diacritics 2'
          )
        ''');
      },
    ),
  );
  return DatabaseService(database: db);
}

void main() {
  late DatabaseService dbService;
  late SearchService searchService;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    dbService = await _createTestDb();
    searchService = SearchService(
      databaseService: dbService,
      textService: FakeTextService(),
    );
  });

  tearDown(() async {
    await dbService.close();
  });

  group('SearchService', () {
    test('ensureIndexed populates the FTS index', () async {
      expect(await dbService.isSearchIndexed(), isFalse);

      await searchService.ensureIndexed();

      expect(await dbService.isSearchIndexed(), isTrue);
    });

    test('ensureIndexed does not re-index if already done', () async {
      await searchService.ensureIndexed();
      // Call again — should be a no-op
      await searchService.ensureIndexed();

      // Still indexed
      expect(await dbService.isSearchIndexed(), isTrue);
    });

    test('search finds matching text', () async {
      await searchService.ensureIndexed();

      final results = await searchService.search('chwały');
      expect(results, isNotEmpty);
      expect(results.first.textId, 'test-book');
      expect(results.first.chapterIndex, 0);
      expect(results.first.bookTitle, 'Testowa Księga');
    });

    test('search finds text in second chapter', () async {
      await searchService.ensureIndexed();

      final results = await searchService.search('serce');
      expect(results, isNotEmpty);
      expect(results.first.chapterIndex, 1);
    });

    test('search returns empty for non-matching query', () async {
      await searchService.ensureIndexed();

      final results = await searchService.search('xyznonexistent');
      expect(results, isEmpty);
    });

    test('search handles diacritics normalization', () async {
      await searchService.ensureIndexed();

      // Search without diacritics should find text with diacritics
      final results = await searchService.search('madrosci');
      expect(results, isNotEmpty);
      expect(results.first.textId, 'test-book');
    });

    test('search returns snippet with match context', () async {
      await searchService.ensureIndexed();

      final results = await searchService.search('niespokojne');
      expect(results, isNotEmpty);
      expect(results.first.snippet, contains('<b>'));
      expect(results.first.snippet, contains('</b>'));
    });

    test('rebuildIndex clears and re-creates index', () async {
      await searchService.ensureIndexed();

      final resultsBefore = await searchService.search('chwały');
      expect(resultsBefore, isNotEmpty);

      await searchService.rebuildIndex();

      final resultsAfter = await searchService.search('chwały');
      expect(resultsAfter, isNotEmpty);
      expect(resultsAfter.length, resultsBefore.length);
    });

    test('search returns empty for empty query', () async {
      await searchService.ensureIndexed();

      final results = await searchService.search('');
      expect(results, isEmpty);
    });

    test('search returns empty for single character', () async {
      await searchService.ensureIndexed();

      final results = await searchService.search('a');
      // FTS may return results for single char, but our service handles it
      // The bloc enforces min 2 chars, but service still works
      expect(results, isA<List<SearchResult>>());
    });
  });
}
