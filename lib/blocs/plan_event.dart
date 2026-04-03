part of 'plan_bloc.dart';

abstract class PlanEvent extends Equatable {
  const PlanEvent();

  @override
  List<Object?> get props => [];
}

class PlansLoadRequested extends PlanEvent {
  const PlansLoadRequested();
}

class PlanStarted extends PlanEvent {
  const PlanStarted(this.planId);
  final String planId;

  @override
  List<Object?> get props => [planId];
}

class PlanDayToggled extends PlanEvent {
  const PlanDayToggled({required this.planId, required this.dayNumber});
  final String planId;
  final int dayNumber;

  @override
  List<Object?> get props => [planId, dayNumber];
}

class PlanDetailRequested extends PlanEvent {
  const PlanDetailRequested(this.planId);
  final String planId;

  @override
  List<Object?> get props => [planId];
}

class PlanReset extends PlanEvent {
  const PlanReset(this.planId);
  final String planId;

  @override
  List<Object?> get props => [planId];
}
