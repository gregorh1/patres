import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:patres/blocs/tts_generation_event.dart';
import 'package:patres/blocs/tts_generation_state.dart';
import 'package:patres/services/audio_service.dart';

class TtsGenerationBloc
    extends Bloc<TtsGenerationEvent, TtsGenerationState> {
  TtsGenerationBloc({required TtsAudioService audioService})
      : _audioService = audioService,
        super(const TtsGenerationState()) {
    on<TtsGenerateChapterRequested>(_onGenerateChapter);
    on<TtsGenerateTextRequested>(_onGenerateText);
    on<TtsCancelRequested>(_onCancel);
    on<TtsDeleteTextAudio>(_onDeleteTextAudio);
    on<TtsLoadCacheStatus>(_onLoadCacheStatus);
  }

  final TtsAudioService _audioService;
  bool _cancelled = false;

  Future<void> _onGenerateChapter(
    TtsGenerateChapterRequested event,
    Emitter<TtsGenerationState> emit,
  ) async {
    _cancelled = false;
    emit(state.copyWith(
      status: TtsGenerationStatus.generating,
      currentTextId: event.textId,
      currentChapterIndex: event.chapterIndex,
      completedChapters: 0,
      totalChapters: 1,
      clearError: true,
    ));

    try {
      await _audioService.generateChapterAudio(
        textId: event.textId,
        chapterIndex: event.chapterIndex,
        chapterContent: event.chapterContent,
        onProgress: (completed, total) {
          if (!_cancelled) {
            // Can't emit from callback — progress tracked via chunks
          }
        },
      );

      if (_cancelled) return;

      final cachedIds = await TtsAudioService.getCachedTextIds();
      final cacheSize = await TtsAudioService.getCachedAudioSize();

      emit(state.copyWith(
        status: TtsGenerationStatus.completed,
        completedChapters: 1,
        cachedTextIds: cachedIds,
        totalCacheSize: cacheSize,
      ));
    } catch (e) {
      if (_cancelled) return;
      emit(state.copyWith(
        status: TtsGenerationStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onGenerateText(
    TtsGenerateTextRequested event,
    Emitter<TtsGenerationState> emit,
  ) async {
    _cancelled = false;
    emit(state.copyWith(
      status: TtsGenerationStatus.generating,
      currentTextId: event.textId,
      completedChapters: 0,
      totalChapters: event.chapterContents.length,
      clearError: true,
    ));

    try {
      for (var i = 0; i < event.chapterContents.length; i++) {
        if (_cancelled) return;

        emit(state.copyWith(currentChapterIndex: i));

        await _audioService.generateChapterAudio(
          textId: event.textId,
          chapterIndex: i,
          chapterContent: event.chapterContents[i],
        );

        emit(state.copyWith(completedChapters: i + 1));
      }

      if (_cancelled) return;

      final cachedIds = await TtsAudioService.getCachedTextIds();
      final cacheSize = await TtsAudioService.getCachedAudioSize();

      emit(state.copyWith(
        status: TtsGenerationStatus.completed,
        cachedTextIds: cachedIds,
        totalCacheSize: cacheSize,
        clearCurrentText: true,
      ));
    } catch (e) {
      if (_cancelled) return;
      emit(state.copyWith(
        status: TtsGenerationStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onCancel(
    TtsCancelRequested event,
    Emitter<TtsGenerationState> emit,
  ) {
    _cancelled = true;
    emit(state.copyWith(
      status: TtsGenerationStatus.idle,
      clearCurrentText: true,
    ));
  }

  Future<void> _onDeleteTextAudio(
    TtsDeleteTextAudio event,
    Emitter<TtsGenerationState> emit,
  ) async {
    await TtsAudioService.deleteTextAudio(event.textId);
    final cachedIds = await TtsAudioService.getCachedTextIds();
    final cacheSize = await TtsAudioService.getCachedAudioSize();
    emit(state.copyWith(
      cachedTextIds: cachedIds,
      totalCacheSize: cacheSize,
    ));
  }

  Future<void> _onLoadCacheStatus(
    TtsLoadCacheStatus event,
    Emitter<TtsGenerationState> emit,
  ) async {
    final cachedIds = await TtsAudioService.getCachedTextIds();
    final cacheSize = await TtsAudioService.getCachedAudioSize();
    emit(state.copyWith(
      cachedTextIds: cachedIds,
      totalCacheSize: cacheSize,
    ));
  }
}
