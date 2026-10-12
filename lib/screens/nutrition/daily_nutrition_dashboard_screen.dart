import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/enums/meal_type.dart';
import '../../models/daily_food_summary_model.dart';
import '../../models/food_post_model.dart';
import '../../providers/food_journal_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/fit_flow_card.dart';
import 'add_food_post_screen.dart';
import 'meal_nutrition_detail_screen.dart';
import 'nutrition_insights_screen.dart';

class DailyNutritionDashboardScreen extends StatefulWidget {
  const DailyNutritionDashboardScreen({super.key});

  @override
  State<DailyNutritionDashboardScreen> createState() => _DailyNutritionDashboardScreenState();
}

class _DailyNutritionDashboardScreenState extends State<DailyNutritionDashboardScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final journalProv = context.watch<FoodJournalProvider>();
    final summary = journalProv.selectedDateSummary ??
        DailyFoodSummary.fromPosts(
          date: _selectedDate,
          posts: [],
          targetCalories: 2000,
          targetProtein: 130,
        );

    final isToday = _selectedDate.year == DateTime.now().year &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.day == DateTime.now().day;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Daily Food Journal', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights_rounded, color: AppColors.primaryLime),
            tooltip: 'Nutrition Insights',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NutritionInsightsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryLime, size: 26),
            tooltip: 'Add Food',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddFoodPostScreen()),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── DATE NAVIGATION BAR ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, size: 22),
                    onPressed: () {
                      final newDate = _selectedDate.subtract(const Duration(days: 1));
                      setState(() => _selectedDate = newDate);
                      journalProv.setSelectedDate(newDate);
                    },
                  ),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primaryLime),
                      const SizedBox(width: 8),
                      Text(
                        isToday ? 'Today, ${DateFormat('MMM d').format(_selectedDate)}' : DateFormat('EEE, MMM d, yyyy').format(_selectedDate),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, size: 22),
                    onPressed: () {
                      final newDate = _selectedDate.add(const Duration(days: 1));
                      setState(() => _selectedDate = newDate);
                      journalProv.setSelectedDate(newDate);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── DAILY TOTALS & TARGET COMPARISON CARD ──
            FitFlowCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('DAILY TARGETS & REMAINING', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.6)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.primaryLime.withOpacity(0.18), borderRadius: BorderRadius.circular(12)),
                        child: Text('${summary.totalCalories} / ${summary.targetCalories} kcal',
                            style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryLime, fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Remaining Badges
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
                              Text('Remaining Protein', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                              const SizedBox(height: 4),
                              Text('${summary.remainingProtein} g', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.proteinColor)),
                              const SizedBox(height: 2),
                              Text('${summary.totalProtein.round()} / ${summary.targetProtein.round()} g consumed', style: TextStyle(fontSize: 10.5, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
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
                              Text('Remaining Calories', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                              const SizedBox(height: 4),
                              Text('${summary.remainingCalories} kcal', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primaryLime)),
                              const SizedBox(height: 2),
                              Text('${summary.totalCalories} / ${summary.targetCalories} kcal', style: TextStyle(fontSize: 10.5, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Macro progress bars
                  _macroProgress('Protein', summary.totalProtein, summary.targetProtein, 'g', AppColors.proteinColor, isDark),
                  const SizedBox(height: 10),
                  _macroProgress('Carbs', summary.totalCarbs, summary.targetCarbs, 'g', AppColors.carbsColor, isDark),
                  const SizedBox(height: 10),
                  _macroProgress('Fat', summary.totalFat, summary.targetFat, 'g', AppColors.fatColor, isDark),
                  const SizedBox(height: 10),
                  _macroProgress('Fiber', summary.totalFiber, summary.targetFiber, 'g', Colors.tealAccent, isDark),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // ── MEAL TIMELINE SECTION (Breakfast, Lunch, Dinner, Snacks, Drinks, Other) ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('MEAL TIMELINE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 0.8)),
                Text('${summary.posts.length} Meals Logged', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
              ],
            ),
            const SizedBox(height: 12),

            ...MealType.values.map((type) {
              final mealsForType = summary.postsByMealType[type] ?? [];
              return _buildMealTimelineSlot(type, mealsForType, isDark);
            }),

            const SizedBox(height: 18),

            // ── DAILY TOTALS RECAP CARD ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('DAY TOTALS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.8)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _recapItem('Calories', '${summary.totalCalories} kcal', isDark),
                      _recapItem('Protein', '${summary.totalProtein} g', isDark, color: AppColors.proteinColor),
                      _recapItem('Carbs', '${summary.totalCarbs} g', isDark, color: AppColors.carbsColor),
                      _recapItem('Fat', '${summary.totalFat} g', isDark, color: AppColors.fatColor),
                      _recapItem('Fiber', '${summary.totalFiber} g', isDark, color: Colors.tealAccent),
                    ],
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

  Widget _buildMealTimelineSlot(MealType type, List<FoodPost> posts, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(type.emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Text(type.displayName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  ],
                ),
                if (posts.isEmpty)
                  TextButton.icon(
                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Log', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AddFoodPostScreen(initialMealType: type)),
                      );
                    },
                  )
                else
                  Text(
                    '${posts.fold(0, (sum, p) => sum + p.calories)} kcal',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.primaryLime),
                  ),
              ],
            ),
          ),
          if (posts.isNotEmpty) ...[
            const Divider(height: 1),
            ...posts.map((post) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MealNutritionDetailScreen(post: post)),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      // Food thumbnail
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: isDark ? AppColors.darkSurfaceElevated : AppColors.gray200,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: post.imageUrl.isNotEmpty
                            ? Image.network(post.imageUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Center(child: Text(type.emoji)))
                            : Center(child: Text(type.emoji)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(post.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text(
                              post.detectedFoods.map((f) => f.name).take(3).join(' • '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${post.calories} kcal', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                          Text('${post.protein}g P', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.proteinColor)),
                        ],
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right_rounded, size: 18),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _macroProgress(String label, double value, double target, String unit, Color color, bool isDark) {
    final progress = target > 0 ? (value / target).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            Text('${value.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} $unit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: isDark ? AppColors.darkProgressUnfilled : AppColors.gray200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _recapItem(String label, String value, bool isDark, {Color? color}) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color ?? (isDark ? Colors.white : Colors.black87))),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
      ],
    );
  }
}
