import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patres/blocs/library_bloc.dart';
import 'package:patres/blocs/locale_bloc.dart';
import 'package:patres/blocs/theme_bloc.dart';
import 'package:patres/blocs/tts_generation_bloc.dart';
import 'package:patres/blocs/tts_generation_event.dart';
import 'package:patres/blocs/tts_generation_state.dart';
import 'package:patres/l10n/generated/app_localizations.dart';
import 'package:patres/screens/audio_downloads_screen.dart';
import 'package:patres/services/text_service.dart';
import 'package:patres/theme.dart';

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

const _testManifestJson = '''
{
  "version": "1.0.0",
  "texts": [
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

// ---------------------------------------------------------------------------
// Fakes & mocks
// ---------------------------------------------------------------------------

class _MockTtsGenerationBloc
    extends MockBloc<TtsGenerationEvent, TtsGenerationState>
    implements TtsGenerationBloc {}

// Sealed event classes require concrete subtypes for fallback values.

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

Widget _testApp(
  Widget child, {
  required TtsGenerationBloc ttsBloc,
  LibraryBloc? libraryBloc,
}) {
  final tBloc = ThemeBloc();
  final lBloc = libraryBloc ?? LibraryBloc(textService: _fakeTextService());
  final lcBloc = LocaleBloc();
  return MultiBlocProvider(
    providers: [
      BlocProvider<ThemeBloc>.value(value: tBloc),
      BlocProvider<LibraryBloc>.value(value: lBloc),
      BlocProvider<LocaleBloc>.value(value: lcBloc),
      BlocProvider<TtsGenerationBloc>.value(value: ttsBloc),
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
  setUpAll(() {
    registerFallbackValue(const TtsCancelRequested());
    registerFallbackValue(const TtsGenerationState());
  });

  group('AudioDownloadsScreen', () {
    late _MockTtsGenerationBloc ttsBloc;

    setUp(() {
      ttsBloc = _MockTtsGenerationBloc();
    });

    tearDown(() {
      ttsBloc.close();
    });

    testWidgets('shows storage info card with cache size', (tester) async {
      const state = TtsGenerationState(
        totalCacheSize: 5 * 1024 * 1024, // 5 MB
      );
      when(() => ttsBloc.state).thenReturn(state);
      whenListen(ttsBloc, const Stream<TtsGenerationState>.empty(),
          initialState: state);

      await tester.pumpWidget(
        _testApp(const AudioDownloadsScreen(), ttsBloc: ttsBloc),
      );
      await tester.pumpAndSettle();

      // AppBar title — Polish: "Audiobooki"
      expect(find.text('Audiobooki'), findsOneWidget);

      // Cache size formatted as "5.0 MB"
      expect(find.text('5.0 MB'), findsOneWidget);

      // Storage icon
      expect(find.byIcon(Icons.storage_rounded), findsOneWidget);
    });

    testWidgets('shows text list from library', (tester) async {
      const state = TtsGenerationState();
      when(() => ttsBloc.state).thenReturn(state);
      whenListen(ttsBloc, const Stream<TtsGenerationState>.empty(),
          initialState: state);

      // Create a loaded LibraryBloc
      final libraryBloc = LibraryBloc(textService: _fakeTextService());
      libraryBloc.add(const LibraryLoadRequested());

      await tester.pumpWidget(
        _testApp(
          const AudioDownloadsScreen(),
          ttsBloc: ttsBloc,
          libraryBloc: libraryBloc,
        ),
      );
      await tester.pumpAndSettle();

      // Text titles from manifest
      expect(find.text('Didache'), findsOneWidget);
      expect(find.text('Wyznania'), findsOneWidget);

      libraryBloc.close();
    });

    testWidgets('shows generation progress when generating', (tester) async {
      const state = TtsGenerationState(
        status: TtsGenerationStatus.generating,
        currentTextId: 'didache',
        currentChapterIndex: 1,
        completedChapters: 2,
        totalChapters: 6,
      );
      when(() => ttsBloc.state).thenReturn(state);
      whenListen(ttsBloc, const Stream<TtsGenerationState>.empty(),
          initialState: state);

      final libraryBloc = LibraryBloc(textService: _fakeTextService());
      libraryBloc.add(const LibraryLoadRequested());

      await tester.pumpWidget(
        _testApp(
          const AudioDownloadsScreen(),
          ttsBloc: ttsBloc,
          libraryBloc: libraryBloc,
        ),
      );
      // Use pump() instead of pumpAndSettle() — the CircularProgressIndicator
      // in the generating state animates continuously and never settles.
      await tester.pump();
      await tester.pump();

      // Progress indicator should be visible
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Cancel button text — Polish: "Anuluj"
      expect(find.text('Anuluj'), findsOneWidget);

      libraryBloc.close();
    });

    testWidgets('shows error card when error', (tester) async {
      const state = TtsGenerationState(
        status: TtsGenerationStatus.error,
        errorMessage: 'Network error',
      );
      when(() => ttsBloc.state).thenReturn(state);
      whenListen(ttsBloc, const Stream<TtsGenerationState>.empty(),
          initialState: state);

      await tester.pumpWidget(
        _testApp(const AudioDownloadsScreen(), ttsBloc: ttsBloc),
      );
      await tester.pumpAndSettle();

      // Error icon
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });
}
