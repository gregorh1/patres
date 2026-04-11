import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show Uint8List;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patres/blocs/library_bloc.dart';
import 'package:patres/blocs/locale_bloc.dart';
import 'package:patres/blocs/theme_bloc.dart';
import 'package:patres/l10n/generated/app_localizations.dart';
import 'package:patres/models/author.dart';
import 'package:patres/models/text_entry.dart';
import 'package:patres/screens/author_profile_screen.dart';
import 'package:patres/services/author_service.dart';
import 'package:patres/services/text_service.dart';
import 'package:patres/theme.dart';

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

const _testAuthor = Author(
  id: 'augustyn',
  name: 'Św. Augustyn z Hippony',
  nameOriginal: 'Aurelius Augustinus',
  dates: '354–430',
  era: 'IV-V w.',
  bio: 'Jeden z najważniejszych Ojców Kościoła i teologów.',
  significance: 'Wywarł ogromny wpływ na rozwój teologii zachodniej.',
  portraitAsset: null,
);

const _testTextEntry = TextEntry(
  id: 'augustyn-wyznania',
  file: 'augustyn-wyznania.json',
  title: 'Wyznania',
  titleOriginal: 'Confessiones',
  author: 'Św. Augustyn z Hippony',
  era: 'IV-V w.',
  category: 'patrystyka',
  language: 'pl',
  chaptersCount: 42,
  status: 'complete',
);

const _testManifestJson = '''
{
  "version": "1.0.0",
  "texts": [
    {
      "id": "augustyn-wyznania",
      "file": "augustyn-wyznania.json",
      "title": "Wyznania",
      "titleOriginal": "Confessiones",
      "author": "Św. Augustyn z Hippony",
      "era": "IV-V w.",
      "category": "patrystyka",
      "language": "pl",
      "chaptersCount": 42,
      "status": "complete"
    },
    {
      "id": "didache",
      "file": "didache.json",
      "title": "Didache",
      "titleOriginal": "Διδαχή",
      "author": "Anonim",
      "era": "I-II w.",
      "category": "patrystyka",
      "language": "pl",
      "chaptersCount": 6,
      "status": "complete"
    }
  ]
}
''';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeAuthorService extends AuthorService {
  final Author? authorToReturn;
  final Completer<Author?>? completer;

  const _FakeAuthorService({this.authorToReturn, this.completer})
      : super();

  @override
  Future<Author?> getAuthorById(String id) {
    if (completer != null) return completer!.future;
    return Future.value(authorToReturn);
  }
}

class _FakeAssetBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (key == 'assets/texts/manifest.json') return _testManifestJson;
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

Widget _testApp(Widget child, {LibraryBloc? libraryBloc}) {
  final tBloc = ThemeBloc();
  final lBloc = libraryBloc ?? LibraryBloc(textService: _fakeTextService());
  final lcBloc = LocaleBloc();
  return MultiBlocProvider(
    providers: [
      BlocProvider<ThemeBloc>.value(value: tBloc),
      BlocProvider<LibraryBloc>.value(value: lBloc),
      BlocProvider<LocaleBloc>.value(value: lcBloc),
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
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AuthorProfileScreen', () {
    testWidgets('shows loading indicator while author loads', (tester) async {
      // Use a Completer that never completes so the FutureBuilder stays in
      // ConnectionState.waiting without leaving pending timers.
      final completer = Completer<Author?>();
      final service = _FakeAuthorService(completer: completer);

      await tester.pumpWidget(
        _testApp(
          AuthorProfileScreen(
            authorId: 'augustyn',
            authorService: service,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the future to avoid dangling resources.
      completer.complete(_testAuthor);
    });

    testWidgets('shows unknown author when author not found', (tester) async {
      const service = _FakeAuthorService(authorToReturn: null);

      await tester.pumpWidget(
        _testApp(
          AuthorProfileScreen(
            authorId: 'nonexistent',
            authorService: service,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Polish l10n: authorUnknown = "Nieznany autor"
      expect(find.text('Nieznany autor'), findsOneWidget);
    });

    testWidgets('shows author name and bio when loaded', (tester) async {
      const service = _FakeAuthorService(authorToReturn: _testAuthor);

      await tester.pumpWidget(
        _testApp(
          AuthorProfileScreen(
            authorId: 'augustyn',
            authorService: service,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Author name appears in the header and in the SliverAppBar title
      expect(find.text('Św. Augustyn z Hippony'), findsWidgets);

      // Dates
      expect(find.text('354–430'), findsWidgets);

      // Bio text
      expect(
        find.text('Jeden z najważniejszych Ojców Kościoła i teologów.'),
        findsOneWidget,
      );

      // Significance text
      expect(
        find.text('Wywarł ogromny wpływ na rozwój teologii zachodniej.'),
        findsOneWidget,
      );

      // Original name
      expect(find.text('Aurelius Augustinus'), findsOneWidget);
    });

    testWidgets('shows author works from library', (tester) async {
      const service = _FakeAuthorService(authorToReturn: _testAuthor);

      // Create a LibraryBloc with the fake text service and load it.
      // Use runAsync so the real async load completes before we pump.
      final libraryBloc = LibraryBloc(textService: _fakeTextService());
      libraryBloc.add(const LibraryLoadRequested());
      // Wait for the loaded state (skip the intermediate loading state)
      await tester.runAsync(
        () => libraryBloc.stream
            .firstWhere((s) => s.status == LibraryStatus.loaded),
      );

      await tester.pumpWidget(
        _testApp(
          AuthorProfileScreen(
            authorId: 'augustyn',
            authorService: service,
          ),
          libraryBloc: libraryBloc,
        ),
      );
      await tester.pumpAndSettle();

      // Scroll down to reveal the works section (below the expanded app bar,
      // bio, and significance sections).
      await tester.scrollUntilVisible(
        find.text('Wyznania'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // The author's work title should appear in the works list
      expect(find.text('Wyznania'), findsOneWidget);

      // The original title should appear in the work card
      expect(find.text('Confessiones'), findsOneWidget);

      // "Didache" by "Anonim" should NOT appear — different author
      expect(find.text('Didache'), findsNothing);

      await tester.runAsync(() => libraryBloc.close());
    });
  });
}
