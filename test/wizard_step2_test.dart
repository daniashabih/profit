import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:profit/models/user_model.dart';
import 'package:profit/core/enums/user_role.dart';
import 'package:profit/providers/auth_provider.dart';
import 'package:profit/providers/role_provider.dart';
import 'package:profit/theme/theme_provider.dart';
import 'package:profit/theme/app_theme.dart';
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
  testWidgets('Test Step 2 on phone dimensions 460x1024 with AppTheme.darkTheme', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(460, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final authService = MockAuthService();
    final testUser = UserModel(
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

    final authProv = AuthProvider(authService: authService);
    authProv.saveUserProfile(testUser);
    final cycleProv = SelfTrainerCycleProvider();
    cycleProv.initializeForUser(testUser);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
          ChangeNotifierProvider<RoleProvider>(create: (_) => RoleProvider()),
          ChangeNotifierProvider<AuthProvider>.value(value: authProv),
          ChangeNotifierProvider<WorkoutProvider>(
            create: (_) => WorkoutProvider(exerciseRepo: LocalExerciseRepository()),
          ),
          ChangeNotifierProvider<NutritionProvider>(create: (_) => NutritionProvider()),
          ChangeNotifierProvider<ProgressProvider>(create: (_) => ProgressProvider()),
          ChangeNotifierProvider<AiCoachProvider>(
            create: (_) => AiCoachProvider(aiService: ExtensibleAiCoachService()),
          ),
          ChangeNotifierProvider<SelfTrainerCycleProvider>.value(value: cycleProv),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const FitnessSetupWizardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // In step 1: Tap Continue to reach Step 2
    final continueFinder = find.widgetWithText(ElevatedButton, 'Continue');
    expect(continueFinder, findsOneWidget);
    await tester.tap(continueFinder);
    await tester.pumpAndSettle();

    // Now on Step 2
    expect(find.text('STEP 2 OF 8'), findsOneWidget);
    expect(find.text('What is your gender?'), findsOneWidget);

    // Let's check if Continue and Back are visible and what their positions are
    final continueInStep2 = find.widgetWithText(ElevatedButton, 'Continue');
    expect(continueInStep2, findsOneWidget);
    final backFinder = find.widgetWithText(OutlinedButton, 'Back');
    expect(backFinder, findsOneWidget);

    debugPrint('Continue button rect: ${tester.getRect(continueInStep2)}');
    debugPrint('Back button rect: ${tester.getRect(backFinder)}');
  });
}
