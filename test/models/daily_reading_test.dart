import 'package:flutter_test/flutter_test.dart';
import 'package:patres/models/daily_reading.dart';

void main() {
  group('DailyReading', () {
    test('fromJson parses correctly', () {
      final json = {
        'textId': 'augustyn-wyznania',
        'chapterIndex': 3,
        'paragraphIndex': 1,
        'quote': 'Test quote',
        'author': 'Test Author',
      };

      final reading = DailyReading.fromJson(json);

      expect(reading.textId, 'augustyn-wyznania');
      expect(reading.chapterIndex, 3);
      expect(reading.paragraphIndex, 1);
      expect(reading.quote, 'Test quote');
      expect(reading.author, 'Test Author');
    });

    test('supports value equality', () {
      const a = DailyReading(
        textId: 'x',
        chapterIndex: 0,
        paragraphIndex: 0,
        quote: 'q',
        author: 'a',
      );
      const b = DailyReading(
        textId: 'x',
        chapterIndex: 0,
        paragraphIndex: 0,
        quote: 'q',
        author: 'a',
      );
      expect(a, equals(b));
    });
  });
}
