import 'package:flutter_test/flutter_test.dart';
import 'package:patres/services/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late DatabaseService dbService;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
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
    dbService = DatabaseService(database: db);
  });

  tearDown(() async {
    await dbService.close();
  });

  group('DatabaseService plan operations', () {
    group('plan progress', () {
      test('getPlanProgress returns null for unknown plan', () async {
        expect(await dbService.getPlanProgress('unknown'), isNull);
      });

      test('startPlan creates progress entry', () async {
        await dbService.startPlan('test-plan');
        final progress = await dbService.getPlanProgress('test-plan');

        expect(progress, isNotNull);
        expect(progress!['plan_id'], 'test-plan');
        expect(progress['current_streak'], 0);
        expect(progress['longest_streak'], 0);
      });

      test('startPlan ignores duplicate', () async {
        await dbService.startPlan('test-plan');
        await dbService.startPlan('test-plan');

        final progress = await dbService.getPlanProgress('test-plan');
        expect(progress, isNotNull);
      });

      test('updatePlanStreak updates streak values', () async {
        await dbService.startPlan('test-plan');
        await dbService.updatePlanStreak('test-plan', 3, 5);

        final progress = await dbService.getPlanProgress('test-plan');
        expect(progress!['current_streak'], 3);
        expect(progress['longest_streak'], 5);
        expect(progress['last_completed_at'], isNotNull);
      });
    });

    group('plan day completions', () {
      test('getCompletedDays returns empty for unknown plan', () async {
        expect(await dbService.getCompletedDays('unknown'), isEmpty);
      });

      test('completePlanDay adds completion', () async {
        await dbService.completePlanDay('test-plan', 1);
        final days = await dbService.getCompletedDays('test-plan');

        expect(days, [1]);
      });

      test('completePlanDay ignores duplicate', () async {
        await dbService.completePlanDay('test-plan', 1);
        await dbService.completePlanDay('test-plan', 1);

        final days = await dbService.getCompletedDays('test-plan');
        expect(days, hasLength(1));
      });

      test('uncompletePlanDay removes completion', () async {
        await dbService.completePlanDay('test-plan', 1);
        await dbService.completePlanDay('test-plan', 2);
        await dbService.uncompletePlanDay('test-plan', 1);

        final days = await dbService.getCompletedDays('test-plan');
        expect(days, [2]);
      });

      test('getCompletedDays returns sorted', () async {
        await dbService.completePlanDay('test-plan', 3);
        await dbService.completePlanDay('test-plan', 1);
        await dbService.completePlanDay('test-plan', 2);

        final days = await dbService.getCompletedDays('test-plan');
        expect(days, [1, 2, 3]);
      });
    });

    group('deletePlanProgress', () {
      test('removes both progress and day completions', () async {
        await dbService.startPlan('test-plan');
        await dbService.completePlanDay('test-plan', 1);
        await dbService.completePlanDay('test-plan', 2);

        await dbService.deletePlanProgress('test-plan');

        expect(await dbService.getPlanProgress('test-plan'), isNull);
        expect(await dbService.getCompletedDays('test-plan'), isEmpty);
      });
    });
  });
}
