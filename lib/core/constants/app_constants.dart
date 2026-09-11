class AppConstants {
  static const String appName = 'PROFIT';
  static const String appTagline = 'Your Fitness. Your Progress.';
  static const String appVersion = '1.0.0';

  // Equipment List for filters
  static const List<String> equipmentList = [
    'All Equipment',
    'No Equipment',
    'Dumbbell',
    'Barbell',
    'Machine',
    'Cable',
    'Kettlebell',
    'Resistance Band',
  ];

  // Rest Timer presets in seconds
  static const List<int> restTimerPresets = [30, 60, 90, 120, 180];

  // Storage keys
  static const String keyThemeMode = 'profit_theme_mode';
  static const String keyUserRole = 'profit_user_role';
  static const String keyWeightUnit = 'profit_weight_unit';
  static const String keyHeightUnit = 'profit_height_unit';
  static const String keyHasOnboarded = 'profit_has_onboarded';

  // Default targets
  static const double defaultDailyCalories = 2200;
  static const double defaultDailyProteinGrams = 150;
  static const double defaultDailyCarbsGrams = 220;
  static const double defaultDailyFatGrams = 65;
  static const double defaultDailyWaterLiters = 3.0;
}
