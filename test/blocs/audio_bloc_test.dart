import 'package:flutter_test/flutter_test.dart';
import 'package:patres/blocs/audio_state.dart';

void main() {
  // AudioBloc requires just_audio's AudioPlayer which uses platform channels.
  // We test the state logic directly since the bloc delegates to AudioPlayer
  // for actual playback which cannot be unit tested without a mock player.

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
}
