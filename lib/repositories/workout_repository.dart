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

    // Exact match to reference image mockup (Chest, January 20):
    // 01 Bench Press, 02 Chest Dip, 03 Dumbbell Fly, 04 Incline Bench Press
    final chestExercises = all.take(4).toList();

    _todayWorkout = WorkoutModel(
      id: 'wk_today_chest',
      title: 'Chest',
      subtitle: 'January 20',
      durationMinutes: 45,
      exercises: chestExercises,
      category: 'Compound',
      intensity: 'High Intensity',
      estimatedCalories: 380,
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
