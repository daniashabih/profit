import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/main.dart';
import '../lib/theme/theme_provider.dart';
import '../lib/providers/auth_provider.dart';
import '../lib/providers/workout_provider.dart';
import '../lib/providers/nutrition_provider.dart';
import '../lib/providers/progress_provider.dart';
import '../lib/providers/ai_coach_provider.dart';
import '../lib/providers/role_provider.dart';

import '../lib/services/auth_service.dart';
import '../lib/services/ai_coach_service.dart';
import '../lib/repositories/exercise_repository.dart';
import '../lib/repositories/workout_repository.dart';
import '../lib/repositories/nutrition_repository.dart';
import '../lib/repositories/progress_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'profit_has_onboarded': true});
  });

  testWidgets('ProFitApp smoke test boots with MultiProvider and Splash', (WidgetTester tester) async {
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
        child: const ProFitApp(),
      ),
    );

    // Initial frame shows ProFit branding
    expect(find.text('Pro'), findsOneWidget);
    expect(find.text('Fit'), findsOneWidget);
    expect(find.text('Your Fitness Journey Starts Here'), findsOneWidget);
  });
}
