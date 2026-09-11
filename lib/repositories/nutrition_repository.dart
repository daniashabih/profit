import '../models/nutrition_model.dart';
import '../core/enums/meal_type.dart';

abstract class NutritionRepository {
  DailyNutritionModel getTodayNutrition();
  void addMealItem(MealItemModel meal);
  void removeMealItem(String mealId);
}

class LocalNutritionRepository implements NutritionRepository {
  late DailyNutritionModel _todayNutrition;

  LocalNutritionRepository() {
    // Setting default mock items totaling ~1,420 kcal out of 1,800 kcal target
    _todayNutrition = DailyNutritionModel(
      targetCalories: 1800,
      targetProteinGrams: 140,
      targetCarbsGrams: 200,
      targetFatGrams: 55,
      meals: [
        MealItemModel(
          id: 'meal_1',
          name: 'Oatmeal with Blueberries & Whey',
          mealType: MealType.breakfast,
          calories: 420,
          proteinGrams: 32,
          carbsGrams: 58,
          fatGrams: 8,
          time: '08:30 AM',
        ),
        MealItemModel(
          id: 'meal_2',
          name: 'Grilled Chicken Breast & Quinoa Bowl',
          mealType: MealType.lunch,
          calories: 580,
          proteinGrams: 48,
          carbsGrams: 62,
          fatGrams: 14,
          time: '01:15 PM',
        ),
        MealItemModel(
          id: 'meal_3',
          name: 'Greek Yogurt & Almonds',
          mealType: MealType.snack,
          calories: 220,
          proteinGrams: 18,
          carbsGrams: 14,
          fatGrams: 10,
          time: '04:45 PM',
        ),
        MealItemModel(
          id: 'meal_4',
          name: 'Baked Salmon & Steamed Asparagus',
          mealType: MealType.dinner,
          calories: 200,
          proteinGrams: 24,
          carbsGrams: 6,
          fatGrams: 9,
          time: '07:30 PM',
        ),
      ],
    );
  }

  @override
  DailyNutritionModel getTodayNutrition() => _todayNutrition;

  @override
  void addMealItem(MealItemModel meal) {
    final updatedList = List<MealItemModel>.from(_todayNutrition.meals)..add(meal);
    _todayNutrition = DailyNutritionModel(
      targetCalories: _todayNutrition.targetCalories,
      targetProteinGrams: _todayNutrition.targetProteinGrams,
      targetCarbsGrams: _todayNutrition.targetCarbsGrams,
      targetFatGrams: _todayNutrition.targetFatGrams,
      meals: updatedList,
    );
  }

  @override
  void removeMealItem(String mealId) {
    final updatedList = _todayNutrition.meals.where((m) => m.id != mealId).toList();
    _todayNutrition = DailyNutritionModel(
      targetCalories: _todayNutrition.targetCalories,
      targetProteinGrams: _todayNutrition.targetProteinGrams,
      targetCarbsGrams: _todayNutrition.targetCarbsGrams,
      targetFatGrams: _todayNutrition.targetFatGrams,
      meals: updatedList,
    );
  }
}
