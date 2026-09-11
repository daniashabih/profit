import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/workout_provider.dart';
import '../../providers/progress_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/fit_flow_card.dart';
import '../../widgets/common/fit_flow_button.dart';
import '../workout/exercise_detail_screen.dart';
import '../ai_coach/ai_coach_screen.dart';
import '../notifications/notifications_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  final ValueChanged<int>? onNavigateTab;

  const HomeDashboardScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProv = context.watch<AuthProvider>();
    final workoutProv = context.watch<WorkoutProvider>();
    final progressProv = context.watch<ProgressProvider>();

    final user = authProv.user;
    final todayWorkout = workoutProv.todayWorkout;
    final userName = user?.name.split(' ').first ?? 'Alex';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        titleSpacing: 24,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Morning, $userName 👋',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Ready to crush today\'s workout?',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, size: 24),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 1. AI HERO CARD: WHAT SHOULD I DO TODAY?
            // ==========================================
            _buildAiRecommendationHero(context, isDark),
            const SizedBox(height: 24),

            // ==========================================
            // 2. TODAY'S WORKOUT HERO CARD
            // ==========================================
            _buildSectionHeader('TODAY\'S WORKOUT', actionText: 'View All', onAction: () {
              onNavigateTab?.call(1); // Navigate to Workout tab
            }),
            const SizedBox(height: 12),
            _buildTodayWorkoutHero(context, todayWorkout, isDark),
            const SizedBox(height: 24),

            // ==========================================
            // 3. YOUR PROGRESS CARDS
            // ==========================================
            _buildSectionHeader('YOUR PROGRESS', actionText: 'Details', onAction: () {
              onNavigateTab?.call(3); // Navigate to Progress tab
            }),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FitFlowCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Current Weight',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                            const Icon(
                              Icons.monitor_weight_outlined,
                              size: 18,
                              color: AppColors.primaryLime,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${progressProv.currentWeight.toStringAsFixed(1)} kg',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.arrow_downward_rounded,
                                size: 14, color: AppColors.success),
                            const SizedBox(width: 2),
                            Text(
                              '-6.5 kg total',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.success
                                    : const Color(0xFF15803D),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: FitFlowCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Goal Progress',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                            const Icon(
                              Icons.flag_outlined,
                              size: 18,
                              color: AppColors.info,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '85%',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: const LinearProgressIndicator(
                            value: 0.85,
                            minHeight: 6,
                            backgroundColor: Color(0xFF1E293B),
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLime),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ==========================================
            // 4. THIS WEEK ACTIVITY (M T W T F S S)
            // ==========================================
            _buildSectionHeader('THIS WEEK'),
            const SizedBox(height: 12),
            _buildThisWeekActivity(progressProv.weeklyActivity, isDark),
            const SizedBox(height: 24),

            // ==========================================
            // 5. FITNESS STREAK
            // ==========================================
            _buildStreakCard(user?.streakDays ?? 5, isDark),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {String? actionText, VoidCallback? onAction}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        if (actionText != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionText,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryLime,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAiRecommendationHero(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF17202A) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? AppColors.primaryLime.withOpacity(0.3)
              : const Color(0xFF93C5FD),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLime.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primaryLime,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'WHAT SHOULD I DO TODAY?',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: AppColors.primaryLime,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AiCoachScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'AI Coach',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                      Icon(Icons.chevron_right, size: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Hit your Upper Body workout today to stay on track with your weekly hypertrophy plan. Stay hydrated with at least 3L of water!',
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          // Possible Actions chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildActionChip(
                  icon: Icons.fitness_center_rounded,
                  label: 'Workout',
                  isPrimary: true,
                  onTap: () => onNavigateTab?.call(1),
                ),
                const SizedBox(width: 8),
                _buildActionChip(
                  icon: Icons.restaurant_rounded,
                  label: 'Nutrition',
                  isPrimary: false,
                  onTap: () => onNavigateTab?.call(2),
                ),
                const SizedBox(width: 8),
                _buildActionChip(
                  icon: Icons.spa_rounded,
                  label: 'Recovery',
                  isPrimary: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AiCoachScreen()),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _buildActionChip(
                  icon: Icons.water_drop_rounded,
                  label: 'Hydration',
                  isPrimary: false,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Logged 500ml water! 💧 Total: 2.5L / 3.0L'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isPrimary ? AppColors.primaryLime : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPrimary ? AppColors.primaryLime : AppColors.darkBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isPrimary ? const Color(0xFF111827) : Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isPrimary ? const Color(0xFF111827) : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayWorkoutHero(
    BuildContext context,
    dynamic workout,
    bool isDark,
  ) {
    return FitFlowCard(
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
                  color: AppColors.primaryLime.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'TODAY\'S TARGET',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppColors.primaryLime,
                  ),
                ),
              ),
              Text(
                'Progress: 70%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.primaryLime : const Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            workout.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.fitness_center_rounded,
                size: 16,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
              const SizedBox(width: 6),
              Text(
                '7 Exercises • 38 Minutes',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const LinearProgressIndicator(
              value: 0.71, // 5 of 7 completed
              minHeight: 8,
              backgroundColor: Color(0xFF1F2937),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLime),
            ),
          ),
          const SizedBox(height: 20),
          // CTA button: START WORKOUT ->
          FitFlowButton(
            text: 'START WORKOUT →',
            onPressed: () {
              if (workout.exercises.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExerciseDetailScreen(
                      exercise: workout.exercises.first,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThisWeekActivity(List<bool> weeklyActivity, bool isDark) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return FitFlowCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(days.length, (index) {
          final isDone = index < weeklyActivity.length ? weeklyActivity[index] : false;
          final isToday = index == 4; // Friday

          return Column(
            children: [
              Text(
                days[index],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isToday
                      ? AppColors.primaryLime
                      : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone
                      ? AppColors.primaryLime
                      : (isDark ? AppColors.darkSurfaceElevated : AppColors.gray200),
                  border: isToday
                      ? Border.all(color: AppColors.primaryLime, width: 2)
                      : null,
                ),
                child: Center(
                  child: isDone
                      ? const Icon(
                          Icons.check_rounded,
                          size: 18,
                          color: Color(0xFF111827),
                        )
                      : Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? AppColors.darkTextMuted : AppColors.gray300,
                          ),
                        ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStreakCard(int streakDays, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E222A), const Color(0xFF14171E)]
              : [const Color(0xFFF1F5F9), Colors.white],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Text(
                '🔥',
                style: TextStyle(fontSize: 30),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streakDays Day Streak',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Keep going! You are 2 days away from your personal record.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
