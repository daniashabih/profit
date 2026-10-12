/// Weekly nutrition insights derived dynamically from accumulated food posts
class WeeklyNutritionInsights {
  final DateTime weekStartDate;
  final DateTime weekEndDate;
  final double averageDailyCalories;
  final double averageDailyProtein;
  final double averageDailyCarbs;
  final double averageDailyFat;
  final double averageDailyFiber;
  final double proteinTargetAchievement; // 0.0 to 1.0 (e.g. 0.82 = 82%)
  final double fiberTargetAchievement; // 0.0 to 1.0 (e.g. 0.71 = 71%)
  final double caloriesTargetAchievement; // 0.0 to 1.0 (e.g. 0.89 = 89%)
  final List<String> insights;

  const WeeklyNutritionInsights({
    required this.weekStartDate,
    required this.weekEndDate,
    required this.averageDailyCalories,
    required this.averageDailyProtein,
    required this.averageDailyCarbs,
    required this.averageDailyFat,
    required this.averageDailyFiber,
    required this.proteinTargetAchievement,
    required this.fiberTargetAchievement,
    required this.caloriesTargetAchievement,
    required this.insights,
  });
}

/// Monthly comprehensive nutrition report integrated with the Monthly Fitness Cycle
class MonthlyNutritionReport {
  final String monthId; // YYYY-MM
  final String monthName; // e.g. October
  final int year;
  final double averageDailyCalories;
  final double averageProtein;
  final double averageFiber;
  final double averageFat;
  final double averageCarbs;
  final double proteinTargetAchievement; // percentage (e.g. 86.0%)
  final double mealLoggingConsistency; // percentage (e.g. 78.0%)
  final double breakfastConsistency;
  final double lunchConsistency;
  final double dinnerConsistency;
  final Map<String, double> workoutDayNutrition; // 'calories', 'protein', etc.
  final Map<String, double> restDayNutrition;
  final List<String> recommendations;

  const MonthlyNutritionReport({
    required this.monthId,
    required this.monthName,
    required this.year,
    required this.averageDailyCalories,
    required this.averageProtein,
    required this.averageFiber,
    required this.averageFat,
    required this.averageCarbs,
    required this.proteinTargetAchievement,
    required this.mealLoggingConsistency,
    this.breakfastConsistency = 0.0,
    this.lunchConsistency = 0.0,
    this.dinnerConsistency = 0.0,
    this.workoutDayNutrition = const {},
    this.restDayNutrition = const {},
    this.recommendations = const [],
  });

  double get proteinTargetAchievementRate => proteinTargetAchievement;
  double get mealLoggingConsistencyRate => mealLoggingConsistency;
  int get daysLogged => averageDailyCalories > 0 ? 1 : 0;

  Map<String, dynamic> toMap() {
    return {
      'monthId': monthId,
      'monthName': monthName,
      'year': year,
      'averageDailyCalories': averageDailyCalories,
      'averageProtein': averageProtein,
      'averageFiber': averageFiber,
      'averageFat': averageFat,
      'averageCarbs': averageCarbs,
      'proteinTargetAchievement': proteinTargetAchievement,
      'mealLoggingConsistency': mealLoggingConsistency,
      'breakfastConsistency': breakfastConsistency,
      'lunchConsistency': lunchConsistency,
      'dinnerConsistency': dinnerConsistency,
      'workoutDayNutrition': workoutDayNutrition,
      'restDayNutrition': restDayNutrition,
      'recommendations': recommendations,
    };
  }

  factory MonthlyNutritionReport.fromMap(Map<String, dynamic> map) {
    return MonthlyNutritionReport(
      monthId: map['monthId']?.toString() ?? '',
      monthName: map['monthName']?.toString() ?? '',
      year: (map['year'] as num?)?.toInt() ?? DateTime.now().year,
      averageDailyCalories: (map['averageDailyCalories'] as num?)?.toDouble() ?? 0.0,
      averageProtein: (map['averageProtein'] as num?)?.toDouble() ?? 0.0,
      averageFiber: (map['averageFiber'] as num?)?.toDouble() ?? 0.0,
      averageFat: (map['averageFat'] as num?)?.toDouble() ?? 0.0,
      averageCarbs: (map['averageCarbs'] as num?)?.toDouble() ?? 0.0,
      proteinTargetAchievement: (map['proteinTargetAchievement'] as num?)?.toDouble() ?? 0.0,
      mealLoggingConsistency: (map['mealLoggingConsistency'] as num?)?.toDouble() ?? 0.0,
      breakfastConsistency: (map['breakfastConsistency'] as num?)?.toDouble() ?? 0.0,
      lunchConsistency: (map['lunchConsistency'] as num?)?.toDouble() ?? 0.0,
      dinnerConsistency: (map['dinnerConsistency'] as num?)?.toDouble() ?? 0.0,
      workoutDayNutrition: map['workoutDayNutrition'] is Map
          ? Map<String, double>.from(
              (map['workoutDayNutrition'] as Map).map((k, v) => MapEntry(k.toString(), (v as num).toDouble())))
          : const {},
      restDayNutrition: map['restDayNutrition'] is Map
          ? Map<String, double>.from(
              (map['restDayNutrition'] as Map).map((k, v) => MapEntry(k.toString(), (v as num).toDouble())))
          : const {},
      recommendations: (map['recommendations'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }
}
