import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uuid/uuid.dart';
import '../core/enums/muscle_group.dart';
import '../models/workout_plan_model.dart';
import '../models/exercise_model.dart';
import '../repositories/exercise_repository.dart';

/// Dynamic Workout Plan Generation and Progression Service
/// Generates tailored splits (2, 3, 4, 5, 6 days) with day-wise target muscles,
/// rest days, and dynamic exercise selection from the exercise repository.
class WorkoutPlanService {
  final FirebaseFirestore? _firestore;
  final ExerciseRepository _exerciseRepo;
  static const _uuid = Uuid();

  // In-memory cache for offline/mock operations
  final Map<String, WorkoutPlan> _localPlans = {};

  WorkoutPlanService({
    FirebaseFirestore? firestore,
    ExerciseRepository? exerciseRepo,
  })  : _firestore = firestore ??
            (Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null),
        _exerciseRepo = exerciseRepo ?? LocalExerciseRepository();

  /// Generates a customized monthly workout plan for a user based on their profile.
  /// Supports progressive overload parameter for automated monthly cycle updates.
  Future<WorkoutPlan> generatePersonalizedPlan({
    required String userId,
    required String goalType,
    required int trainingDaysPerWeek,
    required double userWeightKg,
    String fitnessLevel = 'Beginner',
    String? monthId,
    double progressiveOverloadFactor = 1.0, // e.g. 1.05 for 5% weight progression
  }) async {
    final now = DateTime.now();
    final effectiveMonthId = monthId ?? '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final planId = '${userId}_plan_$effectiveMonthId';

    final days = _buildWeeklySchedule(
      trainingDaysPerWeek: trainingDaysPerWeek.clamp(2, 6),
      goalType: goalType,
      userWeightKg: userWeightKg,
      fitnessLevel: fitnessLevel,
      progressionFactor: progressiveOverloadFactor,
    );

    final splitName = _getSplitName(trainingDaysPerWeek);

    final plan = WorkoutPlan(
      id: planId,
      userId: userId,
      monthId: effectiveMonthId,
      goalType: goalType,
      trainingDaysPerWeek: trainingDaysPerWeek,
      startDate: DateTime(now.year, now.month, 1),
      endDate: DateTime(now.year, now.month + 1, 0),
      status: 'active',
      splitType: splitName,
      days: days,
      createdAt: now,
      updatedAt: now,
    );

    _localPlans[planId] = plan;

    if (_firestore != null && userId.isNotEmpty) {
      try {
        final planRef = _firestore!.collection('workoutPlans').doc(planId);
        await planRef.set(plan.toMap());

        // Also store days in subcollection: workoutPlans/{planId}/days/{dayId}
        final batch = _firestore!.batch();
        for (final day in days) {
          final dayRef = planRef.collection('days').doc(day.id);
          batch.set(dayRef, day.toMap());
        }
        await batch.commit();
      } catch (e) {
        // Fallback gracefully in testing / unauthenticated mode
      }
    }

    return plan;
  }

  /// Builds the 7-day weekly schedule including training and explicit rest days
  List<WorkoutDay> _buildWeeklySchedule({
    required int trainingDaysPerWeek,
    required String goalType,
    required double userWeightKg,
    required String fitnessLevel,
    required double progressionFactor,
  }) {
    switch (trainingDaysPerWeek) {
      case 2:
        return [
          _createDay(
            id: 'day_1',
            dayName: 'Monday',
            dayOfWeek: 1,
            workoutType: 'Full Body A',
            targetMuscles: ['Chest', 'Back', 'Quads', 'Core'],
            isRest: false,
            goalType: goalType,
            userWeightKg: userWeightKg,
            progressionFactor: progressionFactor,
          ),
          _createRestDay(id: 'day_2', dayName: 'Tuesday', dayOfWeek: 2),
          _createRestDay(id: 'day_3', dayName: 'Wednesday', dayOfWeek: 3),
          _createDay(
            id: 'day_4',
            dayName: 'Thursday',
            dayOfWeek: 4,
            workoutType: 'Full Body B',
            targetMuscles: ['Chest', 'Hamstrings', 'Arms', 'Shoulders'],
            isRest: false,
            goalType: goalType,
            userWeightKg: userWeightKg,
            progressionFactor: progressionFactor,
          ),
          _createRestDay(id: 'day_5', dayName: 'Friday', dayOfWeek: 5),
          _createRestDay(id: 'day_6', dayName: 'Saturday', dayOfWeek: 6),
          _createRestDay(id: 'day_7', dayName: 'Sunday', dayOfWeek: 7),
        ];

      case 3:
        return [
          _createDay(
            id: 'day_1',
            dayName: 'Monday',
            dayOfWeek: 1,
            workoutType: 'Upper Body Power',
            targetMuscles: ['Chest', 'Back', 'Shoulders', 'Triceps'],
            isRest: false,
            goalType: goalType,
            userWeightKg: userWeightKg,
            progressionFactor: progressionFactor,
          ),
          _createRestDay(id: 'day_2', dayName: 'Tuesday', dayOfWeek: 2),
          _createDay(
            id: 'day_3',
            dayName: 'Wednesday',
            dayOfWeek: 3,
            workoutType: 'Lower Body Strength',
            targetMuscles: ['Quads', 'Hamstrings', 'Glutes', 'Calves'],
            isRest: false,
            goalType: goalType,
            userWeightKg: userWeightKg,
            progressionFactor: progressionFactor,
          ),
          _createRestDay(id: 'day_4', dayName: 'Thursday', dayOfWeek: 4),
          _createDay(
            id: 'day_5',
            dayName: 'Friday',
            dayOfWeek: 5,
            workoutType: 'Full Body Conditioning',
            targetMuscles: ['Chest', 'Back', 'Legs', 'Core'],
            isRest: false,
            goalType: goalType,
            userWeightKg: userWeightKg,
            progressionFactor: progressionFactor,
          ),
          _createRestDay(id: 'day_6', dayName: 'Saturday', dayOfWeek: 6),
          _createRestDay(id: 'day_7', dayName: 'Sunday', dayOfWeek: 7),
        ];

      case 4:
        return [
          _createDay(
            id: 'day_1',
            dayName: 'Monday',
            dayOfWeek: 1,
            workoutType: 'Chest + Triceps',
            targetMuscles: ['Chest', 'Triceps'],
            isRest: false,
            goalType: goalType,
            userWeightKg: userWeightKg,
            progressionFactor: progressionFactor,
          ),
          _createDay(
            id: 'day_2',
            dayName: 'Tuesday',
            dayOfWeek: 2,
            workoutType: 'Back + Biceps',
            targetMuscles: ['Back', 'Biceps'],
            isRest: false,
            goalType: goalType,
            userWeightKg: userWeightKg,
            progressionFactor: progressionFactor,
          ),
          _createRestDay(id: 'day_3', dayName: 'Wednesday', dayOfWeek: 3),
          _createDay(
            id: 'day_4',
            dayName: 'Thursday',
            dayOfWeek: 4,
            workoutType: 'Legs & Lower Body',
            targetMuscles: ['Quads', 'Hamstrings', 'Calves'],
            isRest: false,
            goalType: goalType,
            userWeightKg: userWeightKg,
            progressionFactor: progressionFactor,
          ),
          _createRestDay(id: 'day_5', dayName: 'Friday', dayOfWeek: 5),
          _createDay(
            id: 'day_6',
            dayName: 'Saturday',
            dayOfWeek: 6,
            workoutType: 'Shoulders + Core',
            targetMuscles: ['Shoulders', 'Core'],
            isRest: false,
            goalType: goalType,
            userWeightKg: userWeightKg,
            progressionFactor: progressionFactor,
          ),
          _createRestDay(id: 'day_7', dayName: 'Sunday', dayOfWeek: 7),
        ];

      case 5:
        return [
          _createDay(
            id: 'day_1',
            dayName: 'Monday',
            dayOfWeek: 1,
            workoutType: 'Chest + Triceps',
            targetMuscles: ['Chest', 'Triceps'],
            isRest: false,
            goalType: goalType,
            userWeightKg: userWeightKg,
            progressionFactor: progressionFactor,
          ),
          _createDay(
            id: 'day_2',
            dayName: 'Tuesday',
            dayOfWeek: 2,
            workoutType: 'Back + Biceps',
            targetMuscles: ['Back', 'Biceps'],
            isRest: false,
            goalType: goalType,
            userWeightKg: userWeightKg,
            progressionFactor: progressionFactor,
          ),
          _createDay(
            id: 'day_3',
            dayName: 'Wednesday',
            dayOfWeek: 3,
            workoutType: 'Legs & Lower Body',
            targetMuscles: ['Quads', 'Hamstrings', 'Glutes'],
            isRest: false,
            goalType: goalType,
            userWeightKg: userWeightKg,
            progressionFactor: progressionFactor,
          ),
          _createRestDay(id: 'day_4', dayName: 'Thursday', dayOfWeek: 4),
          _createDay(
            id: 'day_5',
            dayName: 'Friday',
            dayOfWeek: 5,
            workoutType: 'Shoulders + Core',
            targetMuscles: ['Shoulders', 'Core'],
            isRest: false,
            goalType: goalType,
            userWeightKg: userWeightKg,
            progressionFactor: progressionFactor,
          ),
          _createDay(
            id: 'day_6',
            dayName: 'Saturday',
            dayOfWeek: 6,
            workoutType: 'Full Body / Conditioning',
            targetMuscles: ['Full Body', 'Core'],
            isRest: false,
            goalType: goalType,
            userWeightKg: userWeightKg,
            progressionFactor: progressionFactor,
          ),
          _createRestDay(id: 'day_7', dayName: 'Sunday', dayOfWeek: 7),
        ];

      case 6:
      default:
        return [
          _createDay(
            id: 'day_1',
            dayName: 'Monday',
            dayOfWeek: 1,
            workoutType: 'Push (Chest & Triceps)',
            targetMuscles: ['Chest', 'Shoulders', 'Triceps'],
            isRest: false,
            goalType: goalType,
            userWeightKg: userWeightKg,
            progressionFactor: progressionFactor,
          ),
          _createDay(
            id: 'day_2',
            dayName: 'Tuesday',
            dayOfWeek: 2,
            workoutType: 'Pull (Back & Biceps)',
            targetMuscles: ['Back', 'Biceps'],
            isRest: false,
            goalType: goalType,
            userWeightKg: userWeightKg,
            progressionFactor: progressionFactor,
          ),
          _createDay(
            id: 'day_3',
            dayName: 'Wednesday',
            dayOfWeek: 3,
            workoutType: 'Legs (Lower Body)',
            targetMuscles: ['Quads', 'Hamstrings', 'Calves'],
            isRest: false,
            goalType: goalType,
            userWeightKg: userWeightKg,
            progressionFactor: progressionFactor,
          ),
          _createDay(
            id: 'day_4',
            dayName: 'Thursday',
            dayOfWeek: 4,
            workoutType: 'Push Hypertrophy',
            targetMuscles: ['Chest', 'Shoulders', 'Triceps'],
            isRest: false,
            goalType: goalType,
            userWeightKg: userWeightKg,
            progressionFactor: progressionFactor,
          ),
          _createDay(
            id: 'day_5',
            dayName: 'Friday',
            dayOfWeek: 5,
            workoutType: 'Pull Hypertrophy',
            targetMuscles: ['Back', 'Biceps', 'Core'],
            isRest: false,
            goalType: goalType,
            userWeightKg: userWeightKg,
            progressionFactor: progressionFactor,
          ),
          _createDay(
            id: 'day_6',
            dayName: 'Saturday',
            dayOfWeek: 6,
            workoutType: 'Legs & Core',
            targetMuscles: ['Quads', 'Glutes', 'Core'],
            isRest: false,
            goalType: goalType,
            userWeightKg: userWeightKg,
            progressionFactor: progressionFactor,
          ),
          _createRestDay(id: 'day_7', dayName: 'Sunday', dayOfWeek: 7),
        ];
    }
  }

  WorkoutDay _createRestDay({
    required String id,
    required String dayName,
    required int dayOfWeek,
  }) {
    return WorkoutDay(
      id: id,
      dayName: dayName,
      dayOfWeek: dayOfWeek,
      workoutType: 'Rest & Recovery Day',
      targetMuscles: const ['Rest', 'Active Recovery'],
      isRestDay: true,
      exercises: const [],
    );
  }

  WorkoutDay _createDay({
    required String id,
    required String dayName,
    required int dayOfWeek,
    required String workoutType,
    required List<String> targetMuscles,
    required bool isRest,
    required String goalType,
    required double userWeightKg,
    required double progressionFactor,
  }) {
    final exercises = _selectExercisesForMuscles(
      targetMuscles: targetMuscles,
      goalType: goalType,
      userWeightKg: userWeightKg,
      progressionFactor: progressionFactor,
    );

    return WorkoutDay(
      id: id,
      dayName: dayName,
      dayOfWeek: dayOfWeek,
      workoutType: workoutType,
      targetMuscles: targetMuscles,
      isRestDay: false,
      exercises: exercises,
    );
  }

  List<PlanExercise> _selectExercisesForMuscles({
    required List<String> targetMuscles,
    required String goalType,
    required double userWeightKg,
    required double progressionFactor,
  }) {
    final allExercises = _exerciseRepo.getAllExercises();
    final selected = <PlanExercise>[];
    final normGoal = goalType.toLowerCase();

    // Determine rep range & sets based on goal
    int sets = 3;
    int reps = 10;
    int rest = 60;
    if (normGoal.contains('muscle') || normGoal.contains('build')) {
      sets = 4;
      reps = 10;
      rest = 75;
    } else if (normGoal.contains('lose') || normGoal.contains('fat')) {
      sets = 3;
      reps = 12;
      rest = 45;
    } else if (normGoal.contains('strength')) {
      sets = 4;
      reps = 6;
      rest = 90;
    }

    for (final muscleName in targetMuscles) {
      final matching = allExercises.where((e) {
        return e.muscleGroup.name.toLowerCase() == muscleName.toLowerCase() ||
            e.muscleGroup.displayName.toLowerCase().contains(muscleName.toLowerCase());
      }).toList();

      for (int i = 0; i < matching.length && i < 2; i++) {
        final ex = matching[i];
        if (selected.any((s) => s.id == ex.id)) continue;

        // Base estimated weight proportional to user bodyweight and equipment
        double baseWeight = 20.0;
        if (ex.equipment.toLowerCase().contains('bodyweight')) {
          baseWeight = 0.0;
        } else if (ex.equipment.toLowerCase().contains('barbell')) {
          baseWeight = double.parse(((userWeightKg * 0.45) * progressionFactor).toStringAsFixed(1));
        } else {
          baseWeight = double.parse(((userWeightKg * 0.2) * progressionFactor).toStringAsFixed(1));
        }

        selected.add(
          PlanExercise(
            id: ex.id,
            name: ex.name,
            muscleGroup: ex.muscleGroup,
            equipment: ex.equipment,
            sets: sets,
            reps: reps,
            targetWeightKg: baseWeight,
            restTimeSeconds: rest,
            durationMinutes: ex.durationMinutes,
            notes: 'Target RPE 7-8. Form over load.',
          ),
        );
      }
    }

    // Ensure at least 4 exercises per training day
    if (selected.length < 4) {
      final fallback = allExercises.where((e) => !selected.any((s) => s.id == e.id)).take(4 - selected.length);
      for (final fb in fallback) {
        selected.add(
          PlanExercise(
            id: fb.id,
            name: fb.name,
            muscleGroup: fb.muscleGroup,
            equipment: fb.equipment,
            sets: sets,
            reps: reps,
            targetWeightKg: 15.0 * progressionFactor,
            restTimeSeconds: rest,
            durationMinutes: fb.durationMinutes,
            notes: 'Steady cadence and controlled negative.',
          ),
        );
      }
    }

    return selected;
  }

  String _getSplitName(int days) {
    switch (days) {
      case 2:
        return '2-Day Full Body Frequency Split';
      case 3:
        return '3-Day Upper / Lower / Full Body Split';
      case 4:
        return '4-Day Antagonist Upper / Lower Split';
      case 5:
        return '5-Day Hypertrophy & Conditioning Split';
      case 6:
        return '6-Day Push / Pull / Legs Dual Split';
      default:
        return 'Personalized Split';
    }
  }

  /// Retrieves the active workout plan for a user
  Future<WorkoutPlan?> getActivePlan(String userId) async {
    if (_firestore != null && userId.isNotEmpty) {
      try {
        final query = await _firestore!
            .collection('workoutPlans')
            .where('userId', isEqualTo: userId)
            .where('status', isEqualTo: 'active')
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          final doc = query.docs.first;
          final plan = WorkoutPlan.fromMap(doc.data(), docId: doc.id);
          _localPlans[plan.id] = plan;
          return plan;
        }
      } catch (_) {}
    }

    final cached = _localPlans.values.firstWhere(
      (p) => p.userId == userId && p.status == 'active',
      orElse: () => _localPlans.values.firstOrNull ?? _getDefaultPlan(userId),
    );
    return cached;
  }

  WorkoutPlan _getDefaultPlan(String userId) {
    final now = DateTime.now();
    return WorkoutPlan(
      id: '${userId}_default_plan',
      userId: userId,
      monthId: '${now.year}-${now.month.toString().padLeft(2, '0')}',
      goalType: 'Improve Fitness',
      trainingDaysPerWeek: 4,
      startDate: DateTime(now.year, now.month, 1),
      endDate: DateTime(now.year, now.month + 1, 0),
      splitType: '4-Day Split',
      days: _buildWeeklySchedule(
        trainingDaysPerWeek: 4,
        goalType: 'Improve Fitness',
        userWeightKg: 70.0,
        fitnessLevel: 'Beginner',
        progressionFactor: 1.0,
      ),
      createdAt: now,
      updatedAt: now,
    );
  }
}
