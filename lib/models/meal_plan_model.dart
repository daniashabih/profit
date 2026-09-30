/// Item within a daily meal plan: mealPlans/{planId}/meals/{mealId}
class MealPlanItem {
  final String id;
  final String name;
  final String mealType; // 'Breakfast', 'Lunch', 'Snack', 'Dinner'
  final String servingSize;
  final int calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final bool isConsumed;
  final DateTime? consumedAt;

  const MealPlanItem({
    required this.id,
    required this.name,
    required this.mealType,
    this.servingSize = '1 serving',
    required this.calories,
    required this.proteinGrams,
    this.carbsGrams = 0.0,
    this.fatGrams = 0.0,
    this.isConsumed = false,
    this.consumedAt,
  });

  MealPlanItem copyWith({
    String? id,
    String? name,
    String? mealType,
    String? servingSize,
    int? calories,
    double? proteinGrams,
    double? carbsGrams,
    double? fatGrams,
    bool? isConsumed,
    DateTime? consumedAt,
  }) {
    return MealPlanItem(
      id: id ?? this.id,
      name: name ?? this.name,
      mealType: mealType ?? this.mealType,
      servingSize: servingSize ?? this.servingSize,
      calories: calories ?? this.calories,
      proteinGrams: proteinGrams ?? this.proteinGrams,
      carbsGrams: carbsGrams ?? this.carbsGrams,
      fatGrams: fatGrams ?? this.fatGrams,
      isConsumed: isConsumed ?? this.isConsumed,
      consumedAt: consumedAt ?? this.consumedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mealType': mealType,
      'servingSize': servingSize,
      'calories': calories,
      'proteinGrams': proteinGrams,
      'carbsGrams': carbsGrams,
      'fatGrams': fatGrams,
      'isConsumed': isConsumed,
      if (consumedAt != null) 'consumedAt': consumedAt!.toIso8601String(),
    };
  }

  factory MealPlanItem.fromMap(Map<String, dynamic> map, {String? docId}) {
    return MealPlanItem(
      id: map['id']?.toString() ?? docId ?? '',
      name: map['name']?.toString() ?? '',
      mealType: map['mealType']?.toString() ?? 'Breakfast',
      servingSize: map['servingSize']?.toString() ?? '1 serving',
      calories: (map['calories'] as num?)?.toInt() ?? 0,
      proteinGrams: (map['proteinGrams'] as num?)?.toDouble() ?? 0.0,
      carbsGrams: (map['carbsGrams'] as num?)?.toDouble() ?? 0.0,
      fatGrams: (map['fatGrams'] as num?)?.toDouble() ?? 0.0,
      isConsumed: map['isConsumed'] == true,
      consumedAt: map['consumedAt'] != null
          ? DateTime.tryParse(map['consumedAt'].toString())
          : null,
    );
  }
}

/// Personalized monthly meal and nutrition plan: mealPlans/{planId}
class MealPlan {
  final String id;
  final String userId;
  final String monthId;
  final int targetCalories;
  final double targetProteinGrams;
  final double targetCarbsGrams;
  final double targetFatGrams;
  final List<MealPlanItem> meals;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MealPlan({
    required this.id,
    required this.userId,
    required this.monthId,
    required this.targetCalories,
    required this.targetProteinGrams,
    required this.targetCarbsGrams,
    required this.targetFatGrams,
    this.meals = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// Automatically calculates total protein consumed from marked meals
  double get consumedProteinGrams => meals
      .where((m) => m.isConsumed)
      .fold(0.0, (sum, m) => sum + m.proteinGrams);

  /// Automatically calculates total calories consumed from marked meals
  int get consumedCalories => meals
      .where((m) => m.isConsumed)
      .fold(0, (sum, m) => sum + m.calories);

  /// Protein remaining to reach target
  double get remainingProteinGrams {
    final diff = targetProteinGrams - consumedProteinGrams;
    return diff > 0 ? diff : 0.0;
  }

  /// Consumed protein percentage (0.0 to 1.0)
  double get proteinProgress {
    if (targetProteinGrams <= 0) return 0.0;
    return (consumedProteinGrams / targetProteinGrams).clamp(0.0, 1.0);
  }

  MealPlan copyWith({
    String? id,
    String? userId,
    String? monthId,
    int? targetCalories,
    double? targetProteinGrams,
    double? targetCarbsGrams,
    double? targetFatGrams,
    List<MealPlanItem>? meals,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MealPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      monthId: monthId ?? this.monthId,
      targetCalories: targetCalories ?? this.targetCalories,
      targetProteinGrams: targetProteinGrams ?? this.targetProteinGrams,
      targetCarbsGrams: targetCarbsGrams ?? this.targetCarbsGrams,
      targetFatGrams: targetFatGrams ?? this.targetFatGrams,
      meals: meals ?? this.meals,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'monthId': monthId,
      'targetCalories': targetCalories,
      'targetProteinGrams': targetProteinGrams,
      'targetCarbsGrams': targetCarbsGrams,
      'targetFatGrams': targetFatGrams,
      'meals': meals.map((m) => m.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MealPlan.fromMap(Map<String, dynamic> map, {String? docId}) {
    return MealPlan(
      id: map['id']?.toString() ?? docId ?? '',
      userId: map['userId']?.toString() ?? '',
      monthId: map['monthId']?.toString() ?? '',
      targetCalories: (map['targetCalories'] as num?)?.toInt() ?? 2000,
      targetProteinGrams: (map['targetProteinGrams'] as num?)?.toDouble() ?? 120.0,
      targetCarbsGrams: (map['targetCarbsGrams'] as num?)?.toDouble() ?? 220.0,
      targetFatGrams: (map['targetFatGrams'] as num?)?.toDouble() ?? 60.0,
      meals: (map['meals'] as List<dynamic>?)
              ?.map((m) => MealPlanItem.fromMap(Map<String, dynamic>.from(m as Map)))
              .toList() ??
          const [],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
