import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patres/models/reading_plan.dart';
import 'package:patres/services/plan_service.dart';

part 'plan_event.dart';
part 'plan_state.dart';

class PlanBloc extends Bloc<PlanEvent, PlanState> {
  PlanBloc({required this.planService}) : super(const PlanState()) {
    on<PlansLoadRequested>(_onLoadRequested);
    on<PlanStarted>(_onPlanStarted);
    on<PlanDayToggled>(_onDayToggled);
    on<PlanDetailRequested>(_onDetailRequested);
    on<PlanReset>(_onPlanReset);
  }

  final PlanService planService;

  Future<void> _onLoadRequested(
    PlansLoadRequested event,
    Emitter<PlanState> emit,
  ) async {
    emit(state.copyWith(status: PlanStatus.loading));
    try {
      final plans = await planService.loadPlans();
      final progressMap = <String, PlanProgress>{};
      for (final plan in plans) {
        progressMap[plan.id] = await planService.getProgress(plan.id);
      }
      emit(state.copyWith(
        status: PlanStatus.loaded,
        plans: plans,
        progressMap: progressMap,
      ));
    } catch (e) {
      emit(state.copyWith(status: PlanStatus.error));
    }
  }

  Future<void> _onPlanStarted(
    PlanStarted event,
    Emitter<PlanState> emit,
  ) async {
    await planService.startPlan(event.planId);
    final progress = await planService.getProgress(event.planId);
    final updated = Map<String, PlanProgress>.from(state.progressMap);
    updated[event.planId] = progress;
    emit(state.copyWith(progressMap: updated));
  }

  Future<void> _onDayToggled(
    PlanDayToggled event,
    Emitter<PlanState> emit,
  ) async {
    final plan = state.plans.firstWhere((p) => p.id == event.planId);
    final progress = await planService.toggleDay(
        event.planId, event.dayNumber, plan.totalDays);
    final updated = Map<String, PlanProgress>.from(state.progressMap);
    updated[event.planId] = progress;
    emit(state.copyWith(progressMap: updated));
  }

  Future<void> _onDetailRequested(
    PlanDetailRequested event,
    Emitter<PlanState> emit,
  ) async {
    final progress = await planService.getProgress(event.planId);
    final updated = Map<String, PlanProgress>.from(state.progressMap);
    updated[event.planId] = progress;
    emit(state.copyWith(
      selectedPlanId: event.planId,
      progressMap: updated,
    ));
  }

  Future<void> _onPlanReset(
    PlanReset event,
    Emitter<PlanState> emit,
  ) async {
    await planService.resetPlan(event.planId);
    final progress = PlanProgress(planId: event.planId);
    final updated = Map<String, PlanProgress>.from(state.progressMap);
    updated[event.planId] = progress;
    emit(state.copyWith(progressMap: updated));
  }
}
