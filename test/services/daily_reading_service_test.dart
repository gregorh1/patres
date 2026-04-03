import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patres/services/daily_reading_service.dart';

class _FakeAssetBundle extends CachingAssetBundle {
  final List<Map<String, dynamic>> readings;

  _FakeAssetBundle(this.readings);

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (key == 'assets/daily_readings.json') {
      return json.encode(readings);
    }
    throw Exception('Asset not found: $key');
  }

  @override
  Future<ByteData> load(String key) async {
    throw UnimplementedError();
  }
}

void main() {
  final testReadings = List.generate(
    10,
    (i) => {
      'textId': 'text-$i',
      'chapterIndex': i,
      'paragraphIndex': 0,
      'quote': 'Quote $i',
      'author': 'Author $i',
    },
  );

  group('DailyReadingService', () {
    test('getReadingForDate returns reading based on day of year', () async {
      final bundle = _FakeAssetBundle(testReadings);
      final service = DailyReadingService(assetBundle: bundle);

      // Jan 1 = day 0, so index = 0 % 10 = 0
      final jan1 = DateTime(2026, 1, 1);
      final reading1 = await service.getReadingForDate(jan1);
      expect(reading1.textId, 'text-0');
      expect(reading1.quote, 'Quote 0');

      // Jan 5 = day 4, so index = 4 % 10 = 4
      final jan5 = DateTime(2026, 1, 5);
      final reading5 = await service.getReadingForDate(jan5);
      expect(reading5.textId, 'text-4');

      // Jan 11 = day 10, so index = 10 % 10 = 0 (wraps)
      final jan11 = DateTime(2026, 1, 11);
      final readingWrap = await service.getReadingForDate(jan11);
      expect(readingWrap.textId, 'text-0');
    });

    test('different days return different readings', () async {
      final bundle = _FakeAssetBundle(testReadings);
      final service = DailyReadingService(assetBundle: bundle);

      final r1 = await service.getReadingForDate(DateTime(2026, 3, 1));
      final r2 = await service.getReadingForDate(DateTime(2026, 3, 2));
      expect(r1, isNot(equals(r2)));
    });

    test('getTodaysReading returns a valid reading', () async {
      final bundle = _FakeAssetBundle(testReadings);
      final service = DailyReadingService(assetBundle: bundle);

      final reading = await service.getTodaysReading();
      expect(reading.textId, startsWith('text-'));
      expect(reading.quote, startsWith('Quote'));
    });
  });
}
