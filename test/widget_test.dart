import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitflow/main.dart';
import 'package:fitflow/theme/theme_provider.dart';
import 'package:fitflow/providers/auth_provider.dart';
import 'package:fitflow/providers/workout_provider.dart';
import 'package:fitflow/providers/nutrition_provider.dart';
import 'package:fitflow/providers/progress_provider.dart';
import 'package:fitflow/providers/ai_coach_provider.dart';
import 'package:fitflow/providers/role_provider.dart';

import 'package:fitflow/services/auth_service.dart';
import 'package:fitflow/services/ai_coach_service.dart';
import 'package:fitflow/repositories/exercise_repository.dart';
import 'package:fitflow/repositories/workout_repository.dart';
import 'package:fitflow/repositories/nutrition_repository.dart';
import 'package:fitflow/repositories/progress_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'fitflow_has_onboarded': true});
  });

  testWidgets('FitFlowApp smoke test boots with MultiProvider and Splash', (WidgetTester tester) async {
    final authService = MockAuthService();
    final aiCoachService = ExtensibleAiCoachService();
    final exerciseRepo = LocalExerciseRepository();
    final workoutRepo = LocalWorkoutRepository(exerciseRepo: exerciseRepo);
    final nutritionRepo = LocalNutritionRepository();
    final progressRepo = LocalProgressRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
          ChangeNotifierProvider<RoleProvider>(create: (_) => RoleProvider()),
          ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider(authService: authService)),
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
        ],
        child: const FitFlowApp(),
      ),
    );

    // Initial frame shows FitFlow branding
    expect(find.text('Fit'), findsWidgets);
    expect(find.text('Flow'), findsWidgets);
    expect(find.text('Your Fitness Journey Starts Here'), findsOneWidget);
  });
}
