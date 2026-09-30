import '../core/enums/muscle_group.dart';

/// Exercise specification within a generated Workout Day
class PlanExercise {
  final String id;
  final String name;
  final MuscleGroup muscleGroup;
  final String equipment;
  final int sets;
  final int reps;
  final double targetWeightKg;
  final int restTimeSeconds;
  final int durationMinutes;
  final String notes;

  const PlanExercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    this.sets = 3,
    this.reps = 10,
    this.targetWeightKg = 20.0,
    this.restTimeSeconds = 60,
    this.durationMinutes = 8,
    this.notes = '',
  });

  PlanExercise copyWith({
    String? id,
    String? name,
    MuscleGroup? muscleGroup,
    String? equipment,
    int? sets,
    int? reps,
    double? targetWeightKg,
    int? restTimeSeconds,
    int? durationMinutes,
    String? notes,
  }) {
    return PlanExercise(
      id: id ?? this.id,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      equipment: equipment ?? this.equipment,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      restTimeSeconds: restTimeSeconds ?? this.restTimeSeconds,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'muscleGroup': muscleGroup.name,
      'equipment': equipment,
      'sets': sets,
      'reps': reps,
      'targetWeightKg': targetWeightKg,
      'restTimeSeconds': restTimeSeconds,
      'durationMinutes': durationMinutes,
      'notes': notes,
    };
  }

  factory PlanExercise.fromMap(Map<String, dynamic> map) {
    return PlanExercise(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      muscleGroup: MuscleGroup.values.firstWhere(
        (m) => m.name.toLowerCase() == map['muscleGroup']?.toString().toLowerCase(),
        orElse: () => MuscleGroup.fullBody,
      ),
      equipment: map['equipment']?.toString() ?? 'Bodyweight',
      sets: (map['sets'] as num?)?.toInt() ?? 3,
      reps: (map['reps'] as num?)?.toInt() ?? 10,
      targetWeightKg: (map['targetWeightKg'] as num?)?.toDouble() ?? 20.0,
      restTimeSeconds: (map['restTimeSeconds'] as num?)?.toInt() ?? 60,
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 8,
      notes: map['notes']?.toString() ?? '',
    );
  }
}

/// Day structure within a weekly workout plan: workoutPlans/{planId}/days/{dayId}
class WorkoutDay {
  final String id;
  final String dayName; // 'Monday', 'Tuesday', ...
  final int dayOfWeek; // 1 = Monday, 7 = Sunday
  final String workoutType; // 'Chest + Triceps', 'Rest Day', ...
  final List<String> targetMuscles;
  final bool isRestDay;
  final List<PlanExercise> exercises;

  const WorkoutDay({
    required this.id,
    required this.dayName,
    required this.dayOfWeek,
    required this.workoutType,
    required this.targetMuscles,
    required this.isRestDay,
    this.exercises = const [],
  });

  WorkoutDay copyWith({
    String? id,
    String? dayName,
    int? dayOfWeek,
    String? workoutType,
    List<String>? targetMuscles,
    bool? isRestDay,
    List<PlanExercise>? exercises,
  }) {
    return WorkoutDay(
      id: id ?? this.id,
      dayName: dayName ?? this.dayName,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      workoutType: workoutType ?? this.workoutType,
      targetMuscles: targetMuscles ?? this.targetMuscles,
      isRestDay: isRestDay ?? this.isRestDay,
      exercises: exercises ?? this.exercises,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dayName': dayName,
      'dayOfWeek': dayOfWeek,
      'workoutType': workoutType,
      'targetMuscles': targetMuscles,
      'isRestDay': isRestDay,
      'exercises': exercises.map((e) => e.toMap()).toList(),
    };
  }

  factory WorkoutDay.fromMap(Map<String, dynamic> map, {String? docId}) {
    return WorkoutDay(
      id: map['id']?.toString() ?? docId ?? '',
      dayName: map['dayName']?.toString() ?? 'Monday',
      dayOfWeek: (map['dayOfWeek'] as num?)?.toInt() ?? 1,
      workoutType: map['workoutType']?.toString() ?? 'Workout',
      targetMuscles: (map['targetMuscles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      isRestDay: map['isRestDay'] == true,
      exercises: (map['exercises'] as List<dynamic>?)
              ?.map((e) => PlanExercise.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );
  }
}

/// Dynamic workout plan: workoutPlans/{planId}
class WorkoutPlan {
  final String id;
  final String userId;
  final String monthId; // e.g. '2026-10'
  final String goalType; // 'Lose Weight', 'Build Muscle', ...
  final int trainingDaysPerWeek; // 2..6
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'active', 'completed', 'archived'
  final String splitType; // 'Upper / Lower', 'Push / Pull / Legs', ...
  final List<WorkoutDay> days;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WorkoutPlan({
    required this.id,
    required this.userId,
    required this.monthId,
    required this.goalType,
    required this.trainingDaysPerWeek,
    required this.startDate,
    required this.endDate,
    this.status = 'active',
    this.splitType = 'Custom Split',
    this.days = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  WorkoutPlan copyWith({
    String? id,
    String? userId,
    String? monthId,
    String? goalType,
    int? trainingDaysPerWeek,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? splitType,
    List<WorkoutDay>? days,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      monthId: monthId ?? this.monthId,
      goalType: goalType ?? this.goalType,
      trainingDaysPerWeek: trainingDaysPerWeek ?? this.trainingDaysPerWeek,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      splitType: splitType ?? this.splitType,
      days: days ?? this.days,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'monthId': monthId,
      'goalType': goalType,
      'trainingDaysPerWeek': trainingDaysPerWeek,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status,
      'splitType': splitType,
      'days': days.map((d) => d.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory WorkoutPlan.fromMap(Map<String, dynamic> map, {String? docId}) {
    return WorkoutPlan(
      id: map['id']?.toString() ?? docId ?? '',
      userId: map['userId']?.toString() ?? '',
      monthId: map['monthId']?.toString() ?? '',
      goalType: map['goalType']?.toString() ?? 'Improve Fitness',
      trainingDaysPerWeek: (map['trainingDaysPerWeek'] as num?)?.toInt() ?? 4,
      startDate: map['startDate'] != null
          ? DateTime.tryParse(map['startDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      endDate: map['endDate'] != null
          ? DateTime.tryParse(map['endDate'].toString()) ??
              DateTime.now().add(const Duration(days: 30))
          : DateTime.now().add(const Duration(days: 30)),
      status: map['status']?.toString() ?? 'active',
      splitType: map['splitType']?.toString() ?? 'Custom Split',
      days: (map['days'] as List<dynamic>?)
              ?.map((d) => WorkoutDay.fromMap(Map<String, dynamic>.from(d as Map)))
              .toList() ??
          const [],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
