/// Recorded set performance in a workout log
class LoggedSet {
  final int setNumber;
  final double weightKg;
  final int reps;
  final bool isCompleted;

  const LoggedSet({
    required this.setNumber,
    required this.weightKg,
    required this.reps,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'setNumber': setNumber,
      'weightKg': weightKg,
      'reps': reps,
      'isCompleted': isCompleted,
    };
  }

  factory LoggedSet.fromMap(Map<String, dynamic> map) {
    return LoggedSet(
      setNumber: (map['setNumber'] as num?)?.toInt() ?? 1,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0.0,
      reps: (map['reps'] as num?)?.toInt() ?? 0,
      isCompleted: map['isCompleted'] == true,
    );
  }
}

/// Recorded exercise performance in a workout log
class LoggedExercise {
  final String exerciseId;
  final String exerciseName;
  final String muscleGroup;
  final int plannedSets;
  final int plannedReps;
  final List<LoggedSet> sets;
  final bool isCompleted;

  const LoggedExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.muscleGroup,
    required this.plannedSets,
    required this.plannedReps,
    this.sets = const [],
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'muscleGroup': muscleGroup,
      'plannedSets': plannedSets,
      'plannedReps': plannedReps,
      'sets': sets.map((s) => s.toMap()).toList(),
      'isCompleted': isCompleted,
    };
  }

  factory LoggedExercise.fromMap(Map<String, dynamic> map) {
    return LoggedExercise(
      exerciseId: map['exerciseId']?.toString() ?? '',
      exerciseName: map['exerciseName']?.toString() ?? '',
      muscleGroup: map['muscleGroup']?.toString() ?? '',
      plannedSets: (map['plannedSets'] as num?)?.toInt() ?? 3,
      plannedReps: (map['plannedReps'] as num?)?.toInt() ?? 10,
      sets: (map['sets'] as List<dynamic>?)
              ?.map((s) => LoggedSet.fromMap(Map<String, dynamic>.from(s as Map)))
              .toList() ??
          const [],
      isCompleted: map['isCompleted'] == true,
    );
  }
}

/// Log of an executed daily workout session: workoutLogs/{logId}
class WorkoutLog {
  final String id;
  final String userId;
  final String workoutPlanId;
  final String dayId;
  final String workoutTitle;
  final List<String> targetMuscles;
  final int durationMinutes;
  final int completedExercises;
  final int totalExercises;
  final List<LoggedExercise> exercises;
  final DateTime completedAt;
  final String dateString; // 'YYYY-MM-DD'

  const WorkoutLog({
    required this.id,
    required this.userId,
    required this.workoutPlanId,
    required this.dayId,
    required this.workoutTitle,
    required this.targetMuscles,
    this.durationMinutes = 45,
    required this.completedExercises,
    required this.totalExercises,
    this.exercises = const [],
    required this.completedAt,
    required this.dateString,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'workoutPlanId': workoutPlanId,
      'dayId': dayId,
      'workoutTitle': workoutTitle,
      'targetMuscles': targetMuscles,
      'durationMinutes': durationMinutes,
      'completedExercises': completedExercises,
      'totalExercises': totalExercises,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'completedAt': completedAt.toIso8601String(),
      'dateString': dateString,
      'createdAt': completedAt.toIso8601String(),
    };
  }

  factory WorkoutLog.fromMap(Map<String, dynamic> map, {String? docId}) {
    return WorkoutLog(
      id: map['id']?.toString() ?? docId ?? '',
      userId: map['userId']?.toString() ?? '',
      workoutPlanId: map['workoutPlanId']?.toString() ?? '',
      dayId: map['dayId']?.toString() ?? '',
      workoutTitle: map['workoutTitle']?.toString() ?? '',
      targetMuscles: (map['targetMuscles'] as List<dynamic>?)
              ?.map((m) => m.toString())
              .toList() ??
          const [],
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 45,
      completedExercises: (map['completedExercises'] as num?)?.toInt() ?? 0,
      totalExercises: (map['totalExercises'] as num?)?.toInt() ?? 0,
      exercises: (map['exercises'] as List<dynamic>?)
              ?.map((e) => LoggedExercise.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      completedAt: map['completedAt'] != null
          ? DateTime.tryParse(map['completedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      dateString: map['dateString']?.toString() ??
          DateTime.now().toIso8601String().split('T').first,
    );
  }
}
