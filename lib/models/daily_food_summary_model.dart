import '../core/enums/meal_type.dart';
import 'food_post_model.dart';

/// Aggregated daily food journal summary
class DailyFoodSummary {
  final DateTime date;
  final String dateString; // YYYY-MM-DD
  final int totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double totalFiber;
  final double totalSugar;
  final double totalSodium;
  final int targetCalories;
  final double targetProtein;
  final double targetCarbs;
  final double targetFat;
  final double targetFiber;
  final List<FoodPost> posts;
  final Map<MealType, List<FoodPost>> postsByMealType;

  const DailyFoodSummary({
    required this.date,
    required this.dateString,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.totalFiber,
    this.totalSugar = 0.0,
    this.totalSodium = 0.0,
    required this.targetCalories,
    required this.targetProtein,
    this.targetCarbs = 200.0,
    this.targetFat = 60.0,
    this.targetFiber = 28.0,
    this.posts = const [],
    this.postsByMealType = const {},
  });

  int get remainingCalories => (targetCalories - totalCalories).clamp(0, 10000);
  double get remainingProtein => double.parse(((targetProtein - totalProtein).clamp(0.0, 500.0)).toStringAsFixed(1));

  double get calorieProgress => targetCalories > 0 ? (totalCalories / targetCalories).clamp(0.0, 1.5) : 0.0;
  double get proteinProgress => targetProtein > 0 ? (totalProtein / targetProtein).clamp(0.0, 1.5) : 0.0;
  double get carbsProgress => targetCarbs > 0 ? (totalCarbs / targetCarbs).clamp(0.0, 1.5) : 0.0;
  double get fatProgress => targetFat > 0 ? (totalFat / targetFat).clamp(0.0, 1.5) : 0.0;
  double get fiberProgress => targetFiber > 0 ? (totalFiber / targetFiber).clamp(0.0, 1.5) : 0.0;

  factory DailyFoodSummary.fromPosts({
    required DateTime date,
    required List<FoodPost> posts,
    required int targetCalories,
    required double targetProtein,
    double targetCarbs = 200.0,
    double targetFat = 60.0,
    double targetFiber = 28.0,
  }) {
    final dateStr = date.toIso8601String().split('T').first;
    int cals = 0;
    double protein = 0.0;
    double carbs = 0.0;
    double fat = 0.0;
    double fiber = 0.0;
    double sugar = 0.0;
    double sodium = 0.0;
    final Map<MealType, List<FoodPost>> grouped = {
      for (final type in MealType.values) type: [],
    };

    for (final post in posts) {
      cals += post.calories;
      protein += post.protein;
      carbs += post.carbs;
      fat += post.fat;
      fiber += post.fiber;
      sugar += post.sugar;
      sodium += post.sodium;
      grouped[post.mealType]?.add(post);
    }

    return DailyFoodSummary(
      date: date,
      dateString: dateStr,
      totalCalories: cals,
      totalProtein: double.parse(protein.toStringAsFixed(1)),
      totalCarbs: double.parse(carbs.toStringAsFixed(1)),
      totalFat: double.parse(fat.toStringAsFixed(1)),
      totalFiber: double.parse(fiber.toStringAsFixed(1)),
      totalSugar: double.parse(sugar.toStringAsFixed(1)),
      totalSodium: double.parse(sodium.toStringAsFixed(1)),
      targetCalories: targetCalories,
      targetProtein: targetProtein,
      targetCarbs: targetCarbs,
      targetFat: targetFat,
      targetFiber: targetFiber,
      posts: posts,
      postsByMealType: grouped,
    );
  }
}
