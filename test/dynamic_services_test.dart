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


import 'package:profit/services/auth_service.dart';
import 'package:profit/core/enums/muscle_group.dart';
import 'package:profit/core/enums/exercise_difficulty.dart';
import 'package:profit/core/enums/meal_type.dart';
import 'package:profit/screens/trainer/trainer_dashboard_screen.dart';
import 'package:profit/screens/nutrition/nutrition_screen.dart';
import 'package:profit/screens/progress/progress_screen.dart';
import 'package:profit/models/user_model.dart';
import 'package:profit/models/fitness_profile_model.dart';
import 'package:profit/models/bmi_record_model.dart';
import 'package:profit/models/workout_plan_model.dart';
import 'package:profit/models/workout_log_model.dart';
import 'package:profit/models/meal_plan_model.dart';
import 'package:profit/models/protein_log_model.dart';
import 'package:profit/models/progress_record_model.dart';
import 'package:profit/models/monthly_cycle_model.dart';

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

    test('UserModel contains new self-trainer fields compliant with firestore.rules isValidUser', () {
      const allowedUserFields = {
        'id', 'uid', 'name', 'fullName', 'email', 'avatarUrl', 'profileImage', 'role',
        'trainerStatus', 'trainerProfile', 'phoneNumber', 'gymLocation', 'createdAt',
        'updatedAt', 'fitnessLevel', 'goal', 'currentWeightKg', 'startWeightKg',
        'targetWeightKg', 'heightCm', 'age', 'gender', 'activityLevel', 'streakDays',
        'totalWorkouts', 'totalTrainingMinutes', 'totalVolumeKg', 'totalCaloriesBurned',
        'membershipTier', 'membershipDaysRemaining', 'membershipExpiryDate',
        'trainerId', 'assignedTrainerId',
        'fitnessSetupCompleted', 'goalType', 'bmi', 'bmiCategory', 'trainingDaysPerWeek'
      };

      final user = UserModel(
        id: 'user_st_1',
        name: 'Jordan Lee',
        email: 'jordan@profit.app',
        fitnessSetupCompleted: true,
        trainingDaysPerWeek: 5,
      );

      final map = user.toFirestoreMap();
      map['goalType'] = 'Build Muscle';
      map['bmi'] = 23.5;
      map['bmiCategory'] = 'Normal weight';
      map['fitnessSetupCompleted'] = true;
      map['trainingDaysPerWeek'] = 5;

      for (final key in map.keys) {
        expect(allowedUserFields.contains(key), isTrue,
            reason: 'Field "$key" must be in firestore.rules isValidUser allowed fields');
      }
    });

    test('FitnessProfile.toMap contains only allowed fields per firestore.rules isValidFitnessProfile', () {
      const allowedFitnessProfileFields = {
        'id', 'userId', 'heightCm', 'currentWeightKg', 'targetWeightKg', 'goalType',
        'bmi', 'bmiCategory', 'trainingDaysPerWeek', 'fitnessLevel', 'age', 'gender',
        'activityLevel', 'createdAt', 'updatedAt', 'fullName', 'fitnessSetupCompleted'
      };

      final profile = FitnessProfile(
        userId: 'user_fp_1',
        fullName: 'Jordan Lee',
        age: 28,
        gender: 'Male',
        heightCm: 180,
        currentWeightKg: 78,
        targetWeightKg: 74,
        goalType: 'Lose Weight',
        bmi: 24.1,
        bmiCategory: 'Normal weight',
        trainingDaysPerWeek: 4,
        fitnessLevel: 'Intermediate',
        activityLevel: 'moderately_active',
        fitnessSetupCompleted: true,
        createdAt: DateTime(2026, 9, 30),
        updatedAt: DateTime(2026, 9, 30),
      );

      final map = profile.toMap();

      for (final key in map.keys) {
        expect(allowedFitnessProfileFields.contains(key), isTrue,
            reason: 'Field "$key" must be in firestore.rules isValidFitnessProfile');
      }
    });

    test('BmiRecord.toMap contains only allowed fields per firestore.rules isValidBmiRecord', () {
      const allowedBmiFields = {
        'id', 'userId', 'weight', 'height', 'bmi', 'category', 'calculatedAt'
      };

      final record = BmiRecord(
        id: 'bmi_rec_1',
        userId: 'user_fp_1',
        weight: 78.0,
        height: 180.0,
        bmi: 24.1,
        category: 'Normal weight',
        calculatedAt: DateTime(2026, 9, 30),
      );

      final map = record.toMap();

      for (final key in map.keys) {
        expect(allowedBmiFields.contains(key), isTrue,
            reason: 'Field "$key" must be in firestore.rules isValidBmiRecord');
      }
    });

    test('WorkoutPlan.toMap contains only allowed fields per firestore.rules isValidWorkoutPlan', () {
      const allowedPlanFields = {
        'id', 'userId', 'monthId', 'goalType', 'trainingDaysPerWeek', 'startDate',
        'endDate', 'status', 'splitType', 'days', 'isTemplate', 'createdAt', 'updatedAt'
      };

      final plan = WorkoutPlan(
        id: 'plan_1',
        userId: 'user_fp_1',
        monthId: '2026-10',
        goalType: 'Build Muscle',
        trainingDaysPerWeek: 4,
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 31),
        status: 'active',
        splitType: 'Upper / Lower',
        days: [],
        createdAt: DateTime(2026, 9, 30),
        updatedAt: DateTime(2026, 9, 30),
      );

      final map = plan.toMap();

      for (final key in map.keys) {
        expect(allowedPlanFields.contains(key), isTrue,
            reason: 'Field "$key" must be in firestore.rules isValidWorkoutPlan');
      }
    });

    test('WorkoutLog.toMap contains only allowed fields per firestore.rules isValidWorkoutLog', () {
      const allowedLogFields = {
        'id', 'userId', 'workoutPlanId', 'dayId', 'workoutTitle', 'targetMuscles',
        'durationMinutes', 'completedExercises', 'totalExercises', 'exercises',
        'completedAt', 'dateString', 'createdAt', 'updatedAt'
      };

      final log = WorkoutLog(
        id: 'log_1',
        userId: 'user_fp_1',
        workoutPlanId: 'plan_1',
        dayId: 'day_1',
        workoutTitle: 'Upper Body Power',
        targetMuscles: ['Chest', 'Triceps'],
        completedExercises: 5,
        totalExercises: 5,
        completedAt: DateTime(2026, 9, 30),
        dateString: '2026-09-30',
      );

      final map = log.toMap();

      for (final key in map.keys) {
        expect(allowedLogFields.contains(key), isTrue,
            reason: 'Field "$key" must be in firestore.rules isValidWorkoutLog');
      }
    });

    test('MealPlan.toMap contains only allowed fields per firestore.rules isValidMealPlan', () {
      const allowedMealPlanFields = {
        'id', 'userId', 'monthId', 'targetCalories', 'targetProteinGrams',
        'targetCarbsGrams', 'targetFatGrams', 'meals', 'createdAt', 'updatedAt'
      };

      final mealPlan = MealPlan(
        id: 'meal_plan_1',
        userId: 'user_fp_1',
        monthId: '2026-10',
        targetCalories: 2200,
        targetProteinGrams: 150.0,
        targetCarbsGrams: 220.0,
        targetFatGrams: 60.0,
        meals: [],
        createdAt: DateTime(2026, 9, 30),
        updatedAt: DateTime(2026, 9, 30),
      );

      final map = mealPlan.toMap();

      for (final key in map.keys) {
        expect(allowedMealPlanFields.contains(key), isTrue,
            reason: 'Field "$key" must be in firestore.rules isValidMealPlan');
      }
    });

    test('ProteinLog.toMap contains only allowed fields per firestore.rules isValidProteinLog', () {
      const allowedProteinFields = {
        'id', 'userId', 'date', 'targetGrams', 'consumedGrams', 'remainingGrams',
        'mealsLoggedCount', 'createdAt', 'updatedAt'
      };

      final proteinLog = ProteinLog(
        id: 'prot_1',
        userId: 'user_fp_1',
        date: '2026-09-30',
        targetGrams: 150.0,
        consumedGrams: 120.0,
        remainingGrams: 30.0,
        mealsLoggedCount: 3,
        updatedAt: DateTime(2026, 9, 30),
      );

      final map = proteinLog.toMap();

      for (final key in map.keys) {
        expect(allowedProteinFields.contains(key), isTrue,
            reason: 'Field "$key" must be in firestore.rules isValidProteinLog');
      }
    });

    test('ProgressRecord.toMap contains only allowed fields per firestore.rules isValidProgressRecord', () {
      const allowedProgressFields = {
        'id', 'userId', 'monthId', 'monthName', 'year', 'startDate', 'endDate',
        'startingWeight', 'endingWeight', 'startingBmi', 'endingBmi',
        'workoutCompletionRate', 'proteinGoalCompletionRate', 'calorieAverage',
        'createdAt', 'updatedAt'
      };

      final rec = ProgressRecord(
        id: 'prog_1',
        userId: 'user_fp_1',
        monthId: '2026-09',
        monthName: 'September',
        year: 2026,
        startDate: DateTime(2026, 9, 1),
        endDate: DateTime(2026, 9, 30),
        startingWeight: 80.0,
        endingWeight: 78.0,
        startingBmi: 24.7,
        endingBmi: 24.1,
        workoutCompletionRate: 85.0,
        proteinGoalCompletionRate: 80.0,
        createdAt: DateTime(2026, 9, 30),
      );

      final map = rec.toMap();

      for (final key in map.keys) {
        expect(allowedProgressFields.contains(key), isTrue,
            reason: 'Field "$key" must be in firestore.rules isValidProgressRecord');
      }
    });

    test('MonthlyCycle.toMap contains only allowed fields per firestore.rules isValidMonthlyCycle', () {
      const allowedCycleFields = {
        'id', 'userId', 'monthId', 'monthName', 'year', 'startDate', 'endDate',
        'status', 'workoutPlanId', 'mealPlanId', 'startingWeight', 'endingWeight',
        'startingBmi', 'endingBmi', 'workoutCompletionRate', 'proteinGoalCompletionRate',
        'isCurrent', 'reviewedAt', 'reviewNotes', 'createdAt', 'updatedAt'
      };

      final cycle = MonthlyCycle(
        id: 'cycle_1',
        userId: 'user_fp_1',
        monthId: '2026-10',
        monthName: 'October',
        year: 2026,
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 31),
        status: 'active',
        workoutPlanId: 'plan_1',
        mealPlanId: 'meal_plan_1',
        startingWeight: 78.0,
        startingBmi: 24.1,
        createdAt: DateTime(2026, 9, 30),
        updatedAt: DateTime(2026, 9, 30),
      );

      final map = cycle.toMap();

      for (final key in map.keys) {
        expect(allowedCycleFields.contains(key), isTrue,
            reason: 'Field "$key" must be in firestore.rules isValidMonthlyCycle');
      }
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

      final nutritionProv = NutritionProvider();
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

      final progressProv = ProgressProvider();
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
