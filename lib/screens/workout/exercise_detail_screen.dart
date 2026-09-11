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

    // Grab latest reference from provider if it's in today's workout
    final currentEx = workoutProv.todayWorkout.exercises.firstWhere(
      (e) => e.id == widget.exercise.id,
      orElse: () => widget.exercise,
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          currentEx.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: Icon(
              currentEx.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: currentEx.isFavorite ? Colors.redAccent : null,
            ),
            onPressed: () {
              workoutProv.toggleExerciseFavorite(currentEx.id);
            },
          ),
          IconButton(
            tooltip: 'Rest Timer',
            icon: const Icon(Icons.timer_outlined, color: AppColors.primaryLime),
            onPressed: () => RestTimerDialog.show(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise Media Hero Card
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.gray200,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    currentEx.imageUrl.isNotEmpty
                        ? Image.network(
                            currentEx.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _buildFallbackHero(),
                          )
                        : _buildFallbackHero(),
                    // Overlay with play button
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: AppColors.primaryLime,
                          size: 38,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Badges Row: Muscle, Equipment, Difficulty, Rest Timer
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChip(currentEx.muscleGroup.displayName, Icons.accessibility_new_rounded, isDark),
                _buildChip(currentEx.equipment, Icons.fitness_center_rounded, isDark),
                _buildChip(currentEx.difficulty.displayName, Icons.speed_rounded, isDark),
                _buildChip('${currentEx.restTimeSeconds}s Rest', Icons.timer_outlined, isDark, isHighlight: true),
              ],
            ),
            const SizedBox(height: 24),

            // Instructions expandable
            if (currentEx.instructions.isNotEmpty) ...[
              const Text(
                'FORM GUIDELINES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  children: List.generate(currentEx.instructions.length, (idx) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${idx + 1}. ',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryLime,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              currentEx.instructions[idx],
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 28),
            ],

            // SET TRACKING SECTION (Set | Weight | Reps | Status)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SET LOGGING',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  '${currentEx.completedSetsCount}/${currentEx.setsList.length} Completed',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.primaryLime : const Color(0xFF111827),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Header labels: Set | Weight | Reps | Status
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  const SizedBox(
                    width: 28,
                    child: Text(
                      'SET',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'WEIGHT (KG)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'REPS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const SizedBox(
                    width: 32,
                    child: Center(
                      child: Text(
                        'DONE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Set Tracker Rows
            ...List.generate(currentEx.setsList.length, (index) {
              final setItem = currentEx.setsList[index];
              return SetTrackerRow(
                set: setItem,
                onSetChanged: (updated) {
                  workoutProv.updateSet(currentEx.id, index, updated);
                  if (updated.isCompleted) {
                    // Trigger rest timer
                    workoutProv.startRestTimer(seconds: currentEx.restTimeSeconds);
                    RestTimerDialog.show(context);
                  }
                },
              );
            }),
            const SizedBox(height: 12),

            // Buttons: "+ Add Set" & "Complete Exercise"
            FitFlowButton(
              text: '+ Add Set',
              isOutlined: true,
              icon: Icons.add_rounded,
              onPressed: () {
                workoutProv.addSet(currentEx.id);
              },
            ),
            const SizedBox(height: 14),

            FitFlowButton(
              text: 'Complete Exercise',
              icon: Icons.check_circle_outline_rounded,
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

  Widget _buildFallbackHero() {
    return const Center(
      child: Icon(
        Icons.fitness_center_rounded,
        size: 64,
        color: AppColors.primaryLime,
      ),
    );
  }

  Widget _buildChip(
    String label,
    IconData icon,
    bool isDark, {
    bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isHighlight
            ? AppColors.primaryLime.withOpacity(0.18)
            : (isDark ? AppColors.darkSurface : Colors.white),
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
          Icon(
            icon,
            size: 14,
            color: isHighlight
                ? AppColors.primaryLime
                : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
          ),
          const SizedBox(width: 6),
          Text(
            label,
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
