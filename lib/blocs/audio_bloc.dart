import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

import 'package:patres/blocs/audio_event.dart';
import 'package:patres/blocs/audio_state.dart';

class AudioBloc extends Bloc<AudioEvent, AudioState> {
  AudioBloc({AudioPlayer? player})
      : _player = player ?? AudioPlayer(),
        super(const AudioState()) {
    on<AudioPlayRequested>(_onPlayRequested);
    on<AudioPauseRequested>(_onPauseRequested);
    on<AudioResumeRequested>(_onResumeRequested);
    on<AudioStopRequested>(_onStopRequested);
    on<AudioSeekRequested>(_onSeekRequested);
    on<AudioSkipForwardRequested>(_onSkipForward);
    on<AudioSkipBackwardRequested>(_onSkipBackward);
    on<AudioSpeedChanged>(_onSpeedChanged);
    on<AudioSleepTimerSet>(_onSleepTimerSet);
    on<AudioPositionUpdated>(_onPositionUpdated);
    on<AudioPlaybackCompleted>(_onPlaybackCompleted);
    on<AudioSleepTimerExpired>(_onSleepTimerExpired);

    _setupPlayerListeners();
  }

  final AudioPlayer _player;
  StreamSubscription<void>? _positionSub;
  StreamSubscription<PlayerState>? _playerStateSub;
  Timer? _sleepTimer;

  void _setupPlayerListeners() {
    // Combine position and duration streams
    _positionSub = Rx.combineLatest2<Duration, Duration?, void>(
      _player.positionStream,
      _player.durationStream,
      (position, duration) {
        if (duration != null && !isClosed) {
          add(AudioPositionUpdated(
            position: position,
            duration: duration,
          ));
        }
      },
    ).listen((_) {});

    _playerStateSub = _player.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed &&
          !isClosed) {
        add(const AudioPlaybackCompleted());
      }
    });
  }

  Future<void> _onPlayRequested(
    AudioPlayRequested event,
    Emitter<AudioState> emit,
  ) async {
    emit(state.copyWith(
      status: AudioPlaybackStatus.loading,
      textId: event.textId,
      chapterIndex: event.chapterIndex,
      clearError: true,
    ));

    try {
      await _player.setFilePath(event.filePath);
      await _player.setSpeed(state.speed);
      await _player.play();
      emit(state.copyWith(status: AudioPlaybackStatus.playing));
    } catch (e) {
      emit(state.copyWith(
        status: AudioPlaybackStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onPauseRequested(
    AudioPauseRequested event,
    Emitter<AudioState> emit,
  ) async {
    await _player.pause();
    emit(state.copyWith(status: AudioPlaybackStatus.paused));
  }

  Future<void> _onResumeRequested(
    AudioResumeRequested event,
    Emitter<AudioState> emit,
  ) async {
    await _player.play();
    emit(state.copyWith(status: AudioPlaybackStatus.playing));
  }

  Future<void> _onStopRequested(
    AudioStopRequested event,
    Emitter<AudioState> emit,
  ) async {
    await _player.stop();
    _cancelSleepTimer();
    emit(const AudioState());
  }

  Future<void> _onSeekRequested(
    AudioSeekRequested event,
    Emitter<AudioState> emit,
  ) async {
    await _player.seek(event.position);
  }

  Future<void> _onSkipForward(
    AudioSkipForwardRequested event,
    Emitter<AudioState> emit,
  ) async {
    final newPos = state.position + const Duration(seconds: 15);
    final clamped = newPos > state.duration ? state.duration : newPos;
    await _player.seek(clamped);
  }

  Future<void> _onSkipBackward(
    AudioSkipBackwardRequested event,
    Emitter<AudioState> emit,
  ) async {
    final newPos = state.position - const Duration(seconds: 15);
    final clamped = newPos < Duration.zero ? Duration.zero : newPos;
    await _player.seek(clamped);
  }

  Future<void> _onSpeedChanged(
    AudioSpeedChanged event,
    Emitter<AudioState> emit,
  ) async {
    await _player.setSpeed(event.speed);
    emit(state.copyWith(speed: event.speed));
  }

  void _onSleepTimerSet(
    AudioSleepTimerSet event,
    Emitter<AudioState> emit,
  ) {
    _cancelSleepTimer();

    if (event.duration == null) {
      emit(state.copyWith(clearSleepTimer: true));
      return;
    }

    emit(state.copyWith(sleepTimerRemaining: event.duration));
    _sleepTimer = Timer(event.duration!, () {
      if (!isClosed) {
        add(const AudioSleepTimerExpired());
      }
    });
  }

  void _onPositionUpdated(
    AudioPositionUpdated event,
    Emitter<AudioState> emit,
  ) {
    emit(state.copyWith(
      position: event.position,
      duration: event.duration,
    ));
  }

  void _onPlaybackCompleted(
    AudioPlaybackCompleted event,
    Emitter<AudioState> emit,
  ) {
    emit(state.copyWith(status: AudioPlaybackStatus.completed));
  }

  Future<void> _onSleepTimerExpired(
    AudioSleepTimerExpired event,
    Emitter<AudioState> emit,
  ) async {
    await _player.pause();
    emit(state.copyWith(
      status: AudioPlaybackStatus.paused,
      clearSleepTimer: true,
    ));
  }

  void _cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
  }

  @override
  Future<void> close() async {
    _cancelSleepTimer();
    await _positionSub?.cancel();
    await _playerStateSub?.cancel();
    await _player.dispose();
    return super.close();
  }
}
