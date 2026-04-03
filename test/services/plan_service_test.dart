import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patres/services/database_service.dart';
import 'package:patres/services/plan_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const _plansJson = '''
{
  "version": "1.0.0",
  "plans": [
    {
      "id": "test-plan",
      "title": "Test Plan",
      "description": "A test reading plan",
      "totalDays": 3,
      "icon": "school",
      "days": [
        {"day": 1, "title": "Day 1", "textId": "didache", "chapterIndex": 0, "description": "First day"},
        {"day": 2, "title": "Day 2", "textId": "didache", "chapterIndex": 1, "description": "Second day"},
        {"day": 3, "title": "Day 3", "textId": "didache", "chapterIndex": 2, "description": "Third day"}
      ]
    }
  ]
}
''';

class _FakeAssetBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (key == 'assets/reading_plans.json') {
      return _plansJson;
    }
    throw FlutterError('Asset not found: $key');
  }

  @override
  Future<ByteData> load(String key) async {
    final str = await loadString(key);
    return ByteData.view(Uint8List.fromList(utf8.encode(str)).buffer);
  }
}

Future<DatabaseService> _createTestDb() async {
  final db = await databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE plan_progress (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            plan_id TEXT NOT NULL,
            started_at TEXT NOT NULL,
            current_streak INTEGER NOT NULL DEFAULT 0,
            longest_streak INTEGER NOT NULL DEFAULT 0,
            last_completed_at TEXT,
            UNIQUE(plan_id)
          )
        ''');
        await db.execute('''
          CREATE TABLE plan_day_completions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            plan_id TEXT NOT NULL,
            day_number INTEGER NOT NULL,
            completed_at TEXT NOT NULL,
            UNIQUE(plan_id, day_number)
          )
        ''');
      },
    ),
  );
  return DatabaseService(database: db);
}

void main() {
  late DatabaseService dbService;
  late PlanService planService;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    dbService = await _createTestDb();
    planService = PlanService(
      databaseService: dbService,
      assetBundle: _FakeAssetBundle(),
    );
  });

  tearDown(() async {
    await dbService.close();
  });

  group('PlanService', () {
    test('loadPlans parses plans from JSON asset', () async {
      final plans = await planService.loadPlans();

      expect(plans, hasLength(1));
      expect(plans[0].id, 'test-plan');
      expect(plans[0].title, 'Test Plan');
      expect(plans[0].totalDays, 3);
      expect(plans[0].days, hasLength(3));
    });

    test('getProgress returns empty progress for new plan', () async {
      final progress = await planService.getProgress('test-plan');

      expect(progress.planId, 'test-plan');
      expect(progress.isStarted, isFalse);
      expect(progress.completedDays, isEmpty);
      expect(progress.currentStreak, 0);
    });

    test('startPlan creates progress entry', () async {
      await planService.startPlan('test-plan');
      final progress = await planService.getProgress('test-plan');

      expect(progress.isStarted, isTrue);
      expect(progress.completedDays, isEmpty);
    });

    test('toggleDay completes a day', () async {
      await planService.startPlan('test-plan');
      final progress = await planService.toggleDay('test-plan', 1, 3);

      expect(progress.completedDays, contains(1));
      expect(progress.currentStreak, 1);
    });

    test('toggleDay uncompletes a completed day', () async {
      await planService.startPlan('test-plan');
      await planService.toggleDay('test-plan', 1, 3);
      final progress = await planService.toggleDay('test-plan', 1, 3);

      expect(progress.completedDays, isNot(contains(1)));
    });

    test('toggleDay tracks consecutive streak', () async {
      await planService.startPlan('test-plan');
      await planService.toggleDay('test-plan', 1, 3);
      await planService.toggleDay('test-plan', 2, 3);
      final progress = await planService.toggleDay('test-plan', 3, 3);

      expect(progress.completedDays, {1, 2, 3});
      expect(progress.currentStreak, 3);
      expect(progress.longestStreak, 3);
    });

    test('resetPlan clears all progress', () async {
      await planService.startPlan('test-plan');
      await planService.toggleDay('test-plan', 1, 3);
      await planService.toggleDay('test-plan', 2, 3);

      await planService.resetPlan('test-plan');
      final progress = await planService.getProgress('test-plan');

      expect(progress.isStarted, isFalse);
      expect(progress.completedDays, isEmpty);
    });
  });
}
