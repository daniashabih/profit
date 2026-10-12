import 'package:flutter_test/flutter_test.dart';
import 'package:profit/core/enums/meal_type.dart';
import 'package:profit/models/food_post_model.dart';
import 'package:profit/models/daily_food_summary_model.dart';
import 'package:profit/models/trainer_food_feedback_model.dart';

void main() {
  group('MealType Enum Tests', () {
    test('MealType has all required meal slots including drink and other', () {
      expect(MealType.values, contains(MealType.breakfast));
      expect(MealType.values, contains(MealType.lunch));
      expect(MealType.values, contains(MealType.dinner));
      expect(MealType.values, contains(MealType.snack));
      expect(MealType.values, contains(MealType.drink));
      expect(MealType.values, contains(MealType.other));
    });

    test('MealType display names and emojis are present', () {
      expect(MealType.breakfast.displayName, 'Breakfast');
      expect(MealType.breakfast.emoji, '🌅');

      expect(MealType.lunch.displayName, 'Lunch');
      expect(MealType.lunch.emoji, '☀️');

      expect(MealType.dinner.displayName, 'Dinner');
      expect(MealType.dinner.emoji, '🌙');

      expect(MealType.snack.displayName, 'Snack');
      expect(MealType.snack.emoji, '🍎');

      expect(MealType.drink.displayName, 'Drink');
      expect(MealType.drink.emoji, '🥤');

      expect(MealType.other.displayName, 'Other');
      expect(MealType.other.emoji, '🍽️');
    });

    test('MealType.fromString parses valid strings and falls back gracefully', () {
      expect(MealType.fromString('breakfast'), MealType.breakfast);
      expect(MealType.fromString('Lunch'), MealType.lunch);
      expect(MealType.fromString('DINNER'), MealType.dinner);
      expect(MealType.fromString('snack'), MealType.snack);
      expect(MealType.fromString('drink'), MealType.drink);
      expect(MealType.fromString('other'), MealType.other);
      expect(MealType.fromString('unknown_meal'), MealType.other);
      expect(MealType.fromString(null), MealType.other);
    });
  });

  group('FoodPost & DetectedFoodItem Models', () {
    const sampleItem1 = DetectedFoodItem(
      id: 'item_1',
      name: 'Grilled Chicken Breast',
      portion: '150 g',
      portionGrams: 150.0,
      cookingMethod: 'Grilled',
      calories: 248,
      protein: 46.5,
      carbs: 0.0,
      fat: 5.4,
      fiber: 0.0,
      sugar: 0.0,
      sodium: 111.0,
      micronutrients: {'Potassium': 384.0, 'Magnesium': 43.5, 'Zinc': 1.5, 'Phosphorus': 342.0},
      vitamins: {'B vitamins': 30.0, 'Vitamin A': 1.0},
    );

    const sampleItem2 = DetectedFoodItem(
      id: 'item_2',
      name: 'Steamed Jasmine Rice',
      portion: '1 cup (158g)',
      portionGrams: 158.0,
      cookingMethod: 'Steamed',
      calories: 205,
      protein: 4.2,
      carbs: 45.0,
      fat: 0.4,
      fiber: 0.6,
      sugar: 0.1,
      sodium: 0.0,
      micronutrients: {'Magnesium': 19.0, 'Phosphorus': 68.0},
      vitamins: {'B vitamins': 15.0},
    );

    test('FoodPost.fromItems calculates aggregated macro sums accurately', () {
      final post = FoodPost.fromItems(
        id: 'post_101',
        userId: 'usr_test_1',
        mealType: MealType.lunch,
        imageUrl: 'https://profit.app/images/chicken_rice.jpg',
        title: 'Chicken Rice Lunch',
        notes: 'Post workout meal',
        items: [sampleItem1, sampleItem2],
      );

      expect(post.id, 'post_101');
      expect(post.userId, 'usr_test_1');
      expect(post.mealType, MealType.lunch);
      expect(post.detectedFoods.length, 2);
      expect(post.calories, closeTo(453, 1));
      expect(post.protein, closeTo(50.7, 0.2));
      expect(post.carbs, closeTo(45.0, 0.2));
      expect(post.fat, closeTo(5.8, 0.2));
      expect(post.fiber, closeTo(0.6, 0.2));
    });

    test('DetectedFoodItem.scaleToGrams proportionally scales macros and minerals', () {
      // Scale from 150g to 300g (double)
      final doubled = sampleItem1.scaleToGrams(300.0);

      expect(doubled.portionGrams, 300.0);
      expect(doubled.portion, '300 g');
      expect(doubled.calories, closeTo(496, 2));
      expect(doubled.protein, closeTo(93.0, 0.2));
      expect(doubled.fat, closeTo(10.8, 0.2));
      expect(doubled.micronutrients['Potassium'], closeTo(768.0, 0.2));
    });

    test('FoodPost.updateItem updates item and recalculates post totals', () {
      final post = FoodPost.fromItems(
        id: 'post_102',
        userId: 'usr_test_1',
        mealType: MealType.lunch,
        imageUrl: 'https://profit.app/images/test.jpg',
        title: 'Chicken Rice Lunch',
        items: [sampleItem1, sampleItem2],
      );

      final scaledItem1 = sampleItem1.scaleToGrams(300.0);
      final updatedPost = post.updateItem(scaledItem1);

      expect(updatedPost.detectedFoods.first.portionGrams, 300.0);
      expect(updatedPost.calories, closeTo(701, 2));
      expect(updatedPost.protein, closeTo(97.2, 0.5));
      expect(updatedPost.userVerified, isTrue);
    });

    test('FoodPost serialization toMap and fromMap works seamlessly', () {
      final post = FoodPost.fromItems(
        id: 'post_103',
        userId: 'usr_test_1',
        mealType: MealType.dinner,
        imageUrl: 'https://profit.app/images/dinner.jpg',
        title: 'Salmon Bowl',
        notes: 'High omega-3 dinner',
        items: [sampleItem1],
        analysisStatus: FoodAnalysisStatus.completed,
      );

      final map = post.toMap();
      final revived = FoodPost.fromMap(map, docId: 'post_103');

      expect(revived.id, post.id);
      expect(revived.userId, post.userId);
      expect(revived.mealType, MealType.dinner);
      expect(revived.title, 'Salmon Bowl');
      expect(revived.calories, closeTo(post.calories, 1));
      expect(revived.protein, closeTo(post.protein, 0.1));
      expect(revived.detectedFoods.length, 1);
      expect(revived.detectedFoods.first.name, 'Grilled Chicken Breast');
    });
  });

  group('DailyFoodSummary Calculations', () {
    final now = DateTime.now();

    final breakfastPost = FoodPost.fromItems(
      id: 'b1',
      userId: 'u1',
      mealType: MealType.breakfast,
      imageUrl: '',
      title: 'Eggs and Toast',
      mealDate: now,
      items: [
        const DetectedFoodItem(
          id: 'i1',
          name: 'Eggs',
          portion: '2 eggs',
          portionGrams: 100,
          calories: 144,
          protein: 12.6,
          carbs: 0.8,
          fat: 9.6,
          fiber: 0.0,
        ),
      ],
    );

    final lunchPost = FoodPost.fromItems(
      id: 'l1',
      userId: 'u1',
      mealType: MealType.lunch,
      imageUrl: '',
      title: 'Chicken and Rice',
      mealDate: now,
      items: [
        const DetectedFoodItem(
          id: 'i2',
          name: 'Chicken Breast',
          portion: '150g',
          portionGrams: 150,
          calories: 248,
          protein: 46.5,
          carbs: 0.0,
          fat: 5.4,
          fiber: 0.0,
        ),
      ],
    );

    test('DailyFoodSummary computes correct totals and remaining metrics', () {
      final summary = DailyFoodSummary.fromPosts(
        date: now,
        posts: [breakfastPost, lunchPost],
        targetCalories: 2000,
        targetProtein: 130.0,
        targetFiber: 28.0,
      );

      expect(summary.posts.length, 2);
      expect(summary.totalCalories, closeTo(392, 1));
      expect(summary.totalProtein, closeTo(59.1, 0.2));
      expect(summary.remainingCalories, closeTo(1608, 1));
      expect(summary.remainingProtein, closeTo(70.9, 0.2));
      expect(summary.calorieProgress, closeTo(0.196, 0.01));
      expect(summary.proteinProgress, closeTo(0.454, 0.01));
      expect(summary.postsByMealType[MealType.breakfast]?.length, 1);
      expect(summary.postsByMealType[MealType.lunch]?.length, 1);
      expect(summary.postsByMealType[MealType.dinner]?.length, 0);
    });
  });

  group('TrainerFoodFeedback Model', () {
    test('TrainerFoodFeedback serialization and validation', () {
      final feedback = TrainerFoodFeedback(
        id: 'fb_1',
        postId: 'post_101',
        clientUserId: 'client_001',
        trainerId: 'trainer_001',
        trainerName: 'Coach Ahmed',
        trainerAvatarUrl: 'https://profit.app/avatar.jpg',
        comment: 'Great lean protein choice! Add some steamed broccoli to hit your daily fiber target.',
        createdAt: DateTime.now(),
      );

      final map = feedback.toMap();
      expect(map['trainerName'], 'Coach Ahmed');
      expect(map['comment'], contains('Great lean protein choice'));

      final revived = TrainerFoodFeedback.fromMap(map, docId: 'fb_1');
      expect(revived.id, 'fb_1');
      expect(revived.trainerId, 'trainer_001');
      expect(revived.clientUserId, 'client_001');
      expect(revived.comment, contains('Great lean protein choice'));
    });
  });
}
