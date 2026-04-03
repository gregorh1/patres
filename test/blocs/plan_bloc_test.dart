import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patres/blocs/plan_bloc.dart';
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
        {"day": 1, "title": "Day 1", "textId": "didache", "chapterIndex": 0},
        {"day": 2, "title": "Day 2", "textId": "didache", "chapterIndex": 1},
        {"day": 3, "title": "Day 3", "textId": "didache", "chapterIndex": 2}
      ]
    }
  ]
}
''';

class _FakeAssetBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (key == 'assets/reading_plans.json') return _plansJson;
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
  late PlanBloc bloc;
  late DatabaseService dbService;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    dbService = await _createTestDb();
    bloc = PlanBloc(
      planService: PlanService(
        databaseService: dbService,
        assetBundle: _FakeAssetBundle(),
      ),
    );
  });

  tearDown(() async {
    await bloc.close();
    await dbService.close();
  });

  group('PlanBloc', () {
    test('initial state is PlanStatus.initial', () {
      expect(bloc.state.status, PlanStatus.initial);
      expect(bloc.state.plans, isEmpty);
    });

    test('PlansLoadRequested loads plans and progress', () async {
      bloc.add(const PlansLoadRequested());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.status, PlanStatus.loaded);
      expect(bloc.state.plans, hasLength(1));
      expect(bloc.state.plans[0].id, 'test-plan');
      expect(bloc.state.progressMap, contains('test-plan'));
      expect(bloc.state.progressMap['test-plan']!.isStarted, isFalse);
    });

    test('PlanStarted creates progress for plan', () async {
      bloc.add(const PlansLoadRequested());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      bloc.add(const PlanStarted('test-plan'));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.progressMap['test-plan']!.isStarted, isTrue);
    });

    test('PlanDayToggled completes and uncompletes days', () async {
      bloc.add(const PlansLoadRequested());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      bloc.add(const PlanStarted('test-plan'));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      bloc.add(const PlanDayToggled(planId: 'test-plan', dayNumber: 1));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.progressMap['test-plan']!.completedDays, contains(1));

      // Toggle again to uncomplete
      bloc.add(const PlanDayToggled(planId: 'test-plan', dayNumber: 1));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.progressMap['test-plan']!.completedDays,
          isNot(contains(1)));
    });

    test('PlanReset clears all progress', () async {
      bloc.add(const PlansLoadRequested());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      bloc.add(const PlanStarted('test-plan'));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      bloc.add(const PlanDayToggled(planId: 'test-plan', dayNumber: 1));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      bloc.add(const PlanReset('test-plan'));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.progressMap['test-plan']!.isStarted, isFalse);
      expect(bloc.state.progressMap['test-plan']!.completedDays, isEmpty);
    });

    test('PlanDetailRequested refreshes progress for plan', () async {
      bloc.add(const PlansLoadRequested());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      bloc.add(const PlanDetailRequested('test-plan'));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.selectedPlanId, 'test-plan');
    });
  });
}
