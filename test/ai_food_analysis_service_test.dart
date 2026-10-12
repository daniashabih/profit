import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:profit/core/enums/meal_type.dart';
import 'package:profit/models/food_post_model.dart';
import 'package:profit/services/ai_food_analysis_service.dart';

void main() {
  group('AiFoodAnalysisService Tests', () {
    final service = AiFoodAnalysisService();

    test('analyzeFoodImage detects food items and macro breakdown for Chicken Rice Lunch', () async {
      final result = await service.analyzeFoodImage(
        imageBytes: Uint8List(0),
        mealType: MealType.lunch,
        mealTitleHint: 'Chicken Rice Salad',
        userNotes: 'Grilled chicken breast with brown rice',
      );

      expect(result.detectedFoods.isNotEmpty, isTrue);
      expect(result.status, FoodAnalysisStatus.completed);
      expect(result.confidence, inInclusiveRange(0.7, 1.0));

      final chicken = result.detectedFoods.firstWhere((f) => f.name.contains('Chicken'));
      expect(chicken, isNotNull);
      expect(chicken.protein, greaterThan(20.0));
      expect(chicken.cookingMethod, isNotNull);

      // Check minerals and vitamins presence
      expect(chicken.micronutrients.isNotEmpty, isTrue);
      expect(chicken.vitamins.isNotEmpty, isTrue);
    });

    test('analyzeFoodImage detects breakfast items (Eggs, Toast, Avocado)', () async {
      final result = await service.analyzeFoodImage(
        imageBytes: Uint8List(0),
        mealType: MealType.breakfast,
        mealTitleHint: 'Avocado Toast with Poached Eggs',
      );

      expect(result.detectedFoods.isNotEmpty, isTrue);
      expect(result.detectedFoods.any((f) => f.name.contains('Egg') || f.name.contains('Toast')), isTrue);
      final totalProtein = result.detectedFoods.fold<double>(0.0, (sum, item) => sum + item.protein);
      expect(totalProtein, greaterThan(15.0));
    });

    test('analyzeFoodImage detects dinner items (Salmon, Quinoa, Asparagus)', () async {
      final result = await service.analyzeFoodImage(
        imageBytes: Uint8List(0),
        mealType: MealType.dinner,
        mealTitleHint: 'Grilled Salmon with Quinoa',
      );

      expect(result.detectedFoods.isNotEmpty, isTrue);
      expect(result.detectedFoods.any((f) => f.name.contains('Salmon')), isTrue);
      final totalProtein = result.detectedFoods.fold<double>(0.0, (sum, item) => sum + item.protein);
      expect(totalProtein, greaterThan(25.0));
    });

    test('analyzeFoodImage detects snack items (Greek Yogurt with Berries)', () async {
      final result = await service.analyzeFoodImage(
        imageBytes: Uint8List(0),
        mealType: MealType.snack,
        mealTitleHint: 'Greek Yogurt Bowl',
      );

      expect(result.detectedFoods.isNotEmpty, isTrue);
      expect(result.detectedFoods.any((f) => f.name.contains('Yogurt')), isTrue);
      final totalProtein = result.detectedFoods.fold<double>(0.0, (sum, item) => sum + item.protein);
      expect(totalProtein, greaterThan(10.0));
    });

    test('analyzeFoodImage detects drink items (Whey Protein Shake)', () async {
      final result = await service.analyzeFoodImage(
        imageBytes: Uint8List(0),
        mealType: MealType.drink,
        mealTitleHint: 'Whey Protein Shake with Banana',
      );

      expect(result.detectedFoods.isNotEmpty, isTrue);
      expect(result.detectedFoods.any((f) => f.name.contains('Shake') || f.name.contains('Protein')), isTrue);
      final totalProtein = result.detectedFoods.fold<double>(0.0, (sum, item) => sum + item.protein);
      expect(totalProtein, greaterThan(20.0));
    });

    test('scaleToGrams proportionally recalculates nutritional metrics', () {
      const initialItem = DetectedFoodItem(
        id: 's_item',
        name: 'Grilled Chicken',
        portion: '100 g',
        portionGrams: 100.0,
        calories: 165,
        protein: 31.0,
        carbs: 0.0,
        fat: 3.6,
        fiber: 0.0,
      );

      final scaled = initialItem.scaleToGrams(200.0);

      expect(scaled.portion, '200 g');
      expect(scaled.portionGrams, 200.0);
      expect(scaled.calories, initialItem.calories * 2);
      expect(scaled.protein, initialItem.protein * 2);
      expect(scaled.carbs, initialItem.carbs * 2);
      expect(scaled.fat, initialItem.fat * 2);
    });
  });
}
