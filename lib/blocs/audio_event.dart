import 'package:equatable/equatable.dart';

sealed class AudioEvent extends Equatable {
  const AudioEvent();

  @override
  List<Object?> get props => [];
}

class AudioPlayRequested extends AudioEvent {
  const AudioPlayRequested({
    required this.textId,
    required this.chapterIndex,
    required this.filePath,
  });
  final String textId;
  final int chapterIndex;
  final String filePath;

  @override
  List<Object?> get props => [textId, chapterIndex, filePath];
}

class AudioPauseRequested extends AudioEvent {
  const AudioPauseRequested();
}

class AudioResumeRequested extends AudioEvent {
  const AudioResumeRequested();
}

class AudioStopRequested extends AudioEvent {
  const AudioStopRequested();
}

class AudioSeekRequested extends AudioEvent {
  const AudioSeekRequested({required this.position});
  final Duration position;

  @override
  List<Object?> get props => [position];
}

class AudioSkipForwardRequested extends AudioEvent {
  const AudioSkipForwardRequested();
}

class AudioSkipBackwardRequested extends AudioEvent {
  const AudioSkipBackwardRequested();
}

class AudioSpeedChanged extends AudioEvent {
  const AudioSpeedChanged({required this.speed});
  final double speed;

  @override
  List<Object?> get props => [speed];
}

class AudioSleepTimerSet extends AudioEvent {
  const AudioSleepTimerSet({required this.duration});
  final Duration? duration; // null to cancel

  @override
  List<Object?> get props => [duration];
}

class AudioPositionUpdated extends AudioEvent {
  const AudioPositionUpdated({
    required this.position,
    required this.duration,
  });
  final Duration position;
  final Duration duration;

  @override
  List<Object?> get props => [position, duration];
}

class AudioPlaybackCompleted extends AudioEvent {
  const AudioPlaybackCompleted();
}

class AudioSleepTimerExpired extends AudioEvent {
  const AudioSleepTimerExpired();
}
