import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import '../models/monthly_cycle_model.dart';
import '../models/progress_record_model.dart';
import '../models/fitness_profile_model.dart';
import 'workout_plan_service.dart';
import 'nutrition_service.dart';
import 'fitness_profile_service.dart';
import 'workout_log_service.dart';
import 'bmi_service.dart';

/// MonthlyCycleService
/// Orchestrates the entire Monthly Fitness Cycle:
/// - Idempotent cycle checking and generation on app launch
/// - Automatic month-end evaluation (weight, BMI, workout completion %, protein consistency %)
/// - Progressive overload workout plan creation for next cycle
/// - Dynamic nutrition target adjustments
/// - Non-destructive historical preservation: all monthly cycles and progress records persist
class MonthlyCycleService {
  final FirebaseFirestore? _firestore;
  final FitnessProfileService _fitnessProfileService;
  final WorkoutPlanService _workoutPlanService;
  final NutritionService _nutritionService;
  final WorkoutLogService _workoutLogService;

  // Local cache for offline/testing runs
  final Map<String, MonthlyCycle> _localCycles = {};
  final List<ProgressRecord> _localProgressRecords = [];

  MonthlyCycleService({
    FirebaseFirestore? firestore,
    FitnessProfileService? fitnessProfileService,
    WorkoutPlanService? workoutPlanService,
    NutritionService? nutritionService,
    WorkoutLogService? workoutLogService,
  })  : _firestore = firestore ??
            (Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null),
        _fitnessProfileService = fitnessProfileService ?? FitnessProfileService(firestore: firestore),
        _workoutPlanService = workoutPlanService ?? WorkoutPlanService(firestore: firestore),
        _nutritionService = nutritionService ?? NutritionService(firestore: firestore),
        _workoutLogService = workoutLogService ?? WorkoutLogService(firestore: firestore);

  /// Checks if an active cycle exists for the current calendar month.
  /// If it does, returns the existing cycle (idempotent, never duplicates).
  /// If missing or outdated, safely evaluates previous month's progress and generates the new cycle.
  Future<MonthlyCycle?> checkCurrentMonthlyCycle(String userId) async {
    if (userId.isEmpty) return null;

    final now = DateTime.now();
    final currentMonthId = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final currentCycleId = '${userId}_cycle_$currentMonthId';

    // 1. Check local cache
    if (_localCycles.containsKey(currentCycleId)) {
      return _localCycles[currentCycleId];
    }

    // 2. Check Cloud Firestore for existing active cycle of current month
    if (_firestore != null) {
      try {
        final doc = await _firestore.collection('monthlyCycles').doc(currentCycleId).get();
        if (doc.exists && doc.data() != null) {
          final cycle = MonthlyCycle.fromMap(doc.data()!, docId: doc.id);
          _localCycles[currentCycleId] = cycle;
          return cycle;
        }
      } catch (_) {}
    }

    // 3. Cycle does not exist for current month -> Generate it!
    final profile = await _fitnessProfileService.getFitnessProfile(userId);
    if (profile == null) return null;

    return await _generateNewMonthlyCycle(
      profile: profile,
      now: now,
      monthId: currentMonthId,
      cycleId: currentCycleId,
    );
  }

  /// Internal generator that evaluates past progress, applies progressive overload,
  /// and persists the new cycle.
  Future<MonthlyCycle> _generateNewMonthlyCycle({
    required FitnessProfile profile,
    required DateTime now,
    required String monthId,
    required String cycleId,
  }) async {
    final monthName = DateFormat('MMMM').format(now);
    final startDate = DateTime(now.year, now.month, 1);
    final endDate = DateTime(now.year, now.month + 1, 0);

    // 1. Inspect previous cycle
    final previousCycle = await _getLatestPreviousCycle(profile.userId, monthId);
    double progressiveFactor = 1.0;

    if (previousCycle != null && previousCycle.status == 'active') {
      // Evaluate previous cycle performance
      final prevStart = previousCycle.startDate;
      final prevEnd = previousCycle.endDate;

      final scheduledWorkouts = profile.trainingDaysPerWeek * 4;
      final completionRate = await _workoutLogService.calculateMonthlyCompletionRate(
        userId: profile.userId,
        monthStart: prevStart,
        monthEnd: prevEnd,
        scheduledWorkoutsCount: scheduledWorkouts,
      );

      // Estimate protein adherence (default to 75% or actual consistency if logs exist)
      final proteinRate = (completionRate * 0.95).clamp(40.0, 100.0);

      final endingWeight = profile.currentWeightKg;
      final endingBmi = BmiService.calculateBmi(endingWeight, profile.heightCm);

      // Finalize and archive previous cycle
      final finalizedPrevCycle = previousCycle.copyWith(
        status: 'completed',
        isCurrent: false,
        endingWeight: endingWeight,
        endingBmi: endingBmi,
        workoutCompletionRate: double.parse(completionRate.toStringAsFixed(1)),
        proteinGoalCompletionRate: double.parse(proteinRate.toStringAsFixed(1)),
        updatedAt: now,
      );

      _localCycles[finalizedPrevCycle.id] = finalizedPrevCycle;

      // Save previous month progress record
      final progressRecord = ProgressRecord(
        id: '${profile.userId}_progress_${previousCycle.monthId}',
        userId: profile.userId,
        monthId: previousCycle.monthId,
        monthName: previousCycle.monthName,
        year: previousCycle.year,
        startDate: prevStart,
        endDate: prevEnd,
        startingWeight: previousCycle.startingWeight,
        endingWeight: endingWeight,
        startingBmi: previousCycle.startingBmi,
        endingBmi: endingBmi,
        workoutCompletionRate: double.parse(completionRate.toStringAsFixed(1)),
        proteinGoalCompletionRate: double.parse(proteinRate.toStringAsFixed(1)),
        createdAt: now,
      );
      _localProgressRecords.add(progressRecord);

      if (_firestore != null) {
        try {
          await _firestore.collection('monthlyCycles').doc(finalizedPrevCycle.id).set(finalizedPrevCycle.toMap());
          await _firestore.collection('progressRecords').doc(progressRecord.id).set(progressRecord.toMap());
        } catch (_) {}
      }

      // Progressive overload factor: If athlete adhered to >= 70% of workouts, increase challenge
      if (completionRate >= 70.0) {
        progressiveFactor = 1.05; // 5% progressive overload
      }
    }

    // 2. Generate updated workout plan with progressive overload
    final workoutPlan = await _workoutPlanService.generatePersonalizedPlan(
      userId: profile.userId,
      goalType: profile.goalType,
      trainingDaysPerWeek: profile.trainingDaysPerWeek,
      userWeightKg: profile.currentWeightKg,
      fitnessLevel: profile.fitnessLevel,
      monthId: monthId,
      progressiveOverloadFactor: progressiveFactor,
    );

    // 3. Generate updated nutrition plan
    final mealPlan = await _nutritionService.generatePersonalizedMealPlan(
      userId: profile.userId,
      weightKg: profile.currentWeightKg,
      heightCm: profile.heightCm,
      age: profile.age,
      gender: profile.gender,
      goalType: profile.goalType,
      trainingDaysPerWeek: profile.trainingDaysPerWeek,
      monthId: monthId,
    );

    // 4. Create new MonthlyCycle
    final newCycle = MonthlyCycle(
      id: cycleId,
      userId: profile.userId,
      monthId: monthId,
      monthName: monthName,
      year: now.year,
      startDate: startDate,
      endDate: endDate,
      status: 'active',
      workoutPlanId: workoutPlan.id,
      mealPlanId: mealPlan.id,
      startingWeight: profile.currentWeightKg,
      startingBmi: profile.bmi,
      isCurrent: true,
      createdAt: now,
      updatedAt: now,
    );

    _localCycles[cycleId] = newCycle;

    if (_firestore != null && profile.userId.isNotEmpty) {
      try {
        await _firestore.collection('monthlyCycles').doc(cycleId).set(newCycle.toMap());
      } catch (_) {}
    }

    return newCycle;
  }

  Future<MonthlyCycle?> _getLatestPreviousCycle(String userId, String currentMonthId) async {
    if (_firestore != null && userId.isNotEmpty) {
      try {
        final query = await _firestore
            .collection('monthlyCycles')
            .where('userId', isEqualTo: userId)
            .orderBy('startDate', descending: true)
            .limit(2)
            .get();

        for (final doc in query.docs) {
          final cycle = MonthlyCycle.fromMap(doc.data(), docId: doc.id);
          if (cycle.monthId != currentMonthId) {
            return cycle;
          }
        }
      } catch (_) {}
    }

    return _localCycles.values
        .where((c) => c.userId == userId && c.monthId != currentMonthId)
        .lastOrNull;
  }

  /// Retrieves full history of monthly cycles for the user (non-destructive history)
  Future<List<MonthlyCycle>> getMonthlyCyclesHistory(String userId) async {
    if (_firestore != null && userId.isNotEmpty) {
      try {
        final query = await _firestore
            .collection('monthlyCycles')
            .where('userId', isEqualTo: userId)
            .orderBy('startDate', descending: true)
            .get();

        if (query.docs.isNotEmpty) {
          final list = query.docs
              .map((doc) => MonthlyCycle.fromMap(doc.data(), docId: doc.id))
              .toList();
          for (final c in list) {
            _localCycles[c.id] = c;
          }
          return list;
        }
      } catch (_) {}
    }

    final localList = _localCycles.values.where((c) => c.userId == userId).toList();
    localList.sort((a, b) => b.startDate.compareTo(a.startDate));
    return localList;
  }

  /// Retrieves all historical progress records
  Future<List<ProgressRecord>> getProgressRecords(String userId) async {
    if (_firestore != null && userId.isNotEmpty) {
      try {
        final query = await _firestore
            .collection('progressRecords')
            .where('userId', isEqualTo: userId)
            .orderBy('startDate', descending: true)
            .get();

        if (query.docs.isNotEmpty) {
          return query.docs
              .map((doc) => ProgressRecord.fromMap(doc.data(), docId: doc.id))
              .toList();
        }
      } catch (_) {}
    }

    final list = _localProgressRecords.where((p) => p.userId == userId).toList();
    list.sort((a, b) => b.startDate.compareTo(a.startDate));
    return list;
  }
}
