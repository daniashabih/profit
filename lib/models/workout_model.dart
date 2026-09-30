import 'exercise_model.dart';

class WorkoutModel {
  final String id;
  final String title;
  final String subtitle;
  final int durationMinutes;
  final List<ExerciseModel> exercises;
  final String category;
  final String intensity;
  final int estimatedCalories;
  final String? userId;
  final bool isTemplate;
  final DateTime createdAt;
  final DateTime updatedAt;
  bool isCompletedToday;

  WorkoutModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.durationMinutes,
    required this.exercises,
    this.userId,
    this.category = 'Strength',
    this.intensity = 'Moderate',
    this.estimatedCalories = 280,
    this.isCompletedToday = false,
    this.isTemplate = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  int get totalExercises => exercises.length;

  int get completedExercisesCount =>
      exercises.where((e) => e.isCompleted).length;

  double get progressPercentage {
    if (exercises.isEmpty) return 0.0;
    return completedExercisesCount / exercises.length;
  }

  WorkoutModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? subtitle,
    int? durationMinutes,
    List<ExerciseModel>? exercises,
    String? category,
    String? intensity,
    int? estimatedCalories,
    bool? isCompletedToday,
    bool? isTemplate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      exercises: exercises ?? this.exercises.map((e) => e.copyWith()).toList(),
      category: category ?? this.category,
      intensity: intensity ?? this.intensity,
      estimatedCalories: estimatedCalories ?? this.estimatedCalories,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
      isTemplate: isTemplate ?? this.isTemplate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      if (userId != null) 'userId': userId,
      'title': title,
      'subtitle': subtitle,
      'durationMinutes': durationMinutes,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'category': category,
      'intensity': intensity,
      'estimatedCalories': estimatedCalories,
      'isCompletedToday': isCompletedToday,
      'isTemplate': isTemplate,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Cloud Firestore payload strictly adhering to firestore.rules isValidWorkout
  Map<String, dynamic> toFirestoreMap() {
    final map = <String, dynamic>{
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'durationMinutes': durationMinutes,
      'category': category,
      'intensity': intensity,
      'estimatedCalories': estimatedCalories,
      'isCompletedToday': isCompletedToday,
      'isTemplate': isTemplate,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
    if (userId != null && userId!.isNotEmpty) {
      map['userId'] = userId!;
    }
    return map;
  }

  factory WorkoutModel.fromMap(Map<String, dynamic> map) {
    return WorkoutModel(
      id: map['id']?.toString() ?? '',
      userId: map['userId']?.toString(),
      title: map['title']?.toString() ?? '',
      subtitle: map['subtitle']?.toString() ?? '',
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 30,
      exercises: (map['exercises'] as List<dynamic>?)
              ?.map((item) => ExerciseModel.fromMap(Map<String, dynamic>.from(item as Map)))
              .toList() ??
          [],
      category: map['category']?.toString() ?? 'Strength',
      intensity: map['intensity']?.toString() ?? 'Moderate',
      estimatedCalories: (map['estimatedCalories'] as num?)?.toInt() ?? 250,
      isCompletedToday: map['isCompletedToday'] == true,
      isTemplate: map['isTemplate'] == true,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
