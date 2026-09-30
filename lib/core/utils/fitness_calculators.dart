/// Structured evaluation result for Body Mass Index (BMI).
class BmiResult {
  final double value;
  final String category;
  final double minHealthyWeightKg;
  final double maxHealthyWeightKg;
  final String disclaimer;

  const BmiResult({
    required this.value,
    required this.category,
    required this.minHealthyWeightKg,
    required this.maxHealthyWeightKg,
    this.disclaimer =
        'BMI is a general screening indicator based on height and weight. It does not directly assess body composition or muscle mass.',
  });

  bool get isHealthy => category == 'Healthy Weight';
  bool get isUnderweight => category == 'Underweight';
  bool get isOverweight => category == 'Overweight';
  bool get isObese => category == 'Obese';
}

/// Structured recommendation result for daily protein intake.
class ProteinRecommendation {
  final double minGrams;
  final double maxGrams;
  final double targetGrams;
  final double factorPerKg;
  final String fitnessGoal;
  final String activityLevel;
  final String disclaimer;

  const ProteinRecommendation({
    required this.minGrams,
    required this.maxGrams,
    required this.targetGrams,
    required this.factorPerKg,
    required this.fitnessGoal,
    required this.activityLevel,
    this.disclaimer =
        'This calculation is a general fitness estimate based on body weight and activity level, and does not constitute medical or dietetic advice. Consult a qualified professional before significantly altering your diet.',
  });
}

/// Core fitness calculation engine for PROFIT.
/// Provides pure, deterministic formulas for 1RM, BMI, and daily protein targets.
class FitnessCalculators {
  /// Calculates One Rep Max (1RM) using the Epley formula: Weight * (1 + Reps / 30)
  static double calculateOneRepMax(double weightKg, int reps) {
    if (reps <= 0) return 0;
    if (reps == 1) return weightKg;
    return weightKg * (1 + (reps / 30.0));
  }

  /// Calculates Body Mass Index (BMI): weight (kg) / (height (m) ^ 2)
  static double calculateBmi(double weightKg, double heightCm) {
    if (heightCm <= 0 || weightKg <= 0) return 0.0;
    final heightMeters = heightCm / 100.0;
    final bmi = weightKg / (heightMeters * heightMeters);
    return double.parse(bmi.toStringAsFixed(1));
  }

  /// Categorizes BMI based on standard WHO guidelines
  static String getBmiCategory(double bmi) {
    if (bmi <= 0) return 'Unknown';
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Healthy Weight';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  /// Evaluates BMI with healthy weight boundaries for the given height
  static BmiResult evaluateBmi({
    required double weightKg,
    required double heightCm,
  }) {
    final bmi = calculateBmi(weightKg, heightCm);
    final category = getBmiCategory(bmi);

    double minHealthyKg = 0.0;
    double maxHealthyKg = 0.0;
    if (heightCm > 0) {
      final hm = heightCm / 100.0;
      final hm2 = hm * hm;
      minHealthyKg = double.parse((18.5 * hm2).toStringAsFixed(1));
      maxHealthyKg = double.parse((24.9 * hm2).toStringAsFixed(1));
    }

    return BmiResult(
      value: bmi,
      category: category,
      minHealthyWeightKg: minHealthyKg,
      maxHealthyWeightKg: maxHealthyKg,
    );
  }

  /// Calculates evidence-based daily protein recommendations (g/day).
  ///
  /// Factors:
  /// - Muscle gain / hypertrophy: 1.6 - 2.2 g/kg (optimal ~2.0 g/kg)
  /// - Fat loss / deficit: 1.8 - 2.4 g/kg (to preserve lean tissue)
  /// - Endurance / performance: 1.4 - 1.8 g/kg
  /// - Maintenance / general health: 1.2 - 1.6 g/kg
  static ProteinRecommendation calculateDailyProteinRecommendation({
    required double weightKg,
    String? fitnessGoal,
    String? activityLevel,
  }) {
    if (weightKg <= 0) {
      return const ProteinRecommendation(
        minGrams: 0,
        maxGrams: 0,
        targetGrams: 0,
        factorPerKg: 0,
        fitnessGoal: 'General Fitness',
        activityLevel: 'Moderate',
      );
    }

    final goalNormalized = (fitnessGoal ?? '').toLowerCase();
    final activityNormalized = (activityLevel ?? '').toLowerCase();

    double minFactor = 1.2;
    double maxFactor = 1.6;
    double targetFactor = 1.4;

    if (goalNormalized.contains('muscle') ||
        goalNormalized.contains('strength') ||
        goalNormalized.contains('hypertrophy') ||
        goalNormalized.contains('bulk')) {
      minFactor = 1.6;
      maxFactor = 2.2;
      targetFactor = 2.0;
    } else if (goalNormalized.contains('fat loss') ||
        goalNormalized.contains('weight loss') ||
        goalNormalized.contains('cut') ||
        goalNormalized.contains('lean')) {
      minFactor = 1.8;
      maxFactor = 2.4;
      targetFactor = 2.0;
    } else if (goalNormalized.contains('endurance') ||
        goalNormalized.contains('stamina') ||
        goalNormalized.contains('cardio')) {
      minFactor = 1.4;
      maxFactor = 1.8;
      targetFactor = 1.6;
    }

    // Small activity level adjustment
    if (activityNormalized.contains('very') ||
        activityNormalized.contains('heavy') ||
        activityNormalized.contains('athlete')) {
      minFactor += 0.2;
      maxFactor += 0.2;
      targetFactor += 0.2;
    } else if (activityNormalized.contains('sedentary')) {
      minFactor = (minFactor - 0.2).clamp(1.0, 3.0);
      targetFactor = (targetFactor - 0.2).clamp(1.2, 3.0);
    }

    final minGrams = double.parse((weightKg * minFactor).toStringAsFixed(0));
    final maxGrams = double.parse((weightKg * maxFactor).toStringAsFixed(0));
    final targetGrams = double.parse((weightKg * targetFactor).toStringAsFixed(0));

    return ProteinRecommendation(
      minGrams: minGrams,
      maxGrams: maxGrams,
      targetGrams: targetGrams,
      factorPerKg: targetFactor,
      fitnessGoal: fitnessGoal?.isNotEmpty == true ? fitnessGoal! : 'General Fitness',
      activityLevel: activityLevel?.isNotEmpty == true ? activityLevel! : 'Moderate',
    );
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
