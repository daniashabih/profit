import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/monthly_cycle_model.dart';

/// Screen presenting the end-of-month progress review and transition to the next month's cycle:
/// Displays weight change, BMI delta, workout adherence rate, and protein consistency,
/// followed by the newly generated plan.
class MonthlyReviewScreen extends StatelessWidget {
  final MonthlyCycle cycle;
  final VoidCallback onDismiss;

  const MonthlyReviewScreen({
    super.key,
    required this.cycle,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final endingWeight = cycle.endingWeight ?? cycle.startingWeight;
    final weightDelta = double.parse((endingWeight - cycle.startingWeight).toStringAsFixed(1));
    final endingBmi = cycle.endingBmi ?? cycle.startingBmi;
    final workoutRate = cycle.workoutCompletionRate ?? 80.0;
    final proteinRate = cycle.proteinGoalCompletionRate ?? 75.0;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('${cycle.monthName} Review'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primaryLime.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.workspace_premium_rounded, color: AppColors.primaryLime, size: 40),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${cycle.monthName} Fitness Cycle Complete!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Here is how you performed across weight, workout adherence, and nutrition consistency over the past cycle.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              // Metric Cards Grid
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      label: 'WEIGHT',
                      value: '${cycle.startingWeight} → $endingWeight kg',
                      subtext: weightDelta <= 0
                          ? '↓ ${weightDelta.abs()} kg'
                          : '↑ $weightDelta kg',
                      isPositive: true,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildMetricTile(
                      label: 'BMI',
                      value: '${cycle.startingBmi} → $endingBmi',
                      subtext: 'Calculated metric',
                      isPositive: true,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      label: 'WORKOUT ADHERENCE',
                      value: '${workoutRate.toStringAsFixed(0)}%',
                      subtext: 'Scheduled sessions crushed',
                      isPositive: workoutRate >= 70,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildMetricTile(
                      label: 'PROTEIN GOAL',
                      value: '${proteinRate.toStringAsFixed(0)}%',
                      subtext: 'Macro target achieved',
                      isPositive: proteinRate >= 70,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Next Month Teaser Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppColors.darkCardBackground, AppColors.darkSurface]
                        : [AppColors.lightCardBackground, AppColors.lightSurface],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryLime.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: AppColors.primaryLime, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Your Next Month Plan is Ready',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'PROFIT has automatically applied progressive overload and updated your nutrition targets based on this month\'s consistency.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // CTA button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    onDismiss();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLime,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Text(
                    'View New Month Plan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required String subtext,
    required bool isPositive,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            subtext,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isPositive ? AppColors.primaryLime : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}
