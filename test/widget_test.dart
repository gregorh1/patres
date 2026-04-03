import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patres/blocs/library_bloc.dart';
import 'package:patres/blocs/theme_bloc.dart';
import 'package:patres/l10n/generated/app_localizations.dart';
import 'package:patres/main.dart';
import 'package:patres/models/app_theme_mode.dart';
import 'package:patres/screens/library_screen.dart';
import 'package:patres/screens/settings_screen.dart';
import 'package:patres/services/text_service.dart';
import 'package:patres/theme.dart';

const _testManifestJson = '''
{
  "version": "1.0.0",
  "texts": [
    {
      "id": "didache",
      "file": "didache.json",
      "title": "Didache — Nauka Dwunastu Apostołów",
      "titleOriginal": "Διδαχή",
      "author": "Anonim (Ojcowie Apostolscy)",
      "era": "I-II w.",
      "category": "patrystyka",
      "language": "pl",
      "chaptersCount": 6,
      "status": "complete"
    },
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
    }
  ]
}
''';

const _testDailyReadingsJson = '''
[
  {
    "textId": "augustyn-wyznania",
    "chapterIndex": 0,
    "paragraphIndex": 0,
    "quote": "Test daily reading quote.",
    "author": "Św. Augustyn"
  }
]
''';

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

TextService _fakeTextService() =>
    TextService(assetBundle: _FakeAssetBundle());

/// Wraps a widget with all providers and localizations needed for testing.
Widget testApp(Widget child, {ThemeBloc? themeBloc, LibraryBloc? libraryBloc}) {
  final tBloc = themeBloc ?? ThemeBloc();
  final lBloc = libraryBloc ??
      LibraryBloc(textService: _fakeTextService());
  return MultiBlocProvider(
    providers: [
      BlocProvider<ThemeBloc>.value(value: tBloc),
      BlocProvider<LibraryBloc>.value(value: lBloc),
    ],
    child: BlocBuilder<ThemeBloc, ThemeState>(
      bloc: tBloc,
      builder: (context, state) {
        return MaterialApp(
          theme: PatresTheme.themeFor(state.themeMode),
          locale: const Locale('pl'),
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
    ),
  );
}

void main() {
  group('PatresApp', () {
    testWidgets('renders and shows home screen', (tester) async {
      await tester.pumpWidget(PatresApp(textService: _fakeTextService()));
      await tester.pumpAndSettle();

      expect(find.text('Witaj w Patres'), findsOneWidget);
    });

    testWidgets('bottom navigation has three tabs', (tester) async {
      await tester.pumpWidget(PatresApp(textService: _fakeTextService()));
      await tester.pumpAndSettle();

      expect(find.text('Główna'), findsOneWidget);
      expect(find.text('Biblioteka'), findsOneWidget);
      expect(find.text('Ustawienia'), findsOneWidget);
    });

    testWidgets('navigates to Library tab and loads texts', (tester) async {
      await tester.pumpWidget(PatresApp(textService: _fakeTextService()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Biblioteka'));
      await tester.pumpAndSettle();

      // Library screen should show texts loaded from manifest
      expect(find.text('Wyznania'), findsOneWidget);
    });

    testWidgets('navigates to Settings tab', (tester) async {
      await tester.pumpWidget(PatresApp(textService: _fakeTextService()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ustawienia'));
      await tester.pumpAndSettle();

      expect(find.text('Motyw'), findsOneWidget);
    });

    testWidgets('navigates back to Home from Settings', (tester) async {
      await tester.pumpWidget(PatresApp(textService: _fakeTextService()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ustawienia').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Główna').last);
      await tester.pumpAndSettle();

      expect(find.text('Witaj w Patres'), findsOneWidget);
    });
  });

  group('Theme switching', () {
    testWidgets('Settings shows three theme options', (tester) async {
      await tester.pumpWidget(testApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Jasny'), findsOneWidget);
      expect(find.text('Ciemny'), findsOneWidget);
      expect(find.text('Sepia'), findsOneWidget);
    });

    testWidgets('tapping Dark theme dispatches ThemeChanged event',
        (tester) async {
      final bloc = ThemeBloc();
      await tester.pumpWidget(testApp(const SettingsScreen(), themeBloc: bloc));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ciemny'));
      await tester.pumpAndSettle();

      expect(bloc.state.themeMode, AppThemeMode.dark);
      bloc.close();
    });

    testWidgets('tapping Sepia theme dispatches ThemeChanged event',
        (tester) async {
      final bloc = ThemeBloc();
      await tester.pumpWidget(testApp(const SettingsScreen(), themeBloc: bloc));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sepia'));
      await tester.pumpAndSettle();

      expect(bloc.state.themeMode, AppThemeMode.sepia);
      bloc.close();
    });

    testWidgets('tapping Light theme after Dark restores light',
        (tester) async {
      final bloc = ThemeBloc();
      bloc.add(const ThemeChanged(AppThemeMode.dark));

      await tester.pumpWidget(testApp(const SettingsScreen(), themeBloc: bloc));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Jasny'));
      await tester.pumpAndSettle();

      expect(bloc.state.themeMode, AppThemeMode.light);
      bloc.close();
    });
  });

  group('ThemeBloc', () {
    test('initial state is light theme', () {
      final bloc = ThemeBloc();
      expect(bloc.state.themeMode, AppThemeMode.light);
      bloc.close();
    });

    test('emits dark theme state when ThemeChanged(dark) is added', () async {
      final bloc = ThemeBloc();
      bloc.add(const ThemeChanged(AppThemeMode.dark));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.themeMode, AppThemeMode.dark);
      bloc.close();
    });

    test('emits sepia theme state when ThemeChanged(sepia) is added',
        () async {
      final bloc = ThemeBloc();
      bloc.add(const ThemeChanged(AppThemeMode.sepia));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.themeMode, AppThemeMode.sepia);
      bloc.close();
    });
  });

  group('PatresTheme', () {
    test('light theme uses Material 3', () {
      final theme = PatresTheme.themeFor(AppThemeMode.light);
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
    });

    test('dark theme uses Material 3 with dark brightness', () {
      final theme = PatresTheme.themeFor(AppThemeMode.dark);
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
    });

    test('sepia theme has warm parchment colors', () {
      final theme = PatresTheme.themeFor(AppThemeMode.sepia);
      expect(theme.useMaterial3, isTrue);
      expect(theme.scaffoldBackgroundColor, const Color(0xFFF5ECD7));
    });

    test('all three themes produce distinct ThemeData instances', () {
      final light = PatresTheme.themeFor(AppThemeMode.light);
      final dark = PatresTheme.themeFor(AppThemeMode.dark);
      final sepia = PatresTheme.themeFor(AppThemeMode.sepia);

      expect(light.brightness, isNot(dark.brightness));
      expect(sepia.scaffoldBackgroundColor,
          isNot(equals(light.scaffoldBackgroundColor)));
    });
  });

  group('LibraryScreen', () {
    testWidgets('shows search bar and sort controls', (tester) async {
      final bloc = LibraryBloc(textService: _fakeTextService());
      await tester.pumpWidget(
        testApp(const Scaffold(body: LibraryScreen()), libraryBloc: bloc),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Sortuj'), findsOneWidget);
      expect(find.text('Tytuł'), findsOneWidget);
      expect(find.text('Autor'), findsOneWidget);
      bloc.close();
    });

    testWidgets('loads and displays texts from manifest', (tester) async {
      final bloc = LibraryBloc(textService: _fakeTextService());
      await tester.pumpWidget(
        testApp(const Scaffold(body: LibraryScreen()), libraryBloc: bloc),
      );
      await tester.pumpAndSettle();

      expect(find.text('Wyznania'), findsOneWidget);
      expect(find.text('Didache — Nauka Dwunastu Apostołów'), findsOneWidget);
      bloc.close();
    });

    testWidgets('search filters displayed texts', (tester) async {
      final bloc = LibraryBloc(textService: _fakeTextService());
      await tester.pumpWidget(
        testApp(const Scaffold(body: LibraryScreen()), libraryBloc: bloc),
      );
      await tester.pumpAndSettle();

      // Both texts visible initially
      expect(find.text('Wyznania'), findsOneWidget);

      // Type search query
      await tester.enterText(find.byType(TextField), 'Augustyn');
      await tester.pumpAndSettle();

      expect(find.text('Wyznania'), findsOneWidget);
      expect(find.text('Didache — Nauka Dwunastu Apostołów'), findsNothing);
      bloc.close();
    });

    testWidgets('view mode toggles between grid and list', (tester) async {
      final bloc = LibraryBloc(textService: _fakeTextService());
      await tester.pumpWidget(
        testApp(const Scaffold(body: LibraryScreen()), libraryBloc: bloc),
      );
      await tester.pumpAndSettle();

      // Initially in grid mode — toggle button shows list icon
      expect(find.byIcon(Icons.view_list_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.view_list_rounded));
      await tester.pumpAndSettle();

      // Now in list mode — toggle button shows grid icon
      expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);
      bloc.close();
    });

    testWidgets('shows status badges on cards', (tester) async {
      final bloc = LibraryBloc(textService: _fakeTextService());
      await tester.pumpWidget(
        testApp(const Scaffold(body: LibraryScreen()), libraryBloc: bloc),
      );
      await tester.pumpAndSettle();

      // Both test texts are 'complete'
      expect(find.text('Pełny tekst'), findsNWidgets(2));
      bloc.close();
    });
  });
}
