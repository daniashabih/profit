import 'package:flutter_test/flutter_test.dart';
import 'package:profit/core/enums/user_role.dart';
import 'package:profit/core/utils/fitness_calculators.dart';
import 'package:profit/models/workout_model.dart';
import 'package:profit/models/exercise_model.dart';
import 'package:profit/core/enums/muscle_group.dart';
import 'package:profit/core/enums/exercise_difficulty.dart';
import 'package:profit/models/nutrition_model.dart';
import 'package:profit/models/user_model.dart';
import 'package:profit/models/trainer_member_model.dart';
import 'package:profit/core/enums/meal_type.dart';
import 'package:profit/repositories/exercise_repository.dart';

void main() {
  group('Fitness Calculators Tests', () {
    test('calculateOneRepMax calculates accurate 1RM using Epley formula', () {
      final oneRm = FitnessCalculators.calculateOneRepMax(100.0, 10);
      expect(oneRm, closeTo(133.33, 0.05));
      expect(FitnessCalculators.calculateOneRepMax(80.0, 1), equals(80.0));
      expect(FitnessCalculators.calculateOneRepMax(80.0, 0), equals(0.0));
    });

    test('calculateBmi returns correct value and category', () {
      final bmi = FitnessCalculators.calculateBmi(70.0, 175.0);
      expect(bmi, closeTo(22.86, 0.05));
      expect(FitnessCalculators.getBmiCategory(bmi), equals('Healthy Weight'));

      final overweightBmi = FitnessCalculators.calculateBmi(90.0, 175.0);
      expect(FitnessCalculators.getBmiCategory(overweightBmi), equals('Overweight'));

      final underweightBmi = FitnessCalculators.calculateBmi(45.0, 170.0);
      expect(FitnessCalculators.getBmiCategory(underweightBmi), equals('Underweight'));

      final obeseBmi = FitnessCalculators.calculateBmi(110.0, 175.0);
      expect(FitnessCalculators.getBmiCategory(obeseBmi), equals('Obese'));
    });

    test('evaluateBmi returns healthy weight boundaries and interpretation', () {
      final result = FitnessCalculators.evaluateBmi(weightKg: 70.0, heightCm: 175.0);
      expect(result.value, closeTo(22.9, 0.1));
      expect(result.category, equals('Healthy Weight'));
      expect(result.isHealthy, isTrue);
      expect(result.minHealthyWeightKg, closeTo(56.7, 0.2));
      expect(result.maxHealthyWeightKg, closeTo(76.3, 0.2));
      expect(result.disclaimer, contains('general screening indicator'));
    });

    test('calculateDailyProteinRecommendation provides accurate goals and disclaimers', () {
      // Muscle gain for 80kg individual (~2.0 g/kg)
      final muscleRec = FitnessCalculators.calculateDailyProteinRecommendation(
        weightKg: 80.0,
        fitnessGoal: 'Build Muscle',
        activityLevel: 'moderately_active',
      );
      expect(muscleRec.minGrams, equals(128.0)); // 80 * 1.6
      expect(muscleRec.maxGrams, equals(176.0)); // 80 * 2.2
      expect(muscleRec.targetGrams, equals(160.0)); // 80 * 2.0
      expect(muscleRec.disclaimer, contains('general fitness estimate'));
      expect(muscleRec.disclaimer, contains('medical'));

      // Fat loss for 70kg individual (~2.0 g/kg)
      final fatLossRec = FitnessCalculators.calculateDailyProteinRecommendation(
        weightKg: 70.0,
        fitnessGoal: 'Weight Loss',
        activityLevel: 'moderately_active',
      );
      expect(fatLossRec.targetGrams, equals(140.0)); // 70 * 2.0
      expect(fatLossRec.minGrams, equals(126.0)); // 70 * 1.8

      // Zero weight edge case
      final zeroRec = FitnessCalculators.calculateDailyProteinRecommendation(weightKg: 0);
      expect(zeroRec.targetGrams, equals(0.0));
    });

    test('calculateCaloriesFromMacros accurately computes energy balance', () {
      final cals = FitnessCalculators.calculateCaloriesFromMacros(
        proteinGrams: 150,
        carbsGrams: 200,
        fatGrams: 50,
      );
      expect(cals, equals(1850.0));
    });

    test('calculateProgressPercentage clamps between 0.0 and 1.0', () {
      expect(FitnessCalculators.calculateProgressPercentage(50, 100), equals(0.5));
      expect(FitnessCalculators.calculateProgressPercentage(150, 100), equals(1.0));
      expect(FitnessCalculators.calculateProgressPercentage(0, 100), equals(0.0));
      expect(FitnessCalculators.calculateProgressPercentage(50, 0), equals(0.0));
    });
  });

  group('Domain Models Tests', () {
    test('UserModel integrates BMI, Protein recommendations, and profile fields', () {
      final user = UserModel(
        id: 'user_test_01',
        name: 'Jordan Lee',
        email: 'jordan@profit.app',
        role: UserRole.self,
        age: 26,
        gender: 'male',
        activityLevel: 'moderately_active',
        goal: 'Build Muscle',
        currentWeightKg: 75.0,
        heightCm: 180.0,
      );

      // BMI integration
      expect(user.bmi, closeTo(23.1, 0.1));
      expect(user.bmiCategory, equals('Healthy Weight'));
      expect(user.bmiResult.isHealthy, isTrue);

      // Protein recommendation integration
      expect(user.proteinRecommendation.targetGrams, equals(150.0)); // 75 * 2.0

      // Serialization
      final map = user.toMap();
      expect(map['role'], equals('self'));
      expect(map['age'], equals(26));
      expect(map['gender'], equals('male'));
      expect(map['activityLevel'], equals('moderately_active'));

      final fromMap = UserModel.fromMap(map);
      expect(fromMap.role, equals(UserRole.self));
      expect(fromMap.age, equals(26));
      expect(fromMap.gender, equals('male'));
    });

    test('TrainerMemberModel supports client metrics and authorized client BMI', () {
      final clientRel = TrainerMemberModel(
        id: 'rel_123',
        trainerId: 'trainer_001',
        memberId: 'client_001',
        memberName: 'Chris Taylor',
        memberGoal: 'Weight Loss',
        clientWeightKg: 85.0,
        clientHeightCm: 175.0,
        clientAge: 29,
        clientGender: 'male',
      );

      expect(clientRel.clientId, equals('client_001'));
      expect(clientRel.clientBmi, closeTo(27.8, 0.1));
      expect(clientRel.clientBmiCategory, equals('Overweight'));
      expect(clientRel.clientProteinRecommendation, isNotNull);
      expect(clientRel.clientProteinRecommendation!.targetGrams, equals(170.0)); // 85 * 2.0

      final map = clientRel.toMap();
      expect(map['clientWeightKg'], equals(85.0));
      expect(map['clientHeightCm'], equals(175.0));

      final fromMap = TrainerMemberModel.fromMap(map);
      expect(fromMap.clientWeightKg, equals(85.0));
      expect(fromMap.clientBmi, closeTo(27.8, 0.1));
    });

    test('WorkoutModel computes progress percentage correctly', () {
      final ex1 = ExerciseModel(
        id: '1',
        name: 'Bench Press',
        muscleGroup: MuscleGroup.chest,
        equipment: 'Barbell',
        difficulty: ExerciseDifficulty.intermediate,
        isCompleted: true,
      );
      final ex2 = ExerciseModel(
        id: '2',
        name: 'Shoulder Press',
        muscleGroup: MuscleGroup.shoulders,
        equipment: 'Dumbbell',
        difficulty: ExerciseDifficulty.intermediate,
        isCompleted: false,
      );

      final workout = WorkoutModel(
        id: 'w1',
        title: 'Push Day',
        subtitle: 'Chest & Shoulders',
        durationMinutes: 40,
        exercises: [ex1, ex2],
      );

      expect(workout.totalExercises, equals(2));
      expect(workout.completedExercisesCount, equals(1));
      expect(workout.progressPercentage, equals(0.5));
    });

    test('DailyNutritionModel aggregates calories and macros correctly', () {
      final meal1 = MealItemModel(
        id: 'm1',
        name: 'Eggs',
        mealType: MealType.breakfast,
        calories: 300,
        proteinGrams: 20,
        carbsGrams: 5,
        fatGrams: 22,
        time: '08:00 AM',
      );
      final meal2 = MealItemModel(
        id: 'm2',
        name: 'Chicken Rice',
        mealType: MealType.lunch,
        calories: 600,
        proteinGrams: 50,
        carbsGrams: 70,
        fatGrams: 10,
        time: '01:00 PM',
      );

      final daily = DailyNutritionModel(
        targetCalories: 1800,
        meals: [meal1, meal2],
      );

      expect(daily.consumedCalories, equals(900));
      expect(daily.consumedProtein, equals(70.0));
      expect(daily.calorieProgress, equals(0.5));
    });

    test('ExerciseRepository filters correctly by muscle and equipment', () {
      final repo = LocalExerciseRepository();
      final chestExercises = repo.searchExercises(muscleGroup: MuscleGroup.chest);
      expect(chestExercises.every((e) => e.muscleGroup == MuscleGroup.chest), isTrue);

      final dumbbellOnly = repo.searchExercises(equipment: 'Dumbbell');
      expect(dumbbellOnly.every((e) => e.equipment.toLowerCase() == 'dumbbell'), isTrue);
    });
  });
}
