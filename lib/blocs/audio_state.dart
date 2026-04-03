import 'package:equatable/equatable.dart';

enum AudioPlaybackStatus { idle, loading, playing, paused, completed, error }

class AudioState extends Equatable {
  const AudioState({
    this.status = AudioPlaybackStatus.idle,
    this.textId,
    this.chapterIndex,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.speed = 1.0,
    this.sleepTimerRemaining,
    this.errorMessage,
  });

  final AudioPlaybackStatus status;
  final String? textId;
  final int? chapterIndex;
  final Duration position;
  final Duration duration;
  final double speed;
  final Duration? sleepTimerRemaining;
  final String? errorMessage;

  static const speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  bool get isPlaying => status == AudioPlaybackStatus.playing;
  bool get isPaused => status == AudioPlaybackStatus.paused;
  bool get isActive =>
      status == AudioPlaybackStatus.playing ||
      status == AudioPlaybackStatus.paused;

  double get progress {
    if (duration.inMilliseconds == 0) return 0;
    return position.inMilliseconds / duration.inMilliseconds;
  }

  AudioState copyWith({
    AudioPlaybackStatus? status,
    String? textId,
    int? chapterIndex,
    Duration? position,
    Duration? duration,
    double? speed,
    Duration? sleepTimerRemaining,
    String? errorMessage,
    bool clearSleepTimer = false,
    bool clearError = false,
  }) {
    return AudioState(
      status: status ?? this.status,
      textId: textId ?? this.textId,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      speed: speed ?? this.speed,
      sleepTimerRemaining:
          clearSleepTimer ? null : sleepTimerRemaining ?? this.sleepTimerRemaining,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        textId,
        chapterIndex,
        position,
        duration,
        speed,
        sleepTimerRemaining,
        errorMessage,
      ];
}
