import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:profit/models/user_model.dart';
import 'package:profit/models/workout_plan_model.dart';
import 'package:profit/core/enums/muscle_group.dart';
import 'package:profit/core/enums/user_role.dart';
import 'package:profit/providers/auth_provider.dart';
import 'package:profit/providers/role_provider.dart';
import 'package:profit/theme/theme_provider.dart';
import 'package:profit/providers/workout_provider.dart';
import 'package:profit/providers/nutrition_provider.dart';
import 'package:profit/providers/progress_provider.dart';
import 'package:profit/providers/ai_coach_provider.dart';
import 'package:profit/providers/self_trainer_cycle_provider.dart';
import 'package:profit/services/auth_service.dart';
import 'package:profit/services/ai_coach_service.dart';
import 'package:profit/repositories/exercise_repository.dart';
import 'package:profit/repositories/workout_repository.dart';
import 'package:profit/repositories/nutrition_repository.dart';
import 'package:profit/repositories/progress_repository.dart';
import 'package:profit/screens/home/home_dashboard_screen.dart';
import 'package:profit/screens/self_trainer/fitness_setup_wizard_screen.dart';
import 'package:profit/screens/self_trainer/today_workout_screen.dart';

void main() {
  late MockAuthService authService;
  late UserModel testUser;

  setUp(() {
    authService = MockAuthService();
    testUser = UserModel(
      id: 'test_user_hover',
      email: 'dania@example.com',
      name: 'Dania Shabih',
      role: UserRole.self,
      fitnessSetupCompleted: true,
      currentWeightKg: 69.0,
      targetWeightKg: 58.0,
      heightCm: 152.4,
      goal: 'Lose Weight',
      trainingDaysPerWeek: 4,
    );
  });

  Widget buildTestApp(Widget child) {
    final exerciseRepo = LocalExerciseRepository();
    final workoutRepo = LocalWorkoutRepository(exerciseRepo: exerciseRepo);
    final nutritionRepo = LocalNutritionRepository();
    final progressRepo = LocalProgressRepository();
    final aiCoachService = ExtensibleAiCoachService();

    final authProv = AuthProvider(authService: authService);
    authProv.saveUserProfile(testUser);

    final cycleProv = SelfTrainerCycleProvider();
    cycleProv.initializeForUser(testUser);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<RoleProvider>(create: (_) => RoleProvider()),
        ChangeNotifierProvider<AuthProvider>.value(value: authProv),
        ChangeNotifierProvider<WorkoutProvider>(
          create: (_) => WorkoutProvider(workoutRepo: workoutRepo, exerciseRepo: exerciseRepo),
        ),
        ChangeNotifierProvider<NutritionProvider>(
          create: (_) => NutritionProvider(nutritionRepo: nutritionRepo),
        ),
        ChangeNotifierProvider<ProgressProvider>(
          create: (_) => ProgressProvider(progressRepo: progressRepo),
        ),
        ChangeNotifierProvider<AiCoachProvider>(
          create: (_) => AiCoachProvider(aiService: aiCoachService),
        ),
        ChangeNotifierProvider<SelfTrainerCycleProvider>.value(value: cycleProv),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  testWidgets('Mouse hover and movement across HomeDashboardScreen does not crash mouse tracker',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp(const HomeDashboardScreen()));
    await tester.pumpAndSettle();

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);

    // Move mouse across several locations on the screen
    for (int y = 50; y < 800; y += 40) {
      await gesture.moveTo(Offset(200, y.toDouble()));
      await tester.pump(const Duration(milliseconds: 16));
    }
  });

  testWidgets('Mouse hover and interaction across FitnessSetupWizardScreen does not crash',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp(const FitnessSetupWizardScreen()));
    await tester.pumpAndSettle();

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);

    for (int y = 50; y < 600; y += 30) {
      await gesture.moveTo(Offset(180, y.toDouble()));
      await tester.pump(const Duration(milliseconds: 16));
    }
  });

  testWidgets('FitnessSetupWizardScreen navigate to Step 6 and hover/tap with various screen sizes',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(500, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestApp(const FitnessSetupWizardScreen()));
    await tester.pumpAndSettle();

    // Navigate from Step 1 to Step 6
    for (int i = 0; i < 5; i++) {
      final continueBtn = find.widgetWithText(ElevatedButton, 'Continue');
      expect(continueBtn, findsOneWidget);
      await tester.tap(continueBtn);
      await tester.pumpAndSettle();
    }

    // Now on Step 6: Verify training days options are visible
    expect(find.text('How many days per week do you want to train?'), findsOneWidget);
    expect(find.text('Generate My Fitness Plan'), findsOneWidget);

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);

    // Hover over training day options and bottom bar
    for (int y = 50; y < 580; y += 20) {
      await gesture.moveTo(Offset(250, y.toDouble()));
      await tester.pump(const Duration(milliseconds: 16));
    }

    // Scroll to and tap on '5 Days / Week' option
    final option5 = find.text('5 Days / Week');
    await tester.scrollUntilVisible(
      option5,
      100,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(option5);
    await tester.pumpAndSettle();

    // Hover again after state change
    for (int y = 50; y < 580; y += 20) {
      await gesture.moveTo(Offset(250, y.toDouble()));
      await tester.pump(const Duration(milliseconds: 16));
    }
  });

  testWidgets('TodayWorkoutScreen with RestTimerDialog does not crash on mouse events',
      (WidgetTester tester) async {
    const day = WorkoutDay(
      id: 'day_1',
      dayOfWeek: 1,
      dayName: 'Monday',
      workoutType: 'Chest + Triceps',
      targetMuscles: ['Chest', 'Triceps'],
      isRestDay: false,
      exercises: [
        PlanExercise(
          id: 'ex_1',
          name: 'Bench Press',
          muscleGroup: MuscleGroup.chest,
          equipment: 'Barbell',
          sets: 3,
          reps: 10,
          targetWeightKg: 30.0,
          restTimeSeconds: 60,
        ),
      ],
    );

    await tester.pumpWidget(buildTestApp(const TodayWorkoutScreen(workoutDay: day)));
    await tester.pumpAndSettle();

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);

    // Tap set completion button for set 1 to trigger rest timer
    final checkBtn = find.byIcon(Icons.circle_outlined).first;
    await tester.tap(checkBtn);
    await tester.pumpAndSettle();

    // Hover mouse over the dialog/bottomsheet
    for (int y = 200; y < 700; y += 30) {
      await gesture.moveTo(Offset(200, y.toDouble()));
      await tester.pump(const Duration(milliseconds: 16));
    }
  });
}
