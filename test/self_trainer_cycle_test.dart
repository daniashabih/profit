import 'package:flutter_test/flutter_test.dart';
import 'package:profit/services/bmi_service.dart';
import 'package:profit/services/workout_plan_service.dart';
import 'package:profit/services/nutrition_service.dart';
import 'package:profit/services/monthly_cycle_service.dart';
import 'package:profit/services/fitness_profile_service.dart';
import 'package:profit/services/workout_log_service.dart';
import 'package:profit/models/fitness_profile_model.dart';
import 'package:profit/models/workout_log_model.dart';
import 'package:profit/core/utils/fitness_calculators.dart';

void main() {
  group('1. Automatic BMI Calculation & WHO Categories', () {
    test('Calculates BMI accurately using weight(kg) / height(m)^2', () {
      // Prompt example: Weight = 69 kg, Height = 1.524 m (152.4 cm) -> 29.7
      final bmi = BmiService.calculateBmi(69.0, 152.4);
      expect(bmi, closeTo(29.7, 0.1));
    });

    test('Maps BMI accurately to WHO categories', () {
      expect(BmiService.getBmiCategory(17.5), equals('Underweight'));
      expect(BmiService.getBmiCategory(22.0), equals('Healthy Weight'));
      expect(BmiService.getBmiCategory(27.5), equals('Overweight'));
      expect(BmiService.getBmiCategory(32.0), equals('Obese'));
    });

    test('Calculates healthy target weight range based on WHO BMI 18.5 - 24.9', () {
      final range = BmiService.getHealthyWeightRange(152.4);
      // 18.5 * 1.524^2 = 42.97 kg
      // 24.9 * 1.524^2 = 57.83 kg
      expect(range.minKg, closeTo(43.0, 0.5));
      expect(range.maxKg, closeTo(57.8, 0.5));
    });

    test('Provides sensible target weight suggestions without extreme prescriptions', () {
      // Overweight user wanting to lose weight: suggested target is around upper healthy range
      final suggestedLoss = BmiService.suggestTargetWeight(
        currentWeightKg: 69.0,
        heightCm: 152.4,
        goalType: 'Lose Weight',
      );
      expect(suggestedLoss.suggestedInitialTargetKg, greaterThanOrEqualTo(55.0));
      expect(suggestedLoss.suggestedInitialTargetKg, lessThan(69.0));

      // Normal weight user wanting to build muscle
      final suggestedGain = BmiService.suggestTargetWeight(
        currentWeightKg: 60.0,
        heightCm: 170.0,
        goalType: 'Build Muscle',
      );
      expect(suggestedGain.suggestedInitialTargetKg, greaterThan(60.0));

      // Maintain weight
      final suggestedMaintain = BmiService.suggestTargetWeight(
        currentWeightKg: 65.0,
        heightCm: 170.0,
        goalType: 'Maintain Weight',
      );
      expect(suggestedMaintain.suggestedInitialTargetKg, equals(65.0));
    });

    test('Includes medical disclaimer and non-prescriptive safety guidance', () {
      final evaluated = FitnessCalculators.evaluateBmi(weightKg: 69.0, heightCm: 152.4);
      expect(evaluated.disclaimer, contains('BMI is a general screening indicator'));

      final suggested = BmiService.suggestTargetWeight(
        currentWeightKg: 69.0,
        heightCm: 152.4,
        goalType: 'Lose Weight',
      );
      expect(suggested.rationale, contains('Suggested healthy range'));
      expect(suggested.rationale, isNot(contains('You must weigh')));
    });
  });

  group('2. Dynamic Workout Schedule & Exercise Generation', () {
    late WorkoutPlanService workoutPlanService;

    setUp(() {
      workoutPlanService = WorkoutPlanService();
    });

    test('Generates 3-day split with proper target muscles and explicit rest days', () async {
      final plan = await workoutPlanService.generatePersonalizedPlan(
        userId: 'test_user_3day',
        goalType: 'Build Muscle',
        trainingDaysPerWeek: 3,
        userWeightKg: 70.0,
        fitnessLevel: 'intermediate',
        monthId: '2026-09',
      );

      expect(plan.days.length, equals(7)); // Full 7-day week schedule
      final trainingDays = plan.days.where((d) => !d.isRestDay).toList();
      final restDays = plan.days.where((d) => d.isRestDay).toList();

      expect(trainingDays.length, equals(3));
      expect(restDays.length, equals(4));

      // Verify each training day has exercises with sets, reps, weight, and rest time
      for (final day in trainingDays) {
        expect(day.exercises, isNotEmpty);
        for (final ex in day.exercises) {
          expect(ex.name, isNotEmpty);
          expect(ex.sets, greaterThan(0));
          expect(ex.reps, greaterThan(0));
          expect(ex.targetWeightKg, greaterThanOrEqualTo(0.0));
          expect(ex.restTimeSeconds, greaterThan(0));
        }
      }

      // Verify rest days contain no exercises
      for (final rest in restDays) {
        expect(rest.exercises, isEmpty);
        expect(rest.targetMuscles, contains('Rest'));
      }
    });

    test('Generates 4-day, 5-day, and 6-day splits matching requested days', () async {
      for (final daysCount in [4, 5, 6]) {
        final plan = await workoutPlanService.generatePersonalizedPlan(
          userId: 'test_user_${daysCount}day',
          goalType: 'Lose Weight',
          trainingDaysPerWeek: daysCount,
          userWeightKg: 69.0,
          fitnessLevel: 'beginner',
          monthId: '2026-09',
        );

        expect(plan.trainingDaysPerWeek, equals(daysCount));
        final activeDays = plan.days.where((d) => !d.isRestDay).toList();
        final restDays = plan.days.where((d) => d.isRestDay).toList();

        expect(activeDays.length, equals(daysCount));
        expect(restDays.length, equals(7 - daysCount));
      }
    });

    test('Applies progressive overload factor to exercise target weights', () async {
      final basePlan = await workoutPlanService.generatePersonalizedPlan(
        userId: 'test_user_base',
        goalType: 'Build Muscle',
        trainingDaysPerWeek: 4,
        userWeightKg: 75.0,
        fitnessLevel: 'intermediate',
        monthId: '2026-09',
        progressiveOverloadFactor: 1.0,
      );

      final progressedPlan = await workoutPlanService.generatePersonalizedPlan(
        userId: 'test_user_base',
        goalType: 'Build Muscle',
        trainingDaysPerWeek: 4,
        userWeightKg: 75.0,
        fitnessLevel: 'intermediate',
        monthId: '2026-10',
        progressiveOverloadFactor: 1.05, // 5% overload
      );

      // Find first weighted exercise in both plans
      final baseEx = basePlan.days
          .expand((d) => d.exercises)
          .firstWhere((e) => e.targetWeightKg > 10.0);
      final progEx = progressedPlan.days
          .expand((d) => d.exercises)
          .firstWhere((e) => e.id == baseEx.id);

      expect(progEx.targetWeightKg, greaterThan(baseEx.targetWeightKg));
    });
  });

  group('3. Dynamic Nutrition & Daily Protein Target', () {
    late NutritionService nutritionService;

    setUp(() {
      nutritionService = NutritionService();
    });

    test('Calculates transparent Mifflin-St Jeor TDEE and calorie goal', () {
      // 25 y/o female, 69 kg, 152.4 cm, 3 days/week training
      final calc = NutritionService.calculateDailyTargets(
        weightKg: 69.0,
        heightCm: 152.4,
        age: 25,
        gender: 'female',
        goalType: 'Lose Weight',
        trainingDaysPerWeek: 3,
      );

      // BMR for female: 10 * 69 + 6.25 * 152.4 - 5 * 25 - 161 = 690 + 952.5 - 125 - 161 = 1356.5
      expect(calc.bmr, closeTo(1357, 5));
      expect(calc.tdee, greaterThan(calc.bmr));
      // Calorie deficit for weight loss: ~300-500 kcal below TDEE, capped at safe floor (1200 kcal for female)
      expect(calc.targetCalories, lessThan(calc.tdee));
      expect(calc.targetCalories, greaterThanOrEqualTo(1200));
      // Protein target for weight loss (1.4 - 2.0g/kg)
      expect(calc.targetProteinGrams, greaterThanOrEqualTo(90.0));
      expect(calc.targetProteinGrams, closeTo(97.0, 1.0));
    });

    test('Generates meal plan with Breakfast, Lunch, Snack, Dinner and sums consumed protein', () async {
      final mealPlan = await nutritionService.generatePersonalizedMealPlan(
        userId: 'test_user_nutrition',
        weightKg: 69.0,
        heightCm: 152.4,
        age: 25,
        gender: 'female',
        goalType: 'Lose Weight',
        trainingDaysPerWeek: 4,
        monthId: '2026-09',
      );

      expect(mealPlan.meals.length, equals(4));
      final mealTypes = mealPlan.meals.map((m) => m.mealType).toSet();
      expect(mealTypes, containsAll(['Breakfast', 'Lunch', 'Snack', 'Dinner']));

      // Total planned protein equals sum of all meal items
      final totalPlannedProtein = mealPlan.meals.fold<double>(0.0, (acc, m) => acc + m.proteinGrams);
      expect(mealPlan.targetProteinGrams, closeTo(totalPlannedProtein, 1.0));

      // Initially consumed protein is 0.0
      expect(mealPlan.consumedProteinGrams, equals(0.0));

      // Mark Breakfast as consumed
      final breakfast = mealPlan.meals.firstWhere((m) => m.mealType == 'Breakfast');
      final updatedPlan1 = await nutritionService.toggleMealConsumption(
        planId: mealPlan.id,
        mealId: breakfast.id,
        isConsumed: true,
      );

      expect(updatedPlan1.consumedProteinGrams, closeTo(breakfast.proteinGrams, 0.1));
      expect(updatedPlan1.remainingProteinGrams, closeTo(mealPlan.targetProteinGrams - breakfast.proteinGrams, 0.1));

      // Mark Lunch as consumed
      final lunch = mealPlan.meals.firstWhere((m) => m.mealType == 'Lunch');
      final updatedPlan2 = await nutritionService.toggleMealConsumption(
        planId: mealPlan.id,
        mealId: lunch.id,
        isConsumed: true,
      );

      expect(updatedPlan2.consumedProteinGrams, closeTo(breakfast.proteinGrams + lunch.proteinGrams, 0.1));

      // Toggle Breakfast off (unconsumed)
      final updatedPlan3 = await nutritionService.toggleMealConsumption(
        planId: mealPlan.id,
        mealId: breakfast.id,
        isConsumed: false,
      );

      expect(updatedPlan3.consumedProteinGrams, closeTo(lunch.proteinGrams, 0.1));
    });
  });

  group('4. Monthly Fitness Cycle & Non-Destructive Progression', () {
    late BmiService bmiService;
    late FitnessProfileService profileService;
    late WorkoutPlanService workoutPlanService;
    late WorkoutLogService workoutLogService;
    late NutritionService nutritionService;
    late MonthlyCycleService cycleService;

    setUp(() {
      bmiService = BmiService();
      profileService = FitnessProfileService(bmiService: bmiService);
      workoutPlanService = WorkoutPlanService();
      workoutLogService = WorkoutLogService();
      nutritionService = NutritionService();
      cycleService = MonthlyCycleService(
        fitnessProfileService: profileService,
        workoutPlanService: workoutPlanService,
        nutritionService: nutritionService,
        workoutLogService: workoutLogService,
      );
    });

    test('Initializes monthly cycle and is idempotent on successive calls', () async {
      final profile = FitnessProfile(
        userId: 'cycle_user_1',
        fullName: 'Dania Shabih',
        age: 26,
        gender: 'Female',
        heightCm: 152.4,
        currentWeightKg: 69.0,
        targetWeightKg: 55.0,
        goalType: 'Lose Weight',
        bmi: 29.7,
        bmiCategory: 'Overweight',
        trainingDaysPerWeek: 4,
        fitnessLevel: 'intermediate',
        activityLevel: 'moderately_active',
        fitnessSetupCompleted: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await profileService.saveFitnessProfile(profile);

      // Call 1: creates the cycle
      final cycle1 = await cycleService.checkCurrentMonthlyCycle('cycle_user_1');
      expect(cycle1, isNotNull);
      expect(cycle1!.status, equals('active'));
      expect(cycle1.startingWeight, equals(69.0));
      expect(cycle1.startingBmi, closeTo(29.7, 0.1));

      // Call 2: idempotent, must return the same cycle instance without recreating
      final cycle2 = await cycleService.checkCurrentMonthlyCycle('cycle_user_1');
      expect(cycle2, isNotNull);
      expect(cycle2!.id, equals(cycle1.id));
      expect(cycle2.workoutPlanId, equals(cycle1.workoutPlanId));
      expect(cycle2.mealPlanId, equals(cycle1.mealPlanId));
    });

    test('Logging workout session saves performance and reflects on adherence', () async {
      final log = WorkoutLog(
        id: 'test_log_1',
        userId: 'cycle_user_1',
        workoutPlanId: 'plan_1',
        dayId: 'day_1',
        workoutTitle: 'Chest + Triceps',
        targetMuscles: ['Chest', 'Triceps'],
        dateString: DateTime.now().toIso8601String().split('T').first,
        completedAt: DateTime.now(),
        durationMinutes: 45,
        completedExercises: 1,
        totalExercises: 1,
        exercises: [
          LoggedExercise(
            exerciseId: 'ex_1',
            exerciseName: 'Bench Press',
            muscleGroup: 'Chest',
            plannedSets: 3,
            plannedReps: 10,
            sets: [
              LoggedSet(setNumber: 1, weightKg: 30.0, reps: 10, isCompleted: true),
              LoggedSet(setNumber: 2, weightKg: 30.0, reps: 10, isCompleted: true),
              LoggedSet(setNumber: 3, weightKg: 32.5, reps: 8, isCompleted: true),
            ],
            isCompleted: true,
          ),
        ],
      );

      final saved = await workoutLogService.logWorkoutSession(log);
      expect(saved.id, equals('test_log_1'));

      final logs = await workoutLogService.getWorkoutLogs(userId: 'cycle_user_1');
      expect(logs.length, equals(1));
      expect(logs.first.completedExercises, equals(1));
      expect(logs.first.exercises.first.sets.length, equals(3));
      expect(logs.first.exercises.first.sets[2].weightKg, equals(32.5));
    });

    test('Updating weight recalculates BMI, saves BMI record, and updates profile', () async {
      final profile = FitnessProfile(
        userId: 'cycle_user_2',
        fullName: 'Athlete Two',
        age: 28,
        gender: 'Male',
        heightCm: 180.0,
        currentWeightKg: 85.0,
        targetWeightKg: 78.0,
        goalType: 'Lose Weight',
        bmi: 26.2,
        bmiCategory: 'Overweight',
        trainingDaysPerWeek: 5,
        fitnessLevel: 'intermediate',
        activityLevel: 'active',
        fitnessSetupCompleted: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await profileService.saveFitnessProfile(profile);

      // User drops weight to 82 kg
      final updated = await profileService.updateBodyMetrics(
        userId: 'cycle_user_2',
        newWeightKg: 82.0,
      );

      expect(updated, isNotNull);
      expect(updated!.currentWeightKg, equals(82.0));
      // 82 / (1.80^2) = 25.31
      expect(updated.bmi, closeTo(25.3, 0.1));
      expect(updated.bmiCategory, equals('Overweight'));

      // Check BMI history has been logged
      final bmiHistory = await bmiService.getBmiHistory('cycle_user_2');
      expect(bmiHistory.length, greaterThanOrEqualTo(2));
      expect(bmiHistory.last.weight, equals(82.0));
    });
  });
}
