import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patres/blocs/reader_bloc.dart';
import 'package:patres/blocs/reader_event.dart';
import 'package:patres/blocs/reader_state.dart';
import 'package:patres/models/bookmark.dart';
import 'package:patres/models/highlight.dart';
import 'package:patres/models/text_content.dart';
import 'package:patres/services/database_service.dart';
import 'package:patres/services/reader_storage_service.dart';
import 'package:patres/services/text_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Fakes ---

class FakeTextService extends TextService {
  @override
  Future<TextContent> loadText(String textId) async {
    return TextContent(
      id: textId,
      title: 'Wyznania',
      author: 'Św. Augustyn',
      chapters: const [
        Chapter(title: 'Księga I', content: 'Para 1\n\nPara 2\n\nPara 3'),
        Chapter(title: 'Księga II', content: 'Treść drugiego rozdziału'),
        Chapter(title: 'Księga III', content: 'Treść trzeciego rozdziału'),
      ],
    );
  }
}

class FakeTextServiceThrowing extends TextService {
  @override
  Future<TextContent> loadText(String textId) async {
    throw Exception('File not found');
  }
}

/// In-memory fake that mirrors the DatabaseService API used by
/// ReaderStorageService, without requiring a real SQLite database.
class FakeDatabaseService extends DatabaseService {
  final Map<String, double> _scrollPositions = {};
  final Map<String, int> _lastChapters = {};
  final Map<String, List<Bookmark>> _bookmarks = {};
  final Map<String, List<Highlight>> _highlights = {};
  int _nextBookmarkId = 1;
  int _nextHighlightId = 1;

  FakeDatabaseService() : super(database: null);

  @override
  Future<int> getLastChapter(String textId) async =>
      _lastChapters[textId] ?? 0;

  @override
  Future<void> saveLastChapter(String textId, int chapter) async {
    _lastChapters[textId] = chapter;
  }

  @override
  Future<double> getScrollPosition(String textId, int chapter) async =>
      _scrollPositions['${textId}_$chapter'] ?? 0.0;

  @override
  Future<void> saveScrollPosition(
      String textId, int chapter, double position) async {
    _scrollPositions['${textId}_$chapter'] = position;
  }

  @override
  Future<List<Bookmark>> getBookmarks(String textId) async =>
      List.of(_bookmarks[textId] ?? []);

  @override
  Future<int> insertBookmark(Bookmark bookmark) async {
    final id = _nextBookmarkId++;
    final saved = bookmark.copyWith(id: id);
    _bookmarks.putIfAbsent(bookmark.textId, () => []).add(saved);
    return id;
  }

  @override
  Future<void> deleteBookmark(int id) async {
    for (final list in _bookmarks.values) {
      list.removeWhere((b) => b.id == id);
    }
  }

  @override
  Future<void> deleteBookmarkByChapter(
      String textId, int chapterIndex) async {
    _bookmarks[textId]?.removeWhere((b) => b.chapterIndex == chapterIndex);
  }

  @override
  Future<List<Highlight>> getHighlights(String textId) async =>
      List.of(_highlights[textId] ?? []);

  @override
  Future<void> insertHighlight(Highlight highlight) async {
    final id = _nextHighlightId++;
    final saved = highlight.copyWith(id: id);
    _highlights.putIfAbsent(highlight.textId, () => []).add(saved);
  }

  @override
  Future<void> deleteHighlight(
      String textId, int chapterIndex, int paragraphIndex) async {
    _highlights[textId]?.removeWhere((h) =>
        h.chapterIndex == chapterIndex &&
        h.paragraphIndex == paragraphIndex);
  }
}

// --- Tests ---

void main() {
  late FakeTextService textService;
  late FakeDatabaseService fakeDatabaseService;
  late ReaderStorageService storageService;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    textService = FakeTextService();
    fakeDatabaseService = FakeDatabaseService();
    storageService = ReaderStorageService(
      databaseService: fakeDatabaseService,
    );
  });

  ReaderBloc buildBloc() => ReaderBloc(
        textService: textService,
        storageService: storageService,
      );

  group('ReaderBloc', () {
    group('ReaderLoadRequested', () {
      blocTest<ReaderBloc, ReaderState>(
        'emits [loading, loaded] with text content',
        build: buildBloc,
        act: (bloc) =>
            bloc.add(const ReaderLoadRequested(textId: 'augustyn')),
        expect: () => [
          isA<ReaderState>()
              .having((s) => s.status, 'status', ReaderStatus.loading)
              .having((s) => s.textId, 'textId', 'augustyn'),
          isA<ReaderState>()
              .having((s) => s.status, 'status', ReaderStatus.loaded)
              .having((s) => s.textContent?.title, 'title', 'Wyznania')
              .having((s) => s.textContent?.chapters.length, 'chapters', 3)
              .having((s) => s.currentChapter, 'chapter', 0)
              .having((s) => s.fontSizeIndex, 'fontSize', 1)
              .having((s) => s.fontFamily, 'fontFamily', 'Lora'),
        ],
      );

      blocTest<ReaderBloc, ReaderState>(
        'restores saved chapter and font settings',
        setUp: () async {
          await fakeDatabaseService.saveLastChapter('augustyn', 2);
          await storageService.saveFontSizeIndex(3);
          await storageService.saveFontFamily('Merriweather');
        },
        build: buildBloc,
        act: (bloc) =>
            bloc.add(const ReaderLoadRequested(textId: 'augustyn')),
        expect: () => [
          isA<ReaderState>()
              .having((s) => s.status, 'status', ReaderStatus.loading),
          isA<ReaderState>()
              .having((s) => s.status, 'status', ReaderStatus.loaded)
              .having((s) => s.currentChapter, 'chapter', 2)
              .having((s) => s.fontSizeIndex, 'fontSize', 3)
              .having((s) => s.fontFamily, 'fontFamily', 'Merriweather'),
        ],
      );

      blocTest<ReaderBloc, ReaderState>(
        'emits error when loading fails',
        build: () => ReaderBloc(
          textService: FakeTextServiceThrowing(),
          storageService: storageService,
        ),
        act: (bloc) =>
            bloc.add(const ReaderLoadRequested(textId: 'bad-id')),
        expect: () => [
          isA<ReaderState>()
              .having((s) => s.status, 'status', ReaderStatus.loading),
          isA<ReaderState>()
              .having((s) => s.status, 'status', ReaderStatus.error)
              .having(
                  (s) => s.errorMessage, 'error', contains('File not found')),
        ],
      );
    });

    group('ReaderChapterChanged', () {
      blocTest<ReaderBloc, ReaderState>(
        'changes to requested chapter and saves',
        build: buildBloc,
        seed: () => ReaderState(
          status: ReaderStatus.loaded,
          textId: 'augustyn',
          textContent: TextContent(
            id: 'augustyn',
            title: 'Wyznania',
            author: 'Św. Augustyn',
            chapters: const [
              Chapter(title: 'I', content: 'a'),
              Chapter(title: 'II', content: 'b'),
            ],
          ),
        ),
        act: (bloc) =>
            bloc.add(const ReaderChapterChanged(chapterIndex: 1)),
        expect: () => [
          isA<ReaderState>()
              .having((s) => s.currentChapter, 'chapter', 1)
              .having((s) => s.scrollPosition, 'scroll', 0.0),
        ],
        verify: (_) async {
          expect(
              await fakeDatabaseService.getLastChapter('augustyn'), equals(1));
        },
      );
    });

    group('ReaderFontSizeChanged', () {
      blocTest<ReaderBloc, ReaderState>(
        'updates font size index and persists',
        build: buildBloc,
        seed: () => const ReaderState(status: ReaderStatus.loaded),
        act: (bloc) =>
            bloc.add(const ReaderFontSizeChanged(fontSizeIndex: 4)),
        expect: () => [
          isA<ReaderState>().having((s) => s.fontSizeIndex, 'size', 4),
        ],
        verify: (_) async {
          expect(await storageService.getFontSizeIndex(), equals(4));
        },
      );
    });

    group('ReaderFontFamilyChanged', () {
      blocTest<ReaderBloc, ReaderState>(
        'updates font family and persists',
        build: buildBloc,
        seed: () => const ReaderState(status: ReaderStatus.loaded),
        act: (bloc) => bloc.add(
            const ReaderFontFamilyChanged(fontFamily: 'Merriweather')),
        expect: () => [
          isA<ReaderState>()
              .having((s) => s.fontFamily, 'font', 'Merriweather'),
        ],
        verify: (_) async {
          expect(await storageService.getFontFamily(),
              equals('Merriweather'));
        },
      );
    });

    group('ReaderBookmarkToggled', () {
      blocTest<ReaderBloc, ReaderState>(
        'adds bookmark to current chapter',
        build: buildBloc,
        seed: () => const ReaderState(
          status: ReaderStatus.loaded,
          textId: 'augustyn',
          currentChapter: 1,
        ),
        act: (bloc) => bloc.add(const ReaderBookmarkToggled(
          note: 'Great passage',
          scrollPosition: 150.0,
        )),
        expect: () => [
          isA<ReaderState>()
              .having((s) => s.bookmarks.length, 'count', 1)
              .having((s) => s.bookmarks.first.chapterIndex, 'ch', 1)
              .having((s) => s.bookmarks.first.note, 'note', 'Great passage')
              .having(
                  (s) => s.bookmarks.first.scrollPosition, 'scroll', 150.0)
              .having((s) => s.bookmarks.first.id, 'id', isNotNull),
        ],
      );

      blocTest<ReaderBloc, ReaderState>(
        'removes bookmark when toggled on existing chapter',
        build: buildBloc,
        seed: () => ReaderState(
          status: ReaderStatus.loaded,
          textId: 'augustyn',
          currentChapter: 0,
          bookmarks: [
            Bookmark(
              id: 1,
              textId: 'augustyn',
              chapterIndex: 0,
              timestamp: DateTime(2026, 1, 1),
            ),
          ],
        ),
        act: (bloc) => bloc.add(const ReaderBookmarkToggled()),
        expect: () => [
          isA<ReaderState>()
              .having((s) => s.bookmarks.length, 'count', 0),
        ],
      );
    });

    group('ReaderBookmarkRemoved', () {
      blocTest<ReaderBloc, ReaderState>(
        'removes bookmark at given index',
        build: buildBloc,
        seed: () => ReaderState(
          status: ReaderStatus.loaded,
          textId: 'augustyn',
          bookmarks: [
            Bookmark(
                id: 1,
                textId: 'augustyn',
                chapterIndex: 0,
                timestamp: DateTime(2026, 1, 1)),
            Bookmark(
                id: 2,
                textId: 'augustyn',
                chapterIndex: 2,
                timestamp: DateTime(2026, 1, 2)),
          ],
        ),
        act: (bloc) =>
            bloc.add(const ReaderBookmarkRemoved(index: 0)),
        expect: () => [
          isA<ReaderState>()
              .having((s) => s.bookmarks.length, 'count', 1)
              .having((s) => s.bookmarks.first.chapterIndex, 'ch', 2),
        ],
      );
    });

    group('ReaderHighlightToggled', () {
      blocTest<ReaderBloc, ReaderState>(
        'adds highlight for paragraph in current chapter',
        build: buildBloc,
        seed: () => const ReaderState(
          status: ReaderStatus.loaded,
          textId: 'augustyn',
          currentChapter: 0,
        ),
        act: (bloc) =>
            bloc.add(const ReaderHighlightToggled(paragraphIndex: 2)),
        expect: () => [
          isA<ReaderState>()
              .having((s) => s.highlights.length, 'count', 1)
              .having((s) => s.highlights.first.chapterIndex, 'ch', 0)
              .having((s) => s.highlights.first.paragraphIndex, 'para', 2)
              .having((s) => s.highlights.first.id, 'id', isNotNull),
        ],
      );

      blocTest<ReaderBloc, ReaderState>(
        'removes highlight when toggled on existing paragraph',
        build: buildBloc,
        seed: () => const ReaderState(
          status: ReaderStatus.loaded,
          textId: 'augustyn',
          currentChapter: 0,
          highlights: [
            Highlight(
                id: 1,
                textId: 'augustyn',
                chapterIndex: 0,
                paragraphIndex: 2),
          ],
        ),
        act: (bloc) =>
            bloc.add(const ReaderHighlightToggled(paragraphIndex: 2)),
        expect: () => [
          isA<ReaderState>()
              .having((s) => s.highlights.length, 'count', 0),
        ],
      );
    });

    group('ReaderScrollPositionSaved', () {
      blocTest<ReaderBloc, ReaderState>(
        'persists scroll position without emitting state change',
        build: buildBloc,
        seed: () => const ReaderState(
          status: ReaderStatus.loaded,
          textId: 'augustyn',
          currentChapter: 1,
        ),
        act: (bloc) => bloc
            .add(const ReaderScrollPositionSaved(position: 200.0)),
        expect: () => const <ReaderState>[],
        verify: (_) async {
          expect(
              await fakeDatabaseService.getScrollPosition('augustyn', 1),
              equals(200.0));
        },
      );
    });
  });
}
