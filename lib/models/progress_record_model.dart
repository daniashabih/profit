/// Historical monthly progress evaluation record: progressRecords/{recordId}
class ProgressRecord {
  final String id;
  final String userId;
  final String monthId; // e.g. '2026-09'
  final String monthName; // e.g. 'September'
  final int year;
  final DateTime startDate;
  final DateTime endDate;
  final double startingWeight;
  final double endingWeight;
  final double startingBmi;
  final double endingBmi;
  final double workoutCompletionRate; // e.g. 82.0 (%)
  final double proteinGoalCompletionRate; // e.g. 76.0 (%)
  final int calorieAverage;
  final DateTime createdAt;

  const ProgressRecord({
    required this.id,
    required this.userId,
    required this.monthId,
    required this.monthName,
    required this.year,
    required this.startDate,
    required this.endDate,
    required this.startingWeight,
    required this.endingWeight,
    required this.startingBmi,
    required this.endingBmi,
    required this.workoutCompletionRate,
    required this.proteinGoalCompletionRate,
    this.calorieAverage = 2100,
    required this.createdAt,
  });

  /// Net weight change (negative = weight lost)
  double get weightDeltaKg => endingWeight - startingWeight;

  /// Net BMI change
  double get bmiDelta => endingBmi - startingBmi;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'monthId': monthId,
      'monthName': monthName,
      'year': year,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'startingWeight': startingWeight,
      'endingWeight': endingWeight,
      'startingBmi': startingBmi,
      'endingBmi': endingBmi,
      'workoutCompletionRate': workoutCompletionRate,
      'proteinGoalCompletionRate': proteinGoalCompletionRate,
      'calorieAverage': calorieAverage,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ProgressRecord.fromMap(Map<String, dynamic> map, {String? docId}) {
    return ProgressRecord(
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
      startingWeight: (map['startingWeight'] as num?)?.toDouble() ?? 0.0,
      endingWeight: (map['endingWeight'] as num?)?.toDouble() ?? 0.0,
      startingBmi: (map['startingBmi'] as num?)?.toDouble() ?? 0.0,
      endingBmi: (map['endingBmi'] as num?)?.toDouble() ?? 0.0,
      workoutCompletionRate:
          (map['workoutCompletionRate'] as num?)?.toDouble() ?? 0.0,
      proteinGoalCompletionRate:
          (map['proteinGoalCompletionRate'] as num?)?.toDouble() ?? 0.0,
      calorieAverage: (map['calorieAverage'] as num?)?.toInt() ?? 2000,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
