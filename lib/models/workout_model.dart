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
  bool isCompletedToday;

  WorkoutModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.durationMinutes,
    required this.exercises,
    this.category = 'Strength',
    this.intensity = 'Moderate',
    this.estimatedCalories = 280,
    this.isCompletedToday = false,
  });

  int get totalExercises => exercises.length;

  int get completedExercisesCount =>
      exercises.where((e) => e.isCompleted).length;

  double get progressPercentage {
    if (exercises.isEmpty) return 0.0;
    return completedExercisesCount / exercises.length;
  }

  WorkoutModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    int? durationMinutes,
    List<ExerciseModel>? exercises,
    String? category,
    String? intensity,
    int? estimatedCalories,
    bool? isCompletedToday,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      exercises: exercises ?? this.exercises.map((e) => e.copyWith()).toList(),
      category: category ?? this.category,
      intensity: intensity ?? this.intensity,
      estimatedCalories: estimatedCalories ?? this.estimatedCalories,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'durationMinutes': durationMinutes,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'category': category,
      'intensity': intensity,
      'estimatedCalories': estimatedCalories,
      'isCompletedToday': isCompletedToday,
    };
  }

  factory WorkoutModel.fromMap(Map<String, dynamic> map) {
    return WorkoutModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      durationMinutes: map['durationMinutes'] ?? 30,
      exercises: (map['exercises'] as List<dynamic>?)
              ?.map((item) => ExerciseModel.fromMap(item))
              .toList() ??
          [],
      category: map['category'] ?? 'Strength',
      intensity: map['intensity'] ?? 'Moderate',
      estimatedCalories: map['estimatedCalories'] ?? 250,
      isCompletedToday: map['isCompletedToday'] ?? false,
    );
  }
}
