import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:patres/blocs/tts_generation_bloc.dart';
import 'package:patres/blocs/tts_generation_event.dart';
import 'package:patres/blocs/tts_generation_state.dart';
import 'package:patres/services/audio_service.dart';

void main() {
  group('TtsGenerationBloc', () {
    test('initial state', () {
      final mockClient = MockClient((_) async => http.Response('', 200));
      final service = TtsAudioService(httpClient: mockClient);
      final bloc = TtsGenerationBloc(audioService: service);
      expect(bloc.state.status, TtsGenerationStatus.idle);
      expect(bloc.state.cachedTextIds, isEmpty);
      expect(bloc.state.totalCacheSize, 0);
      bloc.close();
      service.dispose();
    });

    blocTest<TtsGenerationBloc, TtsGenerationState>(
      'TtsCancelRequested resets to idle',
      build: () {
        final mockClient = MockClient((_) async => http.Response('', 200));
        return TtsGenerationBloc(
          audioService: TtsAudioService(httpClient: mockClient),
        );
      },
      seed: () => const TtsGenerationState(
        status: TtsGenerationStatus.generating,
        currentTextId: 'test',
        currentChapterIndex: 0,
      ),
      act: (bloc) => bloc.add(const TtsCancelRequested()),
      expect: () => [
        isA<TtsGenerationState>()
            .having((s) => s.status, 'status', TtsGenerationStatus.idle)
            .having((s) => s.currentTextId, 'currentTextId', isNull),
      ],
    );
  });

  group('TtsGenerationState', () {
    test('chapterProgress calculation', () {
      const state = TtsGenerationState(
        completedChapters: 3,
        totalChapters: 10,
      );
      expect(state.chapterProgress, 0.3);
    });

    test('chapterProgress is 0 when totalChapters is 0', () {
      const state = TtsGenerationState();
      expect(state.chapterProgress, 0);
    });

    test('isGenerating', () {
      expect(
        const TtsGenerationState(status: TtsGenerationStatus.generating)
            .isGenerating,
        isTrue,
      );
      expect(
        const TtsGenerationState(status: TtsGenerationStatus.idle)
            .isGenerating,
        isFalse,
      );
    });

    test('isTextCached', () {
      const state = TtsGenerationState(
        cachedTextIds: {'text-1', 'text-2'},
      );
      expect(state.isTextCached('text-1'), isTrue);
      expect(state.isTextCached('text-3'), isFalse);
    });

    test('cacheSizeFormatted formats bytes', () {
      expect(
        const TtsGenerationState(totalCacheSize: 500).cacheSizeFormatted,
        '500 B',
      );
    });

    test('cacheSizeFormatted formats kilobytes', () {
      expect(
        const TtsGenerationState(totalCacheSize: 2048).cacheSizeFormatted,
        '2.0 KB',
      );
    });

    test('cacheSizeFormatted formats megabytes', () {
      expect(
        const TtsGenerationState(totalCacheSize: 5 * 1024 * 1024)
            .cacheSizeFormatted,
        '5.0 MB',
      );
    });

    test('copyWith preserves values', () {
      const state = TtsGenerationState(
        status: TtsGenerationStatus.generating,
        currentTextId: 'test',
        completedChapters: 5,
        totalChapters: 10,
      );
      final updated = state.copyWith(completedChapters: 6);
      expect(updated.completedChapters, 6);
      expect(updated.currentTextId, 'test');
      expect(updated.totalChapters, 10);
    });

    test('copyWith clearCurrentText', () {
      const state = TtsGenerationState(
        currentTextId: 'test',
        currentChapterIndex: 3,
      );
      final updated = state.copyWith(clearCurrentText: true);
      expect(updated.currentTextId, isNull);
      expect(updated.currentChapterIndex, isNull);
    });
  });
}
