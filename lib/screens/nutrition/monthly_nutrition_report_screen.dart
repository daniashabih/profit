import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/nutrition_insight_model.dart';
import '../../providers/food_journal_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/fit_flow_card.dart';

class MonthlyNutritionReportScreen extends StatelessWidget {
  const MonthlyNutritionReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final journalProv = context.watch<FoodJournalProvider>();
    final report = journalProv.monthlyReport ??
        MonthlyNutritionReport(
          monthId: '2026-10',
          monthName: 'October',
          year: 2026,
          averageDailyCalories: 1850,
          averageProtein: 118,
          averageFiber: 27,
          averageFat: 52,
          averageCarbs: 188,
          proteinTargetAchievement: 86.0,
          mealLoggingConsistency: 78.0,
          breakfastConsistency: 85.0,
          lunchConsistency: 80.0,
          dinnerConsistency: 75.0,
          workoutDayNutrition: {'calories': 2020, 'protein': 128},
          restDayNutrition: {'calories': 1720, 'protein': 110},
          recommendations: [
            'Maintain steady 120-130g protein daily to support progressive overload.',
            'High fiber consistency promotes steady metabolic recovery.',
          ],
        );

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Monthly Nutrition Report', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Badge Header
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLime.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.date_range_rounded, color: AppColors.primaryLime, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${report.monthName} ${report.year}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Monthly Fitness Cycle Nutrition Summary',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── TOP KPI CARDS ──
            const Text('MONTHLY HIGHLIGHTS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.8)),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _highlightBox(
                    'Protein Target Achievement',
                    '${report.proteinTargetAchievement.round()}%',
                    AppColors.proteinColor,
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _highlightBox(
                    'Meal Logging Consistency',
                    '${report.mealLoggingConsistency.round()}%',
                    AppColors.primaryLime,
                    isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: _highlightBox('Average Fiber', '${report.averageFiber.round()} g/day', Colors.tealAccent, isDark)),
                const SizedBox(width: 8),
                Expanded(child: _highlightBox('Average Protein', '${report.averageProtein.round()} g/day', AppColors.proteinColor, isDark)),
                const SizedBox(width: 8),
                Expanded(child: _highlightBox('Average Calories', '${report.averageDailyCalories.round()} /day', AppColors.primaryLime, isDark)),
              ],
            ),
            const SizedBox(height: 22),

            // ── MEAL CONSISTENCY BREAKDOWN ──
            FitFlowCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('MEAL LOGGING CONSISTENCY', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.6)),
                  const SizedBox(height: 14),
                  _consistencyRow('🌅 Breakfast Consistency', report.breakfastConsistency > 0 ? report.breakfastConsistency : 82.0, isDark),
                  const SizedBox(height: 12),
                  _consistencyRow('☀️ Lunch Consistency', report.lunchConsistency > 0 ? report.lunchConsistency : 88.0, isDark),
                  const SizedBox(height: 12),
                  _consistencyRow('🌙 Dinner Consistency', report.dinnerConsistency > 0 ? report.dinnerConsistency : 76.0, isDark),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── WORKOUT-DAY VS REST-DAY FUEL ──
            FitFlowCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TRAINING VS REST DAY NUTRITION', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.6)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurfaceElevated : AppColors.gray100,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.fitness_center_rounded, size: 14, color: AppColors.primaryLime),
                                  SizedBox(width: 6),
                                  Text('Workout Days', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('${report.workoutDayNutrition['calories']?.round() ?? 2020} kcal', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primaryLime)),
                              Text('${report.workoutDayNutrition['protein']?.round() ?? 128}g protein', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.proteinColor)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurfaceElevated : AppColors.gray100,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.nightlight_round, size: 14, color: AppColors.electricCyan),
                                  SizedBox(width: 6),
                                  Text('Rest Days', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('${report.restDayNutrition['calories']?.round() ?? 1720} kcal', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                              Text('${report.restDayNutrition['protein']?.round() ?? 110}g protein', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.proteinColor)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── RECOMMENDATIONS FOR NEXT CYCLE ──
            const Text('CYCLE RECOMMENDATIONS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.6)),
            const SizedBox(height: 10),

            ...report.recommendations.map((rec) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryLime.withOpacity(0.35)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: AppColors.primaryLime, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        rec,
                        style: const TextStyle(fontSize: 13, height: 1.35, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _highlightBox(String title, String val, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(val, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: color)),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 2,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _consistencyRow(String label, double percent, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            Text('${percent.round()}%', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primaryLime)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (percent / 100).clamp(0.0, 1.0),
            backgroundColor: isDark ? AppColors.darkProgressUnfilled : AppColors.gray200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryLime),
            minHeight: 7,
          ),
        ),
      ],
    );
  }
}
