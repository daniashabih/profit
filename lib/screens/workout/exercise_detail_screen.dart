import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/exercise_model.dart';
import '../../providers/workout_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/fit_flow_button.dart';
import '../../widgets/workout/set_tracker_row.dart';
import '../../widgets/workout/rest_timer_dialog.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final ExerciseModel exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final workoutProv = context.watch<WorkoutProvider>();

    final currentEx = workoutProv.todayWorkout.exercises.firstWhere(
      (e) => e.id == widget.exercise.id,
      orElse: () => widget.exercise,
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          currentEx.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Rest Timer',
            icon: const Icon(Icons.timer_outlined, color: AppColors.primaryLime),
            onPressed: () => RestTimerDialog.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video / Exercise Media Hero (Screen 6 in mockup)
            Container(
              height: 210,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.gray200,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      currentEx.imageUrl.isNotEmpty
                          ? currentEx.imageUrl
                          : 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: isDark ? AppColors.darkSurfaceElevated : AppColors.gray200,
                        child: const Center(
                          child: Icon(
                            Icons.fitness_center_rounded,
                            size: 56,
                            color: AppColors.primaryLime,
                          ),
                        ),
                      ),
                    ),
                    // Dark overlay
                    Container(
                      color: Colors.black.withOpacity(0.35),
                    ),
                    // Play Button Overlay
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: AppColors.primaryLime,
                          size: 36,
                        ),
                      ),
                    ),
                    // Duration timestamp badge (02:45) at bottom right
                    Positioned(
                      bottom: 12,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '02:45',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Exercise Title & Subtitle
            Text(
              currentEx.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  currentEx.muscleGroup.displayName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const Text(' • '),
                Text(
                  'Compound',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 3 Stat Badges: Sets | Reps | Rest (matching Screen 6)
            Row(
              children: [
                _buildBadge(Icons.repeat_rounded, '${currentEx.sets} Sets', isDark),
                const SizedBox(width: 8),
                _buildBadge(Icons.bolt_rounded, '${currentEx.reps} Reps', isDark),
                const SizedBox(width: 8),
                _buildBadge(Icons.timer_outlined, 'Rest ${currentEx.restTimeSeconds}s', isDark, isHighlight: true),
              ],
            ),
            const SizedBox(height: 24),

            // Section: Track Your Sets
            const Text(
              'Track Your Sets',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 12),

            // Table Header: Set | Weight (kg) | Reps | Check
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  const SizedBox(
                    width: 32,
                    child: Text(
                      'Set',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Weight (kg)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Reps',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const SizedBox(
                    width: 32,
                    child: Center(
                      child: Icon(Icons.check_circle_outline, size: 18),
                    ),
                  ),
                ],
              ),
            ),

            // Set Tracker Rows
            ...List.generate(currentEx.setsList.length, (index) {
              final setItem = currentEx.setsList[index];
              return SetTrackerRow(
                set: setItem,
                onSetChanged: (updated) {
                  workoutProv.updateSet(currentEx.id, index, updated);
                  if (updated.isCompleted) {
                    workoutProv.startRestTimer(seconds: currentEx.restTimeSeconds);
                    RestTimerDialog.show(context);
                  }
                },
              );
            }),
            const SizedBox(height: 12),

            // + Add Set Button (dashed/outlined)
            FitFlowButton(
              text: '+ Add Set',
              isOutlined: true,
              height: 48,
              borderRadius: 24,
              onPressed: () {
                workoutProv.addSet(currentEx.id);
              },
            ),
            const SizedBox(height: 16),

            // Complete Exercise Button (Lime Pill)
            FitFlowButton(
              text: 'Complete Exercise',
              height: 52,
              borderRadius: 26,
              onPressed: () {
                workoutProv.completeExercise(currentEx.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🎉 ${currentEx.name} completed! Take a quick rest.'),
                    backgroundColor: const Color(0xFF1E293B),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                RestTimerDialog.show(context);
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text, bool isDark, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: isHighlight
            ? AppColors.primaryLime.withOpacity(0.18)
            : (isDark ? AppColors.darkSurfaceElevated : AppColors.gray100),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlight
              ? AppColors.primaryLime
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isHighlight ? AppColors.primaryLime : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isHighlight && !isDark
                  ? const Color(0xFF111827)
                  : (isHighlight
                      ? AppColors.primaryLime
                      : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
            ),
          ),
        ],
      ),
    );
  }
}
