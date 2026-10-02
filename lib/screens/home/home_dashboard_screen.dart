import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/animations/animations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/self_trainer_cycle_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/profit_logo.dart';
import '../ai_coach/ai_coach_screen.dart';
import '../notifications/notifications_screen.dart';
import '../self_trainer/today_workout_screen.dart';
import '../self_trainer/edit_fitness_profile_dialog.dart';
import '../self_trainer/monthly_history_screen.dart';
import '../self_trainer/monthly_review_screen.dart';

/// Complete Dynamic Self Trainer Daily Dashboard for PROFIT.
/// Matches Section 18 layout and Section 28 dynamic calculations:
/// - Real user data from Cloud Firestore / SelfTrainerCycleProvider
/// - Automatic BMI, WHO category badge, and Target Weight remaining
/// - Dynamic Today's Workout with exercise completion progress
/// - Rest Day smart empty state
/// - Daily Protein target, consumed, and remaining metrics with macro progress
/// - Today's Meals (Breakfast, Lunch, Snack, Dinner) with one-tap consumption toggle
/// - Monthly cycle review prompts and historical cycle inspection
class HomeDashboardScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const HomeDashboardScreen({super.key, this.onNavigateTab});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      final cycleProv = context.read<SelfTrainerCycleProvider>();
      if (user != null && cycleProv.fitnessProfile == null) {
        cycleProv.initializeForUser(user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProv = context.watch<AuthProvider>();
    final cycleProv = context.watch<SelfTrainerCycleProvider>();
    final user = authProv.user;
    final userName = user?.name.split(' ').first ?? 'Dania';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        titleSpacing: 12,
        leadingWidth: 54,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Center(
            child: ProFitLogo(
              size: 36,
              showText: false,
              showContainer: true,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning, $userName 👋',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              cycleProv.currentCycle != null
                  ? '${cycleProv.currentCycle!.monthName} Cycle • ${cycleProv.goalType}'
                  : 'PROFIT Dynamic Fitness Cycle',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
        actions: [
          // Edit Fitness Profile Button
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, size: 26),
            tooltip: 'Edit Fitness Profile',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const EditFitnessProfileDialog(),
              );
            },
          ),
          // Past Monthly Cycles History
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined, size: 24),
            tooltip: 'Monthly Cycles History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MonthlyHistoryScreen()),
              );
            },
          ),
          // Notification Bell
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, size: 26),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryLime,
        onRefresh: () async {
          if (user != null) {
            await cycleProv.initializeForUser(user);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // 0. MONTHLY REVIEW ALERT BANNER (If available)
              // ==========================================
              if (cycleProv.cycleToReview != null) ...[
                StaggeredEntrance(
                  index: 0,
                  child: _buildMonthlyReviewBanner(context, cycleProv, isDark),
                ),
                const SizedBox(height: 18),
              ],

              // ==========================================
              // 1. YOUR GOAL SECTION
              // ==========================================
              StaggeredEntrance(
                index: 0,
                child: _buildGoalHeader(cycleProv, isDark),
              ),
              const SizedBox(height: 14),

              // ==========================================
              // 2. WEIGHT & BMI CARDS (Section 18)
              // ==========================================
              StaggeredEntrance(
                index: 1,
                child: _buildWeightAndBmiRow(cycleProv, isDark),
              ),
              const SizedBox(height: 14),

              // ==========================================
              // 3. TARGET WEIGHT PROGRESS BAR (Section 26)
              // ==========================================
              StaggeredEntrance(
                index: 2,
                child: _buildTargetWeightProgress(cycleProv, isDark),
              ),
              const SizedBox(height: 20),

              // ==========================================
              // 4. TODAY'S WORKOUT CARD (Section 14 & 18)
              // ==========================================
              StaggeredEntrance(
                index: 3,
                child: _buildTodayWorkoutCard(context, cycleProv, isDark),
              ),
              const SizedBox(height: 20),

              // ==========================================
              // 5. DAILY PROTEIN TRACKING CARD (Section 16 & 18)
              // ==========================================
              StaggeredEntrance(
                index: 4,
                child: _buildDailyProteinCard(cycleProv, isDark),
              ),
              const SizedBox(height: 20),

              // ==========================================
              // 6. TODAY'S MEALS SECTION (Section 17 & 18)
              // ==========================================
              StaggeredEntrance(
                index: 5,
                child: _buildTodayMealsSection(cycleProv, isDark),
              ),
              const SizedBox(height: 20),

              // ==========================================
              // 7. PROGRESS & STREAK SECTION
              // ==========================================
              StaggeredEntrance(
                index: 6,
                child: _buildProgressAndStreak(user?.streakDays ?? 5, cycleProv, isDark),
              ),
              const SizedBox(height: 20),

              // ==========================================
              // 8. AI COACH GUIDANCE SHORTCUT
              // ==========================================
              StaggeredEntrance(
                index: 7,
                child: _buildAiCoachShortcut(context, isDark),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyReviewBanner(
    BuildContext context,
    SelfTrainerCycleProvider cycleProv,
    bool isDark,
  ) {
    final cycle = cycleProv.cycleToReview!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLime.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryLime, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars_rounded, color: AppColors.primaryLime, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${cycle.monthName} Review Ready',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  'Review your monthly performance and view your next plan.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MonthlyReviewScreen(
                    cycle: cycle,
                    onDismiss: () => cycleProv.dismissMonthlyReview(),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLime,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Review', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalHeader(SelfTrainerCycleProvider cycleProv, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Goal',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              cycleProv.goalType,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          child: Row(
            children: [
              const Icon(Icons.repeat_rounded, size: 14, color: AppColors.primaryLime),
              const SizedBox(width: 6),
              Text(
                '${cycleProv.fitnessProfile?.trainingDaysPerWeek ?? 4} Days / Wk',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeightAndBmiRow(SelfTrainerCycleProvider cycleProv, bool isDark) {
    return Row(
      children: [
        // Current Weight Card
        Expanded(
          child: Container(
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
                  '${cycleProv.currentWeight.toStringAsFixed(1)} kg',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  'Weight',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      cycleProv.weightDeltaKg <= 0
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      size: 14,
                      color: AppColors.primaryLime,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${cycleProv.weightDeltaKg <= 0 ? '↓' : '↑'} ${cycleProv.weightDeltaKg.abs()} kg',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryLime,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Calculated BMI Card
        Expanded(
          child: Container(
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
                  cycleProv.bmi.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  'BMI',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLime.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    cycleProv.bmiCategory,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryLime,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTargetWeightProgress(SelfTrainerCycleProvider cycleProv, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current: ${cycleProv.currentWeight.toStringAsFixed(1)} kg',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              Text(
                'Target: ${cycleProv.targetWeight.toStringAsFixed(1)} kg',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryLime),
              ),
              Text(
                '${cycleProv.weightRemainingKg.toStringAsFixed(1)} kg remaining',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: cycleProv.targetWeightProgress.clamp(0.0, 1.0)),
              duration: AppAnimations.slowDuration,
              curve: AppAnimations.curveAthletic,
              builder: (context, animatedVal, _) {
                return LinearProgressIndicator(
                  value: animatedVal,
                  minHeight: 7,
                  backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryLime),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayWorkoutCard(
    BuildContext context,
    SelfTrainerCycleProvider cycleProv,
    bool isDark,
  ) {
    final today = cycleProv.todayWorkoutDay;
    final isRest = cycleProv.isTodayRestDay || today == null;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLime.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'TODAY\'S WORKOUT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: AppColors.primaryLime,
                  ),
                ),
              ),
              if (!isRest)
                Text(
                  '${(cycleProv.todayWorkoutProgress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
            ],
          ),
          const SizedBox(height: 14),

          if (isRest) ...[
            // Smart Empty State: Rest Day
            const Row(
              children: [
                Icon(Icons.nightlight_round, color: AppColors.primaryLime, size: 24),
                SizedBox(width: 10),
                Text(
                  'Rest Day',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Your body needs recovery too. Cellular repair happens during restorative rest.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.schedule_rounded, size: 16, color: AppColors.primaryLime),
                  SizedBox(width: 8),
                  Text(
                    'Next workout: Tomorrow — Progressive Routine',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ] else ...[
            Text(
              today.workoutType,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
            ),
            const SizedBox(height: 4),
            Text(
              '${cycleProv.todayCompletedExercisesCount} / ${cycleProv.todayTotalExercisesCount} exercises completed',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: cycleProv.todayWorkoutProgress.clamp(0.0, 1.0)),
                duration: AppAnimations.slowDuration,
                curve: AppAnimations.curveAthletic,
                builder: (context, animatedVal, _) {
                  return LinearProgressIndicator(
                    value: animatedVal,
                    minHeight: 7,
                    backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryLime),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TodayWorkoutScreen(workoutDay: today),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLime,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  cycleProv.isTodayWorkoutFinished
                      ? 'Workout Completed ✓'
                      : (cycleProv.todayCompletedExercisesCount > 0 ? 'Continue Workout →' : 'Start Workout →'),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDailyProteinCard(SelfTrainerCycleProvider cycleProv, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Protein Target',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              Text(
                '${cycleProv.dailyProteinConsumed.toStringAsFixed(0)}g / ${cycleProv.dailyProteinTarget.toStringAsFixed(0)}g',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryLime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: cycleProv.dailyProteinProgress.clamp(0.0, 1.0)),
              duration: AppAnimations.slowDuration,
              curve: AppAnimations.curveAthletic,
              builder: (context, animatedVal, _) {
                return LinearProgressIndicator(
                  value: animatedVal,
                  minHeight: 10,
                  backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryLime),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Remaining: ${cycleProv.dailyProteinRemaining.toStringAsFixed(0)}g',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              Text(
                '${(cycleProv.dailyProteinProgress * 100).toStringAsFixed(0)}% achieved',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayMealsSection(SelfTrainerCycleProvider cycleProv, bool isDark) {
    final mealPlan = cycleProv.currentMealPlan;
    final meals = mealPlan?.meals ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Today\'s Meals',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              GestureDetector(
                onTap: () => widget.onNavigateTab?.call(2), // Navigate to Nutrition Screen
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryLime,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (meals.isEmpty) ...[
            // Smart Empty State: No Meals Logged
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    const Icon(Icons.restaurant_menu_rounded, color: Colors.grey, size: 36),
                    const SizedBox(height: 8),
                    const Text('No meals logged today', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      'Start tracking your nutrition to hit your protein targets.',
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.grey : Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            ...meals.map((meal) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: meal.isConsumed
                        ? AppColors.primaryLime.withValues(alpha: 0.08)
                        : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          meal.isConsumed ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                          color: meal.isConsumed ? AppColors.primaryLime : Colors.grey,
                          size: 22,
                        ),
                        onPressed: () {
                          cycleProv.toggleMealConsumed(meal.id, !meal.isConsumed);
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meal.mealType,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                decoration: meal.isConsumed ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            Text(
                              '${meal.name} • ${meal.proteinGrams.toStringAsFixed(0)}g protein',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${meal.calories} kcal',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
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

  Widget _buildProgressAndStreak(int streakDays, SelfTrainerCycleProvider cycleProv, bool isDark) {
    return PressableScale(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Row(
          children: [
            PulsingGlow(
              glowColor: Colors.orange,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(child: Text('🔥', style: TextStyle(fontSize: 22))),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$streakDays Day Activity Streak',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Weight change: ${cycleProv.weightDeltaKg <= 0 ? '↓' : '↑'} ${cycleProv.weightDeltaKg.abs()} kg this cycle',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiCoachShortcut(BuildContext context, bool isDark) {
    return PressableScale(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AiCoachScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161E28) : const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryLime.withValues(alpha: 0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: AppColors.primaryLime, size: 22),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ask PROFIT Coach',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Get AI advice on workouts, recovery, and nutrition',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: AppColors.primaryLime, size: 20),
          ],
        ),
      ),
    );
  }
}
