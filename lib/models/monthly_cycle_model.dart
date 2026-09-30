/// Persistent Monthly Fitness Cycle: monthlyCycles/{cycleId}
class MonthlyCycle {
  final String id;
  final String userId;
  final String monthId; // e.g. '2026-10'
  final String monthName; // e.g. 'October'
  final int year;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'active', 'completed'
  final String workoutPlanId;
  final String mealPlanId;
  final double startingWeight;
  final double? endingWeight;
  final double startingBmi;
  final double? endingBmi;
  final double? workoutCompletionRate; // 0.0 to 100.0 (%)
  final double? proteinGoalCompletionRate; // 0.0 to 100.0 (%)
  final bool isCurrent;
  final DateTime? reviewedAt;
  final String? reviewNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MonthlyCycle({
    required this.id,
    required this.userId,
    required this.monthId,
    required this.monthName,
    required this.year,
    required this.startDate,
    required this.endDate,
    this.status = 'active',
    required this.workoutPlanId,
    required this.mealPlanId,
    required this.startingWeight,
    this.endingWeight,
    required this.startingBmi,
    this.endingBmi,
    this.workoutCompletionRate,
    this.proteinGoalCompletionRate,
    this.isCurrent = true,
    this.reviewedAt,
    this.reviewNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCompleted => status == 'completed';

  MonthlyCycle copyWith({
    String? id,
    String? userId,
    String? monthId,
    String? monthName,
    int? year,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? workoutPlanId,
    String? mealPlanId,
    double? startingWeight,
    double? endingWeight,
    double? startingBmi,
    double? endingBmi,
    double? workoutCompletionRate,
    double? proteinGoalCompletionRate,
    bool? isCurrent,
    DateTime? reviewedAt,
    String? reviewNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MonthlyCycle(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      monthId: monthId ?? this.monthId,
      monthName: monthName ?? this.monthName,
      year: year ?? this.year,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      workoutPlanId: workoutPlanId ?? this.workoutPlanId,
      mealPlanId: mealPlanId ?? this.mealPlanId,
      startingWeight: startingWeight ?? this.startingWeight,
      endingWeight: endingWeight ?? this.endingWeight,
      startingBmi: startingBmi ?? this.startingBmi,
      endingBmi: endingBmi ?? this.endingBmi,
      workoutCompletionRate:
          workoutCompletionRate ?? this.workoutCompletionRate,
      proteinGoalCompletionRate:
          proteinGoalCompletionRate ?? this.proteinGoalCompletionRate,
      isCurrent: isCurrent ?? this.isCurrent,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewNotes: reviewNotes ?? this.reviewNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'monthId': monthId,
      'monthName': monthName,
      'year': year,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status,
      'workoutPlanId': workoutPlanId,
      'mealPlanId': mealPlanId,
      'startingWeight': startingWeight,
      if (endingWeight != null) 'endingWeight': endingWeight,
      'startingBmi': startingBmi,
      if (endingBmi != null) 'endingBmi': endingBmi,
      if (workoutCompletionRate != null)
        'workoutCompletionRate': workoutCompletionRate,
      if (proteinGoalCompletionRate != null)
        'proteinGoalCompletionRate': proteinGoalCompletionRate,
      'isCurrent': isCurrent,
      if (reviewedAt != null) 'reviewedAt': reviewedAt!.toIso8601String(),
      if (reviewNotes != null) 'reviewNotes': reviewNotes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MonthlyCycle.fromMap(Map<String, dynamic> map, {String? docId}) {
    return MonthlyCycle(
      id: map['id']?.toString() ?? docId ?? '',
      userId: map['userId']?.toString() ?? '',
      monthId: map['monthId']?.toString() ?? '',
      monthName: map['monthName']?.toString() ?? '',
      year: (map['year'] as num?)?.toInt() ?? DateTime.now().year,
      startDate: map['startDate'] != null
          ? DateTime.tryParse(map['startDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      endDate: map['endDate'] != null
          ? DateTime.tryParse(map['endDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: map['status']?.toString() ?? 'active',
      workoutPlanId: map['workoutPlanId']?.toString() ?? '',
      mealPlanId: map['mealPlanId']?.toString() ?? '',
      startingWeight: (map['startingWeight'] as num?)?.toDouble() ?? 0.0,
      endingWeight: (map['endingWeight'] as num?)?.toDouble(),
      startingBmi: (map['startingBmi'] as num?)?.toDouble() ?? 0.0,
      endingBmi: (map['endingBmi'] as num?)?.toDouble(),
      workoutCompletionRate:
          (map['workoutCompletionRate'] as num?)?.toDouble(),
      proteinGoalCompletionRate:
          (map['proteinGoalCompletionRate'] as num?)?.toDouble(),
      isCurrent: map['isCurrent'] == true,
      reviewedAt: map['reviewedAt'] != null
          ? DateTime.tryParse(map['reviewedAt'].toString())
          : null,
      reviewNotes: map['reviewNotes']?.toString(),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
