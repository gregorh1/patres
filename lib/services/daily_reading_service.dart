import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:patres/models/daily_reading.dart';

class DailyReadingService {
  const DailyReadingService({AssetBundle? assetBundle})
      : _assetBundle = assetBundle;

  final AssetBundle? _assetBundle;

  AssetBundle get _bundle => _assetBundle ?? rootBundle;

  Future<DailyReading> getTodaysReading() async {
    final readings = await _loadReadings();
    final dayOfYear = _dayOfYear(DateTime.now());
    final index = dayOfYear % readings.length;
    return readings[index];
  }

  Future<DailyReading> getReadingForDate(DateTime date) async {
    final readings = await _loadReadings();
    final dayOfYear = _dayOfYear(date);
    final index = dayOfYear % readings.length;
    return readings[index];
  }

  Future<List<DailyReading>> _loadReadings() async {
    final jsonString =
        await _bundle.loadString('assets/daily_readings.json');
    final list = json.decode(jsonString) as List<dynamic>;
    return list
        .map((e) => DailyReading.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static int _dayOfYear(DateTime date) {
    final firstDay = DateTime(date.year, 1, 1);
    return date.difference(firstDay).inDays;
  }
}
