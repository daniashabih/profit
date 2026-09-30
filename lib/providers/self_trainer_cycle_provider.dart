import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/fitness_profile_model.dart';
import '../models/monthly_cycle_model.dart';
import '../models/workout_plan_model.dart';
import '../models/workout_log_model.dart';
import '../models/meal_plan_model.dart';
import '../models/bmi_record_model.dart';
import '../models/progress_record_model.dart';
import '../services/fitness_profile_service.dart';
import '../services/workout_plan_service.dart';
import '../services/workout_log_service.dart';
import '../services/nutrition_service.dart';
import '../services/monthly_cycle_service.dart';
import '../services/bmi_service.dart';

/// Central reactive provider orchestrating the complete Self Trainer Fitness Cycle
class SelfTrainerCycleProvider extends ChangeNotifier {
  final FitnessProfileService _fitnessProfileService;
  final WorkoutPlanService _workoutPlanService;
  final WorkoutLogService _workoutLogService;
  final NutritionService _nutritionService;
  final MonthlyCycleService _monthlyCycleService;
  final BmiService _bmiService;

  FitnessProfile? _fitnessProfile;
  MonthlyCycle? _currentCycle;
  MonthlyCycle? _cycleToReview;
  List<MonthlyCycle> _cycleHistory = [];
  WorkoutPlan? _currentWorkoutPlan;
  WorkoutDay? _todayWorkoutDay;
  MealPlan? _currentMealPlan;
  WorkoutLog? _todayWorkoutLog;
  List<BmiRecord> _bmiHistory = [];
  List<ProgressRecord> _progressRecords = [];

  bool _isLoading = false;
  String? _errorMessage;
  String? _boundUserId;

  SelfTrainerCycleProvider({
    FitnessProfileService? fitnessProfileService,
    WorkoutPlanService? workoutPlanService,
    WorkoutLogService? workoutLogService,
    NutritionService? nutritionService,
    MonthlyCycleService? monthlyCycleService,
    BmiService? bmiService,
  })  : _fitnessProfileService = fitnessProfileService ?? FitnessProfileService(),
        _workoutPlanService = workoutPlanService ?? WorkoutPlanService(),
        _workoutLogService = workoutLogService ?? WorkoutLogService(),
        _nutritionService = nutritionService ?? NutritionService(),
        _monthlyCycleService = monthlyCycleService ?? MonthlyCycleService(),
        _bmiService = bmiService ?? BmiService();

  // Getters
  FitnessProfile? get fitnessProfile => _fitnessProfile;
  MonthlyCycle? get currentCycle => _currentCycle;
  MonthlyCycle? get cycleToReview => _cycleToReview;
  List<MonthlyCycle> get cycleHistory => _cycleHistory;
  WorkoutPlan? get currentWorkoutPlan => _currentWorkoutPlan;
  WorkoutDay? get todayWorkoutDay => _todayWorkoutDay;
  MealPlan? get currentMealPlan => _currentMealPlan;
  WorkoutLog? get todayWorkoutLog => _todayWorkoutLog;
  List<BmiRecord> get bmiHistory => _bmiHistory;
  List<ProgressRecord> get progressRecords => _progressRecords;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasActivePlan => _currentWorkoutPlan != null && _currentMealPlan != null;

  // Dynamic calculations based on user profile and current data
  double get currentWeight => _fitnessProfile?.currentWeightKg ?? 70.0;
  double get startingWeight => _currentCycle?.startingWeight ?? _fitnessProfile?.currentWeightKg ?? 70.0;
  double get targetWeight => _fitnessProfile?.targetWeightKg ?? 65.0;
  double get heightCm => _fitnessProfile?.heightCm ?? 175.0;
  String get goalType => _fitnessProfile?.goalType ?? 'Improve Fitness';

  double get bmi => BmiService.calculateBmi(currentWeight, heightCm);
  String get bmiCategory => BmiService.getBmiCategory(bmi);

  /// Target weight progress percentage (0.0 to 1.0)
  double get targetWeightProgress {
    final start = startingWeight;
    final current = currentWeight;
    final target = targetWeight;
    final totalSpan = (start - target).abs();
    if (totalSpan < 0.1) return 1.0;

    final normalizedGoal = goalType.toLowerCase();
    if (normalizedGoal.contains('build') || normalizedGoal.contains('muscle') || target > start) {
      // Weight gain goal
      final progress = (current - start) / totalSpan;
      return progress.clamp(0.0, 1.0);
    } else {
      // Weight loss / general reduction goal
      final progress = (start - current) / totalSpan;
      return progress.clamp(0.0, 1.0);
    }
  }

  double get weightDeltaKg {
    final diff = currentWeight - startingWeight;
    return double.parse(diff.toStringAsFixed(1));
  }

  double get weightRemainingKg {
    final diff = (currentWeight - targetWeight).abs();
    return double.parse(diff.toStringAsFixed(1));
  }

  // Protein targets & consumption
  double get dailyProteinTarget => _currentMealPlan?.targetProteinGrams ?? 120.0;
  double get dailyProteinConsumed => _currentMealPlan?.consumedProteinGrams ?? 0.0;
  double get dailyProteinRemaining => (_currentMealPlan?.remainingProteinGrams ?? dailyProteinTarget);
  double get dailyProteinProgress => _currentMealPlan?.proteinProgress ?? 0.0;

  // Calorie targets & consumption
  int get dailyCalorieTarget => _currentMealPlan?.targetCalories ?? 2000;
  int get dailyCalorieConsumed => _currentMealPlan?.consumedCalories ?? 0;

  // Today workout state
  bool get isTodayRestDay => _todayWorkoutDay?.isRestDay ?? false;
  int get todayCompletedExercisesCount => _todayWorkoutLog?.completedExercises ?? 0;
  int get todayTotalExercisesCount => _todayWorkoutDay?.exercises.length ?? 0;

  double get todayWorkoutProgress {
    if (todayTotalExercisesCount == 0) return isTodayRestDay ? 1.0 : 0.0;
    return (todayCompletedExercisesCount / todayTotalExercisesCount).clamp(0.0, 1.0);
  }

  bool get isTodayWorkoutFinished =>
      !isTodayRestDay &&
      todayTotalExercisesCount > 0 &&
      todayCompletedExercisesCount >= todayTotalExercisesCount;

  /// Initializes the fitness cycle for the logged-in user
  Future<void> initializeForUser(UserModel user) async {
    _boundUserId = user.id;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Fetch user fitness profile
      _fitnessProfile = await _fitnessProfileService.getFitnessProfile(user.id);

      // If user hasn't completed setup yet, set loading false and return
      if (_fitnessProfile == null || !_fitnessProfile!.fitnessSetupCompleted) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      // 2. Check / Generate current month cycle (Idempotent)
      _currentCycle = await _monthlyCycleService.checkCurrentMonthlyCycle(user.id);

      // 3. Load active workout plan
      if (_currentCycle != null && _currentCycle!.workoutPlanId.isNotEmpty) {
        _currentWorkoutPlan = await _workoutPlanService.getActivePlan(user.id);
      }

      // 4. Load active meal plan
      if (_currentCycle != null && _currentCycle!.mealPlanId.isNotEmpty) {
        _currentMealPlan = await _nutritionService.getActiveMealPlan(user.id);
      }

      // 5. Determine today's workout day (1 = Monday, 7 = Sunday)
      _resolveTodayWorkoutDay();

      // 6. Check today's workout log
      final logs = await _workoutLogService.getWorkoutLogs(
        userId: user.id,
        startDate: DateTime.now().subtract(const Duration(hours: 24)),
      );
      final todayStr = DateTime.now().toIso8601String().split('T').first;
      _todayWorkoutLog = logs.where((l) => l.dateString == todayStr).lastOrNull;

      // 7. Load BMI history and monthly cycle history
      _bmiHistory = await _bmiService.getBmiHistory(user.id);
      _cycleHistory = await _monthlyCycleService.getMonthlyCyclesHistory(user.id);
      _progressRecords = await _monthlyCycleService.getProgressRecords(user.id);

      // 8. Check if there is an unreviewed completed cycle
      _cycleToReview = _cycleHistory.where((c) => c.isCompleted && c.reviewedAt == null).firstOrNull;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void _resolveTodayWorkoutDay() {
    if (_currentWorkoutPlan == null || _currentWorkoutPlan!.days.isEmpty) {
      _todayWorkoutDay = null;
      return;
    }

    final currentDayOfWeek = DateTime.now().weekday; // 1 = Mon, 7 = Sun
    _todayWorkoutDay = _currentWorkoutPlan!.days.firstWhere(
      (d) => d.dayOfWeek == currentDayOfWeek,
      orElse: () => _currentWorkoutPlan!.days.first,
    );
  }

  /// Completes the Personal Fitness Setup Wizard and immediately generates the first monthly cycle
  Future<void> completeFitnessSetup({
    required String userId,
    required String fullName,
    required int age,
    required String gender,
    required double heightCm,
    required double currentWeightKg,
    required double targetWeightKg,
    required String goalType,
    required int trainingDaysPerWeek,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final calculatedBmi = BmiService.calculateBmi(currentWeightKg, heightCm);
      final category = BmiService.getBmiCategory(calculatedBmi);

      final profile = FitnessProfile(
        userId: userId,
        fullName: fullName,
        age: age,
        gender: gender,
        heightCm: heightCm,
        currentWeightKg: currentWeightKg,
        targetWeightKg: targetWeightKg,
        goalType: goalType,
        bmi: calculatedBmi,
        bmiCategory: category,
        trainingDaysPerWeek: trainingDaysPerWeek,
        fitnessLevel: 'Beginner',
        activityLevel: 'moderately_active',
        fitnessSetupCompleted: true,
        createdAt: now,
        updatedAt: now,
      );

      // 1. Save profile to Firestore
      _fitnessProfile = await _fitnessProfileService.saveFitnessProfile(profile);

      // 2. Generate monthly cycle, workout plan, and meal plan
      _currentCycle = await _monthlyCycleService.checkCurrentMonthlyCycle(userId);

      // 3. Load generated plans
      _currentWorkoutPlan = await _workoutPlanService.getActivePlan(userId);
      _currentMealPlan = await _nutritionService.getActiveMealPlan(userId);

      _resolveTodayWorkoutDay();

      // 4. Update BMI history
      _bmiHistory = await _bmiService.getBmiHistory(userId);
      _cycleHistory = await _monthlyCycleService.getMonthlyCyclesHistory(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Updates current weight, recalculates BMI, creates new BMI record, and refreshes UI
  Future<void> updateWeight(double newWeightKg) async {
    if (_boundUserId == null || _fitnessProfile == null) return;

    try {
      final updatedProfile = await _fitnessProfileService.updateBodyMetrics(
        userId: _boundUserId!,
        newWeightKg: newWeightKg,
      );

      if (updatedProfile != null) {
        _fitnessProfile = updatedProfile;
        _bmiHistory = await _bmiService.getBmiHistory(_boundUserId!);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Toggles meal consumption status and automatically updates daily protein and calories
  Future<void> toggleMealConsumed(String mealId, bool isConsumed) async {
    if (_currentMealPlan == null) return;

    try {
      final updatedPlan = await _nutritionService.toggleMealConsumption(
        planId: _currentMealPlan!.id,
        mealId: mealId,
        isConsumed: isConsumed,
      );

      _currentMealPlan = updatedPlan;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Logs a completed workout session with exercise performance
  Future<void> logWorkoutExecution(WorkoutLog log) async {
    try {
      final savedLog = await _workoutLogService.logWorkoutSession(log);
      _todayWorkoutLog = savedLog;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Regenerates current workout and nutrition plan with updated preferences without deleting past history
  Future<void> regenerateCurrentPlan({
    String? newGoal,
    int? newDaysPerWeek,
  }) async {
    if (_boundUserId == null || _fitnessProfile == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final updatedProfile = _fitnessProfile!.copyWith(
        goalType: newGoal ?? _fitnessProfile!.goalType,
        trainingDaysPerWeek: newDaysPerWeek ?? _fitnessProfile!.trainingDaysPerWeek,
        updatedAt: DateTime.now(),
      );

      await _fitnessProfileService.saveFitnessProfile(updatedProfile);
      _fitnessProfile = updatedProfile;

      final now = DateTime.now();
      final monthId = '${now.year}-${now.month.toString().padLeft(2, '0')}';

      _currentWorkoutPlan = await _workoutPlanService.generatePersonalizedPlan(
        userId: _boundUserId!,
        goalType: updatedProfile.goalType,
        trainingDaysPerWeek: updatedProfile.trainingDaysPerWeek,
        userWeightKg: updatedProfile.currentWeightKg,
        fitnessLevel: updatedProfile.fitnessLevel,
        monthId: monthId,
      );

      _currentMealPlan = await _nutritionService.generatePersonalizedMealPlan(
        userId: _boundUserId!,
        weightKg: updatedProfile.currentWeightKg,
        heightCm: updatedProfile.heightCm,
        age: updatedProfile.age,
        gender: updatedProfile.gender,
        goalType: updatedProfile.goalType,
        trainingDaysPerWeek: updatedProfile.trainingDaysPerWeek,
        monthId: monthId,
      );

      _resolveTodayWorkoutDay();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Dismisses or marks the review dialog for a completed monthly cycle
  void dismissMonthlyReview() {
    _cycleToReview = null;
    notifyListeners();
  }
}
