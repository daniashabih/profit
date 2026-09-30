import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/nutrition_model.dart';
import '../core/errors/app_error.dart';

/// MealService handles dynamic Cloud Firestore CRUD and streams for the
/// 'nutrition_logs' collection, strictly adhering to firestore.rules isValidNutritionLog.
class MealService {
  final FirebaseFirestore? _firestore;

  MealService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? (Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null);

  static const String colNutritionLogs = 'nutrition_logs';

  String _todayStr() => DateTime.now().toIso8601String().split('T').first;

  /// Standard document ID format for daily nutrition: {userId}_{date}
  String _docId(String userId, String date) => '${userId}_$date';

  /// Streams today's nutrition log for a specific user
  Stream<DailyNutritionModel?> streamTodayNutrition(String userId) {
    if (_firestore == null) return const Stream.empty();
    final today = _todayStr();
    final docId = _docId(userId, today);

    return _firestore.collection(colNutritionLogs).doc(docId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      final data = Map<String, dynamic>.from(doc.data()!);
      data['id'] = doc.id;
      return DailyNutritionModel.fromMap(data);
    });
  }

  /// Fetches today's nutrition log or creates a base structure if non-existent
  Future<DailyNutritionModel> getTodayNutrition(String userId) async {
    final today = _todayStr();
    final docId = _docId(userId, today);
    if (_firestore == null) {
      return DailyNutritionModel(
        id: docId,
        userId: userId,
        date: today,
        targetCalories: 1800,
        targetProteinGrams: 140,
        targetCarbsGrams: 200,
        targetFatGrams: 55,
        meals: [],
      );
    }
    try {
      final doc = await _firestore.collection(colNutritionLogs).doc(docId).get();

      if (doc.exists && doc.data() != null) {
        final data = Map<String, dynamic>.from(doc.data()!);
        data['id'] = doc.id;
        return DailyNutritionModel.fromMap(data);
      }

      // Return a standard empty day if none logged yet
      return DailyNutritionModel(
        id: docId,
        userId: userId,
        date: today,
        targetCalories: 1800,
        targetProteinGrams: 140,
        targetCarbsGrams: 200,
        targetFatGrams: 55,
        meals: [],
      );
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Adds a meal item to today's log in Firestore
  Future<DailyNutritionModel> addMealItem(String userId, MealItemModel meal) async {
    final current = await getTodayNutrition(userId);
    final updatedMeals = List<MealItemModel>.from(current.meals)..add(meal);

    final updated = current.copyWith(
      userId: userId,
      meals: updatedMeals,
    );

    if (_firestore == null) return updated;

    try {
      final docId = current.id.isNotEmpty ? current.id : _docId(userId, _todayStr());
      final payload = updated.toFirestoreMap(userId);
      payload['id'] = docId;

      await _firestore
          .collection(colNutritionLogs)
          .doc(docId)
          .set(payload, SetOptions(merge: true));

      return updated;
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Removes a meal item from today's log in Firestore
  Future<DailyNutritionModel> deleteMealItem(String userId, String mealId) async {
    final current = await getTodayNutrition(userId);
    final updatedMeals = current.meals.where((m) => m.id != mealId).toList();

    final updated = current.copyWith(
      userId: userId,
      meals: updatedMeals,
    );

    if (_firestore == null) return updated;

    try {
      final docId = current.id.isNotEmpty ? current.id : _docId(userId, _todayStr());
      final payload = updated.toFirestoreMap(userId);
      payload['id'] = docId;

      await _firestore
          .collection(colNutritionLogs)
          .doc(docId)
          .set(payload, SetOptions(merge: true));

      return updated;
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Updates daily calorie and macronutrient targets
  Future<void> updateNutritionTargets(
    String userId, {
    int? targetCalories,
    double? targetProtein,
    double? targetCarbs,
    double? targetFat,
  }) async {
    if (_firestore == null) return;
    try {
      final today = _todayStr();
      final docId = _docId(userId, today);
      final current = await getTodayNutrition(userId);

      final updated = current.copyWith(
        targetCalories: targetCalories ?? current.targetCalories,
        targetProteinGrams: targetProtein ?? current.targetProteinGrams,
        targetCarbsGrams: targetCarbs ?? current.targetCarbsGrams,
        targetFatGrams: targetFat ?? current.targetFatGrams,
      );

      final payload = updated.toFirestoreMap(userId);
      payload['id'] = docId;

      await _firestore
          .collection(colNutritionLogs)
          .doc(docId)
          .set(payload, SetOptions(merge: true));
    } catch (e) {
      throw AppError.fromException(e);
    }
  }
}
