import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:patres/blocs/audio_bloc.dart';
import 'package:patres/blocs/audio_event.dart';
import 'package:patres/blocs/audio_state.dart';
import 'package:patres/l10n/generated/app_localizations.dart';

/// Full-featured audio player widget shown as a bottom sheet.
class AudioPlayerWidget extends StatelessWidget {
  const AudioPlayerWidget({
    super.key,
    required this.textTitle,
    required this.chapterTitle,
  });

  final String textTitle;
  final String chapterTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<AudioBloc, AudioState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).padding.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Title info
              Text(
                textTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                chapterTitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),

              // Progress slider
              _ProgressSlider(state: state),
              const SizedBox(height: 4),

              // Time labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(state.position),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    _formatDuration(state.duration),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Main controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.replay_10_rounded, size: 32),
                    tooltip: l10n.audioSkipBackward,
                    onPressed: () => context
                        .read<AudioBloc>()
                        .add(const AudioSkipBackwardRequested()),
                  ),
                  const SizedBox(width: 16),
                  _PlayPauseButton(state: state),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.forward_10_rounded, size: 32),
                    tooltip: l10n.audioSkipForward,
                    onPressed: () => context
                        .read<AudioBloc>()
                        .add(const AudioSkipForwardRequested()),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Speed control + Sleep timer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SpeedSelector(currentSpeed: state.speed),
                  _SleepTimerButton(sleepRemaining: state.sleepTimerRemaining),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}

class _ProgressSlider extends StatelessWidget {
  const _ProgressSlider({required this.state});
  final AudioState state;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
        activeTrackColor: cs.primary,
        inactiveTrackColor: cs.primary.withValues(alpha: 0.15),
        thumbColor: cs.primary,
        overlayColor: cs.primary.withValues(alpha: 0.1),
      ),
      child: Slider(
        value: state.progress.clamp(0.0, 1.0),
        onChanged: (value) {
          final position = Duration(
            milliseconds:
                (value * state.duration.inMilliseconds).round(),
          );
          context
              .read<AudioBloc>()
              .add(AudioSeekRequested(position: position));
        },
      ),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({required this.state});
  final AudioState state;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (state.status == AudioPlaybackStatus.loading) {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: cs.onPrimaryContainer,
          ),
        ),
      );
    }

    return FloatingActionButton(
      onPressed: () {
        if (state.isPlaying) {
          context.read<AudioBloc>().add(const AudioPauseRequested());
        } else {
          context.read<AudioBloc>().add(const AudioResumeRequested());
        }
      },
      backgroundColor: cs.primaryContainer,
      foregroundColor: cs.onPrimaryContainer,
      elevation: 2,
      child: Icon(
        state.isPlaying
            ? Icons.pause_rounded
            : Icons.play_arrow_rounded,
        size: 36,
      ),
    );
  }
}

class _SpeedSelector extends StatelessWidget {
  const _SpeedSelector({required this.currentSpeed});
  final double currentSpeed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return TextButton(
      onPressed: () => _showSpeedPicker(context),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: cs.outlineVariant),
        ),
      ),
      child: Text(
        '${currentSpeed}x',
        style: theme.textTheme.labelLarge?.copyWith(
          color: cs.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showSpeedPicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final cs = theme.colorScheme;
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(sheetContext).padding.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.audioSpeed,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: AudioState.speeds.map((speed) {
                  final isSelected = speed == currentSpeed;
                  return ChoiceChip(
                    label: Text('${speed}x'),
                    selected: isSelected,
                    onSelected: (_) {
                      context
                          .read<AudioBloc>()
                          .add(AudioSpeedChanged(speed: speed));
                      Navigator.pop(sheetContext);
                    },
                    selectedColor: cs.primaryContainer,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? cs.onPrimaryContainer
                          : cs.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SleepTimerButton extends StatelessWidget {
  const _SleepTimerButton({this.sleepRemaining});
  final Duration? sleepRemaining;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isActive = sleepRemaining != null;

    return TextButton.icon(
      onPressed: () => _showSleepTimerPicker(context),
      icon: Icon(
        Icons.bedtime_rounded,
        size: 18,
        color: isActive ? cs.primary : cs.onSurfaceVariant,
      ),
      label: Text(
        isActive ? l10n.audioSleepTimerActive : l10n.audioSleepTimer,
        style: theme.textTheme.labelLarge?.copyWith(
          color: isActive ? cs.primary : cs.onSurface,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isActive ? cs.primary : cs.outlineVariant,
          ),
        ),
      ),
    );
  }

  void _showSleepTimerPicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final options = [
      (l10n.audioSleepTimer15, const Duration(minutes: 15)),
      (l10n.audioSleepTimer30, const Duration(minutes: 30)),
      (l10n.audioSleepTimer45, const Duration(minutes: 45)),
      (l10n.audioSleepTimer60, const Duration(minutes: 60)),
    ];

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(sheetContext).padding.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.audioSleepTimer,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ...options.map((opt) => ListTile(
                    title: Text(opt.$1),
                    leading: const Icon(Icons.timer_outlined),
                    onTap: () {
                      context
                          .read<AudioBloc>()
                          .add(AudioSleepTimerSet(duration: opt.$2));
                      Navigator.pop(sheetContext);
                    },
                  )),
              if (sleepRemaining != null)
                ListTile(
                  title: Text(l10n.audioSleepTimerCancel),
                  leading: const Icon(Icons.timer_off_outlined),
                  onTap: () {
                    context
                        .read<AudioBloc>()
                        .add(const AudioSleepTimerSet(duration: null));
                    Navigator.pop(sheetContext);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Mini player bar shown at the bottom of the reader when audio is active.
class MiniAudioPlayer extends StatelessWidget {
  const MiniAudioPlayer({
    super.key,
    required this.textTitle,
    required this.chapterTitle,
    this.onTap,
  });

  final String textTitle;
  final String chapterTitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return BlocBuilder<AudioBloc, AudioState>(
      builder: (context, state) {
        if (!state.isActive) return const SizedBox.shrink();

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              border: Border(
                top: BorderSide(
                  color: cs.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
            ),
            child: Row(
              children: [
                // Play/pause
                IconButton(
                  icon: Icon(
                    state.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: cs.onPrimaryContainer,
                  ),
                  onPressed: () {
                    if (state.isPlaying) {
                      context
                          .read<AudioBloc>()
                          .add(const AudioPauseRequested());
                    } else {
                      context
                          .read<AudioBloc>()
                          .add(const AudioResumeRequested());
                    }
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        textTitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.onPrimaryContainer,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        chapterTitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onPrimaryContainer.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Progress
                SizedBox(
                  width: 48,
                  child: LinearProgressIndicator(
                    value: state.progress.clamp(0.0, 1.0),
                    minHeight: 3,
                    backgroundColor: cs.onPrimaryContainer.withValues(alpha: 0.15),
                    color: cs.onPrimaryContainer,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: cs.onPrimaryContainer,
                    size: 20,
                  ),
                  onPressed: () {
                    context
                        .read<AudioBloc>()
                        .add(const AudioStopRequested());
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
