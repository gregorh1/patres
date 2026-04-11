# Add tests for AudioBloc and AudioService

## Description

The audio playback layer has very low test coverage:

| File | Coverage | Lines |
|------|----------|-------|
| `lib/blocs/audio_bloc.dart` | 0.0% | 0/87 |
| `lib/services/audio_service.dart` | 21.0% | 25/119 |

AudioBloc manages the TTS audiobook playback state (play, pause, seek, track changes). AudioService wraps `just_audio` and `audio_service` for background playback. These are critical for the TTS audiobook feature.

## Acceptance Criteria

- [ ] Create `test/blocs/audio_bloc_test.dart` — test AudioPlayRequested, AudioPauseRequested, AudioSeekRequested, AudioTrackChanged, AudioStopRequested events and their state emissions
- [ ] Expand `test/services/audio_service_test.dart` — increase coverage from 21% to at least 70%, covering initialization, play/pause/stop, seek, playlist management, error handling
- [ ] All new tests pass: `flutter test test/blocs/audio_bloc_test.dart test/services/audio_service_test.dart`
- [ ] No existing tests regressed

## Test approach

Use `bloc_test` for AudioBloc (same pattern as `reader_bloc_test.dart`, `search_bloc_test.dart`). Create a `FakeAudioService` that implements the audio service interface without requiring `just_audio` platform channels. For AudioService, mock the `just_audio` player using `mocktail` or create a fake — check how `test/services/audio_service_test.dart` currently approaches this and extend it.

## Example scenarios

- AudioBloc: play event → emits playing state with current track info
- AudioBloc: pause while playing → emits paused state preserving position
- AudioBloc: seek → emits state with updated position
- AudioService: init → creates audio player, sets up session
- AudioService: error during playback → emits error state, doesn't crash
