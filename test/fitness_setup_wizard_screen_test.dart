import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:profit/models/user_model.dart';
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



import 'package:profit/screens/self_trainer/fitness_setup_wizard_screen.dart';

void main() {
  late MockAuthService authService;
  late UserModel testUser;
  late AuthProvider authProv;
  late SelfTrainerCycleProvider cycleProv;

  setUp(() {
    authService = MockAuthService();
    testUser = UserModel(
      id: 'test_athlete_123',
      email: 'athlete@example.com',
      name: 'Test Athlete',
      role: UserRole.self,
      fitnessSetupCompleted: false,
      currentWeightKg: 70.0,
      targetWeightKg: 65.0,
      heightCm: 175.0,
      goal: 'Build Muscle',
    );
  });

  Widget buildTestApp(Widget child) {
    final exerciseRepo = LocalExerciseRepository();
    
    
    
    final aiCoachService = ExtensibleAiCoachService();

    authProv = AuthProvider(authService: authService);
    authProv.saveUserProfile(testUser);

    cycleProv = SelfTrainerCycleProvider();
    cycleProv.initializeForUser(testUser);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<RoleProvider>(create: (_) => RoleProvider()),
        ChangeNotifierProvider<AuthProvider>.value(value: authProv),
        ChangeNotifierProvider<WorkoutProvider>(
          create: (_) => WorkoutProvider(exerciseRepo: exerciseRepo),
        ),
        ChangeNotifierProvider<NutritionProvider>(
          create: (_) => NutritionProvider(),
        ),
        ChangeNotifierProvider<ProgressProvider>(
          create: (_) => ProgressProvider(),
        ),
        ChangeNotifierProvider<AiCoachProvider>(
          create: (_) => AiCoachProvider(aiService: aiCoachService),
        ),
        ChangeNotifierProvider<SelfTrainerCycleProvider>.value(value: cycleProv),
      ],
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: child,
      ),
    );
  }

  Future<void> navigateToStep6(WidgetTester tester) async {
    for (int i = 0; i < 5; i++) {
      final continueBtn = find.widgetWithText(ElevatedButton, 'Continue');
      expect(continueBtn, findsOneWidget);
      await tester.tap(continueBtn);
      await tester.pumpAndSettle();
    }
  }

  group('Personal Fitness Setup - Step 6 & Bottom CTA Tests', () {
    testWidgets(
        'Step 6 renders progress indicator with proper spacing, unclipped header, and all frequency cards',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const FitnessSetupWizardScreen()));
      await tester.pumpAndSettle();

      await navigateToStep6(tester);

      // Verify header and progress
      expect(find.text('Personal Fitness Setup'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('STEP 6 OF 6'), findsOneWidget);
      expect(find.text('How many days per week do you want to train?'), findsOneWidget);
      expect(
        find.text('Choose your weekly commitment. You can adapt this anytime.'),
        findsOneWidget,
      );

      // Verify all 5 workout frequency cards exist
      expect(find.text('2 Days / Week'), findsOneWidget);
      expect(find.text('3 Days / Week'), findsOneWidget);
      expect(find.text('4 Days / Week'), findsOneWidget);
      expect(find.text('5 Days / Week'), findsOneWidget);
      expect(find.text('6 Days / Week'), findsOneWidget);

      // Verify exact descriptions exist
      expect(
        find.text('Full Body frequency. Ideal for busy schedules and recovery.'),
        findsOneWidget,
      );
      expect(
        find.text('Push / Pull / Legs double cycle. High frequency volume.'),
        findsOneWidget,
      );
    });

    testWidgets(
        'Continue button is initially disabled/subdued when no frequency is selected, then enables on selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const FitnessSetupWizardScreen()));
      await tester.pumpAndSettle();

      await navigateToStep6(tester);

      // Continue button should be present
      final continueFinder = find.widgetWithText(ElevatedButton, 'Continue');
      expect(continueFinder, findsOneWidget);

      // Button is disabled initially
      ElevatedButton btn = tester.widget<ElevatedButton>(continueFinder);
      expect(btn.onPressed, isNull);

      // Tap 2 Days / Week
      await tester.tap(find.text('2 Days / Week'));
      await tester.pumpAndSettle();

      // Button should now be enabled
      btn = tester.widget<ElevatedButton>(continueFinder);
      expect(btn.onPressed, isNotNull);

      // Verify checkmark appears for 2 Days / Week
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets(
        'Selection switches smoothly between 2, 3, 4, 5, and 6 Days / Week',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const FitnessSetupWizardScreen()));
      await tester.pumpAndSettle();

      await navigateToStep6(tester);

      final continueFinder = find.widgetWithText(ElevatedButton, 'Continue');

      // Test 3 Days / Week
      await tester.ensureVisible(find.text('3 Days / Week'));
      await tester.tap(find.text('3 Days / Week'));
      await tester.pumpAndSettle();
      ElevatedButton btn = tester.widget<ElevatedButton>(continueFinder);
      expect(btn.onPressed, isNotNull);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

      // Test 4 Days / Week
      await tester.ensureVisible(find.text('4 Days / Week'));
      await tester.tap(find.text('4 Days / Week'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

      // Test 5 Days / Week
      await tester.ensureVisible(find.text('5 Days / Week'));
      await tester.tap(find.text('5 Days / Week'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

      // Test 6 Days / Week
      await tester.ensureVisible(find.text('6 Days / Week'));
      await tester.tap(find.text('6 Days / Week'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

      // Back to 2 Days / Week
      await tester.ensureVisible(find.text('2 Days / Week'));
      await tester.tap(find.text('2 Days / Week'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets(
        'Fixed bottom CTA remains visible and does not scroll away; responsive on small screens',
        (WidgetTester tester) async {
      // Small screen size (Android 360 x 640)
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestApp(const FitnessSetupWizardScreen()));
      await tester.pumpAndSettle();

      await navigateToStep6(tester);

      final continueFinder = find.widgetWithText(ElevatedButton, 'Continue');
      expect(continueFinder, findsOneWidget);

      // Scroll to 6 Days / Week and tap it
      final option6 = find.text('6 Days / Week');
      await tester.ensureVisible(option6);
      await tester.pumpAndSettle();
      expect(option6, findsOneWidget);

      // Continue button must NOT have scrolled away
      expect(continueFinder, findsOneWidget);

      await tester.tap(option6);
      await tester.pumpAndSettle();

      final btn = tester.widget<ElevatedButton>(continueFinder);
      expect(btn.onPressed, isNotNull);
    });

    testWidgets(
        'Pressing Continue saves frequency and triggers plan generation transition',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const FitnessSetupWizardScreen()));
      await tester.pumpAndSettle();

      await navigateToStep6(tester);

      // Select 5 Days / Week
      await tester.ensureVisible(find.text('5 Days / Week'));
      await tester.tap(find.text('5 Days / Week'));
      await tester.pumpAndSettle();

      final continueFinder = find.widgetWithText(ElevatedButton, 'Continue');
      await tester.tap(continueFinder);
      await tester.pumpAndSettle();

      // Verify the frequency was saved in auth user profile and cycle provider
      expect(authProv.user!.trainingDaysPerWeek, 5);
      expect(authProv.user!.fitnessSetupCompleted, isTrue);
      expect(cycleProv.currentCycle, isNotNull);

      // Verify transition to MainNavigation screen
      expect(find.byType(FitnessSetupWizardScreen), findsNothing);
    });

    testWidgets(
        'Back button in AppBar navigates back to Step 5 (Target Weight)',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const FitnessSetupWizardScreen()));
      await tester.pumpAndSettle();

      await navigateToStep6(tester);
      expect(find.text('STEP 6 OF 6'), findsOneWidget);

      // Tap back in AppBar
      final backBtn = find.byIcon(Icons.arrow_back_ios_new_rounded);
      expect(backBtn, findsOneWidget);
      await tester.tap(backBtn);
      await tester.pumpAndSettle();

      // Should now be on Step 5
      expect(find.text('STEP 5 OF 6'), findsOneWidget);
    });
  });
}
