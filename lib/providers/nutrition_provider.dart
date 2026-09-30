import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/nutrition_model.dart';
import '../repositories/nutrition_repository.dart';
import '../services/meal_service.dart';

class NutritionProvider extends ChangeNotifier {
  final NutritionRepository _nutritionRepo;
  final MealService _mealService;

  late DailyNutritionModel _todayNutrition;
  String? _boundUserId;
  StreamSubscription? _nutritionSub;

  DailyNutritionModel get todayNutrition => _todayNutrition;

  NutritionProvider({
    required NutritionRepository nutritionRepo,
    MealService? mealService,
  })  : _nutritionRepo = nutritionRepo,
        _mealService = mealService ?? MealService() {
    _init();
  }

  void _init() {
    _todayNutrition = _nutritionRepo.getTodayNutrition();
  }

  /// Binds to a user's real-time nutrition stream
  void bindUser(String userId) {
    if (_boundUserId == userId) return;
    _boundUserId = userId;

    if (Firebase.apps.isEmpty) return;

    _nutritionSub?.cancel();
    _nutritionSub = _mealService.streamTodayNutrition(userId).listen((log) {
      if (log != null) {
        _todayNutrition = log;
        notifyListeners();
      }
    });
  }

  void addMeal(MealItemModel meal) {
    _nutritionRepo.addMealItem(meal);
    _todayNutrition = _nutritionRepo.getTodayNutrition();
    notifyListeners();

    if (Firebase.apps.isNotEmpty && _boundUserId != null) {
      _mealService.addMealItem(_boundUserId!, meal).catchError((_) => _todayNutrition);
    }
  }

  void deleteMeal(String mealId) {
    _nutritionRepo.removeMealItem(mealId);
    _todayNutrition = _nutritionRepo.getTodayNutrition();
    notifyListeners();

    if (Firebase.apps.isNotEmpty && _boundUserId != null) {
      _mealService.deleteMealItem(_boundUserId!, mealId).catchError((_) => _todayNutrition);
    }
  }

  Future<void> updateTargets({
    int? targetCalories,
    double? targetProtein,
    double? targetCarbs,
    double? targetFat,
  }) async {
    _todayNutrition = _todayNutrition.copyWith(
      targetCalories: targetCalories,
      targetProteinGrams: targetProtein,
      targetCarbsGrams: targetCarbs,
      targetFatGrams: targetFat,
    );
    notifyListeners();

    if (Firebase.apps.isNotEmpty && _boundUserId != null) {
      await _mealService.updateNutritionTargets(
        _boundUserId!,
        targetCalories: targetCalories,
        targetProtein: targetProtein,
        targetCarbs: targetCarbs,
        targetFat: targetFat,
      );
    }
  }

  @override
  void dispose() {
    _nutritionSub?.cancel();
    super.dispose();
  }
}
