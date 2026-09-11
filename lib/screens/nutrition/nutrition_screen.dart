import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/enums/meal_type.dart';
import '../../models/nutrition_model.dart';
import '../../providers/nutrition_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/fit_flow_card.dart';
import '../../widgets/nutrition/calorie_ring_widget.dart';
import '../../widgets/nutrition/macro_bar_widget.dart';
import 'add_meal_dialog.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nutritionProv = context.watch<NutritionProvider>();
    final today = nutritionProv.todayNutrition;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Nutrition Tracker',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Add Meal',
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryLime, size: 26),
            onPressed: () => AddMealDialog.show(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calorie Ring & Summary Card
            FitFlowCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Calorie Ring
                      CalorieRingWidget(
                        consumedCalories: today.consumedCalories,
                        targetCalories: today.targetCalories,
                        size: 160,
                      ),
                      // Macro Progress Bars
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MacroBarWidget(
                                label: 'Protein',
                                currentGrams: today.consumedProtein,
                                targetGrams: today.targetProteinGrams,
                                barColor: AppColors.proteinColor,
                              ),
                              const SizedBox(height: 14),
                              MacroBarWidget(
                                label: 'Carbs',
                                currentGrams: today.consumedCarbs,
                                targetGrams: today.targetCarbsGrams,
                                barColor: AppColors.carbsColor,
                              ),
                              const SizedBox(height: 14),
                              MacroBarWidget(
                                label: 'Fat',
                                currentGrams: today.consumedFat,
                                targetGrams: today.targetFatGrams,
                                barColor: AppColors.fatColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Meals Breakdown Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'MEALS TODAY',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                GestureDetector(
                  onTap: () => AddMealDialog.show(context),
                  child: const Row(
                    children: [
                      Icon(Icons.add_rounded, size: 16, color: AppColors.primaryLime),
                      SizedBox(width: 4),
                      Text(
                        'Add Meal',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryLime,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 4 Meal Sections: Breakfast, Lunch, Dinner, Snack
            ...MealType.values.map((type) {
              return _buildMealCategorySection(
                context,
                type: type,
                today: today,
                isDark: isDark,
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCategorySection(
    BuildContext context, {
    required MealType type,
    required DailyNutritionModel today,
    required bool isDark,
  }) {
    final meals = today.getMealsByType(type);
    final totalCals = today.getCaloriesByType(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          // Section title bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceElevated : AppColors.gray100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getMealIcon(type),
                    size: 18,
                    color: AppColors.primaryLime,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        totalCals > 0 ? '$totalCals kcal recorded' : type.defaultTime,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  onPressed: () => AddMealDialog.show(context, initialMealType: type),
                ),
              ],
            ),
          ),

          // Logged meal items
          if (meals.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: meals.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              itemBuilder: (context, idx) {
                final item = meals[idx];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'P: ${item.proteinGrams.toStringAsFixed(0)}g • C: ${item.carbsGrams.toStringAsFixed(0)}g • F: ${item.fatGrams.toStringAsFixed(0)}g',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${item.calories} kcal',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 16),
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        onPressed: () {
                          context.read<NutritionProvider>().deleteMeal(item.id);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  IconData _getMealIcon(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.free_breakfast_rounded;
      case MealType.lunch:
        return Icons.lunch_dining_rounded;
      case MealType.dinner:
        return Icons.dinner_dining_rounded;
      case MealType.snack:
        return Icons.bakery_dining_rounded;
    }
  }
}
