part of 'plan_bloc.dart';

enum PlanStatus { initial, loading, loaded, error }

class PlanState extends Equatable {
  const PlanState({
    this.status = PlanStatus.initial,
    this.plans = const [],
    this.progressMap = const {},
    this.selectedPlanId,
  });

  final PlanStatus status;
  final List<ReadingPlan> plans;
  final Map<String, PlanProgress> progressMap;
  final String? selectedPlanId;

  PlanState copyWith({
    PlanStatus? status,
    List<ReadingPlan>? plans,
    Map<String, PlanProgress>? progressMap,
    String? selectedPlanId,
  }) {
    return PlanState(
      status: status ?? this.status,
      plans: plans ?? this.plans,
      progressMap: progressMap ?? this.progressMap,
      selectedPlanId: selectedPlanId ?? this.selectedPlanId,
    );
  }

  @override
  List<Object?> get props => [status, plans, progressMap, selectedPlanId];
}
