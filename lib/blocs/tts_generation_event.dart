import 'package:equatable/equatable.dart';

sealed class TtsGenerationEvent extends Equatable {
  const TtsGenerationEvent();

  @override
  List<Object?> get props => [];
}

class TtsGenerateChapterRequested extends TtsGenerationEvent {
  const TtsGenerateChapterRequested({
    required this.textId,
    required this.chapterIndex,
    required this.chapterContent,
  });
  final String textId;
  final int chapterIndex;
  final String chapterContent;

  @override
  List<Object?> get props => [textId, chapterIndex, chapterContent];
}

class TtsGenerateTextRequested extends TtsGenerationEvent {
  const TtsGenerateTextRequested({
    required this.textId,
    required this.chapterContents,
  });
  final String textId;
  final List<String> chapterContents;

  @override
  List<Object?> get props => [textId, chapterContents];
}

class TtsCancelRequested extends TtsGenerationEvent {
  const TtsCancelRequested();
}

class TtsDeleteTextAudio extends TtsGenerationEvent {
  const TtsDeleteTextAudio({required this.textId});
  final String textId;

  @override
  List<Object?> get props => [textId];
}

class TtsLoadCacheStatus extends TtsGenerationEvent {
  const TtsLoadCacheStatus();
}
