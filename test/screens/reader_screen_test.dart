import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patres/blocs/audio_bloc.dart';
import 'package:patres/blocs/audio_event.dart';
import 'package:patres/blocs/audio_state.dart';
import 'package:patres/blocs/library_bloc.dart';
import 'package:patres/blocs/locale_bloc.dart';
import 'package:patres/blocs/reader_bloc.dart';
import 'package:patres/blocs/reader_event.dart';
import 'package:patres/blocs/reader_state.dart';
import 'package:patres/blocs/theme_bloc.dart';
import 'package:patres/blocs/tts_generation_bloc.dart';
import 'package:patres/blocs/tts_generation_event.dart';
import 'package:patres/blocs/tts_generation_state.dart';
import 'package:patres/l10n/generated/app_localizations.dart';
import 'package:patres/models/text_content.dart';
import 'package:patres/screens/reader_screen.dart';
import 'package:patres/services/text_service.dart';
import 'package:patres/theme.dart';

// ---------------------------------------------------------------------------
// Fakes & mocks
// ---------------------------------------------------------------------------

class _MockReaderBloc extends MockBloc<ReaderEvent, ReaderState>
    implements ReaderBloc {}

class _MockAudioBloc extends MockBloc<AudioEvent, AudioState>
    implements AudioBloc {}

class _MockTtsGenerationBloc
    extends MockBloc<TtsGenerationEvent, TtsGenerationState>
    implements TtsGenerationBloc {}

// Sealed event classes require concrete subtypes for fallback values.

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
  required ReaderBloc readerBloc,
  required AudioBloc audioBloc,
  required TtsGenerationBloc ttsGenerationBloc,
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
      BlocProvider<ReaderBloc>.value(value: readerBloc),
      BlocProvider<AudioBloc>.value(value: audioBloc),
      BlocProvider<TtsGenerationBloc>.value(value: ttsGenerationBloc),
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

const _testTextContent = TextContent(
  id: 'didache',
  title: 'Didache',
  titleOriginal: '\u0394\u03b9\u03b4\u03b1\u03c7\u03ae',
  author: 'Anonim',
  chapters: [
    Chapter(
      title: 'Rozdzia\u0142 I \u2014 Dwie drogi',
      content: 'Dwie drogi s\u0105 na \u015bwiecie.\n\nDroga \u017cycia i droga \u015bmierci.\n\nWielka jest r\u00f3\u017cnica mi\u0119dzy nimi.',
    ),
    Chapter(
      title: 'Rozdzia\u0142 II \u2014 Przykazania',
      content: 'Nie zabijaj.\n\nNie cudzo\u0142\u00f3\u017c.',
    ),
    Chapter(
      title: 'Rozdzia\u0142 III \u2014 Unikanie z\u0142a',
      content: 'Unikaj ka\u017cdego z\u0142a.',
    ),
  ],
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    registerFallbackValue(const ReaderLoadRequested(textId: ''));
    registerFallbackValue(const ReaderState());
    registerFallbackValue(const AudioStopRequested());
    registerFallbackValue(const AudioState());
    registerFallbackValue(const TtsCancelRequested());
    registerFallbackValue(const TtsGenerationState());
  });

  group('ReaderScreen', () {
    late _MockReaderBloc readerBloc;
    late _MockAudioBloc audioBloc;
    late _MockTtsGenerationBloc ttsGenerationBloc;

    setUp(() {
      readerBloc = _MockReaderBloc();
      audioBloc = _MockAudioBloc();
      ttsGenerationBloc = _MockTtsGenerationBloc();

      // Default audio and TTS states for all tests
      when(() => audioBloc.state).thenReturn(const AudioState());
      when(() => ttsGenerationBloc.state)
          .thenReturn(const TtsGenerationState());
    });

    tearDown(() {
      readerBloc.close();
      audioBloc.close();
      ttsGenerationBloc.close();
    });

    testWidgets('shows loading indicator for initial state', (tester) async {
      when(() => readerBloc.state).thenReturn(const ReaderState());

      await tester.pumpWidget(
        _testApp(
          const ReaderScreen(textId: 'didache'),
          readerBloc: readerBloc,
          audioBloc: audioBloc,
          ttsGenerationBloc: ttsGenerationBloc,
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows error message for error state', (tester) async {
      when(() => readerBloc.state).thenReturn(
        const ReaderState(
          status: ReaderStatus.error,
          errorMessage: 'Nie uda\u0142o si\u0119 za\u0142adowa\u0107 tekstu',
        ),
      );

      await tester.pumpWidget(
        _testApp(
          const ReaderScreen(textId: 'didache'),
          readerBloc: readerBloc,
          audioBloc: audioBloc,
          ttsGenerationBloc: ttsGenerationBloc,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Nie uda\u0142o si\u0119 za\u0142adowa\u0107 tekstu'),
        findsOneWidget,
      );
    });

    testWidgets('shows text title and chapter content when loaded',
        (tester) async {
      when(() => readerBloc.state).thenReturn(
        const ReaderState(
          status: ReaderStatus.loaded,
          textId: 'didache',
          textContent: _testTextContent,
          currentChapter: 0,
        ),
      );

      await tester.pumpWidget(
        _testApp(
          const ReaderScreen(textId: 'didache'),
          readerBloc: readerBloc,
          audioBloc: audioBloc,
          ttsGenerationBloc: ttsGenerationBloc,
        ),
      );
      await tester.pumpAndSettle();

      // Title in the app bar
      expect(find.text('Didache'), findsOneWidget);

      // Chapter header — chapter title
      expect(
        find.text('Rozdzia\u0142 I \u2014 Dwie drogi'),
        findsOneWidget,
      );

      // Author name displayed in the chapter header
      expect(find.text('Anonim'), findsOneWidget);

      // Paragraph content — the chapter content is split by newlines
      expect(
        find.text('Dwie drogi s\u0105 na \u015bwiecie.'),
        findsOneWidget,
      );
      expect(
        find.text('Droga \u017cycia i droga \u015bmierci.'),
        findsOneWidget,
      );
    });

    testWidgets('shows chapter navigation bar with chapter count',
        (tester) async {
      when(() => readerBloc.state).thenReturn(
        const ReaderState(
          status: ReaderStatus.loaded,
          textId: 'didache',
          textContent: _testTextContent,
          currentChapter: 0,
        ),
      );

      await tester.pumpWidget(
        _testApp(
          const ReaderScreen(textId: 'didache'),
          readerBloc: readerBloc,
          audioBloc: audioBloc,
          ttsGenerationBloc: ttsGenerationBloc,
        ),
      );
      await tester.pumpAndSettle();

      // Polish: "Rozdział 1 z 3"
      expect(find.text('Rozdzia\u0142 1 z 3'), findsOneWidget);

      // Navigation icons
      expect(
        find.byIcon(Icons.chevron_left_rounded),
        findsOneWidget,
      );
      expect(
        find.byIcon(Icons.chevron_right_rounded),
        findsOneWidget,
      );
    });

    testWidgets('shows bookmark icon as outlined when not bookmarked',
        (tester) async {
      when(() => readerBloc.state).thenReturn(
        const ReaderState(
          status: ReaderStatus.loaded,
          textId: 'didache',
          textContent: _testTextContent,
          currentChapter: 0,
          bookmarks: [],
        ),
      );

      await tester.pumpWidget(
        _testApp(
          const ReaderScreen(textId: 'didache'),
          readerBloc: readerBloc,
          audioBloc: audioBloc,
          ttsGenerationBloc: ttsGenerationBloc,
        ),
      );
      await tester.pumpAndSettle();

      // Not bookmarked: outlined bookmark icon
      expect(
        find.byIcon(Icons.bookmark_border_rounded),
        findsOneWidget,
      );
      // Filled bookmark icon should not be present
      expect(
        find.byIcon(Icons.bookmark_rounded),
        findsNothing,
      );
    });
  });
}
