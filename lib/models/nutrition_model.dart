import '../core/enums/meal_type.dart';

class MealItemModel {
  final String id;
  final String name;
  final MealType mealType;
  final int calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final String time;

  MealItemModel({
    required this.id,
    required this.name,
    required this.mealType,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.time,
  });

  MealItemModel copyWith({
    String? id,
    String? name,
    MealType? mealType,
    int? calories,
    double? proteinGrams,
    double? carbsGrams,
    double? fatGrams,
    String? time,
  }) {
    return MealItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      mealType: mealType ?? this.mealType,
      calories: calories ?? this.calories,
      proteinGrams: proteinGrams ?? this.proteinGrams,
      carbsGrams: carbsGrams ?? this.carbsGrams,
      fatGrams: fatGrams ?? this.fatGrams,
      time: time ?? this.time,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mealType': mealType.name,
      'calories': calories,
      'proteinGrams': proteinGrams,
      'carbsGrams': carbsGrams,
      'fatGrams': fatGrams,
      'time': time,
    };
  }

  factory MealItemModel.fromMap(Map<String, dynamic> map) {
    return MealItemModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      mealType: MealType.values.firstWhere(
        (m) => m.name == map['mealType'],
        orElse: () => MealType.breakfast,
      ),
      calories: map['calories'] ?? 0,
      proteinGrams: (map['proteinGrams'] as num?)?.toDouble() ?? 0.0,
      carbsGrams: (map['carbsGrams'] as num?)?.toDouble() ?? 0.0,
      fatGrams: (map['fatGrams'] as num?)?.toDouble() ?? 0.0,
      time: map['time'] ?? '08:00 AM',
    );
  }
}

class DailyNutritionModel {
  final String id;
  final String? userId;
  final int targetCalories;
  final double targetProteinGrams;
  final double targetCarbsGrams;
  final double targetFatGrams;
  final List<MealItemModel> meals;
  final String date;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyNutritionModel({
    this.id = '',
    this.userId,
    this.targetCalories = 1800,
    this.targetProteinGrams = 140,
    this.targetCarbsGrams = 200,
    this.targetFatGrams = 55,
    this.meals = const [],
    String? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : date = date ?? DateTime.now().toIso8601String().split('T').first,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  int get consumedCalories => meals.fold(0, (sum, item) => sum + item.calories);
  double get consumedProtein =>
      meals.fold(0.0, (sum, item) => sum + item.proteinGrams);
  double get consumedCarbs =>
      meals.fold(0.0, (sum, item) => sum + item.carbsGrams);
  double get consumedFat =>
      meals.fold(0.0, (sum, item) => sum + item.fatGrams);

  double get calorieProgress =>
      targetCalories == 0 ? 0 : (consumedCalories / targetCalories).clamp(0.0, 1.0);
  double get proteinProgress =>
      targetProteinGrams == 0 ? 0 : (consumedProtein / targetProteinGrams).clamp(0.0, 1.0);
  double get carbsProgress =>
      targetCarbsGrams == 0 ? 0 : (consumedCarbs / targetCarbsGrams).clamp(0.0, 1.0);
  double get fatProgress =>
      targetFatGrams == 0 ? 0 : (consumedFat / targetFatGrams).clamp(0.0, 1.0);

  List<MealItemModel> getMealsByType(MealType type) {
    return meals.where((m) => m.mealType == type).toList();
  }

  int getCaloriesByType(MealType type) {
    return getMealsByType(type).fold(0, (sum, item) => sum + item.calories);
  }

  DailyNutritionModel copyWith({
    String? id,
    String? userId,
    int? targetCalories,
    double? targetProteinGrams,
    double? targetCarbsGrams,
    double? targetFatGrams,
    List<MealItemModel>? meals,
    String? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyNutritionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      targetCalories: targetCalories ?? this.targetCalories,
      targetProteinGrams: targetProteinGrams ?? this.targetProteinGrams,
      targetCarbsGrams: targetCarbsGrams ?? this.targetCarbsGrams,
      targetFatGrams: targetFatGrams ?? this.targetFatGrams,
      meals: meals ?? this.meals.map((m) => m.copyWith()).toList(),
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      if (userId != null) 'userId': userId,
      'targetCalories': targetCalories,
      'targetProteinGrams': targetProteinGrams,
      'targetCarbsGrams': targetCarbsGrams,
      'targetFatGrams': targetFatGrams,
      'consumedCalories': consumedCalories,
      'meals': meals.map((m) => m.toMap()).toList(),
      'date': date,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Cloud Firestore payload strictly adhering to firestore.rules isValidNutritionLog
  Map<String, dynamic> toFirestoreMap(String ownerUid) {
    return {
      'id': id,
      'userId': userId?.isNotEmpty == true ? userId! : ownerUid,
      'targetCalories': targetCalories,
      'targetProteinGrams': targetProteinGrams,
      'targetCarbsGrams': targetCarbsGrams,
      'targetFatGrams': targetFatGrams,
      'consumedCalories': consumedCalories,
      'meals': meals.map((m) => m.toMap()).toList(),
      'date': date,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  factory DailyNutritionModel.fromMap(Map<String, dynamic> map) {
    return DailyNutritionModel(
      id: map['id']?.toString() ?? '',
      userId: map['userId']?.toString(),
      targetCalories: (map['targetCalories'] as num?)?.toInt() ?? 1800,
      targetProteinGrams: (map['targetProteinGrams'] as num?)?.toDouble() ?? 140.0,
      targetCarbsGrams: (map['targetCarbsGrams'] as num?)?.toDouble() ?? 200.0,
      targetFatGrams: (map['targetFatGrams'] as num?)?.toDouble() ?? 55.0,
      meals: (map['meals'] as List<dynamic>?)
              ?.map((item) => MealItemModel.fromMap(Map<String, dynamic>.from(item as Map)))
              .toList() ??
          [],
      date: map['date']?.toString(),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
