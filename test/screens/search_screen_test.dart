import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patres/blocs/library_bloc.dart';
import 'package:patres/blocs/locale_bloc.dart';
import 'package:patres/blocs/search_bloc.dart';
import 'package:patres/blocs/theme_bloc.dart';
import 'package:patres/l10n/generated/app_localizations.dart';
import 'package:patres/models/search_result.dart';
import 'package:patres/screens/search_screen.dart';
import 'package:patres/services/text_service.dart';
import 'package:patres/theme.dart';

// ---------------------------------------------------------------------------
// Fakes & mocks
// ---------------------------------------------------------------------------

class _MockSearchBloc extends MockBloc<SearchEvent, SearchState>
    implements SearchBloc {}

class _FakeSearchEvent extends Fake implements SearchEvent {}
class _FakeSearchState extends Fake implements SearchState {}

const _testManifestJson = '''
{
  "version": "1.0.0",
  "texts": []
}
''';

const _testDailyReadingsJson = '[]';

class _FakeAssetBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (key == 'assets/texts/manifest.json') return _testManifestJson;
    if (key == 'assets/daily_readings.json') return _testDailyReadingsJson;
    throw FlutterError('Asset not found: $key');
  }

  @override
  Future<ByteData> load(String key) async {
    final str = await loadString(key);
    return ByteData.view(Uint8List.fromList(utf8.encode(str)).buffer);
  }
}

TextService _fakeTextService() => TextService(assetBundle: _FakeAssetBundle());

// ---------------------------------------------------------------------------
// Test wrapper
// ---------------------------------------------------------------------------

Widget _testApp(
  Widget child, {
  required SearchBloc searchBloc,
  ThemeBloc? themeBloc,
  LibraryBloc? libraryBloc,
  LocaleBloc? localeBloc,
}) {
  final tBloc = themeBloc ?? ThemeBloc();
  final lBloc = libraryBloc ?? LibraryBloc(textService: _fakeTextService());
  final lcBloc = localeBloc ?? LocaleBloc();
  return MultiBlocProvider(
    providers: [
      BlocProvider<ThemeBloc>.value(value: tBloc),
      BlocProvider<LibraryBloc>.value(value: lBloc),
      BlocProvider<LocaleBloc>.value(value: lcBloc),
      BlocProvider<SearchBloc>.value(value: searchBloc),
    ],
    child: BlocBuilder<ThemeBloc, ThemeState>(
      bloc: tBloc,
      builder: (context, themeState) {
        return BlocBuilder<LocaleBloc, LocaleState>(
          bloc: lcBloc,
          builder: (context, localeState) {
            return MaterialApp(
              theme: PatresTheme.themeFor(themeState.themeMode),
              locale: localeState.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: child,
            );
          },
        );
      },
    ),
  );
}

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

const _sampleResults = [
  SearchResult(
    textId: 'didache',
    bookTitle: 'Didache',
    bookAuthor: 'Anonim',
    chapterIndex: 0,
    chapterTitle: 'Rozdział I',
    snippet: 'Dwie drogi są na <b>świecie</b>: droga życia i droga śmierci.',
  ),
  SearchResult(
    textId: 'augustyn-wyznania',
    bookTitle: 'Wyznania',
    bookAuthor: 'Św. Augustyn',
    chapterIndex: 3,
    chapterTitle: 'Księga IV',
    snippet: 'Niespokojne jest serce nasze, dopóki nie <b>spocznie</b> w Tobie.',
  ),
];

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeSearchEvent());
    registerFallbackValue(_FakeSearchState());
  });

  group('SearchScreen', () {
    late _MockSearchBloc searchBloc;

    setUp(() {
      searchBloc = _MockSearchBloc();
    });

    tearDown(() {
      searchBloc.close();
    });

    testWidgets('renders search bar with hint text', (tester) async {
      when(() => searchBloc.state).thenReturn(const SearchState());

      await tester.pumpWidget(
        _testApp(const SearchScreen(), searchBloc: searchBloc),
      );
      await tester.pumpAndSettle();

      // The SearchBar should display the hint text from l10n
      expect(find.byType(SearchBar), findsOneWidget);
      // Polish hint: "Szukaj słów i fraz w tekstach…"
      expect(
        find.text('Szukaj słów i fraz w tekstach…'),
        findsOneWidget,
      );
    });

    testWidgets('shows search prompt when query is short', (tester) async {
      when(() => searchBloc.state).thenReturn(
        const SearchState(status: SearchStatus.ready, query: 'a'),
      );

      await tester.pumpWidget(
        _testApp(const SearchScreen(), searchBloc: searchBloc),
      );
      await tester.pumpAndSettle();

      // Should show the search prompt icon
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      // Polish prompt: "Wpisz co najmniej 2 znaki, aby wyszukać w całej bibliotece"
      expect(
        find.text('Wpisz co najmniej 2 znaki, aby wyszukać w całej bibliotece'),
        findsOneWidget,
      );
    });

    testWidgets('shows indexing progress indicator', (tester) async {
      when(() => searchBloc.state).thenReturn(
        const SearchState(status: SearchStatus.indexing),
      );

      await tester.pumpWidget(
        _testApp(const SearchScreen(), searchBloc: searchBloc),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Polish indexing message: "Indeksowanie tekstów…"
      expect(find.text('Indeksowanie tekstów…'), findsOneWidget);
    });

    testWidgets('shows results when loaded', (tester) async {
      when(() => searchBloc.state).thenReturn(
        const SearchState(
          status: SearchStatus.loaded,
          query: 'świecie',
          results: _sampleResults,
        ),
      );

      await tester.pumpWidget(
        _testApp(const SearchScreen(), searchBloc: searchBloc),
      );
      await tester.pumpAndSettle();

      // Results count header — Polish: "2 wyniki"
      expect(find.text('2 wyniki'), findsOneWidget);

      // Book titles from results
      expect(find.text('Didache'), findsOneWidget);
      expect(find.text('Wyznania'), findsOneWidget);

      // Chapter titles
      expect(find.text('Rozdział I'), findsOneWidget);
      expect(find.text('Księga IV'), findsOneWidget);
    });

    testWidgets('shows no results state', (tester) async {
      when(() => searchBloc.state).thenReturn(
        const SearchState(
          status: SearchStatus.loaded,
          query: 'xyznonexistent',
          results: [],
        ),
      );

      await tester.pumpWidget(
        _testApp(const SearchScreen(), searchBloc: searchBloc),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);
      // Polish: "Brak wyników"
      expect(find.text('Brak wyników'), findsOneWidget);
      // Polish: "Spróbuj zmienić filtry lub wyszukiwanie"
      expect(
        find.text('Spróbuj zmienić filtry lub wyszukiwanie'),
        findsOneWidget,
      );
    });

    testWidgets('shows error message', (tester) async {
      when(() => searchBloc.state).thenReturn(
        const SearchState(
          status: SearchStatus.error,
          query: 'test',
          errorMessage: 'Wyszukiwanie jest niedostępne na tym urządzeniu',
        ),
      );

      await tester.pumpWidget(
        _testApp(const SearchScreen(), searchBloc: searchBloc),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Wyszukiwanie jest niedostępne na tym urządzeniu'),
        findsOneWidget,
      );
    });
  });
}
