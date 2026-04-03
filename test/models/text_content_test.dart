import 'package:flutter_test/flutter_test.dart';
import 'package:patres/models/bookmark.dart';
import 'package:patres/models/highlight.dart';
import 'package:patres/models/text_content.dart';

void main() {
  group('TextContent', () {
    test('fromJson parses complete JSON', () {
      final json = {
        'id': 'augustyn-wyznania',
        'title': 'Wyznania',
        'titleOriginal': 'Confessiones',
        'author': 'Św. Augustyn z Hippony',
        'authorOriginal': 'Aurelius Augustinus',
        'era': 'IV-V w.',
        'description': 'Autobiografia duchowa',
        'chapters': [
          {'title': 'Księga I', 'content': 'Wielki jesteś, Panie'},
          {'title': 'Księga II', 'content': 'Pragnę przypomnieć'},
        ],
      };

      final content = TextContent.fromJson(json);

      expect(content.id, 'augustyn-wyznania');
      expect(content.title, 'Wyznania');
      expect(content.titleOriginal, 'Confessiones');
      expect(content.author, 'Św. Augustyn z Hippony');
      expect(content.authorOriginal, 'Aurelius Augustinus');
      expect(content.era, 'IV-V w.');
      expect(content.description, 'Autobiografia duchowa');
      expect(content.chapters.length, 2);
      expect(content.chapters[0].title, 'Księga I');
      expect(content.chapters[1].content, 'Pragnę przypomnieć');
    });

    test('fromJson handles minimal JSON (optional fields null)', () {
      final json = {
        'id': 'test',
        'title': 'Test',
        'author': 'Author',
        'chapters': <Map<String, dynamic>>[],
      };

      final content = TextContent.fromJson(json);

      expect(content.titleOriginal, isNull);
      expect(content.authorOriginal, isNull);
      expect(content.era, isNull);
      expect(content.description, isNull);
      expect(content.chapters, isEmpty);
    });

    test('equality is based on id', () {
      const a = TextContent(
        id: 'same',
        title: 'A',
        author: 'X',
        chapters: [],
      );
      const b = TextContent(
        id: 'same',
        title: 'B',
        author: 'Y',
        chapters: [],
      );

      expect(a, equals(b));
    });
  });

  group('Chapter', () {
    test('fromJson parses correctly', () {
      final json = {
        'title': 'Księga I',
        'content': 'Wielki jesteś',
      };

      final chapter = Chapter.fromJson(json);

      expect(chapter.title, 'Księga I');
      expect(chapter.content, 'Wielki jesteś');
    });
  });

  group('Bookmark', () {
    test('toJson and fromJson round-trip', () {
      final original = Bookmark(
        id: 42,
        textId: 'augustyn',
        chapterIndex: 5,
        timestamp: DateTime.utc(2026, 4, 3, 12, 0),
        note: 'Piękny fragment',
        scrollPosition: 345.5,
      );

      final json = original.toJson();
      final restored = Bookmark.fromJson(json);

      expect(restored.id, 42);
      expect(restored.textId, 'augustyn');
      expect(restored.chapterIndex, 5);
      expect(restored.timestamp, DateTime.utc(2026, 4, 3, 12, 0));
      expect(restored.note, 'Piękny fragment');
      expect(restored.scrollPosition, 345.5);
    });

    test('fromJson handles null note and missing scrollPosition', () {
      final json = {
        'chapterIndex': 0,
        'timestamp': '2026-01-01T00:00:00.000',
      };

      final bookmark = Bookmark.fromJson(json);

      expect(bookmark.id, isNull);
      expect(bookmark.textId, '');
      expect(bookmark.note, isNull);
      expect(bookmark.scrollPosition, 0.0);
    });

    test('copyWith creates modified copy', () {
      final original = Bookmark(
        id: 1,
        textId: 'test',
        chapterIndex: 0,
        timestamp: DateTime(2026, 1, 1),
      );

      final modified = original.copyWith(id: 42, note: 'updated');

      expect(modified.id, 42);
      expect(modified.note, 'updated');
      expect(modified.textId, 'test');
      expect(modified.chapterIndex, 0);
    });
  });

  group('Highlight', () {
    test('toJson and fromJson round-trip', () {
      const original = Highlight(
        id: 7,
        textId: 'augustyn',
        chapterIndex: 2,
        paragraphIndex: 7,
      );

      final json = original.toJson();
      final restored = Highlight.fromJson(json);

      expect(restored.id, 7);
      expect(restored.textId, 'augustyn');
      expect(restored.chapterIndex, 2);
      expect(restored.paragraphIndex, 7);
    });

    test('copyWith creates modified copy', () {
      const original = Highlight(
        id: 1,
        textId: 'test',
        chapterIndex: 0,
        paragraphIndex: 3,
      );

      final modified = original.copyWith(id: 42, textId: 'other');

      expect(modified.id, 42);
      expect(modified.textId, 'other');
      expect(modified.chapterIndex, 0);
      expect(modified.paragraphIndex, 3);
    });
  });
}
