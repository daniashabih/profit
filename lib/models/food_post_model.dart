import '../core/enums/meal_type.dart';

enum FoodAnalysisStatus {
  pending,
  analyzing,
  completed,
  failed,
  // ignore: constant_identifier_names
  needs_review;

  String get displayName {
    switch (this) {
      case FoodAnalysisStatus.pending:
        return 'Pending';
      case FoodAnalysisStatus.analyzing:
        return 'Analyzing...';
      case FoodAnalysisStatus.completed:
        return 'Analysis Complete';
      case FoodAnalysisStatus.failed:
        return 'Analysis Failed';
      case FoodAnalysisStatus.needs_review:
        return 'Needs Review';
    }
  }

  static FoodAnalysisStatus fromString(String? val) {
    if (val == null) return FoodAnalysisStatus.completed;
    final lower = val.toLowerCase().trim();
    for (final s in FoodAnalysisStatus.values) {
      if (s.name.toLowerCase() == lower) return s;
    }
    return FoodAnalysisStatus.completed;
  }
}

class DetectedFoodItem {
  final String id;
  final String name;
  final String portion;
  final double portionGrams;
  final String? cookingMethod;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium; // mg
  final Map<String, double> micronutrients; // minerals in mg: calcium, iron, magnesium, potassium, zinc, sodium, phosphorus
  final Map<String, double> vitamins; // vitamins in % or mg: vitaminA, vitaminC, vitaminD, vitaminE, vitaminK, bVitamins
  final bool isAiDetected;
  final Map<String, dynamic>? originalAiEstimate;

  const DetectedFoodItem({
    required this.id,
    required this.name,
    required this.portion,
    this.portionGrams = 100.0,
    this.cookingMethod,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    this.sugar = 0.0,
    this.sodium = 0.0,
    this.micronutrients = const {},
    this.vitamins = const {},
    this.isAiDetected = true,
    this.originalAiEstimate,
  });

  DetectedFoodItem copyWith({
    String? id,
    String? name,
    String? portion,
    double? portionGrams,
    String? cookingMethod,
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? fiber,
    double? sugar,
    double? sodium,
    Map<String, double>? micronutrients,
    Map<String, double>? vitamins,
    bool? isAiDetected,
    Map<String, dynamic>? originalAiEstimate,
  }) {
    return DetectedFoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      portion: portion ?? this.portion,
      portionGrams: portionGrams ?? this.portionGrams,
      cookingMethod: cookingMethod ?? this.cookingMethod,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      sugar: sugar ?? this.sugar,
      sodium: sodium ?? this.sodium,
      micronutrients: micronutrients ?? this.micronutrients,
      vitamins: vitamins ?? this.vitamins,
      isAiDetected: isAiDetected ?? this.isAiDetected,
      originalAiEstimate: originalAiEstimate ?? this.originalAiEstimate,
    );
  }

  /// Automatically scales nutritional content when the portion grams changes
  DetectedFoodItem scaleToGrams(double newGrams) {
    if (portionGrams <= 0 || newGrams <= 0) return this;
    final ratio = newGrams / portionGrams;

    final scaledMicros = <String, double>{};
    micronutrients.forEach((k, v) => scaledMicros[k] = double.parse((v * ratio).toStringAsFixed(1)));

    final scaledVits = <String, double>{};
    vitamins.forEach((k, v) => scaledVits[k] = double.parse((v * ratio).toStringAsFixed(1)));

    return copyWith(
      portion: '${newGrams.round()} g',
      portionGrams: newGrams,
      calories: (calories * ratio).round(),
      protein: double.parse((protein * ratio).toStringAsFixed(1)),
      carbs: double.parse((carbs * ratio).toStringAsFixed(1)),
      fat: double.parse((fat * ratio).toStringAsFixed(1)),
      fiber: double.parse((fiber * ratio).toStringAsFixed(1)),
      sugar: double.parse((sugar * ratio).toStringAsFixed(1)),
      sodium: double.parse((sodium * ratio).toStringAsFixed(1)),
      micronutrients: scaledMicros,
      vitamins: scaledVits,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'portion': portion,
      'portionGrams': portionGrams,
      if (cookingMethod != null) 'cookingMethod': cookingMethod,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
      'micronutrients': micronutrients,
      'vitamins': vitamins,
      'isAiDetected': isAiDetected,
      if (originalAiEstimate != null) 'originalAiEstimate': originalAiEstimate,
    };
  }

  factory DetectedFoodItem.fromMap(Map<String, dynamic> map) {
    Map<String, double> parsedMicros = {};
    if (map['micronutrients'] is Map) {
      (map['micronutrients'] as Map).forEach((k, v) {
        parsedMicros[k.toString()] = (v as num).toDouble();
      });
    }

    Map<String, double> parsedVitamins = {};
    if (map['vitamins'] is Map) {
      (map['vitamins'] as Map).forEach((k, v) {
        parsedVitamins[k.toString()] = (v as num).toDouble();
      });
    }

    return DetectedFoodItem(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      portion: map['portion']?.toString() ?? '1 serving',
      portionGrams: (map['portionGrams'] as num?)?.toDouble() ?? 100.0,
      cookingMethod: map['cookingMethod']?.toString(),
      calories: (map['calories'] as num?)?.toInt() ?? 0,
      protein: (map['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (map['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (map['fat'] as num?)?.toDouble() ?? 0.0,
      fiber: (map['fiber'] as num?)?.toDouble() ?? 0.0,
      sugar: (map['sugar'] as num?)?.toDouble() ?? 0.0,
      sodium: (map['sodium'] as num?)?.toDouble() ?? 0.0,
      micronutrients: parsedMicros,
      vitamins: parsedVitamins,
      isAiDetected: map['isAiDetected'] != false,
      originalAiEstimate: map['originalAiEstimate'] is Map
          ? Map<String, dynamic>.from(map['originalAiEstimate'] as Map)
          : null,
    );
  }
}

class FoodPost {
  final String id;
  final String userId;
  final MealType mealType;
  final String imageUrl;
  final String imagePath;
  final String title;
  final String description;
  final String notes;
  final DateTime createdAt;
  final DateTime mealDate;
  final FoodAnalysisStatus analysisStatus;
  final String analysisVersion;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium; // mg
  final double cholesterol; // mg
  final Map<String, double> micronutrients; // calcium, iron, magnesium, potassium, zinc, phosphorus, etc.
  final Map<String, double> vitamins; // vitaminA, vitaminC, vitaminD, vitaminE, vitaminK, bVitamins
  final List<DetectedFoodItem> detectedFoods;
  final Map<String, String> portionEstimates;
  final double aiConfidence; // 0.0 - 1.0
  final bool userVerified;
  final DateTime updatedAt;

  const FoodPost({
    required this.id,
    required this.userId,
    required this.mealType,
    required this.imageUrl,
    this.imagePath = '',
    required this.title,
    this.description = '',
    this.notes = '',
    required this.createdAt,
    required this.mealDate,
    this.analysisStatus = FoodAnalysisStatus.completed,
    this.analysisVersion = 'v1.0-gemini',
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    this.sugar = 0.0,
    this.sodium = 0.0,
    this.cholesterol = 0.0,
    this.micronutrients = const {},
    this.vitamins = const {},
    this.detectedFoods = const [],
    this.portionEstimates = const {},
    this.aiConfidence = 0.92,
    this.userVerified = false,
    required this.updatedAt,
  });

  /// Factory constructor to aggregate total nutrition values from a list of food items
  factory FoodPost.fromItems({
    required String id,
    required String userId,
    required MealType mealType,
    required String imageUrl,
    String imagePath = '',
    required String title,
    String description = '',
    String notes = '',
    DateTime? createdAt,
    DateTime? mealDate,
    FoodAnalysisStatus analysisStatus = FoodAnalysisStatus.completed,
    String analysisVersion = 'v1.0-gemini',
    required List<DetectedFoodItem> items,
    double aiConfidence = 0.92,
    bool userVerified = true,
  }) {
    final now = DateTime.now();
    int totalCals = 0;
    double totalP = 0.0;
    double totalC = 0.0;
    double totalF = 0.0;
    double totalFib = 0.0;
    double totalSug = 0.0;
    double totalSod = 0.0;
    final Map<String, double> aggregateMicros = {};
    final Map<String, double> aggregateVits = {};
    final Map<String, String> portionMap = {};

    for (final item in items) {
      totalCals += item.calories;
      totalP += item.protein;
      totalC += item.carbs;
      totalF += item.fat;
      totalFib += item.fiber;
      totalSug += item.sugar;
      totalSod += item.sodium;
      portionMap[item.name] = item.portion;

      item.micronutrients.forEach((k, v) {
        aggregateMicros[k] = (aggregateMicros[k] ?? 0.0) + v;
      });
      item.vitamins.forEach((k, v) {
        aggregateVits[k] = (aggregateVits[k] ?? 0.0) + v;
      });
    }

    return FoodPost(
      id: id,
      userId: userId,
      mealType: mealType,
      imageUrl: imageUrl,
      imagePath: imagePath,
      title: title,
      description: description,
      notes: notes,
      createdAt: createdAt ?? now,
      mealDate: mealDate ?? now,
      analysisStatus: analysisStatus,
      analysisVersion: analysisVersion,
      calories: totalCals,
      protein: double.parse(totalP.toStringAsFixed(1)),
      carbs: double.parse(totalC.toStringAsFixed(1)),
      fat: double.parse(totalF.toStringAsFixed(1)),
      fiber: double.parse(totalFib.toStringAsFixed(1)),
      sugar: double.parse(totalSug.toStringAsFixed(1)),
      sodium: double.parse(totalSod.toStringAsFixed(1)),
      micronutrients: aggregateMicros,
      vitamins: aggregateVits,
      detectedFoods: items,
      portionEstimates: portionMap,
      aiConfidence: aiConfidence,
      userVerified: userVerified,
      updatedAt: now,
    );
  }

  FoodPost copyWith({
    String? id,
    String? userId,
    MealType? mealType,
    String? imageUrl,
    String? imagePath,
    String? title,
    String? description,
    String? notes,
    DateTime? createdAt,
    DateTime? mealDate,
    FoodAnalysisStatus? analysisStatus,
    String? analysisVersion,
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? fiber,
    double? sugar,
    double? sodium,
    double? cholesterol,
    Map<String, double>? micronutrients,
    Map<String, double>? vitamins,
    List<DetectedFoodItem>? detectedFoods,
    Map<String, String>? portionEstimates,
    double? aiConfidence,
    bool? userVerified,
    DateTime? updatedAt,
  }) {
    return FoodPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mealType: mealType ?? this.mealType,
      imageUrl: imageUrl ?? this.imageUrl,
      imagePath: imagePath ?? this.imagePath,
      title: title ?? this.title,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      mealDate: mealDate ?? this.mealDate,
      analysisStatus: analysisStatus ?? this.analysisStatus,
      analysisVersion: analysisVersion ?? this.analysisVersion,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      sugar: sugar ?? this.sugar,
      sodium: sodium ?? this.sodium,
      cholesterol: cholesterol ?? this.cholesterol,
      micronutrients: micronutrients ?? this.micronutrients,
      vitamins: vitamins ?? this.vitamins,
      detectedFoods: detectedFoods ?? this.detectedFoods,
      portionEstimates: portionEstimates ?? this.portionEstimates,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      userVerified: userVerified ?? this.userVerified,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Re-aggregates nutrition after modifying a food item
  FoodPost updateItem(DetectedFoodItem updatedItem) {
    final updatedList = detectedFoods.map((it) => it.id == updatedItem.id ? updatedItem : it).toList();
    return FoodPost.fromItems(
      id: id,
      userId: userId,
      mealType: mealType,
      imageUrl: imageUrl,
      imagePath: imagePath,
      title: title,
      description: description,
      notes: notes,
      createdAt: createdAt,
      mealDate: mealDate,
      analysisStatus: analysisStatus,
      analysisVersion: analysisVersion,
      items: updatedList,
      aiConfidence: aiConfidence,
      userVerified: true,
    );
  }

  /// Removes an item and recalculates nutritional totals
  FoodPost removeItem(String itemId) {
    final updatedList = detectedFoods.where((it) => it.id != itemId).toList();
    return FoodPost.fromItems(
      id: id,
      userId: userId,
      mealType: mealType,
      imageUrl: imageUrl,
      imagePath: imagePath,
      title: title,
      description: description,
      notes: notes,
      createdAt: createdAt,
      mealDate: mealDate,
      analysisStatus: analysisStatus,
      analysisVersion: analysisVersion,
      items: updatedList,
      aiConfidence: aiConfidence,
      userVerified: true,
    );
  }

  /// Adds a new food item and recalculates nutritional totals
  FoodPost addItem(DetectedFoodItem newItem) {
    final updatedList = [...detectedFoods, newItem];
    return FoodPost.fromItems(
      id: id,
      userId: userId,
      mealType: mealType,
      imageUrl: imageUrl,
      imagePath: imagePath,
      title: title,
      description: description,
      notes: notes,
      createdAt: createdAt,
      mealDate: mealDate,
      analysisStatus: analysisStatus,
      analysisVersion: analysisVersion,
      items: updatedList,
      aiConfidence: aiConfidence,
      userVerified: true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'mealType': mealType.name,
      'imageUrl': imageUrl,
      'imagePath': imagePath,
      'title': title,
      'description': description,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'mealDate': mealDate.toIso8601String(),
      'analysisStatus': analysisStatus.name,
      'analysisVersion': analysisVersion,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
      'cholesterol': cholesterol,
      'micronutrients': micronutrients,
      'vitamins': vitamins,
      'detectedFoods': detectedFoods.map((e) => e.toMap()).toList(),
      'portionEstimates': portionEstimates,
      'aiConfidence': aiConfidence,
      'userVerified': userVerified,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestoreMap() => toMap();

  factory FoodPost.fromMap(Map<String, dynamic> map, {String? docId}) {
    List<DetectedFoodItem> items = [];
    if (map['detectedFoods'] is List) {
      items = (map['detectedFoods'] as List)
          .map((e) => DetectedFoodItem.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    Map<String, double> parsedMicros = {};
    if (map['micronutrients'] is Map) {
      (map['micronutrients'] as Map).forEach((k, v) {
        parsedMicros[k.toString()] = (v as num).toDouble();
      });
    }

    Map<String, double> parsedVitamins = {};
    if (map['vitamins'] is Map) {
      (map['vitamins'] as Map).forEach((k, v) {
        parsedVitamins[k.toString()] = (v as num).toDouble();
      });
    }

    Map<String, String> parsedPortions = {};
    if (map['portionEstimates'] is Map) {
      (map['portionEstimates'] as Map).forEach((k, v) {
        parsedPortions[k.toString()] = v.toString();
      });
    }

    return FoodPost(
      id: map['id']?.toString() ?? docId ?? '',
      userId: map['userId']?.toString() ?? '',
      mealType: MealType.fromString(map['mealType']?.toString()),
      imageUrl: map['imageUrl']?.toString() ?? '',
      imagePath: map['imagePath']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Meal',
      description: map['description']?.toString() ?? '',
      notes: map['notes']?.toString() ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      mealDate: map['mealDate'] != null
          ? DateTime.tryParse(map['mealDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      analysisStatus: FoodAnalysisStatus.fromString(map['analysisStatus']?.toString()),
      analysisVersion: map['analysisVersion']?.toString() ?? 'v1.0-gemini',
      calories: (map['calories'] as num?)?.toInt() ?? 0,
      protein: (map['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (map['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (map['fat'] as num?)?.toDouble() ?? 0.0,
      fiber: (map['fiber'] as num?)?.toDouble() ?? 0.0,
      sugar: (map['sugar'] as num?)?.toDouble() ?? 0.0,
      sodium: (map['sodium'] as num?)?.toDouble() ?? 0.0,
      cholesterol: (map['cholesterol'] as num?)?.toDouble() ?? 0.0,
      micronutrients: parsedMicros,
      vitamins: parsedVitamins,
      detectedFoods: items,
      portionEstimates: parsedPortions,
      aiConfidence: (map['aiConfidence'] as num?)?.toDouble() ?? 0.9,
      userVerified: map['userVerified'] == true,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
