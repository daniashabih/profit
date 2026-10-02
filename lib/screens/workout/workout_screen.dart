import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/animations/animations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/workout_provider.dart';
import '../../models/exercise_model.dart';
import '../../theme/app_colors.dart';
import 'exercise_detail_screen.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final workoutProv = context.watch<WorkoutProvider>();
    final authProv = context.watch<AuthProvider>();
    final todayWorkout = workoutProv.todayWorkout;
    final user = authProv.user;

    final workoutTitle = todayWorkout?.title.isNotEmpty == true ? todayWorkout!.title : 'Chest';
    final workoutDate = todayWorkout?.subtitle.isNotEmpty == true ? todayWorkout!.subtitle : 'January 20';
    final exercises = todayWorkout?.exercises ?? [];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Stack(
        children: [
          // Ambient Athletic Backdrop at the Top
          if (isDark)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 340,
              child: ShaderMask(
                shaderCallback: (rect) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black,
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.95],
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstIn,
                child: Opacity(
                  opacity: 0.16,
                  child: Image.network(
                    'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
                    fit: BoxFit.cover,
                    errorBuilder: (_, o, s) => const SizedBox(),
                  ),
                ),
              ),
            ),

          // Main Content
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row (Title, Date, and Avatar)
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$workoutTitle,',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                                color: isDark ? Colors.white : AppColors.lightTextPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              workoutDate,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                                color: AppColors.primaryLime,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Top Right Profile Avatar
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? Colors.white.withOpacity(0.2) : AppColors.lightBorder,
                            width: 1.5,
                          ),
                        ),
                        child: ClipOval(
                          child: (user?.avatarUrl.isNotEmpty ?? false)
                              ? Image.network(
                                  user!.avatarUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, o, s) => const Icon(
                                    Icons.person_rounded,
                                    color: AppColors.primaryLime,
                                  ),
                                )
                              : Image.network(
                                  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, o, s) => const Icon(
                                    Icons.person_rounded,
                                    color: AppColors.primaryLime,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Weekly Workouts Progress Bar (Segmented Pills)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(4, (index) {
                          final isFilled = index == 0; // 1/4 weekly workouts done
                          return Expanded(
                            child: Container(
                              height: 4.5,
                              margin: EdgeInsets.only(right: index < 3 ? 6 : 0),
                              decoration: BoxDecoration(
                                color: isFilled
                                    ? AppColors.primaryLime
                                    : (isDark
                                        ? AppColors.darkProgressUnfilled
                                        : AppColors.gray200),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1/4 weekly workouts done',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Exercise Cards List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 90),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      return StaggeredEntrance(
                        index: index,
                        child: _buildExerciseCard(
                          context: context,
                          exercise: exercise,
                          index: index,
                          allExercises: exercises,
                          isDark: isDark,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Bottom Fixed Lime CTA: "START WORKOUT"
          Positioned(
            left: 20,
            right: 20,
            bottom: 16,
            child: SizedBox(
              height: 54,
              child: PressableScale(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLime,
                    foregroundColor: const Color(0xFF0B1216),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    if (exercises.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ExerciseDetailScreen(
                            exercise: exercises.first,
                            allExercises: exercises,
                            currentIndex: 0,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'START WORKOUT',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: Color(0xFF0B1216),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard({
    required BuildContext context,
    required ExerciseModel exercise,
    required int index,
    required List<ExerciseModel> allExercises,
    required bool isDark,
  }) {
    return PressableScale(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExerciseDetailScreen(
              exercise: exercise,
              allExercises: allExercises,
              currentIndex: index,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface.withOpacity(0.9) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder.withOpacity(0.6) : AppColors.lightBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Exercise Icon Container
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0C161C) : AppColors.gray100,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder.withOpacity(0.4) : AppColors.lightBorder,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildExerciseThumbnail(exercise, isDark),
            ),
            const SizedBox(width: 16),

            // Exercise Title and Tag
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    exercise.tagDisplay,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                      color: AppColors.primaryLime,
                    ),
                  ),
                ],
              ),
            ),

            // Right Chevron
            Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseThumbnail(ExerciseModel exercise, bool isDark) {
    if (exercise.imageUrl.isNotEmpty) {
      return Image.network(
        exercise.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, o, s) => _buildFallbackIcon(exercise, isDark),
      );
    }
    return _buildFallbackIcon(exercise, isDark);
  }

  Widget _buildFallbackIcon(ExerciseModel exercise, bool isDark) {
    IconData icon = Icons.fitness_center_rounded;
    if (exercise.name.toLowerCase().contains('dip')) {
      icon = Icons.sports_gymnastics_rounded;
    } else if (exercise.name.toLowerCase().contains('fly')) {
      icon = Icons.accessibility_new_rounded;
    }

    return Center(
      child: Icon(
        icon,
        size: 28,
        color: isDark ? Colors.white.withOpacity(0.8) : const Color(0xFF1E293B),
      ),
    );
  }
}
