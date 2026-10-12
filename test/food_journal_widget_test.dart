import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:profit/core/enums/meal_type.dart';
import 'package:profit/core/enums/user_role.dart';
import 'package:profit/models/food_post_model.dart';
import 'package:profit/models/user_model.dart';
import 'package:profit/providers/auth_provider.dart';
import 'package:profit/providers/food_journal_provider.dart';
import 'package:profit/providers/progress_provider.dart';
import 'package:profit/providers/role_provider.dart';
import 'package:profit/screens/profile/profile_screen.dart';
import 'package:profit/screens/nutrition/add_food_post_screen.dart';
import 'package:profit/screens/nutrition/food_detection_result_screen.dart';
import 'package:profit/screens/nutrition/meal_nutrition_detail_screen.dart';

void main() {
  final sampleUser = UserModel(
    id: 'usr_dania_1',
    name: 'Dania',
    email: 'dania@profit.app',
    avatarUrl: '',
    role: UserRole.selfTrainer,
    createdAt: DateTime(2026, 1, 1),
    fitnessLevel: 'Advanced',
    goal: 'Fat Loss',
    activityLevel: 'moderately_active',
    currentWeightKg: 69.0,
    startWeightKg: 75.0,
    targetWeightKg: 55.0,
    heightCm: 165.0,
    streakDays: 14,
    totalWorkouts: 86,
    totalTrainingMinutes: 3200,
    totalVolumeKg: 24000,
    totalCaloriesBurned: 28000,
    membershipTier: 'pro',
    membershipDaysRemaining: 20,
    membershipExpiryDate: DateTime(2026, 11, 1),
    fitnessSetupCompleted: true,
    trainingDaysPerWeek: 4,
  );

  const sampleFoodItem = DetectedFoodItem(
    id: 'item_c1',
    name: '🍗 Grilled Chicken',
    portion: '150 g',
    portionGrams: 150.0,
    cookingMethod: 'Grilled',
    calories: 247,
    protein: 46.5,
    carbs: 0.0,
    fat: 5.4,
    fiber: 0.0,
    micronutrients: {'Potassium': 384.0, 'Magnesium': 43.5, 'Zinc': 1.5, 'Sodium': 110.0},
    vitamins: {'Vitamin A': 1.0, 'Vitamin C': 0.0, 'B vitamins': 30.0},
  );

  final samplePost = FoodPost.fromItems(
    id: 'post_sample_1',
    userId: 'usr_dania_1',
    mealType: MealType.lunch,
    imageUrl: '',
    title: 'Chicken Rice Lunch',
    notes: 'Post workout recovery meal',
    items: [sampleFoodItem],
  );

  Widget createTestWidget(Widget child, {FoodJournalProvider? foodJournalProv}) {
    final roleProv = RoleProvider()..setRole(UserRole.selfTrainer);
    final progressProv = ProgressProvider();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => MockAuthProvider(sampleUser),
        ),
        ChangeNotifierProvider<RoleProvider>.value(value: roleProv),
        ChangeNotifierProvider<ProgressProvider>.value(value: progressProv),
        if (foodJournalProv != null)
          ChangeNotifierProvider<FoodJournalProvider>.value(value: foodJournalProv),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('ProfileScreen Social-Style UI Widget Tests', () {
    testWidgets('Renders Profile header, stats row, action buttons, and food grid', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final foodProv = FoodJournalProvider();

      await tester.pumpWidget(createTestWidget(
        const ProfileScreen(),
        foodJournalProv: foodProv,
      ));
      await tester.pumpAndSettle();

      // Top section
      expect(find.text('Dania'), findsOneWidget);
      expect(find.text('@dania'), findsOneWidget);
      expect(find.textContaining('Fat Loss'), findsOneWidget);

      // Weight, Target, BMI
      expect(find.text('Weight'), findsOneWidget);
      expect(find.text('Target'), findsOneWidget);
      expect(find.text('BMI'), findsOneWidget);
      expect(find.text('69 kg'), findsOneWidget);
      expect(find.text('55 kg'), findsOneWidget);

      // Stats: Posts | Workouts | Progress
      expect(find.text('Posts'), findsOneWidget);
      expect(find.text('Workouts'), findsOneWidget);
      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('86'), findsOneWidget); // totalWorkouts

      // Buttons: [ Edit Profile ] and [ + Add Food ]
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('+ Add Food'), findsOneWidget);

      // Segmented Tabs
      expect(find.text('Food Posts'), findsOneWidget);
      expect(find.text('Nutrition Hub'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);

      // Food grid renders items
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('Tapping Nutrition Hub tab shows Daily, Insights, and Monthly cards', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final foodProv = FoodJournalProvider();

      await tester.pumpWidget(createTestWidget(
        const ProfileScreen(),
        foodJournalProv: foodProv,
      ));
      await tester.pumpAndSettle();

      // Switch to Nutrition Hub
      await tester.tap(find.text('Nutrition Hub'));
      await tester.pumpAndSettle();

      expect(find.text('Daily Nutrition Dashboard'), findsOneWidget);
      expect(find.text('Nutrition Insights'), findsOneWidget);
      expect(find.text('Monthly Nutrition Analysis'), findsOneWidget);
      expect(find.text('Body Metrics & Nutrition Estimates'), findsOneWidget);
    });
  });

  group('AddFoodPostScreen Widget Tests', () {
    testWidgets('Renders meal type selector, inputs, and analyze food action', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final foodProv = FoodJournalProvider();

      await tester.pumpWidget(createTestWidget(
        const AddFoodPostScreen(),
        foodJournalProv: foodProv,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Add Food Post'), findsOneWidget);
      expect(find.text('🌅  Breakfast'), findsOneWidget);
      expect(find.text('☀️  Lunch'), findsOneWidget);
      expect(find.text('🌙  Dinner'), findsOneWidget);
      expect(find.text('🍎  Snack'), findsOneWidget);
      expect(find.text('🥤  Drink'), findsOneWidget);
      expect(find.text('🍽️  Other'), findsOneWidget);
      expect(find.text('Take Photo or Upload Food Image'), findsOneWidget);
      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text('Analyze Food'), findsOneWidget);
    });
  });

  group('FoodDetectionResultScreen Widget Tests', () {
    testWidgets('Renders detected foods, portions, macro cards, and edit actions', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final foodProv = FoodJournalProvider();

      await tester.pumpWidget(createTestWidget(
        FoodDetectionResultScreen(
          postId: 'post_sample_1',
          mealType: MealType.lunch,
          mealTitle: 'Chicken Rice Lunch',
          notes: 'Post workout recovery meal',
          mealDateTime: DateTime.now(),
          initialFoods: const [sampleFoodItem],
          confidence: 0.94,
        ),
        foodJournalProv: foodProv,
      ));
      await tester.pumpAndSettle();

      // Detection confirmation
      expect(find.textContaining('Grilled Chicken'), findsWidgets);
      expect(find.textContaining('150 g'), findsWidgets);
      expect(find.text('Edit Portion'), findsOneWidget);
      expect(find.text('Edit Food'), findsOneWidget);
      expect(find.text('Add Food'), findsOneWidget);

      // Disclaimers
      expect(find.text('AI estimated nutrition'), findsOneWidget);
      expect(find.textContaining('Values are estimates'), findsOneWidget);

      // Confirm & Save
      expect(find.text('Confirm & View Nutrition'), findsOneWidget);
    });
  });

  group('MealNutritionDetailScreen Widget Tests', () {
    testWidgets('Renders full nutritional dashboard with calories, macros, and vitamins', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final foodProv = FoodJournalProvider();

      await tester.pumpWidget(createTestWidget(
        MealNutritionDetailScreen(post: samplePost),
        foodJournalProv: foodProv,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Chicken Rice Lunch'), findsNWidgets(2));
      expect(find.textContaining('247'), findsWidgets); // Calories
      expect(find.text('Protein'), findsWidgets);
      expect(find.text('Carbs'), findsWidgets);
      expect(find.text('Fat'), findsWidgets);
      expect(find.text('Fiber'), findsWidgets);

      // Micronutrients
      expect(find.text('Important Minerals'), findsOneWidget);
      expect(find.text('Important Vitamins'), findsOneWidget);

      // Trainer feedback section
      expect(find.text('Trainer Feedback'), findsOneWidget);
    });
  });
}

class MockAuthProvider extends ChangeNotifier implements AuthProvider {
  UserModel? _user;

  MockAuthProvider(this._user);

  @override
  UserModel? get user => _user;

  @override
  bool get isAuthenticated => _user != null;

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => null;

  @override
  Future<bool> updateProfileDetails({
    String? name,
    String? goal,
    double? currentWeightKg,
    double? heightCm,
    int? age,
    String? gender,
    String? activityLevel,
  }) async {
    if (_user != null) {
      _user = _user!.copyWith(
        name: name,
        goal: goal,
        currentWeightKg: currentWeightKg,
        heightCm: heightCm,
        age: age,
        gender: gender,
        activityLevel: activityLevel,
      );
      notifyListeners();
    }
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
