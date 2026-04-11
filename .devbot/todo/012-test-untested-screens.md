# Add tests for untested screens

## Description

Six screens have 0–1% line coverage and no dedicated test files. These are critical user-facing flows that need widget tests.

### Coverage gaps

| Screen | Coverage | Lines |
|--------|----------|-------|
| `reader_screen.dart` | 0.0% | 0/322 |
| `author_profile_screen.dart` | 0.0% | 0/196 |
| `plan_detail_screen.dart` | 0.0% | 0/150 |
| `search_screen.dart` | 0.7% | 1/148 |
| `audio_downloads_screen.dart` | 0.6% | 1/157 |
| `plans_screen.dart` | 1.0% | 1/105 |

## Acceptance Criteria

- [ ] Create `test/screens/reader_screen_test.dart` — test text loading, chapter navigation, bookmark/highlight actions, scroll position restore
- [ ] Create `test/screens/search_screen_test.dart` — test search input, results display, empty state, navigation to result
- [ ] Create `test/screens/plan_detail_screen_test.dart` — test plan loading, day list display, day completion toggle
- [ ] Create `test/screens/plans_screen_test.dart` — test plan list display, navigation to plan detail
- [ ] Create `test/screens/author_profile_screen_test.dart` — test author info display, text list for author
- [ ] Create `test/screens/audio_downloads_screen_test.dart` — test download list, empty state, playback controls
- [ ] All new tests pass: `flutter test test/screens/`
- [ ] No existing tests regressed

## Test approach

Use the project's existing pattern: inject fake services (FakeDatabaseService, FakeTextService, etc.) into BLoCs, provide BLoCs via `BlocProvider`, and pump the screen widget. Follow patterns from `test/widget_test.dart` for widget testing setup. The reader screen is the highest priority — it's the core user flow with the most untested lines.
