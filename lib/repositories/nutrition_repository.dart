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
    // Exact match to mockup Screen 9: 1,420 / 1,800 kcal, Protein 92/120g, Carbs 150/200g, Fat 42/60g
    _todayNutrition = DailyNutritionModel(
      targetCalories: 1800,
      targetProteinGrams: 120,
      targetCarbsGrams: 200,
      targetFatGrams: 60,
      meals: [
        MealItemModel(
          id: 'meal_1',
          name: 'Oats, Banana, Almonds',
          mealType: MealType.breakfast,
          calories: 420,
          proteinGrams: 22,
          carbsGrams: 65,
          fatGrams: 10,
          time: '08:30 AM',
        ),
        MealItemModel(
          id: 'meal_2',
          name: 'Chicken, Brown Rice, Salad',
          mealType: MealType.lunch,
          calories: 550,
          proteinGrams: 42,
          carbsGrams: 55,
          fatGrams: 16,
          time: '01:15 PM',
        ),
        MealItemModel(
          id: 'meal_3',
          name: 'Grilled Fish, Vegetables',
          mealType: MealType.dinner,
          calories: 250,
          proteinGrams: 20,
          carbsGrams: 15,
          fatGrams: 9,
          time: '07:30 PM',
        ),
        MealItemModel(
          id: 'meal_4',
          name: 'Greek Yogurt',
          mealType: MealType.snack,
          calories: 200,
          proteinGrams: 8,
          carbsGrams: 15,
          fatGrams: 7,
          time: '04:45 PM',
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
