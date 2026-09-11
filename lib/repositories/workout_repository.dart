import '../models/workout_model.dart';
import '../models/workout_set_model.dart';
import 'exercise_repository.dart';

abstract class WorkoutRepository {
  WorkoutModel getTodayWorkout();
  List<WorkoutModel> getWorkoutPlans();
  void updateExerciseSet(String exerciseId, int setIndex, WorkoutSetModel updatedSet);
  void addExerciseSet(String exerciseId);
  void markExerciseComplete(String exerciseId);
}

class LocalWorkoutRepository implements WorkoutRepository {
  final ExerciseRepository _exerciseRepo;
  late WorkoutModel _todayWorkout;

  LocalWorkoutRepository({required ExerciseRepository exerciseRepo})
      : _exerciseRepo = exerciseRepo {
    _initTodayWorkout();
  }

  void _initTodayWorkout() {
    final all = _exerciseRepo.getAllExercises();

    // 7 numbered journey exercises as requested:
    // 01 Bench Press, 02 Shoulder Press, 03 Lat Pulldown, 04 Dumbbell Row, 05 Squat, 06 Leg Press, 07 Plank
    final journeyExercises = [
      all[0].copyWith(isCompleted: true), // 01 Bench Press
      all[1].copyWith(isCompleted: true), // 02 Shoulder Press
      all[2].copyWith(isCompleted: true), // 03 Lat Pulldown
      all[3].copyWith(isCompleted: true), // 04 Dumbbell Row
      all[4].copyWith(isCompleted: true), // 05 Squat (making it ~70% overall progress: 5/7 = 71%)
      all[5].copyWith(isCompleted: false), // 06 Leg Press
      all[6].copyWith(isCompleted: false), // 07 Plank
    ];

    _todayWorkout = WorkoutModel(
      id: 'wk_today_upper_body',
      title: 'Upper Body',
      subtitle: 'Strength & Hypertrophy Focus',
      durationMinutes: 38,
      exercises: journeyExercises,
      category: 'Strength',
      intensity: 'High Intensity',
      estimatedCalories: 340,
    );
  }

  @override
  WorkoutModel getTodayWorkout() => _todayWorkout;

  @override
  List<WorkoutModel> getWorkoutPlans() {
    return [
      _todayWorkout,
      WorkoutModel(
        id: 'wk_lower_strength',
        title: 'Lower Body & Core',
        subtitle: 'Glutes, Quads & Hamstrings',
        durationMinutes: 45,
        exercises: _exerciseRepo.getAllExercises().sublist(4, 7),
        category: 'Lower Body',
        intensity: 'Moderate',
        estimatedCalories: 380,
      ),
      WorkoutModel(
        id: 'wk_full_body_hiit',
        title: 'Full Body Circuit',
        subtitle: 'Cardio & Muscular Endurance',
        durationMinutes: 30,
        exercises: _exerciseRepo.getAllExercises().take(5).toList(),
        category: 'Conditioning',
        intensity: 'Maximum',
        estimatedCalories: 410,
      ),
    ];
  }

  @override
  void updateExerciseSet(String exerciseId, int setIndex, WorkoutSetModel updatedSet) {
    final exIndex = _todayWorkout.exercises.indexWhere((e) => e.id == exerciseId);
    if (exIndex != -1) {
      final exercise = _todayWorkout.exercises[exIndex];
      if (setIndex < exercise.setsList.length) {
        exercise.setsList[setIndex] = updatedSet;
        // Check if all sets completed
        final allDone = exercise.setsList.every((s) => s.isCompleted);
        exercise.isCompleted = allDone;
      }
    }
  }

  @override
  void addExerciseSet(String exerciseId) {
    final exIndex = _todayWorkout.exercises.indexWhere((e) => e.id == exerciseId);
    if (exIndex != -1) {
      final exercise = _todayWorkout.exercises[exIndex];
      final newSetNum = exercise.setsList.length + 1;
      final lastWeight = exercise.setsList.isNotEmpty ? exercise.setsList.last.weightKg : 20.0;
      final lastReps = exercise.setsList.isNotEmpty ? exercise.setsList.last.reps : 10;
      exercise.setsList.add(WorkoutSetModel(
        setNumber: newSetNum,
        weightKg: lastWeight,
        reps: lastReps,
        isCompleted: false,
      ));
    }
  }

  @override
  void markExerciseComplete(String exerciseId) {
    final exIndex = _todayWorkout.exercises.indexWhere((e) => e.id == exerciseId);
    if (exIndex != -1) {
      final exercise = _todayWorkout.exercises[exIndex];
      for (final s in exercise.setsList) {
        s.isCompleted = true;
      }
      exercise.isCompleted = true;
    }
  }
}
