import 'package:flutter_test/flutter_test.dart';
import 'package:patres/models/text_entry.dart';

void main() {
  group('TextEntry', () {
    test('fromJson creates entry from valid JSON', () {
      final json = {
        'id': 'didache',
        'file': 'didache.json',
        'title': 'Didache',
        'titleOriginal': 'Διδαχή',
        'author': 'Anonim',
        'era': 'I-II w.',
        'category': 'patrystyka',
        'language': 'pl',
        'chaptersCount': 6,
        'status': 'complete',
      };

      final entry = TextEntry.fromJson(json);

      expect(entry.id, 'didache');
      expect(entry.title, 'Didache');
      expect(entry.titleOriginal, 'Διδαχή');
      expect(entry.author, 'Anonim');
      expect(entry.era, 'I-II w.');
      expect(entry.category, 'patrystyka');
      expect(entry.chaptersCount, 6);
      expect(entry.status, 'complete');
    });

    test('fromJson uses defaults for missing optional fields', () {
      final json = {
        'id': 'test',
        'file': 'test.json',
        'title': 'Test',
        'author': 'Author',
        'era': 'I w.',
        'category': 'patrystyka',
      };

      final entry = TextEntry.fromJson(json);

      expect(entry.titleOriginal, '');
      expect(entry.language, 'pl');
      expect(entry.chaptersCount, 0);
      expect(entry.status, 'placeholder');
    });

    test('eraSortKey extracts numeric value from era', () {
      const entry = TextEntry(
        id: 'test',
        file: 'test.json',
        title: 'Test',
        titleOriginal: '',
        author: 'Author',
        era: 'IV-V w.',
        category: 'patrystyka',
        language: 'pl',
        chaptersCount: 1,
        status: 'complete',
      );

      expect(entry.eraSortKey, 4);
    });

    test('eraSortKey returns 99 for non-numeric era', () {
      const entry = TextEntry(
        id: 'test',
        file: 'test.json',
        title: 'Test',
        titleOriginal: '',
        author: 'Author',
        era: 'unknown',
        category: 'patrystyka',
        language: 'pl',
        chaptersCount: 1,
        status: 'complete',
      );

      expect(entry.eraSortKey, 99);
    });

    test('equality is based on id', () {
      const a = TextEntry(
        id: 'same',
        file: 'a.json',
        title: 'A',
        titleOriginal: '',
        author: 'Author A',
        era: 'I w.',
        category: 'patrystyka',
        language: 'pl',
        chaptersCount: 1,
        status: 'complete',
      );
      const b = TextEntry(
        id: 'same',
        file: 'b.json',
        title: 'B',
        titleOriginal: '',
        author: 'Author B',
        era: 'II w.',
        category: 'monastycyzm',
        language: 'pl',
        chaptersCount: 2,
        status: 'partial',
      );

      expect(a, equals(b));
    });
  });
}
