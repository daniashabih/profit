class WorkoutSetModel {
  final int setNumber;
  double weightKg;
  int reps;
  bool isCompleted;

  WorkoutSetModel({
    required this.setNumber,
    required this.weightKg,
    required this.reps,
    this.isCompleted = false,
  });

  WorkoutSetModel copyWith({
    int? setNumber,
    double? weightKg,
    int? reps,
    bool? isCompleted,
  }) {
    return WorkoutSetModel(
      setNumber: setNumber ?? this.setNumber,
      weightKg: weightKg ?? this.weightKg,
      reps: reps ?? this.reps,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'setNumber': setNumber,
      'weightKg': weightKg,
      'reps': reps,
      'isCompleted': isCompleted,
    };
  }

  factory WorkoutSetModel.fromMap(Map<String, dynamic> map) {
    return WorkoutSetModel(
      setNumber: map['setNumber'] ?? 1,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0.0,
      reps: map['reps'] ?? 0,
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}
