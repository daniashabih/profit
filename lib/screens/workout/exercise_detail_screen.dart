import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/animations/animations.dart';
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

    final todayWorkout = workoutProv.todayWorkout;
    final allList = widget.allExercises ?? (todayWorkout?.exercises ?? []);
    final totalCount = allList.isNotEmpty ? allList.length : 4;

    // Get live exercise instance from provider if available
    final liveExercise = todayWorkout?.exercises.firstWhere(
      (e) => e.id == _currentExercise.id,
      orElse: () => _currentExercise,
    ) ?? _currentExercise;

    // Filter next exercises
    final nextExercises =
        allList.where((e) => e.id != liveExercise.id).toList();
    final remainingCount = nextExercises.length;

    final bg =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: bg,
      // ── Proper layout: scrollable content + pinned CTA ──────────────────
      body: SafeArea(
        bottom: false, // we handle bottom inset manually on the CTA
        child: Column(
          children: [
            // ── Scrollable workout content ─────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Hero media + nav overlay ───────────────────────────
                    _HeroSection(
                      liveExercise: liveExercise,
                      isDark: isDark,
                    ),

                    // ── Exercise header ────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EXERCISE ${_currentIndex + 1}/$totalCount',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: AppColors.primaryLime,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Target the Muscles of your '
                            '${liveExercise.muscleGroup.displayName} '
                            'with ${liveExercise.name}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              height: 1.25,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.lightTextPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Next exercises section ─────────────────────────────
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
                              color: isDark
                                  ? Colors.white
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          Text(
                            '$remainingCount Remaining',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ── Exercise cards list ────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: nextExercises.map((ex) {
                          return _ExerciseCard(
                            exercise: ex,
                            isDark: isDark,
                            onTap: () {
                              setState(() {
                                _currentExercise = ex;
                                _currentIndex = allList.indexOf(ex);
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Track Your Sets card ───────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _SetTrackerCard(
                        liveExercise: liveExercise,
                        workoutProv: workoutProv,
                        isDark: isDark,
                        showTracker: _showSetTracker,
                        onToggle: () => setState(
                            () => _showSetTracker = !_showSetTracker),
                        onOpenTimer: () => RestTimerDialog.show(context),
                      ),
                    ),

                    // ── Bottom breathing room above CTA ───────────────────
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Pinned "BEGIN EXERCISE" CTA ────────────────────────────────
            _BeginExerciseCta(
              onPressed: () => RestTimerDialog.show(context),
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero section: exercise image + back/more buttons overlay
// ─────────────────────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final ExerciseModel liveExercise;
  final bool isDark;

  const _HeroSection({
    required this.liveExercise,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Exercise image
        Container(
          height: 260,
          width: double.infinity,
          color: isDark ? const Color(0xFF0D171D) : AppColors.gray200,
          child: Stack(
            fit: StackFit.expand,
            children: [
              TweenAnimationBuilder<double>(
                key: ValueKey('hero_${liveExercise.id}'),
                tween: Tween<double>(begin: 0.94, end: 1.0),
                duration: AppAnimations.mediumDuration,
                curve: AppAnimations.curveEaseOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: ((scale - 0.94) / 0.06).clamp(0.0, 1.0),
                      child: child,
                    ),
                  );
                },
                child: Image.network(
                  liveExercise.imageUrl.isNotEmpty
                      ? liveExercise.imageUrl
                      : 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800',
                  fit: BoxFit.cover,
                  errorBuilder: (_, o, s) => Container(
                    color: isDark
                        ? const Color(0xFF0F1A21)
                        : AppColors.gray200,
                    child: const Center(
                      child: Icon(
                        Icons.fitness_center_rounded,
                        size: 56,
                        color: AppColors.primaryLime,
                      ),
                    ),
                  ),
                ),
              ),
              // Gradient vignette
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                        (isDark
                                ? AppColors.darkBackground
                                : AppColors.lightBackground)
                            .withOpacity(0.85),
                        isDark
                            ? AppColors.darkBackground
                            : AppColors.lightBackground,
                      ],
                      stops: const [0.0, 0.45, 0.85, 1.0],
                    ),
                  ),
                ),
              ),
              // Centered play button – uses primaryLime consistent with PROFIT
              Center(
                child: Semantics(
                  label: 'Play exercise',
                  button: true,
                  child: PressableScale(
                    onTap: () => RestTimerDialog.show(context),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryLime,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryLime.withOpacity(0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: Color(0xFF0B1216),
                          size: 34,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Top navigation (back + more) – lives inside a SafeArea so it clears
        // the status bar on all devices without needing the outer SafeArea.
        SafeArea(
          bottom: false,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavButton(
                  icon: Icons.arrow_back_rounded,
                  label: 'Back',
                  isDark: isDark,
                  onTap: () => Navigator.pop(context),
                ),
                _NavButton(
                  icon: Icons.more_horiz_rounded,
                  label: 'More options',
                  isDark: isDark,
                  onTap: () => RestTimerDialog.show(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Circular nav button (back / more)
// ─────────────────────────────────────────────────────────────────────────────
class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: PressableScale(
        onTap: onTap,
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
            icon,
            size: 20,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single exercise card in the "next exercises" list
// ─────────────────────────────────────────────────────────────────────────────
class _ExerciseCard extends StatelessWidget {
  final ExerciseModel exercise;
  final bool isDark;
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.exercise,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Play ${exercise.name}',
      button: true,
      child: PressableScale(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurface.withOpacity(0.85)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? AppColors.darkBorder.withOpacity(0.6)
                  : AppColors.lightBorder,
            ),
          ),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: ColoredBox(
                    color: isDark
                        ? const Color(0xFF0C161C)
                        : AppColors.gray100,
                    child: Image.network(
                      exercise.imageUrl.isNotEmpty
                          ? exercise.imageUrl
                          : 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=300',
                      fit: BoxFit.cover,
                      errorBuilder: (_, o, s) => const Center(
                        child: Icon(
                          Icons.fitness_center_rounded,
                          size: 22,
                          color: AppColors.primaryLime,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Exercise info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? Colors.white
                            : AppColors.lightTextPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${exercise.durationMinutes} min',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.repeat_rounded,
                          size: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${exercise.sets} sets',
                          style: TextStyle(
                            fontSize: 12,
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
              const SizedBox(width: 10),

              // Play button
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
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// "Track Your Sets" card
// ─────────────────────────────────────────────────────────────────────────────
class _SetTrackerCard extends StatelessWidget {
  final ExerciseModel liveExercise;
  final WorkoutProvider workoutProv;
  final bool isDark;
  final bool showTracker;
  final VoidCallback onToggle;
  final VoidCallback onOpenTimer;

  const _SetTrackerCard({
    required this.liveExercise,
    required this.workoutProv,
    required this.isDark,
    required this.showTracker,
    required this.onToggle,
    required this.onOpenTimer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withOpacity(0.7)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withOpacity(0.5)
              : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ─────────────────────────────────────────────────
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
              SizedBox(
                width: 36,
                height: 36,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    showTracker
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  onPressed: onToggle,
                ),
              ),
            ],
          ),

          if (showTracker) ...[
            const SizedBox(height: 6),

            // ── Column headers ─────────────────────────────────────────
            _ColumnHeaders(isDark: isDark),
            const SizedBox(height: 4),

            // ── Set rows ───────────────────────────────────────────────
            ...List.generate(liveExercise.setsList.length, (index) {
              final setItem = liveExercise.setsList[index];
              return SetTrackerRow(
                key: ValueKey('set_row_$index'),
                set: setItem,
                onSetChanged: (updated) {
                  workoutProv.updateSet(liveExercise.id, index, updated);
                  if (updated.isCompleted) {
                    workoutProv.startRestTimer(
                        seconds: liveExercise.restTimeSeconds);
                    onOpenTimer();
                  }
                },
              );
            }),

            const SizedBox(height: 8),

            // ── Add Set button ─────────────────────────────────────────
            Semantics(
              label: 'Add set',
              button: true,
              child: PressableScale(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryLime,
                    side: BorderSide(
                        color: AppColors.primaryLime.withOpacity(0.6)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size.fromHeight(44),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => workoutProv.addSet(liveExercise.id),
                  child: const Text(
                    '+ Add Set',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Table column header row
// ─────────────────────────────────────────────────────────────────────────────
class _ColumnHeaders extends StatelessWidget {
  final bool isDark;

  const _ColumnHeaders({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
    );

    return Padding(
      // Mirrors the row's horizontal padding (12px) + set-badge width (28) + gap (8)
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Set column
          SizedBox(
            width: 28,
            child: Text('Set', style: style, textAlign: TextAlign.center),
          ),
          const SizedBox(width: 8),
          // Weight column
          Flexible(
            flex: 2,
            child: Text('Weight (kg)', style: style, textAlign: TextAlign.center),
          ),
          const SizedBox(width: 6),
          // Reps column
          Flexible(
            flex: 2,
            child: Text('Reps', style: style, textAlign: TextAlign.center),
          ),
          const SizedBox(width: 8),
          // Done column
          SizedBox(
            width: 32,
            child: Icon(
              Icons.check_circle_outline,
              size: 16,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pinned "BEGIN EXERCISE" CTA — PROFIT lime, SafeArea-aware
// ─────────────────────────────────────────────────────────────────────────────
class _BeginExerciseCta extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isDark;

  const _BeginExerciseCta({
    required this.onPressed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      // Top border to visually separate from scrollable area
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.darkBorder.withOpacity(0.4)
                : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottomPadding),
      child: Semantics(
        label: 'Begin exercise',
        button: true,
        child: PressableScale(
          onTap: onPressed,
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLime,
                foregroundColor: const Color(0xFF0B1216),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: onPressed,
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
      ),
    );
  }
}
