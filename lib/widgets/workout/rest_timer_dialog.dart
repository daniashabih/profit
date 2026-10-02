import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/animations/animations.dart';
import '../../providers/workout_provider.dart';
import '../../core/utils/formatters.dart';
import '../../theme/app_colors.dart';
import '../common/fit_flow_button.dart';

class RestTimerDialog extends StatefulWidget {
  final int? initialSeconds;
  const RestTimerDialog({super.key, this.initialSeconds});

  static void show(BuildContext context, {int? initialSeconds}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RestTimerDialog(initialSeconds: initialSeconds),
    );
  }

  @override
  State<RestTimerDialog> createState() => _RestTimerDialogState();
}

class _RestTimerDialogState extends State<RestTimerDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final workoutProv = context.read<WorkoutProvider>();
      if (widget.initialSeconds != null && widget.initialSeconds! > 0) {
        workoutProv.startRestTimer(seconds: widget.initialSeconds);
      } else if (!workoutProv.isRestTimerActive) {
        workoutProv.startRestTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<WorkoutProvider>(
      builder: (context, workoutProv, child) {
        final remaining = workoutProv.restTimerSeconds;
        final progress = workoutProv.restTimerProgress;
        final isActive = workoutProv.isRestTimerActive;

        return Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'REST & RECOVERY',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: AppColors.primaryLime,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Catch Your Breath',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 28),
              // Circular Timer Display
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 170,
                    height: 170,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: progress, end: progress),
                      duration: AppAnimations.standardDuration,
                      curve: Curves.linear,
                      builder: (context, animatedProgress, _) {
                        return CircularProgressIndicator(
                          value: animatedProgress,
                          strokeWidth: 8,
                          backgroundColor: isDark
                              ? AppColors.darkSurfaceElevated
                              : AppColors.gray200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primaryLime,
                          ),
                        );
                      },
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: AppAnimations.fastDuration,
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                        child: Text(
                          Formatters.formatSecondsToMinutes(remaining),
                          key: ValueKey('sec_$remaining'),
                          style: const TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isActive ? 'REMAINING' : 'PAUSED',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),
              // Quick time adjustment chips (+15s, +30s, +60s)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildQuickAddChip(
                    context,
                    label: '+15s',
                    onTap: () => workoutProv.addRestTime(15),
                  ),
                  const SizedBox(width: 12),
                  _buildQuickAddChip(
                    context,
                    label: '+30s',
                    onTap: () => workoutProv.addRestTime(30),
                  ),
                  const SizedBox(width: 12),
                  _buildQuickAddChip(
                    context,
                    label: '+60s',
                    onTap: () => workoutProv.addRestTime(60),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              // Controls
              Row(
                children: [
                  Expanded(
                    child: FitFlowButton(
                      text: isActive ? 'Pause' : 'Resume',
                      icon: isActive ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      isOutlined: true,
                      onPressed: () {
                        if (isActive) {
                          workoutProv.pauseRestTimer();
                        } else {
                          workoutProv.startRestTimer();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FitFlowButton(
                      text: 'Skip Rest',
                      icon: Icons.fast_forward_rounded,
                      onPressed: () {
                        workoutProv.stopRestTimer();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

  Widget _buildQuickAddChip(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PressableScale(
      child: ActionChip(
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        backgroundColor: isDark ? AppColors.darkSurfaceElevated : AppColors.gray100,
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onPressed: onTap,
      ),
    );
  }
}
