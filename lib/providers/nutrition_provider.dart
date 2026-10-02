import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/nutrition_model.dart';
import '../services/meal_service.dart';

class NutritionProvider extends ChangeNotifier {
  final MealService _mealService;

  DailyNutritionModel? _todayNutrition;
  String? _boundUserId;
  StreamSubscription? _nutritionSub;

  bool _isLoading = false;
  String? _error;

  DailyNutritionModel? get todayNutrition => _todayNutrition;
  bool get isLoading => _isLoading;
  String? get error => _error;

  NutritionProvider({
    MealService? mealService,
  })  : _mealService = mealService ?? MealService() {
    _init();
  }

  void _init() {
    _todayNutrition = DailyNutritionModel();
  }

  /// Binds to a user's real-time nutrition stream
  void bindUser(String userId) {
    if (_boundUserId == userId) return;
    _boundUserId = userId;

    if (Firebase.apps.isEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    _nutritionSub?.cancel();
    _nutritionSub = _mealService.streamTodayNutrition(userId).listen(
      (log) {
        if (log != null) {
          _todayNutrition = log;
        } else {
          _todayNutrition = DailyNutritionModel();
        }
        _isLoading = false;
        notifyListeners();
      },
      onError: (err) {
        _isLoading = false;
        _error = err.toString();
        debugPrint('Error streaming nutrition: $_error');
        notifyListeners();
      },
    );
  }

  void addMeal(MealItemModel meal) {
    if (_todayNutrition != null) {
      final updatedMeals = List<MealItemModel>.from(_todayNutrition!.meals)..add(meal);
      _todayNutrition = _todayNutrition!.copyWith(meals: updatedMeals);
      notifyListeners();
    }

    if (Firebase.apps.isNotEmpty && _boundUserId != null) {
      _mealService.addMealItem(_boundUserId!, meal).catchError((err) {
        _error = err.toString();
        debugPrint('Error adding meal: $_error');
        notifyListeners();
        return DailyNutritionModel();
      });
    }
  }

  void deleteMeal(String mealId) {
    if (_todayNutrition != null) {
      final updatedMeals = _todayNutrition!.meals.where((m) => m.id != mealId).toList();
      _todayNutrition = _todayNutrition!.copyWith(meals: updatedMeals);
      notifyListeners();
    }

    if (Firebase.apps.isNotEmpty && _boundUserId != null) {
      _mealService.deleteMealItem(_boundUserId!, mealId).catchError((err) {
        _error = err.toString();
        debugPrint('Error deleting meal: $_error');
        notifyListeners();
        return DailyNutritionModel();
      });
    }
  }

  Future<void> updateTargets({
    int? targetCalories,
    double? targetProtein,
    double? targetCarbs,
    double? targetFat,
  }) async {
    if (_todayNutrition != null) {
      _todayNutrition = _todayNutrition!.copyWith(
        targetCalories: targetCalories,
        targetProteinGrams: targetProtein,
        targetCarbsGrams: targetCarbs,
        targetFatGrams: targetFat,
      );
      notifyListeners();
    }

    if (Firebase.apps.isNotEmpty && _boundUserId != null) {
      try {
        await _mealService.updateNutritionTargets(
          _boundUserId!,
          targetCalories: targetCalories,
          targetProtein: targetProtein,
          targetCarbs: targetCarbs,
          targetFat: targetFat,
        );
      } catch (err) {
        _error = err.toString();
        debugPrint('Error updating targets: $_error');
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _nutritionSub?.cancel();
    super.dispose();
  }
}
