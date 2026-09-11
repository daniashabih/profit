import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/enums/muscle_group.dart';
import '../../core/enums/exercise_difficulty.dart';
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

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Exercise Library',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Show Favorites',
            icon: Icon(
              workoutProv.showFavoritesOnly
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: workoutProv.showFavoritesOnly ? Colors.redAccent : null,
            ),
            onPressed: () => workoutProv.toggleFavoritesOnly(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search bar
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
                suffixIcon: workoutProv.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => workoutProv.setSearchQuery(''),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          // Horizontal Category Filter (Chest, Back, Legs, Arms, Shoulders, Core)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'All Muscles',
                  isSelected: workoutProv.selectedMuscle == null,
                  onTap: () => workoutProv.selectMuscleGroup(null),
                  isDark: isDark,
                ),
                ...MuscleGroup.values
                    .where((m) => m != MuscleGroup.fullBody)
                    .map((m) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: _buildFilterChip(
                      label: m.displayName,
                      isSelected: workoutProv.selectedMuscle == m,
                      onTap: () => workoutProv.selectMuscleGroup(m),
                      isDark: isDark,
                    ),
                  );
                }),
              ],
            ),
          ),

          // Secondary Filter Bar: Equipment & Difficulty
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                // Equipment dropdown
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: workoutProv.selectedEquipment,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down_rounded, size: 20),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                        dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                        items: AppConstants.equipmentList.map((eq) {
                          return DropdownMenuItem(
                            value: eq,
                            child: Text(eq),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) workoutProv.selectEquipment(val);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Difficulty dropdown
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<ExerciseDifficulty?>(
                        value: workoutProv.selectedDifficulty,
                        isExpanded: true,
                        hint: Text(
                          'All Levels',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Levels'),
                          ),
                          ...ExerciseDifficulty.values.map((d) {
                            return DropdownMenuItem(
                              value: d,
                              child: Text(d.displayName),
                            );
                          }),
                        ],
                        onChanged: (val) => workoutProv.selectDifficulty(val),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Exercise Grid/List View
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
                          'No exercises match your filters',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final ex = exercises[index];
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
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ExerciseDetailScreen(exercise: ex),
                              ),
                            );
                          },
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 54,
                              height: 54,
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
                                  ex.muscleGroup.displayName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Text(' • '),
                                Text(
                                  ex.difficulty.displayName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.darkTextMuted
                                        : AppColors.lightTextMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              ex.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: ex.isFavorite ? Colors.redAccent : null,
                              size: 22,
                            ),
                            onPressed: () {
                              workoutProv.toggleExerciseFavorite(ex.id);
                            },
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

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primaryLime : const Color(0xFF111827))
              : (isDark ? AppColors.darkSurface : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.primaryLime : const Color(0xFF111827))
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? (isDark ? const Color(0xFF111827) : Colors.white)
                : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          ),
        ),
      ),
    );
  }
}
