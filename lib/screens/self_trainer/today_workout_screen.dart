import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/animations/animations.dart';
import '../../theme/app_colors.dart';
import '../../providers/self_trainer_cycle_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/workout_plan_model.dart';
import '../../models/workout_log_model.dart';
import '../../widgets/workout/rest_timer_dialog.dart';

/// Screen for tracking today's scheduled workout session:
/// Shows target muscles, exercises, planned vs actual sets, reps, and weights,
/// rest timers, and logs actual performance to Cloud Firestore: workoutLogs/{logId}.
class TodayWorkoutScreen extends StatefulWidget {
  final WorkoutDay workoutDay;

  const TodayWorkoutScreen({super.key, required this.workoutDay});

  @override
  State<TodayWorkoutScreen> createState() => _TodayWorkoutScreenState();
}

class _TodayWorkoutScreenState extends State<TodayWorkoutScreen> {
  // In-session tracking maps: exerciseId -> List of LoggedSet
  final Map<String, List<LoggedSet>> _exerciseSets = {};
  final Set<String> _completedExerciseIds = {};
  int _sessionMinutes = 0;
  Timer? _sessionTimer;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Initialize default sets for each planned exercise
    for (final ex in widget.workoutDay.exercises) {
      _exerciseSets[ex.id] = List.generate(
        ex.sets,
        (i) => LoggedSet(
          setNumber: i + 1,
          weightKg: ex.targetWeightKg,
          reps: ex.reps,
          isCompleted: false,
        ),
      );
    }

    _sessionTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() => _sessionMinutes++);
    });
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  void _toggleSetCompletion(String exerciseId, int setIndex) {
    setState(() {
      final sets = _exerciseSets[exerciseId]!;
      final current = sets[setIndex];
      sets[setIndex] = LoggedSet(
        setNumber: current.setNumber,
        weightKg: current.weightKg,
        reps: current.reps,
        isCompleted: !current.isCompleted,
      );

      // Check if all sets for this exercise are now completed
      if (sets.every((s) => s.isCompleted)) {
        _completedExerciseIds.add(exerciseId);
      } else {
        _completedExerciseIds.remove(exerciseId);
      }
    });

    // If set was marked completed, trigger rest timer
    if (_exerciseSets[exerciseId]![setIndex].isCompleted) {
      final ex = widget.workoutDay.exercises.firstWhere((e) => e.id == exerciseId);
      RestTimerDialog.show(context, initialSeconds: ex.restTimeSeconds);
    }
  }

  void _updateSetWeightReps(String exerciseId, int setIndex, {double? weight, int? reps}) {
    setState(() {
      final sets = _exerciseSets[exerciseId]!;
      final current = sets[setIndex];
      sets[setIndex] = LoggedSet(
        setNumber: current.setNumber,
        weightKg: weight ?? current.weightKg,
        reps: reps ?? current.reps,
        isCompleted: current.isCompleted,
      );
    });
  }

  Future<void> _finishWorkout() async {
    final authProv = context.read<AuthProvider>();
    final cycleProv = context.read<SelfTrainerCycleProvider>();
    final user = authProv.user;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      final loggedExercises = widget.workoutDay.exercises.map((ex) {
        final sets = _exerciseSets[ex.id] ?? [];
        return LoggedExercise(
          exerciseId: ex.id,
          exerciseName: ex.name,
          muscleGroup: ex.muscleGroup.name,
          plannedSets: ex.sets,
          plannedReps: ex.reps,
          sets: sets,
          isCompleted: sets.isNotEmpty && sets.every((s) => s.isCompleted),
        );
      }).toList();

      final now = DateTime.now();
      final log = WorkoutLog(
        id: '${user.id}_log_${now.millisecondsSinceEpoch}',
        userId: user.id,
        workoutPlanId: cycleProv.currentWorkoutPlan?.id ?? '',
        dayId: widget.workoutDay.id,
        workoutTitle: widget.workoutDay.workoutType,
        targetMuscles: widget.workoutDay.targetMuscles,
        durationMinutes: _sessionMinutes > 0 ? _sessionMinutes : 35,
        completedExercises: _completedExerciseIds.length,
        totalExercises: widget.workoutDay.exercises.length,
        exercises: loggedExercises,
        completedAt: now,
        dateString: now.toIso8601String().split('T').first,
      );

      await cycleProv.logWorkoutExecution(log);

      if (!mounted) return;

      _showCelebrationDialog();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save workout log: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showCelebrationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.7, end: 1.0),
              duration: AppAnimations.mediumDuration,
              curve: AppAnimations.curveSubtleSpring,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: const PulsingGlow(
                glowColor: AppColors.primaryLime,
                child: Icon(Icons.emoji_events_rounded, color: AppColors.primaryLime, size: 32),
              ),
            ),
            const SizedBox(width: 12),
            const Text('Workout Completed!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Great work crushing today\'s ${widget.workoutDay.workoutType} session.',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            StaggeredEntrance(
              index: 0,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryLime.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _dialogStat('Completed', '${_completedExerciseIds.length}/${widget.workoutDay.exercises.length}'),
                    _dialogStat('Duration', '$_sessionMinutes min'),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          PressableScale(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLime,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Back to Dashboard', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dialogStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = widget.workoutDay.exercises.length;
    final completed = _completedExerciseIds.length;
    final progress = total > 0 ? (completed / total) : 0.0;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.workoutDay.workoutType,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            Text(
              'Target: ${widget.workoutDay.targetMuscles.join(' • ')}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLime.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_sessionMinutes min',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryLime,
                  ),
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: progress.clamp(0.0, 1.0)),
            duration: AppAnimations.standardDuration,
            curve: AppAnimations.curveAthletic,
            builder: (context, val, _) {
              return LinearProgressIndicator(
                value: val,
                backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryLime),
                minHeight: 6,
              );
            },
          ),
        ),
      ),
      body: widget.workoutDay.exercises.isEmpty
          ? _buildEmptyOrRestDay(isDark)
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: widget.workoutDay.exercises.length + 1,
              itemBuilder: (context, index) {
                if (index == widget.workoutDay.exercises.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: PressableScale(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _finishWorkout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLime,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black),
                              )
                            : Text(
                                completed >= total ? 'Finish Workout' : 'Save Session Progress',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                              ),
                      ),
                    ),
                  );
                }

                final exercise = widget.workoutDay.exercises[index];
                return StaggeredEntrance(
                  index: index,
                  child: _buildExerciseCard(exercise, index + 1, isDark),
                );
              },
            ),
    );
  }

  Widget _buildEmptyOrRestDay(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.nightlight_round, size: 54, color: AppColors.primaryLime),
            const SizedBox(height: 18),
            const Text(
              'Rest Day — Muscle Recovery',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Recovery is when muscles adapt and synthesize tissue. Hydrate and get adequate sleep.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(PlanExercise ex, int exerciseNumber, bool isDark) {
    final sets = _exerciseSets[ex.id] ?? [];
    final isAllCompleted = _completedExerciseIds.contains(ex.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAllCompleted
              ? AppColors.primaryLime.withValues(alpha: 0.6)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isAllCompleted ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise Header
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isAllCompleted
                        ? AppColors.primaryLime
                        : (isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isAllCompleted
                          ? AppColors.primaryLime
                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: isAllCompleted
                        ? const Icon(Icons.check, size: 18, color: Colors.black)
                        : Text(
                            '$exerciseNumber',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ex.name,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Planned: ${ex.sets} Sets × ${ex.reps} Reps @ ${ex.targetWeightKg} kg • Rest ${ex.restTimeSeconds}s',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.timer_outlined, color: AppColors.primaryLime),
                  onPressed: () {
                    RestTimerDialog.show(context, initialSeconds: ex.restTimeSeconds);
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Sets Table Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              children: [
                const SizedBox(width: 36, child: Text('SET', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey))),
                const Expanded(child: Text('WEIGHT (KG)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey))),
                const Expanded(child: Text('REPS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey))),
                const SizedBox(width: 44, child: Center(child: Text('DONE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey)))),
              ],
            ),
          ),

          // Interactive Set Rows
          ...List.generate(sets.length, (sIndex) {
            final s = sets[sIndex];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: s.isCompleted
                      ? AppColors.primaryLime.withValues(alpha: 0.08)
                      : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 26,
                      child: Text(
                        '${s.setNumber}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (s.weightKg > 2.5) {
                                _updateSetWeightReps(ex.id, sIndex, weight: s.weightKg - 2.5);
                              }
                            },
                            child: const Icon(Icons.remove, size: 16, color: Colors.grey),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              '${s.weightKg} kg',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _updateSetWeightReps(ex.id, sIndex, weight: s.weightKg + 2.5);
                            },
                            child: const Icon(Icons.add, size: 16, color: AppColors.primaryLime),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (s.reps > 1) {
                                _updateSetWeightReps(ex.id, sIndex, reps: s.reps - 1);
                              }
                            },
                            child: const Icon(Icons.remove, size: 16, color: Colors.grey),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              '${s.reps}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _updateSetWeightReps(ex.id, sIndex, reps: s.reps + 1);
                            },
                            child: const Icon(Icons.add, size: 16, color: AppColors.primaryLime),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 44,
                      child: Center(
                        child: IconButton(
                          icon: Icon(
                            s.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                            color: s.isCompleted ? AppColors.primaryLime : Colors.grey,
                            size: 24,
                          ),
                          onPressed: () => _toggleSetCompletion(ex.id, sIndex),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
