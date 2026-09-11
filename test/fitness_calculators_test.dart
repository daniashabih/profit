import 'package:flutter_test/flutter_test.dart';
import 'package:profit/core/utils/fitness_calculators.dart';
import 'package:profit/models/workout_model.dart';
import 'package:profit/models/exercise_model.dart';
import 'package:profit/core/enums/muscle_group.dart';
import 'package:profit/core/enums/exercise_difficulty.dart';
import 'package:profit/models/nutrition_model.dart';
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
