import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/workout_provider.dart';
import 'providers/nutrition_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/ai_coach_provider.dart';
import 'providers/role_provider.dart';

import 'services/auth_service.dart';
import 'services/ai_coach_service.dart';
import 'repositories/exercise_repository.dart';
import 'repositories/workout_repository.dart';
import 'repositories/nutrition_repository.dart';
import 'repositories/progress_repository.dart';

import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Initialize Core Services & Repositories
  final authService = MockAuthService();
  final aiCoachService = ExtensibleAiCoachService();
  final exerciseRepo = LocalExerciseRepository();
  final workoutRepo = LocalWorkoutRepository(exerciseRepo: exerciseRepo);
  final nutritionRepo = LocalNutritionRepository();
  final progressRepo = LocalProgressRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<RoleProvider>(
          create: (_) => RoleProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authService: authService),
        ),
        ChangeNotifierProvider<WorkoutProvider>(
          create: (_) => WorkoutProvider(
            workoutRepo: workoutRepo,
            exerciseRepo: exerciseRepo,
          ),
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
}

class ProfitApp extends StatelessWidget {
  const ProfitApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'PROFIT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const SplashScreen(),
    );
  }
}

/// Alias for backwards compatibility
typedef FitFlowApp = ProfitApp;
