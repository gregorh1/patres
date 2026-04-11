import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patres/blocs/audio_bloc.dart';
import 'package:patres/blocs/audio_event.dart';
import 'package:patres/blocs/audio_state.dart';
import 'package:patres/l10n/generated/app_localizations.dart';
import 'package:patres/models/app_theme_mode.dart';
import 'package:patres/theme.dart';
import 'package:patres/widgets/audio_player_widget.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class _MockAudioBloc extends MockBloc<AudioEvent, AudioState>
    implements AudioBloc {}

// ---------------------------------------------------------------------------
// Test wrapper
// ---------------------------------------------------------------------------

Widget _testApp(Widget child, {required AudioBloc audioBloc}) {
  return BlocProvider<AudioBloc>.value(
    value: audioBloc,
    child: MaterialApp(
      theme: PatresTheme.themeFor(AppThemeMode.light),
      locale: const Locale('pl'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: child),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    registerFallbackValue(const AudioStopRequested());
    registerFallbackValue(const AudioState());
  });

  group('AudioPlayerWidget', () {
    late _MockAudioBloc audioBloc;

    setUp(() {
      audioBloc = _MockAudioBloc();
      when(() => audioBloc.state).thenReturn(const AudioState());
    });

    tearDown(() {
      audioBloc.close();
    });

    testWidgets('shows text and chapter titles', (tester) async {
      when(() => audioBloc.state).thenReturn(const AudioState(
        status: AudioPlaybackStatus.playing,
      ));

      await tester.pumpWidget(_testApp(
        const AudioPlayerWidget(
          textTitle: 'Didache',
          chapterTitle: 'Rozdział I',
        ),
        audioBloc: audioBloc,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Didache'), findsOneWidget);
      expect(find.text('Rozdział I'), findsOneWidget);
    });

    testWidgets('shows play button when paused', (tester) async {
      when(() => audioBloc.state).thenReturn(const AudioState(
        status: AudioPlaybackStatus.paused,
      ));

      await tester.pumpWidget(_testApp(
        const AudioPlayerWidget(
          textTitle: 'Test',
          chapterTitle: 'Ch 1',
        ),
        audioBloc: audioBloc,
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.byIcon(Icons.pause_rounded), findsNothing);
    });

    testWidgets('shows pause button when playing', (tester) async {
      when(() => audioBloc.state).thenReturn(const AudioState(
        status: AudioPlaybackStatus.playing,
      ));

      await tester.pumpWidget(_testApp(
        const AudioPlayerWidget(
          textTitle: 'Test',
          chapterTitle: 'Ch 1',
        ),
        audioBloc: audioBloc,
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
    });

    testWidgets('shows loading indicator when loading', (tester) async {
      when(() => audioBloc.state).thenReturn(const AudioState(
        status: AudioPlaybackStatus.loading,
      ));

      await tester.pumpWidget(_testApp(
        const AudioPlayerWidget(
          textTitle: 'Test',
          chapterTitle: 'Ch 1',
        ),
        audioBloc: audioBloc,
      ));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows skip backward/forward buttons', (tester) async {
      when(() => audioBloc.state).thenReturn(const AudioState(
        status: AudioPlaybackStatus.playing,
      ));

      await tester.pumpWidget(_testApp(
        const AudioPlayerWidget(
          textTitle: 'Test',
          chapterTitle: 'Ch 1',
        ),
        audioBloc: audioBloc,
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.replay_10_rounded), findsOneWidget);
      expect(find.byIcon(Icons.forward_10_rounded), findsOneWidget);
    });

    testWidgets('tapping pause button dispatches AudioPauseRequested',
        (tester) async {
      when(() => audioBloc.state).thenReturn(const AudioState(
        status: AudioPlaybackStatus.playing,
      ));

      await tester.pumpWidget(_testApp(
        const AudioPlayerWidget(
          textTitle: 'Test',
          chapterTitle: 'Ch 1',
        ),
        audioBloc: audioBloc,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.pause_rounded));

      verify(() => audioBloc.add(const AudioPauseRequested())).called(1);
    });

    testWidgets('tapping play button dispatches AudioResumeRequested',
        (tester) async {
      when(() => audioBloc.state).thenReturn(const AudioState(
        status: AudioPlaybackStatus.paused,
      ));

      await tester.pumpWidget(_testApp(
        const AudioPlayerWidget(
          textTitle: 'Test',
          chapterTitle: 'Ch 1',
        ),
        audioBloc: audioBloc,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.play_arrow_rounded));

      verify(() => audioBloc.add(const AudioResumeRequested())).called(1);
    });

    testWidgets('tapping skip backward dispatches AudioSkipBackwardRequested',
        (tester) async {
      when(() => audioBloc.state).thenReturn(const AudioState(
        status: AudioPlaybackStatus.playing,
      ));

      await tester.pumpWidget(_testApp(
        const AudioPlayerWidget(
          textTitle: 'Test',
          chapterTitle: 'Ch 1',
        ),
        audioBloc: audioBloc,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.replay_10_rounded));

      verify(() => audioBloc.add(const AudioSkipBackwardRequested())).called(1);
    });

    testWidgets('tapping skip forward dispatches AudioSkipForwardRequested',
        (tester) async {
      when(() => audioBloc.state).thenReturn(const AudioState(
        status: AudioPlaybackStatus.playing,
      ));

      await tester.pumpWidget(_testApp(
        const AudioPlayerWidget(
          textTitle: 'Test',
          chapterTitle: 'Ch 1',
        ),
        audioBloc: audioBloc,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.forward_10_rounded));

      verify(() => audioBloc.add(const AudioSkipForwardRequested())).called(1);
    });

    testWidgets('displays formatted time labels', (tester) async {
      when(() => audioBloc.state).thenReturn(const AudioState(
        status: AudioPlaybackStatus.playing,
        position: Duration(minutes: 3, seconds: 45),
        duration: Duration(minutes: 12, seconds: 30),
      ));

      await tester.pumpWidget(_testApp(
        const AudioPlayerWidget(
          textTitle: 'Test',
          chapterTitle: 'Ch 1',
        ),
        audioBloc: audioBloc,
      ));
      await tester.pumpAndSettle();

      expect(find.text('03:45'), findsOneWidget);
      expect(find.text('12:30'), findsOneWidget);
    });

    testWidgets('displays hours in time when duration exceeds 1 hour',
        (tester) async {
      when(() => audioBloc.state).thenReturn(const AudioState(
        status: AudioPlaybackStatus.playing,
        position: Duration(hours: 1, minutes: 5, seconds: 10),
        duration: Duration(hours: 2, minutes: 30, seconds: 0),
      ));

      await tester.pumpWidget(_testApp(
        const AudioPlayerWidget(
          textTitle: 'Test',
          chapterTitle: 'Ch 1',
        ),
        audioBloc: audioBloc,
      ));
      await tester.pumpAndSettle();

      expect(find.text('01:05:10'), findsOneWidget);
      expect(find.text('02:30:00'), findsOneWidget);
    });

    testWidgets('shows speed selector with current speed', (tester) async {
      when(() => audioBloc.state).thenReturn(const AudioState(
        status: AudioPlaybackStatus.playing,
        speed: 1.5,
      ));

      await tester.pumpWidget(_testApp(
        const AudioPlayerWidget(
          textTitle: 'Test',
          chapterTitle: 'Ch 1',
        ),
        audioBloc: audioBloc,
      ));
      await tester.pumpAndSettle();

      expect(find.text('1.5x'), findsOneWidget);
    });

    testWidgets('shows progress slider', (tester) async {
      when(() => audioBloc.state).thenReturn(const AudioState(
        status: AudioPlaybackStatus.playing,
        position: Duration(seconds: 30),
        duration: Duration(minutes: 1),
      ));

      await tester.pumpWidget(_testApp(
        const AudioPlayerWidget(
          textTitle: 'Test',
          chapterTitle: 'Ch 1',
        ),
        audioBloc: audioBloc,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Slider), findsOneWidget);
    });
  });

  group('MiniAudioPlayer', () {
    late _MockAudioBloc audioBloc;

    setUp(() {
      audioBloc = _MockAudioBloc();
      when(() => audioBloc.state).thenReturn(const AudioState());
    });

    tearDown(() {
      audioBloc.close();
    });

    testWidgets('hides when audio is not active', (tester) async {
      when(() => audioBloc.state).thenReturn(const AudioState(
        status: AudioPlaybackStatus.idle,
      ));

      await tester.pumpWidget(_testApp(
        const MiniAudioPlayer(
          textTitle: 'Test',
          chapterTitle: 'Ch 1',
        ),
        audioBloc: audioBloc,
      ));
      await tester.pump();

      expect(find.text('Test'), findsNothing);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('shows when audio is playing', (tester) async {
      when(() => audioBloc.state).thenReturn(const AudioState(
        status: AudioPlaybackStatus.playing,
      ));

      await tester.pumpWidget(_testApp(
        const MiniAudioPlayer(
          textTitle: 'Didache',
          chapterTitle: 'Rozdział I',
        ),
        audioBloc: audioBloc,
      ));
      await tester.pump();

      expect(find.text('Didache'), findsOneWidget);
      expect(find.text('Rozdział I'), findsOneWidget);
    });

    testWidgets('shows when audio is paused', (tester) async {
      when(() => audioBloc.state).thenReturn(const AudioState(
        status: AudioPlaybackStatus.paused,
      ));

      await tester.pumpWidget(_testApp(
        const MiniAudioPlayer(
          textTitle: 'Didache',
          chapterTitle: 'Rozdział I',
        ),
        audioBloc: audioBloc,
      ));
      await tester.pump();

      expect(find.text('Didache'), findsOneWidget);
    });

    testWidgets('shows pause icon when playing', (tester) async {
      when(() => audioBloc.state).thenReturn(const AudioState(
        status: AudioPlaybackStatus.playing,
      ));

      await tester.pumpWidget(_testApp(
        const MiniAudioPlayer(
          textTitle: 'Test',
          chapterTitle: 'Ch 1',
        ),
        audioBloc: audioBloc,
      ));
      await tester.pump();

      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
    });

    testWidgets('shows play icon when paused', (tester) async {
      when(() => audioBloc.state).thenReturn(const AudioState(
        status: AudioPlaybackStatus.paused,
      ));

      await tester.pumpWidget(_testApp(
        const MiniAudioPlayer(
          textTitle: 'Test',
          chapterTitle: 'Ch 1',
        ),
        audioBloc: audioBloc,
      ));
      await tester.pump();

      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    });

    testWidgets('tapping play/pause dispatches correct event',
        (tester) async {
      when(() => audioBloc.state).thenReturn(const AudioState(
        status: AudioPlaybackStatus.playing,
      ));

      await tester.pumpWidget(_testApp(
        const MiniAudioPlayer(
          textTitle: 'Test',
          chapterTitle: 'Ch 1',
        ),
        audioBloc: audioBloc,
      ));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.pause_rounded));

      verify(() => audioBloc.add(const AudioPauseRequested())).called(1);
    });

    testWidgets('tapping close dispatches AudioStopRequested',
        (tester) async {
      when(() => audioBloc.state).thenReturn(const AudioState(
        status: AudioPlaybackStatus.playing,
      ));

      await tester.pumpWidget(_testApp(
        const MiniAudioPlayer(
          textTitle: 'Test',
          chapterTitle: 'Ch 1',
        ),
        audioBloc: audioBloc,
      ));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.close_rounded));

      verify(() => audioBloc.add(const AudioStopRequested())).called(1);
    });

    testWidgets('shows progress indicator', (tester) async {
      when(() => audioBloc.state).thenReturn(const AudioState(
        status: AudioPlaybackStatus.playing,
        position: Duration(seconds: 30),
        duration: Duration(minutes: 1),
      ));

      await tester.pumpWidget(_testApp(
        const MiniAudioPlayer(
          textTitle: 'Test',
          chapterTitle: 'Ch 1',
        ),
        audioBloc: audioBloc,
      ));
      await tester.pump();

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('calls onTap callback when tapped', (tester) async {
      when(() => audioBloc.state).thenReturn(const AudioState(
        status: AudioPlaybackStatus.playing,
      ));

      var tapped = false;
      await tester.pumpWidget(_testApp(
        MiniAudioPlayer(
          textTitle: 'Test',
          chapterTitle: 'Ch 1',
          onTap: () => tapped = true,
        ),
        audioBloc: audioBloc,
      ));
      await tester.pump();

      // Tap on the text area (not on a button)
      await tester.tap(find.text('Test'));

      expect(tapped, isTrue);
    });
  });
}
