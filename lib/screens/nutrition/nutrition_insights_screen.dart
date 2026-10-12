import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/food_journal_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/fit_flow_card.dart';
import 'monthly_nutrition_report_screen.dart';

class NutritionInsightsScreen extends StatelessWidget {
  const NutritionInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final journalProv = context.watch<FoodJournalProvider>();
    final insights = journalProv.weeklyInsights;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Nutrition Insights', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.calendar_month_rounded, size: 16),
            label: const Text('Monthly Report', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MonthlyNutritionReportScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER CARD ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLime.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.analytics_rounded, color: AppColors.primaryLime, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Weekly Rolling Analysis', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        const SizedBox(height: 2),
                        Text(
                          insights != null
                              ? '${DateFormat('MMM d').format(insights.weekStartDate)} - ${DateFormat('MMM d, yyyy').format(insights.weekEndDate)}'
                              : 'Current Week',
                          style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── TARGET ACHIEVEMENT BARS ──
            const Text('WEEKLY NUTRITION GOAL ADHERENCE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.6)),
            const SizedBox(height: 10),

            if (insights != null) ...[
              FitFlowCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _achievementRow('Protein Target', insights.proteinTargetAchievement, AppColors.proteinColor, isDark),
                    const SizedBox(height: 14),
                    _achievementRow('Fiber Target', insights.fiberTargetAchievement, Colors.tealAccent, isDark),
                    const SizedBox(height: 14),
                    _achievementRow('Calories Target', insights.caloriesTargetAchievement, AppColors.primaryLime, isDark),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ── 7-DAY DAILY AVERAGES ──
              const Text('WEEKLY DAILY AVERAGES', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.6)),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(child: _statBox('Avg Calories', '${insights.averageDailyCalories.round()} kcal', isDark, AppColors.primaryLime)),
                  const SizedBox(width: 10),
                  Expanded(child: _statBox('Avg Protein', '${insights.averageDailyProtein.round()} g', isDark, AppColors.proteinColor)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _statBox('Avg Fiber', '${insights.averageDailyFiber.round()} g', isDark, Colors.tealAccent)),
                  const SizedBox(width: 10),
                  Expanded(child: _statBox('Avg Carbs', '${insights.averageDailyCarbs.round()} g', isDark, AppColors.carbsColor)),
                  const SizedBox(width: 10),
                  Expanded(child: _statBox('Avg Fat', '${insights.averageDailyFat.round()} g', isDark, AppColors.fatColor)),
                ],
              ),
              const SizedBox(height: 24),

              // ── DYNAMIC HABIT & NUTRITION INSIGHTS ──
              const Text('DATA-DRIVEN INSIGHTS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.6)),
              const SizedBox(height: 10),

              ...insights.insights.map((text) {
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
                      const Icon(Icons.tips_and_updates_outlined, color: AppColors.primaryLime, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          text,
                          style: const TextStyle(fontSize: 13, height: 1.35, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],

            const SizedBox(height: 20),

            // ── MONTHLY REPORT CTA ──
            FitFlowCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.calendar_month_rounded, color: AppColors.primaryLime, size: 20),
                      SizedBox(width: 8),
                      Text('Monthly Cycle Report', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Analyze your 30-day nutrition consistency, workout-day vs rest-day fuel, and export metrics to the next monthly cycle.',
                    style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryLime),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.primaryLime, size: 16),
                    label: const Text('View Monthly Nutrition Report', style: TextStyle(color: AppColors.primaryLime, fontWeight: FontWeight.w700)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MonthlyNutritionReportScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _achievementRow(String label, double achievementRatio, Color color, bool isDark) {
    final pct = (achievementRatio * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            Text('$pct%', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: achievementRatio.clamp(0.0, 1.0),
            backgroundColor: isDark ? AppColors.darkProgressUnfilled : AppColors.gray200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _statBox(String title, String val, bool isDark, Color accent) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
          const SizedBox(height: 4),
          Text(val, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: accent)),
        ],
      ),
    );
  }
}
