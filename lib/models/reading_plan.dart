import 'package:equatable/equatable.dart';

class PlanDay extends Equatable {
  const PlanDay({
    required this.day,
    required this.title,
    required this.textId,
    required this.chapterIndex,
    this.description = '',
  });

  final int day;
  final String title;
  final String textId;
  final int chapterIndex;
  final String description;

  factory PlanDay.fromJson(Map<String, dynamic> json) => PlanDay(
        day: json['day'] as int,
        title: json['title'] as String,
        textId: json['textId'] as String,
        chapterIndex: json['chapterIndex'] as int,
        description: json['description'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'day': day,
        'title': title,
        'textId': textId,
        'chapterIndex': chapterIndex,
        'description': description,
      };

  @override
  List<Object?> get props => [day, title, textId, chapterIndex, description];
}

class ReadingPlan extends Equatable {
  const ReadingPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.totalDays,
    required this.days,
    this.icon = 'auto_stories',
  });

  final String id;
  final String title;
  final String description;
  final int totalDays;
  final List<PlanDay> days;
  final String icon;

  factory ReadingPlan.fromJson(Map<String, dynamic> json) {
    final daysList = (json['days'] as List<dynamic>)
        .map((d) => PlanDay.fromJson(d as Map<String, dynamic>))
        .toList();
    return ReadingPlan(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      totalDays: json['totalDays'] as int,
      days: daysList,
      icon: json['icon'] as String? ?? 'auto_stories',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'totalDays': totalDays,
        'days': days.map((d) => d.toJson()).toList(),
        'icon': icon,
      };

  @override
  List<Object?> get props => [id, title, description, totalDays, days, icon];
}

class PlanProgress extends Equatable {
  const PlanProgress({
    required this.planId,
    this.startedAt,
    this.completedDays = const {},
    this.currentStreak = 0,
    this.longestStreak = 0,
  });

  final String planId;
  final DateTime? startedAt;
  final Set<int> completedDays;
  final int currentStreak;
  final int longestStreak;

  double progressFraction(int totalDays) =>
      totalDays > 0 ? completedDays.length / totalDays : 0.0;

  bool get isStarted => startedAt != null;

  PlanProgress copyWith({
    String? planId,
    DateTime? startedAt,
    Set<int>? completedDays,
    int? currentStreak,
    int? longestStreak,
  }) {
    return PlanProgress(
      planId: planId ?? this.planId,
      startedAt: startedAt ?? this.startedAt,
      completedDays: completedDays ?? this.completedDays,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
    );
  }

  @override
  List<Object?> get props =>
      [planId, startedAt, completedDays, currentStreak, longestStreak];
}
