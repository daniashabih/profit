import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/meal_plan_model.dart';
import '../models/protein_log_model.dart';
import '../core/utils/fitness_calculators.dart';

/// Nutrition and Meal Service
/// Calculates transparent, evidence-based daily calorie and protein targets,
/// generates balanced daily meal plans (Breakfast, Lunch, Snack, Dinner),
/// and manages consumption logging to Cloud Firestore: mealPlans/{planId} & proteinLogs/{logId}.
class NutritionService {
  final FirebaseFirestore? _firestore;

  final Map<String, MealPlan> _localMealPlans = {};
  final List<ProteinLog> _localProteinLogs = [];

  NutritionService({FirebaseFirestore? firestore})
      : _firestore = firestore ??
            (Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null);

  /// Calculates estimated Total Daily Energy Expenditure (TDEE) using the Mifflin-St Jeor formula.
  /// Applies a safe, non-extreme goal modifier.
  static ({
    int bmr,
    int tdee,
    int targetCalories,
    double targetProteinGrams,
    double targetCarbsGrams,
    double targetFatGrams,
    String calorieRationale,
  }) calculateDailyTargets({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
    required String goalType,
    required int trainingDaysPerWeek,
  }) {
    // 1. Basal Metabolic Rate (BMR) - Mifflin-St Jeor
    double bmrValue;
    final normGender = gender.toLowerCase();
    if (normGender.contains('female') || normGender.contains('woman')) {
      bmrValue = (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    } else if (normGender.contains('male') || normGender.contains('man')) {
      bmrValue = (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    } else {
      bmrValue = (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 78;
    }

    // 2. Activity Multiplier based on training frequency
    double activityMultiplier;
    if (trainingDaysPerWeek <= 2) {
      activityMultiplier = 1.30; // Lightly active
    } else if (trainingDaysPerWeek <= 4) {
      activityMultiplier = 1.50; // Moderately active
    } else {
      activityMultiplier = 1.65; // Highly active
    }

    final tdeeValue = bmrValue * activityMultiplier;

    // 3. Goal Calorie Adjustment
    final normGoal = goalType.toLowerCase();
    double targetCal;
    String rationale;

    if (normGoal.contains('lose') || normGoal.contains('weight loss') || normGoal.contains('cut')) {
      // Safe, sustainable 400-500 kcal deficit
      targetCal = tdeeValue - 450;
      // Safety clamp: Never recommend starvation calories
      final safeFloor = (normGender.contains('female')) ? 1300.0 : 1550.0;
      if (targetCal < safeFloor) targetCal = safeFloor;
      rationale = 'Sustainable ~450 kcal deficit to promote gradual fat loss while preserving lean muscle.';
    } else if (normGoal.contains('build') || normGoal.contains('muscle') || normGoal.contains('bulk')) {
      targetCal = tdeeValue + 300;
      rationale = 'Moderate ~300 kcal surplus to fuel progressive muscle hypertrophy and strength recovery.';
    } else {
      // Maintain Weight or Improve Fitness
      targetCal = tdeeValue;
      rationale = 'Maintenance intake balanced to match your daily activity and athletic energy expenditure.';
    }

    // 4. Protein Target
    final proteinRec = FitnessCalculators.calculateDailyProteinRecommendation(
      weightKg: weightKg,
      fitnessGoal: goalType,
    );
    final targetProtein = proteinRec.targetGrams;

    // 5. Fat (25% of calories) & Carbs (remaining)
    final fatCalories = targetCal * 0.25;
    final targetFat = double.parse((fatCalories / 9.0).toStringAsFixed(0));

    final proteinCalories = targetProtein * 4.0;
    final remainingCalories = (targetCal - proteinCalories - fatCalories).clamp(200.0, 5000.0);
    final targetCarbs = double.parse((remainingCalories / 4.0).toStringAsFixed(0));

    return (
      bmr: bmrValue.round(),
      tdee: tdeeValue.round(),
      targetCalories: targetCal.round(),
      targetProteinGrams: targetProtein,
      targetCarbsGrams: targetCarbs,
      targetFatGrams: targetFat,
      calorieRationale: rationale,
    );
  }

  /// Generates a personalized daily meal plan structured into Breakfast, Lunch, Snack, and Dinner.
  Future<MealPlan> generatePersonalizedMealPlan({
    required String userId,
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
    required String goalType,
    required int trainingDaysPerWeek,
    String? monthId,
  }) async {
    final now = DateTime.now();
    final effectiveMonthId = monthId ?? '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final planId = '${userId}_mealplan_$effectiveMonthId';

    final targets = calculateDailyTargets(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      gender: gender,
      goalType: goalType,
      trainingDaysPerWeek: trainingDaysPerWeek,
    );

    final meals = _createStructuredMeals(
      targetCalories: targets.targetCalories,
      targetProtein: targets.targetProteinGrams,
      goalType: goalType,
    );

    final plan = MealPlan(
      id: planId,
      userId: userId,
      monthId: effectiveMonthId,
      targetCalories: targets.targetCalories,
      targetProteinGrams: targets.targetProteinGrams,
      targetCarbsGrams: targets.targetCarbsGrams,
      targetFatGrams: targets.targetFatGrams,
      meals: meals,
      createdAt: now,
      updatedAt: now,
    );

    _localMealPlans[planId] = plan;

    if (_firestore != null && userId.isNotEmpty) {
      try {
        final planRef = _firestore.collection('mealPlans').doc(planId);
        await planRef.set(plan.toMap());

        final batch = _firestore.batch();
        for (final meal in meals) {
          final mealRef = planRef.collection('meals').doc(meal.id);
          batch.set(mealRef, meal.toMap());
        }
        await batch.commit();
      } catch (_) {}
    }

    return plan;
  }

  List<MealPlanItem> _createStructuredMeals({
    required int targetCalories,
    required double targetProtein,
    required String goalType,
  }) {
    // Distribute macros across 4 meals:
    // Breakfast: 25% cal, 25% protein
    // Lunch: 35% cal, 35% protein
    // Snack: 15% cal, 15% protein
    // Dinner: 25% cal, 25% protein
    final bProtein = double.parse((targetProtein * 0.25).toStringAsFixed(1));
    final lProtein = double.parse((targetProtein * 0.35).toStringAsFixed(1));
    final sProtein = double.parse((targetProtein * 0.15).toStringAsFixed(1));
    final dProtein = double.parse((targetProtein * 0.25).toStringAsFixed(1));

    return [
      MealPlanItem(
        id: 'meal_breakfast',
        name: 'Eggs, Rolled Oats & Greek Yogurt',
        mealType: 'Breakfast',
        servingSize: '3 Eggs, 60g Oats, 100g Yogurt',
        calories: (targetCalories * 0.26).round(),
        proteinGrams: bProtein,
        carbsGrams: 45.0,
        fatGrams: 14.0,
        isConsumed: false,
      ),
      MealPlanItem(
        id: 'meal_lunch',
        name: 'Grilled Chicken Breast, Brown Rice & Broccoli',
        mealType: 'Lunch',
        servingSize: '180g Chicken, 1 Cup Rice, Steamed Veggies',
        calories: (targetCalories * 0.36).round(),
        proteinGrams: lProtein,
        carbsGrams: 60.0,
        fatGrams: 16.0,
        isConsumed: false,
      ),
      MealPlanItem(
        id: 'meal_snack',
        name: 'Whey Protein Shake & Almonds',
        mealType: 'Snack',
        servingSize: '1 Scoop Protein, 20g Almonds',
        calories: (targetCalories * 0.14).round(),
        proteinGrams: sProtein,
        carbsGrams: 8.0,
        fatGrams: 11.0,
        isConsumed: false,
      ),
      MealPlanItem(
        id: 'meal_dinner',
        name: 'Baked Salmon, Sweet Potato & Asparagus',
        mealType: 'Dinner',
        servingSize: '160g Salmon, 1 Medium Potato, Greens',
        calories: (targetCalories * 0.24).round(),
        proteinGrams: dProtein,
        carbsGrams: 35.0,
        fatGrams: 15.0,
        isConsumed: false,
      ),
    ];
  }

  /// Toggles a meal item's consumed state, updates the meal plan in Firestore,
  /// and updates the daily protein log: proteinLogs/{logId}.
  Future<MealPlan> toggleMealConsumption({
    required String planId,
    required String mealId,
    required bool isConsumed,
  }) async {
    final existing = _localMealPlans[planId] ?? await getMealPlanById(planId);
    if (existing == null) {
      throw Exception('Meal plan not found: $planId');
    }

    final updatedMeals = existing.meals.map((m) {
      if (m.id == mealId) {
        return m.copyWith(
          isConsumed: isConsumed,
          consumedAt: isConsumed ? DateTime.now() : null,
        );
      }
      return m;
    }).toList();

    final updatedPlan = existing.copyWith(
      meals: updatedMeals,
      updatedAt: DateTime.now(),
    );

    _localMealPlans[planId] = updatedPlan;

    // Log/update daily protein tracking in proteinLogs/{logId}
    await _updateDailyProteinLog(
      userId: updatedPlan.userId,
      targetGrams: updatedPlan.targetProteinGrams,
      consumedGrams: updatedPlan.consumedProteinGrams,
      mealsLogged: updatedMeals.where((m) => m.isConsumed).length,
    );

    if (_firestore != null && updatedPlan.userId.isNotEmpty) {
      try {
        final planRef = _firestore.collection('mealPlans').doc(planId);
        await planRef.update(updatedPlan.toMap());
        await planRef.collection('meals').doc(mealId).update({
          'isConsumed': isConsumed,
          'consumedAt': isConsumed ? DateTime.now().toIso8601String() : null,
        });
      } catch (_) {}
    }

    return updatedPlan;
  }

  Future<void> _updateDailyProteinLog({
    required String userId,
    required double targetGrams,
    required double consumedGrams,
    required int mealsLogged,
  }) async {
    final todayStr = DateTime.now().toIso8601String().split('T').first;
    final logId = '${userId}_protein_$todayStr';

    final log = ProteinLog(
      id: logId,
      userId: userId,
      date: todayStr,
      targetGrams: targetGrams,
      consumedGrams: consumedGrams,
      remainingGrams: (targetGrams - consumedGrams).clamp(0.0, 1000.0),
      mealsLoggedCount: mealsLogged,
      updatedAt: DateTime.now(),
    );

    _localProteinLogs.removeWhere((l) => l.id == logId);
    _localProteinLogs.add(log);

    if (_firestore != null && userId.isNotEmpty) {
      try {
        await _firestore.collection('proteinLogs').doc(logId).set(log.toMap());
      } catch (_) {}
    }
  }

  /// Retrieves a meal plan by ID
  Future<MealPlan?> getMealPlanById(String planId) async {
    if (_localMealPlans.containsKey(planId)) {
      return _localMealPlans[planId];
    }

    if (_firestore != null && planId.isNotEmpty) {
      try {
        final doc = await _firestore.collection('mealPlans').doc(planId).get();
        if (doc.exists && doc.data() != null) {
          final plan = MealPlan.fromMap(doc.data()!, docId: doc.id);
          _localMealPlans[plan.id] = plan;
          return plan;
        }
      } catch (_) {}
    }

    return null;
  }

  /// Retrieves the active meal plan for a user
  Future<MealPlan?> getActiveMealPlan(String userId) async {
    if (_firestore != null && userId.isNotEmpty) {
      try {
        final query = await _firestore
            .collection('mealPlans')
            .where('userId', isEqualTo: userId)
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          final plan = MealPlan.fromMap(query.docs.first.data(), docId: query.docs.first.id);
          _localMealPlans[plan.id] = plan;
          return plan;
        }
      } catch (_) {}
    }

    return _localMealPlans.values.firstWhere(
      (p) => p.userId == userId,
      orElse: () => _getDefaultMealPlan(userId),
    );
  }

  MealPlan _getDefaultMealPlan(String userId) {
    final now = DateTime.now();
    final plan = MealPlan(
      id: '${userId}_default_mealplan',
      userId: userId,
      monthId: '${now.year}-${now.month.toString().padLeft(2, '0')}',
      targetCalories: 2100,
      targetProteinGrams: 130.0,
      targetCarbsGrams: 230.0,
      targetFatGrams: 65.0,
      meals: _createStructuredMeals(
        targetCalories: 2100,
        targetProtein: 130.0,
        goalType: 'Improve Fitness',
      ),
      createdAt: now,
      updatedAt: now,
    );
    _localMealPlans[plan.id] = plan;
    return plan;
  }
}
