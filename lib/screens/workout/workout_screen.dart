import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workout_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/workout/journey_step_card.dart';
import '../../widgets/common/fit_flow_button.dart';
import '../library/exercise_library_screen.dart';
import 'exercise_detail_screen.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final workoutProv = context.watch<WorkoutProvider>();
    final todayWorkout = workoutProv.todayWorkout;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Today\'s ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryLime,
              ),
            ),
            const Text(
              'Workout',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Exercise Library',
            icon: const Icon(Icons.fitness_center_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExerciseLibraryScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Bookmark',
            icon: const Icon(Icons.bookmark_border_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Workout routine bookmarked')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 7 Numbered Exercises with Connected Timeline (Screen 5 in mockup)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: todayWorkout.exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = todayWorkout.exercises[index];
                    final isLast = index == todayWorkout.exercises.length - 1;

                    return JourneyStepCard(
                      stepIndex: index,
                      exercise: exercise,
                      isLast: isLast,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExerciseDetailScreen(exercise: exercise),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          // Bottom Fixed Lime Button: "Start Workout" (matching Screen 5)
          Positioned(
            left: 20,
            right: 20,
            bottom: 16,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryLime.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FitFlowButton(
                text: 'Start Workout',
                height: 52,
                borderRadius: 26,
                onPressed: () {
                  if (todayWorkout.exercises.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExerciseDetailScreen(
                          exercise: todayWorkout.exercises.first,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
