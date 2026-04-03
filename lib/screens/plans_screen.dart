import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:patres/blocs/plan_bloc.dart';
import 'package:patres/l10n/generated/app_localizations.dart';
import 'package:patres/models/reading_plan.dart';

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scaffoldBg = theme.scaffoldBackgroundColor;

    return DecoratedBox(
      decoration: theme.brightness == Brightness.light
          ? BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  scaffoldBg,
                  Color.lerp(scaffoldBg, Colors.brown.withValues(alpha: 0.1), 0.15) ?? scaffoldBg,
                ],
              ),
            )
          : const BoxDecoration(),
      child: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(
              l10n.plansTab,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w300,
                letterSpacing: 2,
              ),
            ),
          ),
          BlocBuilder<PlanBloc, PlanState>(
            builder: (context, state) {
              if (state.status == PlanStatus.loading ||
                  state.status == PlanStatus.initial) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state.status == PlanStatus.error) {
                return SliverFillRemaining(
                  child: Center(child: Text(l10n.plansError)),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.separated(
                  itemCount: state.plans.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final plan = state.plans[index];
                    final progress = state.progressMap[plan.id] ??
                        PlanProgress(planId: plan.id);
                    return _PlanCard(plan: plan, progress: progress);
                  },
                ),
              );
            },
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.progress});

  final ReadingPlan plan;
  final PlanProgress progress;

  static IconData _iconForName(String name) {
    return switch (name) {
      'school' => Icons.school_rounded,
      'terrain' => Icons.terrain_rounded,
      'brightness_7' => Icons.brightness_7_rounded,
      _ => Icons.auto_stories_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final fraction = progress.progressFraction(plan.totalDays);
    final completedCount = progress.completedDays.length;
    final isCompleted = completedCount == plan.totalDays && plan.totalDays > 0;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/plans/${plan.id}'),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _iconForName(plan.icon),
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.planDaysCount(plan.totalDays),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (progress.isStarted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? cs.primaryContainer
                            : cs.tertiaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isCompleted
                            ? l10n.planCompletedStatus
                            : l10n.planInProgress,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isCompleted
                              ? cs.onPrimaryContainer
                              : cs.onTertiaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                plan.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (progress.isStarted) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 6,
                    backgroundColor: cs.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(cs.primary),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${(fraction * 100).round()}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (progress.currentStreak > 0) ...[
                      Icon(
                        Icons.local_fire_department_rounded,
                        size: 16,
                        color: cs.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.streakDays(progress.currentStreak),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
