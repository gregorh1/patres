import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patres/blocs/search_bloc.dart';
import 'package:patres/models/search_result.dart';
import 'package:patres/services/database_service.dart';
import 'package:patres/services/search_service.dart';
import 'package:patres/services/text_service.dart';

// --- Fakes ---

class FakeSearchService extends SearchService {
  FakeSearchService()
      : super(
          databaseService: DatabaseService(database: null),
          textService: const TextService(),
        );

  bool indexCalled = false;
  bool shouldThrow = false;
  bool shouldThrowFtsUnavailable = false;

  @override
  Future<void> ensureIndexed() async {
    indexCalled = true;
    if (shouldThrowFtsUnavailable) throw const SearchUnavailableException();
    if (shouldThrow) throw Exception('Index failed');
  }

  @override
  Future<List<SearchResult>> search(String query, {int limit = 50}) async {
    if (shouldThrowFtsUnavailable) throw const SearchUnavailableException();
    if (shouldThrow) throw Exception('Search failed');
    if (query.contains('empty')) return [];
    return [
      SearchResult(
        textId: 'test',
        bookTitle: 'Test Book',
        bookAuthor: 'Author',
        chapterIndex: 0,
        chapterTitle: 'Chapter 1',
        snippet: 'text with <b>$query</b> match',
      ),
    ];
  }
}

void main() {
  group('SearchBloc', () {
    late FakeSearchService fakeService;

    setUp(() {
      fakeService = FakeSearchService();
    });

    test('initial state', () {
      final bloc = SearchBloc(searchService: fakeService);
      expect(bloc.state.status, SearchStatus.initial);
      expect(bloc.state.query, '');
      expect(bloc.state.results, isEmpty);
      bloc.close();
    });

    blocTest<SearchBloc, SearchState>(
      'SearchIndexRequested indexes and moves to ready',
      build: () => SearchBloc(searchService: fakeService),
      act: (bloc) => bloc.add(const SearchIndexRequested()),
      expect: () => [
        const SearchState(status: SearchStatus.indexing),
        const SearchState(status: SearchStatus.ready),
      ],
      verify: (_) {
        expect(fakeService.indexCalled, isTrue);
      },
    );

    blocTest<SearchBloc, SearchState>(
      'SearchIndexRequested emits error on failure',
      build: () {
        fakeService.shouldThrow = true;
        return SearchBloc(searchService: fakeService);
      },
      act: (bloc) => bloc.add(const SearchIndexRequested()),
      expect: () => [
        const SearchState(status: SearchStatus.indexing),
        isA<SearchState>()
            .having((s) => s.status, 'status', SearchStatus.error),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'SearchIndexRequested emits Polish error when FTS unavailable',
      build: () {
        fakeService.shouldThrowFtsUnavailable = true;
        return SearchBloc(searchService: fakeService);
      },
      act: (bloc) => bloc.add(const SearchIndexRequested()),
      expect: () => [
        const SearchState(status: SearchStatus.indexing),
        isA<SearchState>()
            .having((s) => s.status, 'status', SearchStatus.error)
            .having((s) => s.errorMessage, 'errorMessage',
                'Wyszukiwanie jest niedostępne na tym urządzeniu'),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'SearchQueryChanged emits Polish error when FTS unavailable',
      build: () {
        fakeService.shouldThrowFtsUnavailable = true;
        return SearchBloc(searchService: fakeService);
      },
      seed: () => const SearchState(status: SearchStatus.ready),
      act: (bloc) => bloc.add(const SearchQueryChanged('test query')),
      wait: const Duration(milliseconds: 500),
      expect: () => [
        const SearchState(status: SearchStatus.ready, query: 'test query'),
        const SearchState(
            status: SearchStatus.searching, query: 'test query'),
        isA<SearchState>()
            .having((s) => s.status, 'status', SearchStatus.error)
            .having((s) => s.errorMessage, 'errorMessage',
                'Wyszukiwanie jest niedostępne na tym urządzeniu'),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'SearchQueryChanged with short query resets to ready',
      build: () => SearchBloc(searchService: fakeService),
      seed: () => const SearchState(status: SearchStatus.ready),
      act: (bloc) => bloc.add(const SearchQueryChanged('a')),
      expect: () => [
        const SearchState(status: SearchStatus.ready, query: 'a'),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'SearchQueryChanged with valid query returns results',
      build: () => SearchBloc(searchService: fakeService),
      seed: () => const SearchState(status: SearchStatus.ready),
      act: (bloc) => bloc.add(const SearchQueryChanged('test')),
      wait: const Duration(milliseconds: 500),
      expect: () => [
        const SearchState(status: SearchStatus.ready, query: 'test'),
        const SearchState(status: SearchStatus.searching, query: 'test'),
        isA<SearchState>()
            .having((s) => s.status, 'status', SearchStatus.loaded)
            .having((s) => s.results.length, 'results count', 1)
            .having((s) => s.results.first.textId, 'textId', 'test'),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'SearchQueryChanged with no results shows empty',
      build: () => SearchBloc(searchService: fakeService),
      seed: () => const SearchState(status: SearchStatus.ready),
      act: (bloc) => bloc.add(const SearchQueryChanged('empty query')),
      wait: const Duration(milliseconds: 500),
      expect: () => [
        const SearchState(
            status: SearchStatus.ready, query: 'empty query'),
        const SearchState(
            status: SearchStatus.searching, query: 'empty query'),
        const SearchState(
            status: SearchStatus.loaded, query: 'empty query', results: []),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'SearchQueryChanged clears results when query becomes short',
      build: () => SearchBloc(searchService: fakeService),
      seed: () => const SearchState(
        status: SearchStatus.loaded,
        query: 'test',
        results: [
          SearchResult(
            textId: 'a',
            bookTitle: 'B',
            bookAuthor: 'C',
            chapterIndex: 0,
            chapterTitle: 'D',
            snippet: 'E',
          ),
        ],
      ),
      act: (bloc) => bloc.add(const SearchQueryChanged('')),
      expect: () => [
        // First emit updates query (keeps previous status and results)
        isA<SearchState>()
            .having((s) => s.query, 'query', ''),
        // Then clears results when query is too short
        const SearchState(
          status: SearchStatus.ready,
          query: '',
          results: [],
        ),
      ],
    );
  });
}
