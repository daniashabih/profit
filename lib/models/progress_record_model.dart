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
  final DateTime? date;
  final double? weight;
  final double? height;
  final double? bmi;
  final String? goal;

  const ProgressRecord({
    required this.id,
    required this.userId,
    this.monthId = '',
    this.monthName = '',
    this.year = 0,
    DateTime? startDate,
    DateTime? endDate,
    this.startingWeight = 0.0,
    this.endingWeight = 0.0,
    this.startingBmi = 0.0,
    this.endingBmi = 0.0,
    this.workoutCompletionRate = 0.0,
    this.proteinGoalCompletionRate = 0.0,
    this.calorieAverage = 2100,
    required this.createdAt,
    this.date,
    this.weight,
    this.height,
    this.bmi,
    this.goal,
  })  : startDate = startDate ?? createdAt,
        endDate = endDate ?? createdAt;

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
      'year': year > 0 ? year : DateTime.now().year,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'startingWeight': startingWeight,
      'endingWeight': endingWeight > 0 ? endingWeight : (weight ?? 0.0),
      'startingBmi': startingBmi,
      'endingBmi': endingBmi > 0 ? endingBmi : (bmi ?? 0.0),
      'workoutCompletionRate': workoutCompletionRate,
      'proteinGoalCompletionRate': proteinGoalCompletionRate,
      'calorieAverage': calorieAverage,
      'createdAt': createdAt.toIso8601String(),
      if (date != null) 'date': date!.toIso8601String(),
      if (weight != null) 'weight': weight,
      if (height != null) 'height': height,
      if (bmi != null) 'bmi': bmi,
      if (goal != null) 'goal': goal,
    };
  }

  factory ProgressRecord.fromMap(Map<String, dynamic> map, {String? docId}) {
    final created = map['createdAt'] != null
        ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
        : DateTime.now();
    return ProgressRecord(
      id: map['id']?.toString() ?? docId ?? '',
      userId: map['userId']?.toString() ?? '',
      monthId: map['monthId']?.toString() ?? '',
      monthName: map['monthName']?.toString() ?? '',
      year: (map['year'] as num?)?.toInt() ?? DateTime.now().year,
      startDate: map['startDate'] != null
          ? DateTime.tryParse(map['startDate'].toString()) ?? created
          : created,
      endDate: map['endDate'] != null
          ? DateTime.tryParse(map['endDate'].toString()) ?? created
          : created,
      startingWeight: (map['startingWeight'] as num?)?.toDouble() ?? 0.0,
      endingWeight: (map['endingWeight'] as num?)?.toDouble() ?? (map['weight'] as num?)?.toDouble() ?? 0.0,
      startingBmi: (map['startingBmi'] as num?)?.toDouble() ?? 0.0,
      endingBmi: (map['endingBmi'] as num?)?.toDouble() ?? (map['bmi'] as num?)?.toDouble() ?? 0.0,
      workoutCompletionRate:
          (map['workoutCompletionRate'] as num?)?.toDouble() ?? 0.0,
      proteinGoalCompletionRate:
          (map['proteinGoalCompletionRate'] as num?)?.toDouble() ?? 0.0,
      calorieAverage: (map['calorieAverage'] as num?)?.toInt() ?? 2000,
      createdAt: created,
      date: map['date'] != null ? DateTime.tryParse(map['date'].toString()) : null,
      weight: (map['weight'] as num?)?.toDouble() ?? (map['endingWeight'] as num?)?.toDouble(),
      height: (map['height'] as num?)?.toDouble(),
      bmi: (map['bmi'] as num?)?.toDouble() ?? (map['endingBmi'] as num?)?.toDouble(),
      goal: map['goal']?.toString(),
    );
  }
}
