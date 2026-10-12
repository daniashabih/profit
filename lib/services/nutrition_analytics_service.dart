import 'dart:math';
import '../core/enums/meal_type.dart';
import '../models/food_post_model.dart';
import '../models/daily_food_summary_model.dart';
import '../models/nutrition_insight_model.dart';
import '../models/user_model.dart';

/// Nutrition analytics engine calculating dynamic daily totals,
/// weekly trends, and monthly cycle reports from real stored food posts.
class NutritionAnalyticsService {
  /// Computes daily food summary for a given day
  static DailyFoodSummary calculateDailySummary({
    required DateTime date,
    required List<FoodPost> postsForDate,
    required UserModel? user,
  }) {
    final proteinTarget = user?.proteinRecommendation.targetGrams ?? 130.0;
    // Standard recommended macro calorie distribution:
    final caloriesTarget = (user?.currentWeightKg != null && user!.currentWeightKg > 0)
        ? (user.currentWeightKg * 28).round()
        : 2000;

    return DailyFoodSummary.fromPosts(
      date: date,
      posts: postsForDate,
      targetCalories: caloriesTarget,
      targetProtein: proteinTarget,
      targetCarbs: 220.0,
      targetFat: 60.0,
      targetFiber: 28.0,
    );
  }

  /// Calculates weekly nutrition trends and dynamic data-driven insights
  static WeeklyNutritionInsights calculateWeeklyInsights({
    required DateTime currentDay,
    required List<FoodPost> recentPosts,
    required UserModel? user,
  }) {
    final end = DateTime(currentDay.year, currentDay.month, currentDay.day, 23, 59, 59);
    final start = end.subtract(const Duration(days: 6));

    final weekPosts = recentPosts.where((p) {
      return p.mealDate.isAfter(start.subtract(const Duration(seconds: 1))) &&
          p.mealDate.isBefore(end.add(const Duration(seconds: 1)));
    }).toList();

    // Group by unique days logged
    final Map<String, List<FoodPost>> daysMap = {};
    for (int i = 0; i < 7; i++) {
      final d = start.add(Duration(days: i));
      final dKey = d.toIso8601String().split('T').first;
      daysMap[dKey] = [];
    }

    for (final post in weekPosts) {
      final key = post.mealDate.toIso8601String().split('T').first;
      daysMap[key]?.add(post);
    }

    double sumCals = 0;
    double sumProtein = 0;
    double sumCarbs = 0;
    double sumFat = 0;
    double sumFiber = 0;

    double breakfastProteinSum = 0;
    int breakfastCount = 0;
    double lunchProteinSum = 0;
    int lunchCount = 0;

    for (final dayEntries in daysMap.values) {
      for (final p in dayEntries) {
        sumCals += p.calories;
        sumProtein += p.protein;
        sumCarbs += p.carbs;
        sumFat += p.fat;
        sumFiber += p.fiber;

        if (p.mealType == MealType.breakfast) {
          breakfastProteinSum += p.protein;
          breakfastCount++;
        } else if (p.mealType == MealType.lunch) {
          lunchProteinSum += p.protein;
          lunchCount++;
        }
      }
    }

    final double avgCals = sumCals / 7.0;
    final double avgProtein = sumProtein / 7.0;
    final double avgCarbs = sumCarbs / 7.0;
    final double avgFat = sumFat / 7.0;
    final double avgFiber = sumFiber / 7.0;

    final targetProtein = user?.proteinRecommendation.targetGrams ?? 130.0;
    final targetCals = (user?.currentWeightKg != null && user!.currentWeightKg > 0)
        ? (user.currentWeightKg * 28).toDouble()
        : 2000.0;
    const targetFiber = 28.0;

    final proteinAchieve = targetProtein > 0 ? (avgProtein / targetProtein).clamp(0.0, 1.0) : 0.0;
    final fiberAchieve = targetFiber > 0 ? (avgFiber / targetFiber).clamp(0.0, 1.0) : 0.0;
    final calsAchieve = targetCals > 0 ? (avgCals / targetCals).clamp(0.0, 1.0) : 0.0;

    // Build dynamic insights based on user's actual stored meals
    final List<String> insights = [];

    if (avgProtein < targetProtein * 0.85) {
      insights.add('Your average protein intake (${avgProtein.round()}g/day) is below your current target of ${targetProtein.round()}g.');
    } else {
      insights.add('Great consistency! Your average protein intake (${avgProtein.round()}g/day) meets your target.');
    }

    if (avgFiber >= 25.0) {
      insights.add('Excellent gut health: You achieved a higher-fiber intake this week with ${avgFiber.round()}g daily average.');
    } else {
      insights.add('Add more vegetables and whole grains to raise daily fiber closer to the 28g goal.');
    }

    if (breakfastCount > 0 && lunchCount > 0) {
      final avgB = breakfastProteinSum / breakfastCount;
      final avgL = lunchProteinSum / lunchCount;
      if (avgB < avgL * 0.75) {
        insights.add('Your breakfast protein (${avgB.round()}g) is consistently lower than your lunch protein (${avgL.round()}g). Consider adding eggs or Greek yogurt.');
      }
    }

    if (weekPosts.length >= 14) {
      insights.add('Outstanding meal tracking habit! Logging meals consistently improves body composition outcomes.');
    } else {
      insights.add('Try logging every meal consistently to increase data accuracy and unlock better recommendations.');
    }

    return WeeklyNutritionInsights(
      weekStartDate: start,
      weekEndDate: end,
      averageDailyCalories: double.parse(avgCals.toStringAsFixed(0)),
      averageDailyProtein: double.parse(avgProtein.toStringAsFixed(1)),
      averageDailyCarbs: double.parse(avgCarbs.toStringAsFixed(1)),
      averageDailyFat: double.parse(avgFat.toStringAsFixed(1)),
      averageDailyFiber: double.parse(avgFiber.toStringAsFixed(1)),
      proteinTargetAchievement: double.parse(proteinAchieve.toStringAsFixed(2)),
      fiberTargetAchievement: double.parse(fiberAchieve.toStringAsFixed(2)),
      caloriesTargetAchievement: double.parse(calsAchieve.toStringAsFixed(2)),
      insights: insights,
    );
  }

  /// Calculates monthly nutrition analysis integrating with the monthly fitness cycle
  static MonthlyNutritionReport calculateMonthlyReport({
    required String monthId, // e.g. 2026-10
    required String monthName,
    required int year,
    required List<FoodPost> monthlyPosts,
    required UserModel? user,
    List<String> completedWorkoutDates = const [],
  }) {
    // Days in month calculation
    final parts = monthId.split('-');
    final m = int.tryParse(parts.length > 1 ? parts[1] : '10') ?? 10;
    final y = int.tryParse(parts.first) ?? year;
    final daysInMonth = DateTime(y, m + 1, 0).day;

    final Map<String, List<FoodPost>> daysMap = {};
    for (int d = 1; d <= daysInMonth; d++) {
      final key = '$y-${m.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';
      daysMap[key] = [];
    }

    for (final post in monthlyPosts) {
      final key = post.mealDate.toIso8601String().split('T').first;
      daysMap[key]?.add(post);
    }

    int daysWithLogs = 0;
    int breakfastDays = 0;
    int lunchDays = 0;
    int dinnerDays = 0;

    double totalCals = 0;
    double totalProtein = 0;
    double totalFiber = 0;
    double totalFat = 0;
    double totalCarbs = 0;

    double workoutDayCals = 0;
    double workoutDayProtein = 0;
    int workoutDaysCount = 0;

    double restDayCals = 0;
    double restDayProtein = 0;
    int restDaysCount = 0;

    daysMap.forEach((dateKey, posts) {
      if (posts.isNotEmpty) {
        daysWithLogs++;
        double dCals = 0;
        double dProt = 0;

        for (final p in posts) {
          totalCals += p.calories;
          totalProtein += p.protein;
          totalFiber += p.fiber;
          totalFat += p.fat;
          totalCarbs += p.carbs;
          dCals += p.calories;
          dProt += p.protein;

          if (p.mealType == MealType.breakfast) breakfastDays++;
          if (p.mealType == MealType.lunch) lunchDays++;
          if (p.mealType == MealType.dinner) dinnerDays++;
        }

        if (completedWorkoutDates.contains(dateKey)) {
          workoutDayCals += dCals;
          workoutDayProtein += dProt;
          workoutDaysCount++;
        } else {
          restDayCals += dCals;
          restDayProtein += dProt;
          restDaysCount++;
        }
      }
    });

    final effectiveLoggedDays = max(daysWithLogs, 1);
    final avgDailyCals = totalCals / effectiveLoggedDays;
    final avgProtein = totalProtein / effectiveLoggedDays;
    final avgFiber = totalFiber / effectiveLoggedDays;
    final avgFat = totalFat / effectiveLoggedDays;
    final avgCarbs = totalCarbs / effectiveLoggedDays;

    final targetProtein = user?.proteinRecommendation.targetGrams ?? 130.0;
    final proteinAchievementPercent = targetProtein > 0
        ? ((avgProtein / targetProtein) * 100).clamp(0.0, 100.0)
        : 85.0;

    final mealLoggingConsistency = ((daysWithLogs / daysInMonth) * 100).clamp(0.0, 100.0);
    final bConsistency = ((breakfastDays / daysInMonth) * 100).clamp(0.0, 100.0);
    final lConsistency = ((lunchDays / daysInMonth) * 100).clamp(0.0, 100.0);
    final dConsistency = ((dinnerDays / daysInMonth) * 100).clamp(0.0, 100.0);

    final recommendations = <String>[];
    if (proteinAchievementPercent >= 80.0) {
      recommendations.add('Protein adherence was strong at ${proteinAchievementPercent.round()}%. Maintain this target for the upcoming monthly fitness cycle.');
    } else {
      recommendations.add('Increase daily protein intake closer to ${targetProtein.round()}g to accelerate muscle recovery.');
    }

    if (mealLoggingConsistency >= 70.0) {
      recommendations.add('High meal tracking consistency (${mealLoggingConsistency.round()}%) provided clear nutritional clarity.');
    } else {
      recommendations.add('Log meals more consistently during the next monthly cycle to ensure accurate progressive adjustments.');
    }

    return MonthlyNutritionReport(
      monthId: monthId,
      monthName: monthName,
      year: year,
      averageDailyCalories: double.parse(avgDailyCals.toStringAsFixed(0)),
      averageProtein: double.parse(avgProtein.toStringAsFixed(1)),
      averageFiber: double.parse(avgFiber.toStringAsFixed(1)),
      averageFat: double.parse(avgFat.toStringAsFixed(1)),
      averageCarbs: double.parse(avgCarbs.toStringAsFixed(1)),
      proteinTargetAchievement: double.parse(proteinAchievementPercent.toStringAsFixed(1)),
      mealLoggingConsistency: double.parse(mealLoggingConsistency.toStringAsFixed(1)),
      breakfastConsistency: double.parse(bConsistency.toStringAsFixed(1)),
      lunchConsistency: double.parse(lConsistency.toStringAsFixed(1)),
      dinnerConsistency: double.parse(dConsistency.toStringAsFixed(1)),
      workoutDayNutrition: {
        'calories': workoutDaysCount > 0 ? (workoutDayCals / workoutDaysCount) : avgDailyCals,
        'protein': workoutDaysCount > 0 ? (workoutDayProtein / workoutDaysCount) : avgProtein,
      },
      restDayNutrition: {
        'calories': restDaysCount > 0 ? (restDayCals / restDaysCount) : avgDailyCals,
        'protein': restDaysCount > 0 ? (restDayProtein / restDaysCount) : avgProtein,
      },
      recommendations: recommendations,
    );
  }
}
