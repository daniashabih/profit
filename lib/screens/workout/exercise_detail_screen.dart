import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/exercise_model.dart';
import '../../providers/workout_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/workout/set_tracker_row.dart';
import '../../widgets/workout/rest_timer_dialog.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final ExerciseModel exercise;
  final List<ExerciseModel>? allExercises;
  final int currentIndex;

  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
    this.allExercises,
    this.currentIndex = 0,
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  late ExerciseModel _currentExercise;
  late int _currentIndex;
  bool _showSetTracker = true;

  @override
  void initState() {
    super.initState();
    _currentExercise = widget.exercise;
    _currentIndex = widget.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final workoutProv = context.watch<WorkoutProvider>();

    final allList = widget.allExercises ?? workoutProv.todayWorkout.exercises;
    final totalCount = allList.isNotEmpty ? allList.length : 4;

    // Get live exercise instance from provider if available
    final liveExercise = workoutProv.todayWorkout.exercises.firstWhere(
      (e) => e.id == _currentExercise.id,
      orElse: () => _currentExercise,
    );

    // Filter next exercises
    final nextExercises = allList.where((e) => e.id != liveExercise.id).toList();
    final remainingCount = nextExercises.length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Stack(
        children: [
          // Scrollable Content
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Hero Media Visual Container with Back & Options Overlay
                Stack(
                  children: [
                    // Exercise Image Hero
                    Container(
                      height: 280,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0D171D) : AppColors.gray200,
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            liveExercise.imageUrl.isNotEmpty
                                ? liveExercise.imageUrl
                                : 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800',
                            fit: BoxFit.cover,
                            errorBuilder: (_, o, s) => Container(
                              color: isDark ? const Color(0xFF0F1A21) : AppColors.gray200,
                              child: const Center(
                                child: Icon(
                                  Icons.fitness_center_rounded,
                                  size: 64,
                                  color: AppColors.primaryLime,
                                ),
                              ),
                            ),
                          ),
                          // Subtle dark gradient vignette at the bottom
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.3),
                                    Colors.transparent,
                                    (isDark ? AppColors.darkBackground : AppColors.lightBackground)
                                        .withOpacity(0.85),
                                    isDark ? AppColors.darkBackground : AppColors.lightBackground,
                                  ],
                                  stops: const [0.0, 0.45, 0.85, 1.0],
                                ),
                              ),
                            ),
                          ),
                          // Centered Large Electric Cyan Circular Play Button
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                RestTimerDialog.show(context);
                              },
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.electricCyan,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.electricCyan.withOpacity(0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.play_arrow_rounded,
                                    color: Color(0xFF0B1216),
                                    size: 38,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Top Navigation Actions (Back Arrow & More Dots)
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back Button
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (isDark ? const Color(0xFF132228) : Colors.white)
                                      .withOpacity(0.75),
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.darkBorder.withOpacity(0.6)
                                        : AppColors.lightBorder,
                                  ),
                                ),
                                child: Icon(
                                  Icons.arrow_back_rounded,
                                  size: 20,
                                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                                ),
                              ),
                            ),
                            // More Options Button
                            GestureDetector(
                              onTap: () => RestTimerDialog.show(context),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (isDark ? const Color(0xFF132228) : Colors.white)
                                      .withOpacity(0.75),
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.darkBorder.withOpacity(0.6)
                                        : AppColors.lightBorder,
                                  ),
                                ),
                                child: Icon(
                                  Icons.more_horiz_rounded,
                                  size: 20,
                                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Exercise Header & Target Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tag: EXERCISE 1/4
                      Text(
                        'EXERCISE ${_currentIndex + 1}/$totalCount',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: AppColors.primaryLime,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Title
                      Text(
                        'Target the Muscles of your ${liveExercise.muscleGroup.displayName} with ${liveExercise.name}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                          color: isDark ? Colors.white : AppColors.lightTextPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Next Exercises Section (matching Screen 2)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Next Exercises',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.lightTextPrimary,
                        ),
                      ),
                      Text(
                        '$remainingCount Remaining',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Next Exercises List Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: nextExercises.map((ex) {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(() {
                            _currentExercise = ex;
                            _currentIndex = allList.indexOf(ex);
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface.withOpacity(0.85) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder.withOpacity(0.6)
                                  : AppColors.lightBorder,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Exercise Thumbnail
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: 52,
                                  height: 52,
                                  color: isDark ? const Color(0xFF0C161C) : AppColors.gray100,
                                  child: Image.network(
                                    ex.imageUrl.isNotEmpty
                                        ? ex.imageUrl
                                        : 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=300',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, o, s) => const Center(
                                      child: Icon(
                                        Icons.fitness_center_rounded,
                                        size: 24,
                                        color: AppColors.primaryLime,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Exercise Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ex.name,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? Colors.white : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.timer_outlined,
                                          size: 13,
                                          color: isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.lightTextSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${ex.durationMinutes} min',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: isDark
                                                ? AppColors.darkTextSecondary
                                                : AppColors.lightTextSecondary,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Icon(
                                          Icons.repeat_rounded,
                                          size: 13,
                                          color: isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.lightTextSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${ex.sets} sets',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: isDark
                                                ? AppColors.darkTextSecondary
                                                : AppColors.lightTextSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Small Circular Lime Play Button
                              Container(
                                width: 34,
                                height: 34,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryLime,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.play_arrow_rounded,
                                    size: 20,
                                    color: Color(0xFF0B1216),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 18),

                // Interactive Set Tracker Drawer ("Track Your Sets")
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface.withOpacity(0.7) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder.withOpacity(0.5) : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Track Your Sets',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : AppColors.lightTextPrimary,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _showSetTracker ? Icons.expand_less : Icons.expand_more,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                              onPressed: () => setState(() => _showSetTracker = !_showSetTracker),
                            ),
                          ],
                        ),
                        if (_showSetTracker) ...[
                          const SizedBox(height: 8),
                          // Header: Set | Weight | Reps | Done
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 32,
                                  child: Text('Set', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                ),
                                const Expanded(
                                  child: Center(
                                    child: Text('Weight (kg)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                  ),
                                ),
                                const Expanded(
                                  child: Center(
                                    child: Text('Reps', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const SizedBox(
                                  width: 32,
                                  child: Center(child: Icon(Icons.check_circle_outline, size: 18)),
                                ),
                              ],
                            ),
                          ),
                          ...List.generate(liveExercise.setsList.length, (index) {
                            final setItem = liveExercise.setsList[index];
                            return SetTrackerRow(
                              set: setItem,
                              onSetChanged: (updated) {
                                workoutProv.updateSet(liveExercise.id, index, updated);
                                if (updated.isCompleted) {
                                  workoutProv.startRestTimer(seconds: liveExercise.restTimeSeconds);
                                  RestTimerDialog.show(context);
                                }
                              },
                            );
                          }),
                          const SizedBox(height: 10),
                          // Add Set Row
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryLime,
                              side: BorderSide(color: AppColors.primaryLime.withOpacity(0.6)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              minimumSize: const Size.fromHeight(44),
                            ),
                            onPressed: () => workoutProv.addSet(liveExercise.id),
                            child: const Text('+ Add Set', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),

          // Bottom Action CTA: "BEGIN EXERCISE" in Electric Cyan
          Positioned(
            left: 20,
            right: 20,
            bottom: 16,
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricCyan,
                  foregroundColor: const Color(0xFF0B1216),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  RestTimerDialog.show(context);
                },
                child: const Text(
                  'BEGIN EXERCISE',
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
        ],
      ),
    );
  }
}
