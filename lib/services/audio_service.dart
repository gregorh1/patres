import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Client for the sound_clearing TTS API.
///
/// Handles authentication, token refresh, text chunking, and local caching
/// of generated MP3 files.
class TtsAudioService {
  TtsAudioService({
    this.baseUrl = 'http://192.168.0.193:8000',
    this.username = 'openclaw',
    this.password = 'wi&SDuKAwtSQirA5DJn2BDFbCjhbWL',
    http.Client? httpClient,
  }) : _client = httpClient ?? http.Client();

  final String baseUrl;
  final String username;
  final String password;
  final http.Client _client;

  String? _token;
  DateTime? _tokenExpiry;

  static const _maxChunkLength = 500;
  static const _tokenLifetime = Duration(minutes: 14); // refresh before 15m

  /// Returns a valid Bearer token, refreshing if needed.
  Future<String> _getToken() async {
    if (_token != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _token!;
    }
    return _authenticate();
  }

  Future<String> _authenticate() async {
    final uri = Uri.parse('$baseUrl/api/auth/login');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw TtsApiException(
        'Authentication failed: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    _token = body['access_token'] as String? ?? body['token'] as String?;
    if (_token == null) {
      throw const TtsApiException('No token in auth response');
    }
    _tokenExpiry = DateTime.now().add(_tokenLifetime);
    return _token!;
  }

  /// Generates TTS audio for a single text chunk.
  /// Returns the raw MP3 bytes.
  Future<List<int>> generateTtsChunk(
    String text, {
    String language = 'pl',
    String format = 'mp3',
  }) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl/api/agent/tts');

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['text'] = text
      ..fields['language'] = language
      ..fields['format'] = format;

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 401) {
      // Token expired, retry once
      _token = null;
      return generateTtsChunk(text, language: language, format: format);
    }

    if (response.statusCode != 200) {
      throw TtsApiException(
        'TTS generation failed: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    return response.bodyBytes;
  }

  /// Splits text into chunks at sentence boundaries, each ≤ [maxLength] chars.
  static List<String> splitTextIntoChunks(String text,
      {int maxLength = _maxChunkLength}) {
    if (text.trim().isEmpty) return [];
    if (text.length <= maxLength) return [text];

    final chunks = <String>[];
    var remaining = text;

    while (remaining.isNotEmpty) {
      if (remaining.length <= maxLength) {
        chunks.add(remaining.trim());
        break;
      }

      // Find the last sentence boundary within maxLength
      var splitIndex = -1;
      for (final delimiter in ['. ', '! ', '? ', '.\n', '!\n', '?\n']) {
        final idx = remaining.lastIndexOf(delimiter, maxLength);
        if (idx > 0 && idx > splitIndex) {
          splitIndex = idx + delimiter.length;
        }
      }

      // Fallback: split at last space
      if (splitIndex <= 0) {
        splitIndex = remaining.lastIndexOf(' ', maxLength);
      }

      // Fallback: force split at maxLength
      if (splitIndex <= 0) {
        splitIndex = maxLength;
      }

      chunks.add(remaining.substring(0, splitIndex).trim());
      remaining = remaining.substring(splitIndex).trim();
    }

    return chunks.where((c) => c.isNotEmpty).toList();
  }

  /// Returns the local audio directory, creating it if needed.
  static Future<Directory> getAudioDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory(p.join(appDir.path, 'audio'));
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return audioDir;
  }

  /// Returns the file path for a cached chapter audio file.
  static Future<String> chapterAudioPath(
      String textId, int chapterIndex) async {
    final audioDir = await getAudioDirectory();
    return p.join(audioDir.path, '${textId}_chapter_$chapterIndex.mp3');
  }

  /// Checks whether a chapter's audio has been generated and cached.
  static Future<bool> isChapterCached(
      String textId, int chapterIndex) async {
    final path = await chapterAudioPath(textId, chapterIndex);
    return File(path).exists();
  }

  /// Generates and caches TTS audio for an entire chapter.
  /// [onProgress] reports progress as (completedChunks, totalChunks).
  Future<String> generateChapterAudio({
    required String textId,
    required int chapterIndex,
    required String chapterContent,
    String language = 'pl',
    void Function(int completed, int total)? onProgress,
  }) async {
    final filePath = await chapterAudioPath(textId, chapterIndex);
    final file = File(filePath);

    // Return cached file if it exists
    if (await file.exists()) {
      return filePath;
    }

    final chunks = splitTextIntoChunks(chapterContent);
    final allBytes = <int>[];

    for (var i = 0; i < chunks.length; i++) {
      final chunkBytes =
          await generateTtsChunk(chunks[i], language: language);
      allBytes.addAll(chunkBytes);
      onProgress?.call(i + 1, chunks.length);
    }

    await file.writeAsBytes(allBytes);
    return filePath;
  }

  /// Generates audio for all chapters of a text.
  /// [onChapterProgress] reports (completedChapters, totalChapters).
  Future<void> generateTextAudio({
    required String textId,
    required List<String> chapterContents,
    String language = 'pl',
    void Function(int completedChapters, int totalChapters)? onChapterProgress,
    void Function(int chapterIndex, int completedChunks, int totalChunks)?
        onChunkProgress,
  }) async {
    for (var i = 0; i < chapterContents.length; i++) {
      await generateChapterAudio(
        textId: textId,
        chapterIndex: i,
        chapterContent: chapterContents[i],
        language: language,
        onProgress: (completed, total) {
          onChunkProgress?.call(i, completed, total);
        },
      );
      onChapterProgress?.call(i + 1, chapterContents.length);
    }
  }

  /// Deletes all cached audio files for a text.
  static Future<void> deleteTextAudio(String textId) async {
    final audioDir = await getAudioDirectory();
    final files = audioDir.listSync();
    for (final file in files) {
      if (file is File && p.basename(file.path).startsWith('${textId}_')) {
        await file.delete();
      }
    }
  }

  /// Returns total size of cached audio in bytes.
  static Future<int> getCachedAudioSize() async {
    final audioDir = await getAudioDirectory();
    if (!await audioDir.exists()) return 0;
    var total = 0;
    await for (final entity in audioDir.list()) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }

  /// Returns list of text IDs that have any cached audio.
  static Future<Set<String>> getCachedTextIds() async {
    final audioDir = await getAudioDirectory();
    if (!await audioDir.exists()) return {};
    final ids = <String>{};
    await for (final entity in audioDir.list()) {
      if (entity is File) {
        final name = p.basenameWithoutExtension(entity.path);
        final match = RegExp(r'^(.+)_chapter_\d+$').firstMatch(name);
        if (match != null) {
          ids.add(match.group(1)!);
        }
      }
    }
    return ids;
  }

  /// Returns count of cached chapters for a text.
  static Future<int> getCachedChapterCount(String textId) async {
    final audioDir = await getAudioDirectory();
    if (!await audioDir.exists()) return 0;
    var count = 0;
    await for (final entity in audioDir.list()) {
      if (entity is File &&
          p.basename(entity.path).startsWith('${textId}_chapter_')) {
        count++;
      }
    }
    return count;
  }

  void dispose() {
    _client.close();
  }
}

class TtsApiException implements Exception {
  const TtsApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => 'TtsApiException: $message';
}
