import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
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
      final text = '${'A' * 250}. ${'B' * 250}. ${'C' * 100}.';
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
      final chunks =
          TtsAudioService.splitTextIntoChunks(words, maxLength: 50);
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
      final text = 'First sentence is here. Second sentence is there. '
          'Third sentence comes next. Fourth sentence is last.';
      final chunks =
          TtsAudioService.splitTextIntoChunks(text, maxLength: 60);
      for (final chunk in chunks) {
        expect(chunk.length, lessThanOrEqualTo(60));
      }
    });

    test('preserves all content when splitting', () {
      final text = 'Hello world. This is a test. Another sentence here.';
      final chunks =
          TtsAudioService.splitTextIntoChunks(text, maxLength: 30);
      final rejoined = chunks.join(' ');
      // All words should be present
      expect(rejoined, contains('Hello'));
      expect(rejoined, contains('test'));
      expect(rejoined, contains('sentence'));
    });

    test('handles exclamation and question marks as boundaries', () {
      final text = '${'A' * 200}! ${'B' * 200}? ${'C' * 100}.';
      final chunks = TtsAudioService.splitTextIntoChunks(text);
      expect(chunks.length, greaterThan(1));
    });

    test('splits at newline sentence boundaries', () {
      final text = '${'A' * 250}.\n${'B' * 250}.\n${'C' * 100}.';
      final chunks = TtsAudioService.splitTextIntoChunks(text);
      expect(chunks.length, greaterThan(1));
    });

    test('force splits at maxLength when no boundary found', () {
      // A single long word with no spaces or sentence boundaries
      final text = 'a' * 1000;
      final chunks =
          TtsAudioService.splitTextIntoChunks(text, maxLength: 100);
      expect(chunks.length, greaterThan(1));
      for (final chunk in chunks) {
        expect(chunk.length, lessThanOrEqualTo(100));
      }
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

    test('toString format', () {
      const ex = TtsApiException('fail');
      expect(ex.toString(), 'TtsApiException: fail');
    });
  });

  group('TtsAudioService authentication', () {
    test('authenticates and caches token', () async {
      var authCallCount = 0;
      final mockClient = http_testing.MockClient((request) async {
        if (request.url.path == '/api/auth/login') {
          authCallCount++;
          return http.Response(
            jsonEncode({'access_token': 'test-token-123'}),
            200,
          );
        }
        if (request.url.path == '/api/agent/tts') {
          expect(request.headers['Authorization'], 'Bearer test-token-123');
          return http.Response.bytes([1, 2, 3], 200);
        }
        return http.Response('Not found', 404);
      });

      final service = TtsAudioService(
        baseUrl: 'http://localhost:8000',
        httpClient: mockClient,
      );

      // First call authenticates
      await service.generateTtsChunk('Hello');
      expect(authCallCount, 1);

      // Second call reuses cached token
      await service.generateTtsChunk('World');
      expect(authCallCount, 1);

      service.dispose();
    });

    test('throws TtsApiException on auth failure', () async {
      final mockClient = http_testing.MockClient((request) async {
        if (request.url.path == '/api/auth/login') {
          return http.Response('Unauthorized', 401);
        }
        return http.Response('Not found', 404);
      });

      final service = TtsAudioService(
        baseUrl: 'http://localhost:8000',
        httpClient: mockClient,
      );

      expect(
        () => service.generateTtsChunk('Hello'),
        throwsA(isA<TtsApiException>()
            .having((e) => e.statusCode, 'statusCode', 401)),
      );

      service.dispose();
    });

    test('throws TtsApiException when no token in response', () async {
      final mockClient = http_testing.MockClient((request) async {
        if (request.url.path == '/api/auth/login') {
          return http.Response(jsonEncode({}), 200);
        }
        return http.Response('Not found', 404);
      });

      final service = TtsAudioService(
        baseUrl: 'http://localhost:8000',
        httpClient: mockClient,
      );

      expect(
        () => service.generateTtsChunk('Hello'),
        throwsA(isA<TtsApiException>().having(
            (e) => e.message, 'message', 'No token in auth response')),
      );

      service.dispose();
    });
  });

  group('TtsAudioService.generateTtsChunk', () {
    test('returns audio bytes on success', () async {
      final expectedBytes = [0xFF, 0xFB, 0x90, 0x00];
      final mockClient = http_testing.MockClient((request) async {
        if (request.url.path == '/api/auth/login') {
          return http.Response(
            jsonEncode({'access_token': 'token'}),
            200,
          );
        }
        if (request.url.path == '/api/agent/tts') {
          return http.Response.bytes(expectedBytes, 200);
        }
        return http.Response('Not found', 404);
      });

      final service = TtsAudioService(
        baseUrl: 'http://localhost:8000',
        httpClient: mockClient,
      );

      final result = await service.generateTtsChunk('Test text');
      expect(result, expectedBytes);

      service.dispose();
    });

    test('throws TtsApiException on TTS generation failure', () async {
      final mockClient = http_testing.MockClient((request) async {
        if (request.url.path == '/api/auth/login') {
          return http.Response(
            jsonEncode({'access_token': 'token'}),
            200,
          );
        }
        if (request.url.path == '/api/agent/tts') {
          return http.Response('Server error', 500);
        }
        return http.Response('Not found', 404);
      });

      final service = TtsAudioService(
        baseUrl: 'http://localhost:8000',
        httpClient: mockClient,
      );

      expect(
        () => service.generateTtsChunk('Test text'),
        throwsA(isA<TtsApiException>()
            .having((e) => e.statusCode, 'statusCode', 500)),
      );

      service.dispose();
    });

    test('retries authentication on 401 response', () async {
      var ttsCallCount = 0;
      var authCallCount = 0;

      final mockClient = http_testing.MockClient((request) async {
        if (request.url.path == '/api/auth/login') {
          authCallCount++;
          return http.Response(
            jsonEncode({'access_token': 'new-token-$authCallCount'}),
            200,
          );
        }
        if (request.url.path == '/api/agent/tts') {
          ttsCallCount++;
          if (ttsCallCount == 1) {
            return http.Response('Unauthorized', 401);
          }
          return http.Response.bytes([1, 2, 3], 200);
        }
        return http.Response('Not found', 404);
      });

      final service = TtsAudioService(
        baseUrl: 'http://localhost:8000',
        httpClient: mockClient,
      );

      final result = await service.generateTtsChunk('Test');
      expect(result, [1, 2, 3]);
      expect(authCallCount, 2);

      service.dispose();
    });

    test('accepts token field in auth response', () async {
      final mockClient = http_testing.MockClient((request) async {
        if (request.url.path == '/api/auth/login') {
          return http.Response(
            jsonEncode({'token': 'alt-token'}),
            200,
          );
        }
        if (request.url.path == '/api/agent/tts') {
          expect(request.headers['Authorization'], 'Bearer alt-token');
          return http.Response.bytes([1], 200);
        }
        return http.Response('Not found', 404);
      });

      final service = TtsAudioService(
        baseUrl: 'http://localhost:8000',
        httpClient: mockClient,
      );

      final result = await service.generateTtsChunk('Test');
      expect(result, [1]);

      service.dispose();
    });
  });

  group('TtsAudioService constructor', () {
    test('uses default values', () {
      final service = TtsAudioService();
      expect(service.baseUrl, 'http://192.168.0.193:8000');
      expect(service.username, 'openclaw');
      service.dispose();
    });

    test('accepts custom values', () {
      final service = TtsAudioService(
        baseUrl: 'http://custom:9000',
        username: 'user',
        password: 'pass',
      );
      expect(service.baseUrl, 'http://custom:9000');
      expect(service.username, 'user');
      service.dispose();
    });
  });
}
