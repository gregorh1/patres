# Add tests for untested reusable widgets

## Description

Three reusable widgets in `lib/widgets/` have 0–1% coverage and no dedicated tests:

| Widget | Coverage | Lines |
|--------|----------|-------|
| `audio_player_widget.dart` | 0.0% | 0/238 |
| `chapter_list_sheet.dart` | 0.0% | 0/56 |
| `reader_settings_sheet.dart` | 1.1% | 1/91 |

These widgets are shared across screens and contain complex UI logic (audio playback controls, chapter navigation, reader font/theme settings).

## Acceptance Criteria

- [ ] Create `test/widgets/audio_player_widget_test.dart` — test play/pause/stop controls, progress display, loading state, error state
- [ ] Create `test/widgets/chapter_list_sheet_test.dart` — test chapter list rendering, chapter selection callback, scroll behavior
- [ ] Create `test/widgets/reader_settings_sheet_test.dart` — test font size slider, theme selection, line height adjustment
- [ ] All new tests pass: `flutter test test/widgets/`
- [ ] No existing tests regressed

## Test approach

These are pure widget tests — mock the BLoCs or callbacks they depend on. Use `pumpWidget` with appropriate `BlocProvider` wrappers. For `audio_player_widget`, mock the audio player state since it interacts with `just_audio`. Follow the existing pattern of fake services used in `test/blocs/` and `test/services/`.
