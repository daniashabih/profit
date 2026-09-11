import 'package:flutter/material.dart';
import '../models/nutrition_model.dart';
import '../repositories/nutrition_repository.dart';

class NutritionProvider extends ChangeNotifier {
  final NutritionRepository _nutritionRepo;
  late DailyNutritionModel _todayNutrition;

  DailyNutritionModel get todayNutrition => _todayNutrition;

  NutritionProvider({required NutritionRepository nutritionRepo})
      : _nutritionRepo = nutritionRepo {
    _init();
  }

  void _init() {
    _todayNutrition = _nutritionRepo.getTodayNutrition();
  }

  void addMeal(MealItemModel meal) {
    _nutritionRepo.addMealItem(meal);
    _todayNutrition = _nutritionRepo.getTodayNutrition();
    notifyListeners();
  }

  void deleteMeal(String mealId) {
    _nutritionRepo.removeMealItem(mealId);
    _todayNutrition = _nutritionRepo.getTodayNutrition();
    notifyListeners();
  }
}
