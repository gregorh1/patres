import 'package:flutter_test/flutter_test.dart';
import 'package:patres/models/reading_plan.dart';

void main() {
  group('PlanDay', () {
    test('fromJson creates correct instance', () {
      final json = {
        'day': 1,
        'title': 'Day One',
        'textId': 'augustyn-wyznania',
        'chapterIndex': 0,
        'description': 'First day description',
      };

      final day = PlanDay.fromJson(json);

      expect(day.day, 1);
      expect(day.title, 'Day One');
      expect(day.textId, 'augustyn-wyznania');
      expect(day.chapterIndex, 0);
      expect(day.description, 'First day description');
    });

    test('toJson roundtrips correctly', () {
      const day = PlanDay(
        day: 5,
        title: 'Day Five',
        textId: 'didache',
        chapterIndex: 2,
        description: 'Some description',
      );

      final json = day.toJson();
      final restored = PlanDay.fromJson(json);

      expect(restored, day);
    });

    test('defaults description to empty string', () {
      final json = {
        'day': 1,
        'title': 'Title',
        'textId': 'id',
        'chapterIndex': 0,
      };

      final day = PlanDay.fromJson(json);
      expect(day.description, '');
    });
  });

  group('ReadingPlan', () {
    test('fromJson creates correct instance', () {
      final json = {
        'id': 'test-plan',
        'title': 'Test Plan',
        'description': 'A test plan',
        'totalDays': 2,
        'icon': 'school',
        'days': [
          {
            'day': 1,
            'title': 'Day 1',
            'textId': 'didache',
            'chapterIndex': 0,
          },
          {
            'day': 2,
            'title': 'Day 2',
            'textId': 'didache',
            'chapterIndex': 1,
          },
        ],
      };

      final plan = ReadingPlan.fromJson(json);

      expect(plan.id, 'test-plan');
      expect(plan.title, 'Test Plan');
      expect(plan.description, 'A test plan');
      expect(plan.totalDays, 2);
      expect(plan.icon, 'school');
      expect(plan.days, hasLength(2));
      expect(plan.days[0].day, 1);
      expect(plan.days[1].textId, 'didache');
    });

    test('toJson roundtrips correctly', () {
      const plan = ReadingPlan(
        id: 'test',
        title: 'Test',
        description: 'Desc',
        totalDays: 1,
        days: [
          PlanDay(day: 1, title: 'D1', textId: 'a', chapterIndex: 0),
        ],
        icon: 'terrain',
      );

      final restored = ReadingPlan.fromJson(plan.toJson());
      expect(restored, plan);
    });
  });

  group('PlanProgress', () {
    test('progressFraction returns correct value', () {
      const progress = PlanProgress(
        planId: 'test',
        completedDays: {1, 2, 3},
      );

      expect(progress.progressFraction(10), 0.3);
      expect(progress.progressFraction(3), 1.0);
      expect(progress.progressFraction(0), 0.0);
    });

    test('isStarted returns true when startedAt is set', () {
      final progress = PlanProgress(
        planId: 'test',
        startedAt: DateTime(2026, 1, 1),
      );
      expect(progress.isStarted, isTrue);
    });

    test('isStarted returns false when startedAt is null', () {
      const progress = PlanProgress(planId: 'test');
      expect(progress.isStarted, isFalse);
    });

    test('copyWith creates correct copy', () {
      const progress = PlanProgress(
        planId: 'test',
        completedDays: {1, 2},
        currentStreak: 2,
        longestStreak: 5,
      );

      final updated = progress.copyWith(
        completedDays: {1, 2, 3},
        currentStreak: 3,
      );

      expect(updated.completedDays, {1, 2, 3});
      expect(updated.currentStreak, 3);
      expect(updated.longestStreak, 5); // unchanged
      expect(updated.planId, 'test');
    });
  });
}
