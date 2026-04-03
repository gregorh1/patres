import 'package:flutter_test/flutter_test.dart';
import 'package:patres/services/audio_service.dart';

void main() {
  group('TtsAudioService.splitTextIntoChunks', () {
    test('returns single chunk for short text', () {
      final chunks = TtsAudioService.splitTextIntoChunks('Hello world.');
      expect(chunks, ['Hello world.']);
    });

    test('returns single chunk when text equals max length', () {
      final text = 'a' * 500;
      final chunks = TtsAudioService.splitTextIntoChunks(text);
      expect(chunks, [text]);
    });

    test('splits at sentence boundary', () {
      final text =
          '${'A' * 250}. ${'B' * 250}. ${'C' * 100}.';
      final chunks = TtsAudioService.splitTextIntoChunks(text);
      expect(chunks.length, greaterThan(1));
      // Each chunk should end with a period (sentence boundary)
      for (final chunk in chunks) {
        expect(chunk, endsWith('.'));
      }
    });

    test('splits at space when no sentence boundary found', () {
      // Text with no sentence-ending punctuation
      final words = List.generate(100, (i) => 'word$i').join(' ');
      final chunks = TtsAudioService.splitTextIntoChunks(words, maxLength: 50);
      expect(chunks.length, greaterThan(1));
      for (final chunk in chunks) {
        expect(chunk.length, lessThanOrEqualTo(50));
      }
    });

    test('handles empty string', () {
      final chunks = TtsAudioService.splitTextIntoChunks('');
      expect(chunks, isEmpty);
    });

    test('handles whitespace-only string', () {
      final chunks = TtsAudioService.splitTextIntoChunks('   ');
      expect(chunks, isEmpty);
    });

    test('respects max length constraint', () {
      final text =
          'First sentence is here. Second sentence is there. '
          'Third sentence comes next. Fourth sentence is last.';
      final chunks = TtsAudioService.splitTextIntoChunks(text, maxLength: 60);
      for (final chunk in chunks) {
        expect(chunk.length, lessThanOrEqualTo(60));
      }
    });

    test('preserves all content when splitting', () {
      final text = 'Hello world. This is a test. Another sentence here.';
      final chunks = TtsAudioService.splitTextIntoChunks(text, maxLength: 30);
      final rejoined = chunks.join(' ');
      // All words should be present
      expect(rejoined, contains('Hello'));
      expect(rejoined, contains('test'));
      expect(rejoined, contains('sentence'));
    });

    test('handles exclamation and question marks as boundaries', () {
      final text =
          '${'A' * 200}! ${'B' * 200}? ${'C' * 100}.';
      final chunks = TtsAudioService.splitTextIntoChunks(text);
      expect(chunks.length, greaterThan(1));
    });
  });

  group('TtsApiException', () {
    test('toString includes message', () {
      const ex = TtsApiException('test error', statusCode: 401);
      expect(ex.toString(), contains('test error'));
      expect(ex.statusCode, 401);
    });

    test('works without statusCode', () {
      const ex = TtsApiException('no code');
      expect(ex.statusCode, isNull);
      expect(ex.message, 'no code');
    });
  });
}
