import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:profit/main.dart';
import 'package:profit/theme/theme_provider.dart';
import 'package:profit/providers/auth_provider.dart';
import 'package:profit/providers/workout_provider.dart';
import 'package:profit/providers/nutrition_provider.dart';
import 'package:profit/providers/progress_provider.dart';
import 'package:profit/providers/ai_coach_provider.dart';
import 'package:profit/providers/role_provider.dart';

import 'package:profit/services/auth_service.dart';
import 'package:profit/services/ai_coach_service.dart';
import 'package:profit/repositories/exercise_repository.dart';
import 'package:profit/repositories/workout_repository.dart';
import 'package:profit/repositories/nutrition_repository.dart';
import 'package:profit/repositories/progress_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'profit_has_onboarded': true});
  });

  testWidgets('ProfitApp smoke test boots with MultiProvider and Splash', (WidgetTester tester) async {
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
        child: const ProfitApp(),
      ),
    );

    // Initial frame shows PROFIT branding and official tagline
    expect(find.text('PRO'), findsWidgets);
    expect(find.text('FIT'), findsWidgets);
    expect(find.text('Your Fitness. Your Progress.'), findsOneWidget);
  });
}
