# Fix existing test failures

## Description

Two tests are currently failing and must be fixed before adding new test coverage:

1. **`test/blocs/plan_bloc_test.dart`** — "PlanDayToggled completes and uncompletes days" fails with `DatabaseException(error database_closed)`. The test's database is being closed before async operations (specifically `updatePlanStreak`) complete. The `setUp`/`tearDown` lifecycle needs to ensure the database stays open until all BLoC event handlers finish.

2. **`test/widget_test.dart`** — "Language switching tapping Polski after English restores Polish" times out after 10 minutes. This test appears to be stuck in an infinite loop or waiting for a condition that never resolves. Investigate the test logic for the language switching flow.

## Acceptance Criteria

- [ ] `plan_bloc_test.dart` PlanDayToggled test passes — fix the database lifecycle so it isn't closed before `updatePlanStreak` completes
- [ ] `widget_test.dart` language switching test passes without timing out
- [ ] Full test suite runs green: `flutter test`
- [ ] No other tests regressed

## Specific files

- `test/blocs/plan_bloc_test.dart` — line ~88 setUp, line ~138 assertion
- `test/widget_test.dart` — language switching group
- `lib/blocs/plan_bloc.dart` — PlanDayToggled handler calls `updatePlanStreak`
- `lib/services/database_service.dart:454` — `updatePlanStreak` method
