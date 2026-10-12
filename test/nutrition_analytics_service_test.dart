import 'package:flutter_test/flutter_test.dart';
import 'package:profit/core/enums/meal_type.dart';
import 'package:profit/core/enums/user_role.dart';
import 'package:profit/models/food_post_model.dart';
import 'package:profit/models/user_model.dart';
import 'package:profit/services/nutrition_analytics_service.dart';

void main() {
  group('NutritionAnalyticsService Tests', () {
    final testUser = UserModel(
      id: 'test_user_1',
      name: 'Dania',
      email: 'dania@profit.app',
      avatarUrl: '',
      role: UserRole.selfTrainer,
      createdAt: DateTime(2026, 1, 1),
      fitnessLevel: 'Intermediate',
      goal: 'Muscle Gain',
      activityLevel: 'moderately_active',
      currentWeightKg: 69.0,
      startWeightKg: 72.0,
      targetWeightKg: 55.0,
      heightCm: 165.0,
      streakDays: 5,
      totalWorkouts: 42,
      totalTrainingMinutes: 1800,
      totalVolumeKg: 12000,
      totalCaloriesBurned: 15000,
      membershipTier: 'pro',
      membershipDaysRemaining: 30,
      membershipExpiryDate: DateTime(2026, 12, 31),
      fitnessSetupCompleted: true,
      trainingDaysPerWeek: 4,
    );

    final now = DateTime.now();

    final breakfastPost = FoodPost.fromItems(
      id: 'p1',
      userId: 'test_user_1',
      mealType: MealType.breakfast,
      imageUrl: '',
      title: 'Eggs & Oatmeal',
      mealDate: now,
      items: [
        const DetectedFoodItem(
          id: 'i1',
          name: 'Poached Eggs',
          portion: '2 eggs',
          portionGrams: 100,
          calories: 144,
          protein: 13.0,
          carbs: 1.0,
          fat: 10.0,
          fiber: 0.0,
        ),
      ],
    );

    final lunchPost = FoodPost.fromItems(
      id: 'p2',
      userId: 'test_user_1',
      mealType: MealType.lunch,
      imageUrl: '',
      title: 'Chicken & Rice',
      mealDate: now,
      items: [
        const DetectedFoodItem(
          id: 'i2',
          name: 'Chicken Breast',
          portion: '200g',
          portionGrams: 200,
          calories: 330,
          protein: 62.0,
          carbs: 0.0,
          fat: 7.2,
          fiber: 0.0,
        ),
      ],
    );

    test('calculateDailySummary aggregates today posts against user fitness target', () {
      final summary = NutritionAnalyticsService.calculateDailySummary(
        date: now,
        postsForDate: [breakfastPost, lunchPost],
        user: testUser,
      );

      expect(summary.totalCalories, 474);
      expect(summary.totalProtein, closeTo(75.0, 0.1));
      expect(summary.targetCalories, greaterThan(1500));
      expect(summary.targetProtein, greaterThan(80.0));
      expect(summary.remainingProtein, greaterThan(0.0));
    });

    test('calculateWeeklyInsights produces averages and real data insights', () {
      final posts = [
        breakfastPost,
        lunchPost,
        FoodPost.fromItems(
          id: 'p3',
          userId: 'test_user_1',
          mealType: MealType.dinner,
          imageUrl: '',
          title: 'Salmon Salad',
          mealDate: now.subtract(const Duration(days: 1)),
          items: [
            const DetectedFoodItem(
              id: 'i3',
              name: 'Salmon',
              portion: '150g',
              portionGrams: 150,
              calories: 310,
              protein: 38.0,
              carbs: 0.0,
              fat: 17.0,
              fiber: 0.0,
            ),
          ],
        ),
      ];

      final insights = NutritionAnalyticsService.calculateWeeklyInsights(
        currentDay: now,
        recentPosts: posts,
        user: testUser,
      );

      expect(insights.averageDailyCalories, greaterThan(0));
      expect(insights.averageDailyProtein, greaterThan(0));
      expect(insights.insights.isNotEmpty, isTrue);
    });

    test('calculateMonthlyReport produces monthly consistency and target rates', () {
      final posts = [
        breakfastPost,
        lunchPost,
        FoodPost.fromItems(
          id: 'p4',
          userId: 'test_user_1',
          mealType: MealType.dinner,
          imageUrl: '',
          title: 'Tofu Stirfry',
          mealDate: DateTime(2026, 10, 5),
          items: [
            const DetectedFoodItem(
              id: 'i4',
              name: 'Tofu',
              portion: '200g',
              portionGrams: 200,
              calories: 250,
              protein: 24.0,
              carbs: 6.0,
              fat: 14.0,
              fiber: 4.0,
            ),
          ],
        ),
      ];

      final report = NutritionAnalyticsService.calculateMonthlyReport(
        monthId: '2026-10',
        monthName: 'October',
        year: 2026,
        monthlyPosts: posts,
        user: testUser,
        completedWorkoutDates: ['2026-10-05'],
      );

      expect(report.monthName, 'October');
      expect(report.year, 2026);
      expect(report.proteinTargetAchievementRate, inInclusiveRange(0.0, 100.0));
      expect(report.mealLoggingConsistencyRate, inInclusiveRange(0.0, 100.0));
      expect(report.recommendations.isNotEmpty, isTrue);
    });
  });
}
