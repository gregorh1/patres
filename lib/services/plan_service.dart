import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:patres/models/reading_plan.dart';
import 'package:patres/services/database_service.dart';

class PlanService {
  const PlanService({
    required this.databaseService,
    this.assetBundle,
  });

  final DatabaseService databaseService;
  final AssetBundle? assetBundle;

  AssetBundle get _bundle => assetBundle ?? rootBundle;

  Future<List<ReadingPlan>> loadPlans() async {
    final jsonStr = await _bundle.loadString('assets/reading_plans.json');
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    final plansList = data['plans'] as List<dynamic>;
    return plansList
        .map((p) => ReadingPlan.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  Future<PlanProgress> getProgress(String planId) async {
    final row = await databaseService.getPlanProgress(planId);
    if (row == null) {
      return PlanProgress(planId: planId);
    }

    final completedDays = await databaseService.getCompletedDays(planId);

    return PlanProgress(
      planId: planId,
      startedAt: DateTime.parse(row['started_at'] as String),
      completedDays: completedDays.toSet(),
      currentStreak: row['current_streak'] as int,
      longestStreak: row['longest_streak'] as int,
    );
  }

  Future<void> startPlan(String planId) async {
    await databaseService.startPlan(planId);
  }

  Future<PlanProgress> toggleDay(String planId, int dayNumber, int totalDays) async {
    final progress = await getProgress(planId);
    final completed = Set<int>.from(progress.completedDays);

    if (completed.contains(dayNumber)) {
      await databaseService.uncompletePlanDay(planId, dayNumber);
      completed.remove(dayNumber);
    } else {
      await databaseService.completePlanDay(planId, dayNumber);
      completed.add(dayNumber);
    }

    // Recalculate streak
    final streak = _calculateStreak(completed, totalDays);
    final longestStreak = streak > progress.longestStreak
        ? streak
        : progress.longestStreak;

    await databaseService.updatePlanStreak(planId, streak, longestStreak);

    return progress.copyWith(
      completedDays: completed,
      currentStreak: streak,
      longestStreak: longestStreak,
    );
  }

  Future<void> resetPlan(String planId) async {
    await databaseService.deletePlanProgress(planId);
  }

  int _calculateStreak(Set<int> completedDays, int totalDays) {
    if (completedDays.isEmpty) return 0;

    // Find the longest consecutive run ending at the last completed day
    final sorted = completedDays.toList()..sort();
    int streak = 1;
    int maxStreak = 1;

    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i] == sorted[i - 1] + 1) {
        streak++;
        if (streak > maxStreak) maxStreak = streak;
      } else {
        streak = 1;
      }
    }

    return maxStreak;
  }
}
