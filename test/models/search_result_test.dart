import 'package:flutter_test/flutter_test.dart';
import 'package:patres/models/search_result.dart';

void main() {
  group('SearchResult', () {
    test('equality based on all fields', () {
      const a = SearchResult(
        textId: 'augustyn-wyznania',
        bookTitle: 'Wyznania',
        bookAuthor: 'Św. Augustyn',
        chapterIndex: 3,
        chapterTitle: 'Księga IV',
        snippet: '…tekst z <b>wyszukiwanym</b> fragmentem…',
      );
      const b = SearchResult(
        textId: 'augustyn-wyznania',
        bookTitle: 'Wyznania',
        bookAuthor: 'Św. Augustyn',
        chapterIndex: 3,
        chapterTitle: 'Księga IV',
        snippet: '…tekst z <b>wyszukiwanym</b> fragmentem…',
      );
      expect(a, equals(b));
    });

    test('different snippet means not equal', () {
      const a = SearchResult(
        textId: 'augustyn-wyznania',
        bookTitle: 'Wyznania',
        bookAuthor: 'Św. Augustyn',
        chapterIndex: 3,
        chapterTitle: 'Księga IV',
        snippet: 'snippet A',
      );
      const b = SearchResult(
        textId: 'augustyn-wyznania',
        bookTitle: 'Wyznania',
        bookAuthor: 'Św. Augustyn',
        chapterIndex: 3,
        chapterTitle: 'Księga IV',
        snippet: 'snippet B',
      );
      expect(a, isNot(equals(b)));
    });
  });
}
