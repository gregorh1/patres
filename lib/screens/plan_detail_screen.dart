import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:patres/blocs/plan_bloc.dart';
import 'package:patres/l10n/generated/app_localizations.dart';
import 'package:patres/models/reading_plan.dart';

class PlanDetailScreen extends StatelessWidget {
  const PlanDetailScreen({super.key, required this.planId});

  final String planId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return BlocBuilder<PlanBloc, PlanState>(
      builder: (context, state) {
        final plan = state.plans.cast<ReadingPlan?>().firstWhere(
              (p) => p?.id == planId,
              orElse: () => null,
            );
        if (plan == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final progress =
            state.progressMap[planId] ?? PlanProgress(planId: planId);
        final fraction = progress.progressFraction(plan.totalDays);

        return Scaffold(
          appBar: AppBar(
            title: Text(plan.title),
          ),
          body: CustomScrollView(
            slivers: [
              // Progress header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.description,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Stats row
                      Row(
                        children: [
                          _StatChip(
                            icon: Icons.check_circle_outline_rounded,
                            label:
                                '${progress.completedDays.length}/${plan.totalDays}',
                            subtitle: l10n.planCompleted,
                          ),
                          const SizedBox(width: 12),
                          _StatChip(
                            icon: Icons.local_fire_department_rounded,
                            label: '${progress.currentStreak}',
                            subtitle: l10n.planStreak,
                          ),
                          const SizedBox(width: 12),
                          _StatChip(
                            icon: Icons.emoji_events_outlined,
                            label: '${progress.longestStreak}',
                            subtitle: l10n.planLongestStreak,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: fraction,
                          minHeight: 8,
                          backgroundColor: cs.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation(cs.primary),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (!progress.isStarted)
                        Center(
                          child: FilledButton.icon(
                            onPressed: () {
                              context
                                  .read<PlanBloc>()
                                  .add(PlanStarted(planId));
                            },
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: Text(l10n.planStart),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Day list
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.separated(
                  itemCount: plan.days.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final day = plan.days[index];
                    final isCompleted =
                        progress.completedDays.contains(day.day);
                    return _DayTile(
                      day: day,
                      isCompleted: isCompleted,
                      isStarted: progress.isStarted,
                      onToggle: () {
                        if (!progress.isStarted) {
                          context
                              .read<PlanBloc>()
                              .add(PlanStarted(planId));
                        }
                        context.read<PlanBloc>().add(PlanDayToggled(
                              planId: planId,
                              dayNumber: day.day,
                            ));
                      },
                      onRead: () {
                        context.push(
                          '/reader/${day.textId}?chapter=${day.chapterIndex}',
                        );
                      },
                    );
                  },
                ),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
            ],
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.subtitle,
  });

  final IconData icon;
  final String label;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: cs.primary),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              subtitle,
              style: theme.textTheme.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.day,
    required this.isCompleted,
    required this.isStarted,
    required this.onToggle,
    required this.onRead,
  });

  final PlanDay day;
  final bool isCompleted;
  final bool isStarted;
  final VoidCallback onToggle;
  final VoidCallback onRead;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onRead,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Day number badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? cs.primary
                      : cs.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isCompleted
                      ? Icon(Icons.check_rounded,
                          size: 18, color: cs.onPrimary)
                      : Text(
                          '${day.day}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: isCompleted
                            ? cs.onSurfaceVariant
                            : cs.onSurface,
                      ),
                    ),
                    if (day.description.isNotEmpty)
                      Text(
                        day.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // Toggle button
              IconButton(
                icon: Icon(
                  isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isCompleted ? cs.primary : cs.outline,
                ),
                tooltip: isCompleted
                    ? l10n.planMarkIncomplete
                    : l10n.planMarkComplete,
                onPressed: onToggle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
