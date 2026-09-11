import 'dart:async';
import 'package:flutter/material.dart';
import '../models/workout_model.dart';
import '../models/exercise_model.dart';
import '../models/workout_set_model.dart';
import '../core/enums/muscle_group.dart';
import '../core/enums/exercise_difficulty.dart';
import '../repositories/workout_repository.dart';
import '../repositories/exercise_repository.dart';

class WorkoutProvider extends ChangeNotifier {
  final WorkoutRepository _workoutRepo;
  final ExerciseRepository _exerciseRepo;

  late WorkoutModel _todayWorkout;
  List<ExerciseModel> _filteredLibrary = [];

  // Filter criteria for Exercise Library
  String _searchQuery = '';
  MuscleGroup? _selectedMuscle;
  String _selectedEquipment = 'All Equipment';
  ExerciseDifficulty? _selectedDifficulty;
  bool _showFavoritesOnly = false;

  // Rest Timer State
  int _restTimerSeconds = 60;
  int _restTimerInitialSeconds = 60;
  bool _isRestTimerActive = false;
  Timer? _restTimer;

  WorkoutModel get todayWorkout => _todayWorkout;
  List<ExerciseModel> get filteredLibrary => _filteredLibrary;
  String get searchQuery => _searchQuery;
  MuscleGroup? get selectedMuscle => _selectedMuscle;
  String get selectedEquipment => _selectedEquipment;
  ExerciseDifficulty? get selectedDifficulty => _selectedDifficulty;
  bool get showFavoritesOnly => _showFavoritesOnly;

  int get restTimerSeconds => _restTimerSeconds;
  int get restTimerInitialSeconds => _restTimerInitialSeconds;
  bool get isRestTimerActive => _isRestTimerActive;
  double get restTimerProgress =>
      _restTimerInitialSeconds == 0 ? 0.0 : (_restTimerSeconds / _restTimerInitialSeconds);

  WorkoutProvider({
    required WorkoutRepository workoutRepo,
    required ExerciseRepository exerciseRepo,
  })  : _workoutRepo = workoutRepo,
        _exerciseRepo = exerciseRepo {
    _init();
  }

  void _init() {
    _todayWorkout = _workoutRepo.getTodayWorkout();
    _applyLibraryFilters();
  }

  void updateSet(String exerciseId, int setIndex, WorkoutSetModel set) {
    _workoutRepo.updateExerciseSet(exerciseId, setIndex, set);
    _todayWorkout = _workoutRepo.getTodayWorkout();
    notifyListeners();
  }

  void addSet(String exerciseId) {
    _workoutRepo.addExerciseSet(exerciseId);
    _todayWorkout = _workoutRepo.getTodayWorkout();
    notifyListeners();
  }

  void completeExercise(String exerciseId) {
    _workoutRepo.markExerciseComplete(exerciseId);
    _todayWorkout = _workoutRepo.getTodayWorkout();
    notifyListeners();
    // Automatically trigger rest timer
    final exercise = _todayWorkout.exercises.firstWhere((e) => e.id == exerciseId);
    startRestTimer(seconds: exercise.restTimeSeconds);
  }

  // Rest Timer Controls
  void startRestTimer({int? seconds}) {
    if (seconds != null) {
      _restTimerInitialSeconds = seconds;
      _restTimerSeconds = seconds;
    }
    _restTimer?.cancel();
    _isRestTimerActive = true;
    notifyListeners();

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restTimerSeconds > 0) {
        _restTimerSeconds--;
        notifyListeners();
      } else {
        stopRestTimer();
      }
    });
  }

  void pauseRestTimer() {
    _restTimer?.cancel();
    _isRestTimerActive = false;
    notifyListeners();
  }

  void resetRestTimer() {
    _restTimer?.cancel();
    _restTimerSeconds = _restTimerInitialSeconds;
    _isRestTimerActive = false;
    notifyListeners();
  }

  void stopRestTimer() {
    _restTimer?.cancel();
    _isRestTimerActive = false;
    notifyListeners();
  }

  void addRestTime(int extraSeconds) {
    _restTimerSeconds += extraSeconds;
    _restTimerInitialSeconds += extraSeconds;
    notifyListeners();
  }

  // Library Filters
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyLibraryFilters();
  }

  void selectMuscleGroup(MuscleGroup? muscle) {
    _selectedMuscle = (_selectedMuscle == muscle) ? null : muscle;
    _applyLibraryFilters();
  }

  void selectEquipment(String equipment) {
    _selectedEquipment = equipment;
    _applyLibraryFilters();
  }

  void selectDifficulty(ExerciseDifficulty? difficulty) {
    _selectedDifficulty = (_selectedDifficulty == difficulty) ? null : difficulty;
    _applyLibraryFilters();
  }

  void toggleFavoritesOnly() {
    _showFavoritesOnly = !_showFavoritesOnly;
    _applyLibraryFilters();
  }

  void toggleExerciseFavorite(String exerciseId) {
    _exerciseRepo.toggleFavorite(exerciseId);
    _applyLibraryFilters();
    notifyListeners();
  }

  void _applyLibraryFilters() {
    _filteredLibrary = _exerciseRepo.searchExercises(
      query: _searchQuery,
      muscleGroup: _selectedMuscle,
      equipment: _selectedEquipment,
      difficulty: _selectedDifficulty,
      favoritesOnly: _showFavoritesOnly,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }
}
