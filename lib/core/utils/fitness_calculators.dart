class FitnessCalculators {
  /// Calculates One Rep Max (1RM) using the Epley formula: Weight * (1 + Reps / 30)
  static double calculateOneRepMax(double weightKg, int reps) {
    if (reps <= 0) return 0;
    if (reps == 1) return weightKg;
    return weightKg * (1 + (reps / 30.0));
  }

  /// Calculates Body Mass Index (BMI): weight (kg) / (height (m) ^ 2)
  static double calculateBmi(double weightKg, double heightCm) {
    if (heightCm <= 0 || weightKg <= 0) return 0;
    final heightMeters = heightCm / 100.0;
    return weightKg / (heightMeters * heightMeters);
  }

  /// Categorizes BMI
  static String getBmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Healthy Weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  /// Calculates total calories from macronutrients:
  /// Protein = 4 kcal/g, Carbs = 4 kcal/g, Fat = 9 kcal/g
  static double calculateCaloriesFromMacros({
    required double proteinGrams,
    required double carbsGrams,
    required double fatGrams,
  }) {
    return (proteinGrams * 4) + (carbsGrams * 4) + (fatGrams * 9);
  }

  /// Calculates percentage completion clamped between 0.0 and 1.0
  static double calculateProgressPercentage(double current, double target) {
    if (target <= 0) return 0.0;
    final ratio = current / target;
    return ratio.clamp(0.0, 1.0);
  }
}
