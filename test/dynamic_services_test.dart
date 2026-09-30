import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:profit/models/trainer_member_model.dart';
import 'package:profit/models/workout_model.dart';
import 'package:profit/models/nutrition_model.dart';
import 'package:profit/models/measurement_model.dart';
import 'package:profit/models/exercise_model.dart';
import 'package:profit/models/workout_set_model.dart';
import 'package:profit/providers/trainer_provider.dart';
import 'package:profit/providers/auth_provider.dart';
import 'package:profit/providers/role_provider.dart';
import 'package:profit/providers/progress_provider.dart';
import 'package:profit/providers/nutrition_provider.dart';
import 'package:profit/repositories/progress_repository.dart';
import 'package:profit/repositories/nutrition_repository.dart';
import 'package:profit/services/auth_service.dart';
import 'package:profit/core/enums/muscle_group.dart';
import 'package:profit/core/enums/exercise_difficulty.dart';
import 'package:profit/core/enums/meal_type.dart';
import 'package:profit/screens/trainer/trainer_dashboard_screen.dart';
import 'package:profit/screens/nutrition/nutrition_screen.dart';
import 'package:profit/screens/progress/progress_screen.dart';

void main() {
  group('Firestore Rules Schema & Serialization Compliance', () {
    test('TrainerMemberModel.toFirestoreMap contains only allowed fields per firestore.rules', () {
      final member = TrainerMemberModel(
        id: 'rel_123',
        trainerId: 'trainer_abc',
        memberId: 'client_xyz',
        memberName: 'Alex Rivera',
        memberEmail: 'alex@example.com',
        memberAvatarUrl: 'https://example.com/avatar.jpg',
        memberGoal: 'Hypertrophy',
        assignedPlan: 'Push Pull Legs',
        status: 'active',
        progressPercent: 0.85,
        streakDays: 14,
        clientWeightKg: 78.5,
        clientHeightCm: 180,
      );

      final map = member.toFirestoreMap();

      // Allowed fields in isValidTrainerMember:
      const allowed = {
        'id',
        'trainerId',
        'memberId',
        'clientId',
        'memberName',
        'memberEmail',
        'memberAvatarUrl',
        'memberGoal',
        'assignedPlan',
        'status',
        'createdAt',
        'updatedAt',
        'progressPercent',
      };

      for (final key in map.keys) {
        expect(allowed.contains(key), isTrue,
            reason: 'Field "$key" must be an allowed field in firestore.rules trainer_members');
      }

      expect(map['trainerId'], 'trainer_abc');
      expect(map['memberId'], 'client_xyz');
      expect(map['memberName'], 'Alex Rivera');
      expect(map['assignedPlan'], 'Push Pull Legs');
      expect(map['progressPercent'], 0.85);
    });

    test('WorkoutModel.toFirestoreMap matches firestore.rules isValidWorkout schema', () {
      final workout = WorkoutModel(
        id: 'w_123',
        userId: 'user_456',
        title: 'Full Body Power',
        subtitle: 'Heavy compound session',
        durationMinutes: 60,
        category: 'Strength',
        intensity: 'High',
        isTemplate: false,
        exercises: [
          ExerciseModel(
            id: 'ex_1',
            name: 'Barbell Squat',
            muscleGroup: MuscleGroup.legs,
            equipment: 'Barbell',
            difficulty: ExerciseDifficulty.intermediate,
            setsList: [
              WorkoutSetModel(setNumber: 1, weightKg: 100, reps: 5, isCompleted: true),
            ],
          ),
        ],
      );

      final map = workout.toFirestoreMap();

      expect(map['id'], 'w_123');
      expect(map['userId'], 'user_456');
      expect(map['title'], 'Full Body Power');
      expect(map['subtitle'], 'Heavy compound session');
      expect(map['durationMinutes'], 60);
      expect(map['category'], 'Strength');
      expect(map['intensity'], 'High');
      expect(map['isTemplate'], isFalse);
      expect(map['exercises'], isA<List>());
      expect((map['exercises'] as List).length, 1);
      expect(map.containsKey('createdAt'), isTrue);
      expect(map.containsKey('updatedAt'), isTrue);
    });

    test('DailyNutritionModel.toFirestoreMap matches firestore.rules isValidNutritionLog schema', () {
      final nutrition = DailyNutritionModel(
        id: 'user_1_2026-09-30',
        userId: 'user_1',
        date: '2026-09-30',
        targetCalories: 2200,
        targetProteinGrams: 160,
        targetCarbsGrams: 240,
        targetFatGrams: 65,
        meals: [
          MealItemModel(
            id: 'meal_1',
            name: 'Oatmeal & Whey Protein',
            calories: 450,
            proteinGrams: 35,
            carbsGrams: 55,
            fatGrams: 8,
            mealType: MealType.breakfast,
            time: '08:00 AM',
          ),
        ],
      );

      final map = nutrition.toFirestoreMap('user_1');

      expect(map['id'], 'user_1_2026-09-30');
      expect(map['userId'], 'user_1');
      expect(map['date'], '2026-09-30');
      expect(map['targetCalories'], 2200);
      expect(map['targetProteinGrams'], 160);
      expect(map['targetCarbsGrams'], 240);
      expect(map['targetFatGrams'], 65);
      expect(map['meals'], isA<List>());
      expect((map['meals'] as List).length, 1);
    });

    test('BodyMeasurementModel.toFirestoreMap matches firestore.rules isValidMeasurement schema', () {
      final measurement = BodyMeasurementModel(
        id: 'm_100',
        userId: 'user_99',
        date: DateTime(2026, 9, 30),
        weightKg: 75.2,
        chestCm: 102.0,
        waistCm: 81.0,
        armsCm: 37.0,
        thighsCm: 56.0,
        note: 'Feeling energized and leaner',
      );

      final map = measurement.toFirestoreMap('user_99');

      expect(map['id'], 'm_100');
      expect(map['userId'], 'user_99');
      expect(map['weightKg'], 75.2);
      expect(map['chestCm'], 102.0);
      expect(map['waistCm'], 81.0);
      expect(map['note'], 'Feeling energized and leaner');
    });
  });

  group('TrainerProvider Dynamic State Management', () {
    test('TrainerProvider handles dynamic addClient, assignPlan, and deleteClient', () async {
      final provider = TrainerProvider();

      final initialCount = provider.clients.length;
      expect(initialCount, greaterThan(0));

      // Test adding a client
      final newClient = ClientModel(
        id: 'test_client_99',
        trainerId: 'trainer_1',
        memberId: 'user_99',
        memberName: 'Morgan Taylor',
        memberEmail: 'morgan@example.com',
        memberGoal: 'Fat Loss',
        assignedPlan: 'Starter Burn',
        status: 'active',
        progressPercent: 0.5,
        clientWeightKg: 82.0,
        clientHeightCm: 172.0,
      );

      await provider.addClient(newClient);
      expect(provider.clients.any((c) => c.memberName == 'Morgan Taylor'), isTrue);
      expect(provider.totalMembers, initialCount + 1);

      // Test assigning plan
      await provider.assignPlanToClient('test_client_99', 'Advanced Strength');
      final updatedClient = provider.clients.firstWhere((c) => c.id == 'test_client_99');
      expect(updatedClient.assignedPlan, 'Advanced Strength');

      // Test creating a new workout plan
      final initialPlanCount = provider.workoutPlans.length;
      final newPlan = WorkoutModel(
        id: 'plan_kettlebell',
        title: 'Kettlebell Shred',
        subtitle: 'High intensity kettlebell circuit',
        durationMinutes: 45,
        category: 'Functional',
        intensity: 'Intermediate',
        isTemplate: true,
        exercises: const [],
      );
      await provider.createWorkoutPlan(newPlan);
      expect(provider.workoutPlans.length, initialPlanCount + 1);
      expect(provider.workoutPlans.any((p) => p.title == 'Kettlebell Shred'), isTrue);

      // Test deleting client
      await provider.deleteClient('test_client_99');
      expect(provider.clients.any((c) => c.id == 'test_client_99'), isFalse);
    });
  });

  group('Safe Deletion Confirmation Dialogs', () {
    testWidgets('TrainerDashboardScreen prompts confirmation dialog before deleting client', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1200, 1800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      final trainerProvider = TrainerProvider();
      final authProvider = AuthProvider(authService: MockAuthService());
      final roleProvider = RoleProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<TrainerProvider>.value(value: trainerProvider),
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<RoleProvider>.value(value: roleProvider),
          ],
          child: const MaterialApp(
            home: TrainerDashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to Members tab (index 1)
      final membersTab = find.text('Members');
      expect(membersTab, findsWidgets);
      await tester.tap(membersTab.first);
      await tester.pumpAndSettle();

      // Find delete button on first client card
      final deleteIcons = find.byIcon(Icons.delete_outline_rounded);
      expect(deleteIcons, findsWidgets);

      // Tap first delete icon
      await tester.tap(deleteIcons.first);
      await tester.pumpAndSettle();

      // Verify confirmation dialog appeared with Warning / Danger styling
      expect(find.text('Delete Client?'), findsOneWidget);
      expect(find.textContaining('Are you sure you want to remove'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      // Tap Cancel - verify dialog dismissed and clients preserved
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Delete Client?'), findsNothing);
    });

    testWidgets('NutritionScreen prompts confirmation dialog before deleting meal', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1200, 1800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      final nutritionProv = NutritionProvider(nutritionRepo: LocalNutritionRepository());
      final authProv = AuthProvider(authService: MockAuthService());

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<NutritionProvider>.value(value: nutritionProv),
            ChangeNotifierProvider<AuthProvider>.value(value: authProv),
          ],
          child: const MaterialApp(
            home: NutritionScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find delete meal button
      final deleteButtons = find.byIcon(Icons.delete_outline_rounded);
      if (deleteButtons.evaluate().isNotEmpty) {
        await tester.tap(deleteButtons.first);
        await tester.pumpAndSettle();

        expect(find.text('Delete Meal?'), findsOneWidget);
        expect(find.textContaining('Are you sure you want to remove'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Delete'), findsOneWidget);

        // Cancel dismissal
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(find.text('Delete Meal?'), findsNothing);
      }
    });

    testWidgets('ProgressScreen prompts confirmation dialog before deleting measurement', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1200, 1800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      final progressProv = ProgressProvider(progressRepo: LocalProgressRepository());
      final authProv = AuthProvider(authService: MockAuthService());

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ProgressProvider>.value(value: progressProv),
            ChangeNotifierProvider<AuthProvider>.value(value: authProv),
          ],
          child: const MaterialApp(
            home: ProgressScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find delete measurement button
      final deleteButtons = find.byIcon(Icons.delete_outline_rounded);
      if (deleteButtons.evaluate().isNotEmpty) {
        await tester.tap(deleteButtons.first);
        await tester.pumpAndSettle();

        expect(find.text('Delete Record?'), findsOneWidget);
        expect(find.textContaining('Are you sure you want to remove'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Delete'), findsOneWidget);

        // Cancel dismissal
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(find.text('Delete Record?'), findsNothing);
      }
    });
  });

  group('AuthProvider Dynamic Profile Updates', () {
    test('updateProfileDetails dynamically modifies user properties', () async {
      final authService = MockAuthService();
      final authProvider = AuthProvider(authService: authService);

      await authProvider.signIn('alex@profit.app', 'Password123!');
      expect(authProvider.user, isNotNull);

      await authProvider.updateProfileDetails(
        name: 'Alexander Rivera',
        goal: 'Elite Conditioning',
        currentWeightKg: 82.5,
        heightCm: 182.0,
      );

      expect(authProvider.user!.name, 'Alexander Rivera');
      expect(authProvider.user!.goal, 'Elite Conditioning');
      expect(authProvider.user!.currentWeightKg, 82.5);
      expect(authProvider.user!.heightCm, 182.0);
    });
  });
}
