import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patres/blocs/audio_bloc.dart';
import 'package:patres/blocs/audio_event.dart';
import 'package:patres/blocs/audio_state.dart';

// ---------------------------------------------------------------------------
// Mock
// ---------------------------------------------------------------------------

class _MockAudioPlayer extends Mock implements AudioPlayer {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Creates a mock AudioPlayer with stubbed streams and methods.
_MockAudioPlayer _createMockPlayer({
  StreamController<Duration>? positionController,
  StreamController<Duration?>? durationController,
  StreamController<PlayerState>? playerStateController,
}) {
  final player = _MockAudioPlayer();
  final posCtrl = positionController ?? StreamController<Duration>.broadcast();
  final durCtrl =
      durationController ?? StreamController<Duration?>.broadcast();
  final psCtrl =
      playerStateController ?? StreamController<PlayerState>.broadcast();

  when(() => player.positionStream).thenAnswer((_) => posCtrl.stream);
  when(() => player.durationStream).thenAnswer((_) => durCtrl.stream);
  when(() => player.playerStateStream).thenAnswer((_) => psCtrl.stream);
  when(() => player.setFilePath(any())).thenAnswer((_) async => null);
  when(() => player.setSpeed(any())).thenAnswer((_) async {});
  when(() => player.play()).thenAnswer((_) async {});
  when(() => player.pause()).thenAnswer((_) async {});
  when(() => player.stop()).thenAnswer((_) async {});
  when(() => player.seek(any())).thenAnswer((_) async {});
  when(() => player.dispose()).thenAnswer((_) async {});

  return player;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AudioState', () {
    test('progress calculation', () {
      const state = AudioState(
        position: Duration(seconds: 30),
        duration: Duration(seconds: 60),
      );
      expect(state.progress, 0.5);
    });

    test('progress is 0 when duration is 0', () {
      const state = AudioState(
        position: Duration.zero,
        duration: Duration.zero,
      );
      expect(state.progress, 0);
    });

    test('isPlaying returns true when playing', () {
      const state = AudioState(status: AudioPlaybackStatus.playing);
      expect(state.isPlaying, isTrue);
      expect(state.isPaused, isFalse);
    });

    test('isPaused returns true when paused', () {
      const state = AudioState(status: AudioPlaybackStatus.paused);
      expect(state.isPaused, isTrue);
      expect(state.isPlaying, isFalse);
    });

    test('isActive returns true when playing or paused', () {
      expect(
        const AudioState(status: AudioPlaybackStatus.playing).isActive,
        isTrue,
      );
      expect(
        const AudioState(status: AudioPlaybackStatus.paused).isActive,
        isTrue,
      );
      expect(
        const AudioState(status: AudioPlaybackStatus.idle).isActive,
        isFalse,
      );
      expect(
        const AudioState(status: AudioPlaybackStatus.completed).isActive,
        isFalse,
      );
    });

    test('copyWith preserves values', () {
      const state = AudioState(
        status: AudioPlaybackStatus.playing,
        textId: 'test',
        chapterIndex: 5,
        speed: 1.5,
        position: Duration(seconds: 10),
        duration: Duration(minutes: 5),
      );
      final updated = state.copyWith(speed: 2.0);
      expect(updated.speed, 2.0);
      expect(updated.textId, 'test');
      expect(updated.chapterIndex, 5);
      expect(updated.status, AudioPlaybackStatus.playing);
      expect(updated.position, const Duration(seconds: 10));
      expect(updated.duration, const Duration(minutes: 5));
    });

    test('copyWith clearSleepTimer', () {
      const state = AudioState(
        sleepTimerRemaining: Duration(minutes: 15),
      );
      final updated = state.copyWith(clearSleepTimer: true);
      expect(updated.sleepTimerRemaining, isNull);
    });

    test('copyWith clearError', () {
      const state = AudioState(
        errorMessage: 'some error',
      );
      final updated = state.copyWith(clearError: true);
      expect(updated.errorMessage, isNull);
    });

    test('speeds list has correct values', () {
      expect(AudioState.speeds, [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]);
    });

    test('default state values', () {
      const state = AudioState();
      expect(state.status, AudioPlaybackStatus.idle);
      expect(state.textId, isNull);
      expect(state.chapterIndex, isNull);
      expect(state.position, Duration.zero);
      expect(state.duration, Duration.zero);
      expect(state.speed, 1.0);
      expect(state.sleepTimerRemaining, isNull);
      expect(state.errorMessage, isNull);
      expect(state.isPlaying, isFalse);
      expect(state.isPaused, isFalse);
      expect(state.isActive, isFalse);
      expect(state.progress, 0);
    });

    test('equatable props', () {
      const state1 = AudioState(
        status: AudioPlaybackStatus.playing,
        textId: 'test',
      );
      const state2 = AudioState(
        status: AudioPlaybackStatus.playing,
        textId: 'test',
      );
      expect(state1, equals(state2));
    });

    test('equatable inequality', () {
      const state1 = AudioState(status: AudioPlaybackStatus.playing);
      const state2 = AudioState(status: AudioPlaybackStatus.paused);
      expect(state1, isNot(equals(state2)));
    });
  });

  group('AudioBloc', () {
    late _MockAudioPlayer mockPlayer;

    setUp(() {
      mockPlayer = _createMockPlayer();
    });

    test('initial state is idle', () {
      final bloc = AudioBloc(player: mockPlayer);
      expect(bloc.state, const AudioState());
      bloc.close();
    });

    blocTest<AudioBloc, AudioState>(
      'AudioPlayRequested emits loading then playing',
      build: () => AudioBloc(player: mockPlayer),
      act: (bloc) => bloc.add(const AudioPlayRequested(
        textId: 'didache',
        chapterIndex: 0,
        filePath: '/tmp/test.mp3',
      )),
      expect: () => [
        isA<AudioState>()
            .having((s) => s.status, 'status', AudioPlaybackStatus.loading)
            .having((s) => s.textId, 'textId', 'didache')
            .having((s) => s.chapterIndex, 'chapterIndex', 0),
        isA<AudioState>()
            .having((s) => s.status, 'status', AudioPlaybackStatus.playing),
      ],
      verify: (_) {
        verify(() => mockPlayer.setFilePath('/tmp/test.mp3')).called(1);
        verify(() => mockPlayer.setSpeed(1.0)).called(1);
        verify(() => mockPlayer.play()).called(1);
      },
    );

    blocTest<AudioBloc, AudioState>(
      'AudioPlayRequested emits error when setFilePath fails',
      build: () {
        when(() => mockPlayer.setFilePath(any()))
            .thenThrow(Exception('File not found'));
        return AudioBloc(player: mockPlayer);
      },
      act: (bloc) => bloc.add(const AudioPlayRequested(
        textId: 'didache',
        chapterIndex: 0,
        filePath: '/tmp/missing.mp3',
      )),
      expect: () => [
        isA<AudioState>()
            .having((s) => s.status, 'status', AudioPlaybackStatus.loading),
        isA<AudioState>()
            .having((s) => s.status, 'status', AudioPlaybackStatus.error)
            .having(
                (s) => s.errorMessage, 'errorMessage', contains('File not found')),
      ],
    );

    blocTest<AudioBloc, AudioState>(
      'AudioPauseRequested emits paused state',
      build: () => AudioBloc(player: mockPlayer),
      seed: () => const AudioState(status: AudioPlaybackStatus.playing),
      act: (bloc) => bloc.add(const AudioPauseRequested()),
      expect: () => [
        isA<AudioState>()
            .having((s) => s.status, 'status', AudioPlaybackStatus.paused),
      ],
      verify: (_) {
        verify(() => mockPlayer.pause()).called(1);
      },
    );

    blocTest<AudioBloc, AudioState>(
      'AudioResumeRequested emits playing state',
      build: () => AudioBloc(player: mockPlayer),
      seed: () => const AudioState(status: AudioPlaybackStatus.paused),
      act: (bloc) => bloc.add(const AudioResumeRequested()),
      expect: () => [
        isA<AudioState>()
            .having((s) => s.status, 'status', AudioPlaybackStatus.playing),
      ],
      verify: (_) {
        verify(() => mockPlayer.play()).called(1);
      },
    );

    blocTest<AudioBloc, AudioState>(
      'AudioStopRequested resets to idle state',
      build: () => AudioBloc(player: mockPlayer),
      seed: () => const AudioState(
        status: AudioPlaybackStatus.playing,
        textId: 'didache',
        chapterIndex: 2,
        position: Duration(seconds: 30),
        duration: Duration(minutes: 5),
      ),
      act: (bloc) => bloc.add(const AudioStopRequested()),
      expect: () => [const AudioState()],
      verify: (_) {
        verify(() => mockPlayer.stop()).called(1);
      },
    );

    blocTest<AudioBloc, AudioState>(
      'AudioSeekRequested calls player seek',
      build: () => AudioBloc(player: mockPlayer),
      seed: () => const AudioState(status: AudioPlaybackStatus.playing),
      act: (bloc) => bloc.add(
        const AudioSeekRequested(position: Duration(seconds: 45)),
      ),
      expect: () => [],
      verify: (_) {
        verify(() => mockPlayer.seek(const Duration(seconds: 45))).called(1);
      },
    );

    blocTest<AudioBloc, AudioState>(
      'AudioSkipForwardRequested seeks forward 15 seconds',
      build: () => AudioBloc(player: mockPlayer),
      seed: () => const AudioState(
        status: AudioPlaybackStatus.playing,
        position: Duration(seconds: 30),
        duration: Duration(minutes: 5),
      ),
      act: (bloc) => bloc.add(const AudioSkipForwardRequested()),
      expect: () => [],
      verify: (_) {
        verify(() => mockPlayer.seek(const Duration(seconds: 45))).called(1);
      },
    );

    blocTest<AudioBloc, AudioState>(
      'AudioSkipForwardRequested clamps to duration',
      build: () => AudioBloc(player: mockPlayer),
      seed: () => const AudioState(
        status: AudioPlaybackStatus.playing,
        position: Duration(seconds: 55),
        duration: Duration(minutes: 1),
      ),
      act: (bloc) => bloc.add(const AudioSkipForwardRequested()),
      expect: () => [],
      verify: (_) {
        // 55 + 15 = 70s > 60s, should clamp to 60s
        verify(() => mockPlayer.seek(const Duration(minutes: 1))).called(1);
      },
    );

    blocTest<AudioBloc, AudioState>(
      'AudioSkipBackwardRequested seeks backward 15 seconds',
      build: () => AudioBloc(player: mockPlayer),
      seed: () => const AudioState(
        status: AudioPlaybackStatus.playing,
        position: Duration(seconds: 30),
        duration: Duration(minutes: 5),
      ),
      act: (bloc) => bloc.add(const AudioSkipBackwardRequested()),
      expect: () => [],
      verify: (_) {
        verify(() => mockPlayer.seek(const Duration(seconds: 15))).called(1);
      },
    );

    blocTest<AudioBloc, AudioState>(
      'AudioSkipBackwardRequested clamps to zero',
      build: () => AudioBloc(player: mockPlayer),
      seed: () => const AudioState(
        status: AudioPlaybackStatus.playing,
        position: Duration(seconds: 5),
        duration: Duration(minutes: 5),
      ),
      act: (bloc) => bloc.add(const AudioSkipBackwardRequested()),
      expect: () => [],
      verify: (_) {
        verify(() => mockPlayer.seek(Duration.zero)).called(1);
      },
    );

    blocTest<AudioBloc, AudioState>(
      'AudioSpeedChanged updates speed and calls player',
      build: () => AudioBloc(player: mockPlayer),
      seed: () => const AudioState(status: AudioPlaybackStatus.playing),
      act: (bloc) => bloc.add(const AudioSpeedChanged(speed: 1.5)),
      expect: () => [
        isA<AudioState>().having((s) => s.speed, 'speed', 1.5),
      ],
      verify: (_) {
        verify(() => mockPlayer.setSpeed(1.5)).called(1);
      },
    );

    blocTest<AudioBloc, AudioState>(
      'AudioPositionUpdated updates position and duration',
      build: () => AudioBloc(player: mockPlayer),
      seed: () => const AudioState(status: AudioPlaybackStatus.playing),
      act: (bloc) => bloc.add(const AudioPositionUpdated(
        position: Duration(seconds: 42),
        duration: Duration(minutes: 3),
      )),
      expect: () => [
        isA<AudioState>()
            .having(
                (s) => s.position, 'position', const Duration(seconds: 42))
            .having(
                (s) => s.duration, 'duration', const Duration(minutes: 3)),
      ],
    );

    blocTest<AudioBloc, AudioState>(
      'AudioPlaybackCompleted emits completed status',
      build: () => AudioBloc(player: mockPlayer),
      seed: () => const AudioState(status: AudioPlaybackStatus.playing),
      act: (bloc) => bloc.add(const AudioPlaybackCompleted()),
      expect: () => [
        isA<AudioState>()
            .having((s) => s.status, 'status', AudioPlaybackStatus.completed),
      ],
    );

    blocTest<AudioBloc, AudioState>(
      'AudioSleepTimerSet with duration sets sleep timer',
      build: () => AudioBloc(player: mockPlayer),
      seed: () => const AudioState(status: AudioPlaybackStatus.playing),
      act: (bloc) => bloc.add(
        const AudioSleepTimerSet(duration: Duration(minutes: 15)),
      ),
      expect: () => [
        isA<AudioState>().having((s) => s.sleepTimerRemaining,
            'sleepTimerRemaining', const Duration(minutes: 15)),
      ],
    );

    blocTest<AudioBloc, AudioState>(
      'AudioSleepTimerSet with null cancels sleep timer',
      build: () => AudioBloc(player: mockPlayer),
      seed: () => const AudioState(
        status: AudioPlaybackStatus.playing,
        sleepTimerRemaining: Duration(minutes: 15),
      ),
      act: (bloc) => bloc.add(const AudioSleepTimerSet(duration: null)),
      expect: () => [
        isA<AudioState>()
            .having((s) => s.sleepTimerRemaining, 'sleepTimerRemaining', isNull),
      ],
    );

    blocTest<AudioBloc, AudioState>(
      'AudioSleepTimerExpired pauses and clears timer',
      build: () => AudioBloc(player: mockPlayer),
      seed: () => const AudioState(
        status: AudioPlaybackStatus.playing,
        sleepTimerRemaining: Duration(minutes: 5),
      ),
      act: (bloc) => bloc.add(const AudioSleepTimerExpired()),
      expect: () => [
        isA<AudioState>()
            .having((s) => s.status, 'status', AudioPlaybackStatus.paused)
            .having(
                (s) => s.sleepTimerRemaining, 'sleepTimerRemaining', isNull),
      ],
      verify: (_) {
        verify(() => mockPlayer.pause()).called(1);
      },
    );

    test('dispose cancels subscriptions and disposes player', () async {
      final bloc = AudioBloc(player: mockPlayer);
      await bloc.close();
      verify(() => mockPlayer.dispose()).called(1);
    });
  });

  group('AudioEvent', () {
    test('AudioPlayRequested props', () {
      const event = AudioPlayRequested(
        textId: 'test',
        chapterIndex: 1,
        filePath: '/path',
      );
      expect(event.props, ['test', 1, '/path']);
    });

    test('AudioSeekRequested props', () {
      const event = AudioSeekRequested(position: Duration(seconds: 10));
      expect(event.props, [const Duration(seconds: 10)]);
    });

    test('AudioSpeedChanged props', () {
      const event = AudioSpeedChanged(speed: 1.5);
      expect(event.props, [1.5]);
    });

    test('AudioSleepTimerSet props', () {
      const event = AudioSleepTimerSet(duration: Duration(minutes: 15));
      expect(event.props, [const Duration(minutes: 15)]);
    });

    test('AudioPositionUpdated props', () {
      const event = AudioPositionUpdated(
        position: Duration(seconds: 30),
        duration: Duration(minutes: 5),
      );
      expect(
          event.props, [const Duration(seconds: 30), const Duration(minutes: 5)]);
    });

    test('stateless events have empty props', () {
      expect(const AudioPauseRequested().props, isEmpty);
      expect(const AudioResumeRequested().props, isEmpty);
      expect(const AudioStopRequested().props, isEmpty);
      expect(const AudioSkipForwardRequested().props, isEmpty);
      expect(const AudioSkipBackwardRequested().props, isEmpty);
      expect(const AudioPlaybackCompleted().props, isEmpty);
      expect(const AudioSleepTimerExpired().props, isEmpty);
    });
  });
}
