import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/enums/muscle_group.dart';
import '../../providers/workout_provider.dart';
import '../../theme/app_colors.dart';
import '../workout/exercise_detail_screen.dart';

class ExerciseLibraryScreen extends StatelessWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final workoutProv = context.watch<WorkoutProvider>();
    final exercises = workoutProv.filteredLibrary;

    final categories = [
      {'name': 'Chest', 'group': MuscleGroup.chest, 'icon': Icons.fitness_center_rounded},
      {'name': 'Back', 'group': MuscleGroup.back, 'icon': Icons.airline_seat_recline_extra_rounded},
      {'name': 'Legs', 'group': MuscleGroup.legs, 'icon': Icons.directions_walk_rounded},
      {'name': 'Arms', 'group': MuscleGroup.arms, 'icon': Icons.sports_kabaddi_rounded},
      {'name': 'Shoulders', 'group': MuscleGroup.shoulders, 'icon': Icons.accessibility_new_rounded},
      {'name': 'Core', 'group': MuscleGroup.core, 'icon': Icons.shield_rounded},
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Exercise Library',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar (Screen 7 in mockup)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              onChanged: (val) => workoutProv.setSearchQuery(val),
              style: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                fillColor: isDark ? AppColors.darkSurface : Colors.white,
              ),
            ),
          ),

          // Muscle Group Filter Pills 2-row / scrollable with icons (Screen 7 in mockup)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((cat) {
                final group = cat['group'] as MuscleGroup;
                final isSelected = workoutProv.selectedMuscle == group;

                return GestureDetector(
                  onTap: () {
                    if (isSelected) {
                      workoutProv.selectMuscleGroup(null);
                    } else {
                      workoutProv.selectMuscleGroup(group);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryLime
                          : (isDark ? AppColors.darkSurface : Colors.white),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryLime
                            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          cat['icon'] as IconData,
                          size: 15,
                          color: isSelected
                              ? const Color(0xFF0F172A)
                              : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cat['name'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? const Color(0xFF0F172A)
                                : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Section Header: "Popular Exercises" (Screen 7)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Text(
              'Popular Exercises',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Exercises List (Screen 7 items: Bench Press, Squat, Deadlift, Push Up)
          Expanded(
            child: exercises.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No exercises match your search',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final ex = exercises[index];
                      final isPopular = ex.name.toLowerCase().contains('bench') ||
                          ex.name.toLowerCase().contains('squat') ||
                          ex.name.toLowerCase().contains('deadlift');

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ExerciseDetailScreen(exercise: ex),
                              ),
                            );
                          },
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: 56,
                              height: 56,
                              color: isDark ? AppColors.darkSurfaceElevated : AppColors.gray100,
                              child: ex.imageUrl.isNotEmpty
                                  ? Image.network(
                                      ex.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => const Icon(
                                        Icons.fitness_center_rounded,
                                        color: AppColors.primaryLime,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.fitness_center_rounded,
                                      color: AppColors.primaryLime,
                                    ),
                            ),
                          ),
                          title: Text(
                            ex.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              children: [
                                Text(
                                  '${ex.muscleGroup.displayName} • ${ex.difficulty.displayName}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (isPopular) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLime.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.star_rounded, size: 12, color: AppColors.primaryLime),
                                        SizedBox(width: 2),
                                        Text(
                                          'Popular',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primaryLime,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
