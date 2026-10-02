import 'package:flutter/material.dart';
import '../../core/animations/animations.dart';
import '../../models/workout_set_model.dart';
import '../../theme/app_colors.dart';

/// A single row in the "Track Your Sets" table.
///
/// Layout (responsive, no hardcoded positions):
///
///  [Set#]  [─ weight ─]  [─ reps ─]  [✓]
///   32px     Flex(2)       Flex(2)    32px
///
/// The weight and reps columns use Flexible so they shrink gracefully on small
/// screens. The +/- stepper buttons are compactly sized (24×24) with no
/// additional outer padding that would cause overflow.
class SetTrackerRow extends StatelessWidget {
  final WorkoutSetModel set;
  final ValueChanged<WorkoutSetModel> onSetChanged;

  const SetTrackerRow({
    super.key,
    required this.set,
    required this.onSetChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: AppAnimations.standardDuration,
      curve: AppAnimations.curveAthletic,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: set.isCompleted
            ? (isDark
                ? AppColors.primaryLime.withOpacity(0.08)
                : AppColors.primaryLime.withOpacity(0.12))
            : (isDark ? AppColors.darkSurfaceElevated : AppColors.gray100),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: set.isCompleted
              ? AppColors.primaryLime.withOpacity(0.4)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Set number badge ────────────────────────────────────────────
          Semantics(
            label: 'Set ${set.setNumber}',
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.darkSurface : Colors.white,
                border: Border.all(
                  color: isDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  '${set.setNumber}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // ── Weight stepper ───────────────────────────────────────────────
          Flexible(
            flex: 2,
            child: Semantics(
              label: 'Weight ${set.weightKg} kg, adjust with buttons',
              child: _StepperField(
                value:
                    '${set.weightKg.toStringAsFixed(set.weightKg % 1 == 0 ? 0 : 1)} kg',
                valueKey: 'weight_${set.weightKg}',
                onDecrement: set.weightKg > 2.5
                    ? () => onSetChanged(
                        set.copyWith(weightKg: set.weightKg - 2.5))
                    : null,
                onIncrement: () =>
                    onSetChanged(set.copyWith(weightKg: set.weightKg + 2.5)),
                isDark: isDark,
              ),
            ),
          ),

          const SizedBox(width: 6),

          // ── Reps stepper ─────────────────────────────────────────────────
          Flexible(
            flex: 2,
            child: Semantics(
              label: '${set.reps} reps, adjust with buttons',
              child: _StepperField(
                value: '${set.reps} reps',
                valueKey: 'reps_${set.reps}',
                onDecrement: set.reps > 1
                    ? () =>
                        onSetChanged(set.copyWith(reps: set.reps - 1))
                    : null,
                onIncrement: () =>
                    onSetChanged(set.copyWith(reps: set.reps + 1)),
                isDark: isDark,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // ── Completion toggle ─────────────────────────────────────────────
          Semantics(
            label: set.isCompleted ? 'Mark set incomplete' : 'Complete set',
            button: true,
            child: PressableScale(
              onTap: () =>
                  onSetChanged(set.copyWith(isCompleted: !set.isCompleted)),
              child: AnimatedContainer(
                duration: AppAnimations.fastDuration,
                curve: AppAnimations.curveAthletic,
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: set.isCompleted
                      ? AppColors.primaryLime
                      : Colors.transparent,
                  border: Border.all(
                    color: set.isCompleted
                        ? AppColors.primaryLime
                        : (isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: AnimatedScale(
                    scale: set.isCompleted ? 1.0 : 0.0,
                    duration: AppAnimations.fastDuration,
                    curve: AppAnimations.curveSubtleSpring,
                    child: const Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: Color(0xFF111827),
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal stepper field: [−] [value] [+]
// Constrained so it never overflows its Flexible parent.
// ─────────────────────────────────────────────────────────────────────────────
class _StepperField extends StatelessWidget {
  final String value;
  final String valueKey;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;
  final bool isDark;

  const _StepperField({
    required this.value,
    required this.valueKey,
    required this.onDecrement,
    required this.onIncrement,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepButton(
          icon: Icons.remove,
          onTap: onDecrement,
          isDark: isDark,
        ),
        Flexible(
          child: AnimatedSwitcher(
            duration: AppAnimations.fastDuration,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: child,
            ),
            child: Text(
              value,
              key: ValueKey(valueKey),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ),
        ),
        _StepButton(
          icon: Icons.add,
          onTap: onIncrement,
          isDark: isDark,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Compact +/– tap button (24×24, no excess padding).
// ─────────────────────────────────────────────────────────────────────────────
class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDark;

  const _StepButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final active = onTap != null;
    return PressableScale(
      onTap: onTap,
      child: SizedBox(
        width: 24,
        height: 24,
        child: Icon(
          icon,
          size: 15,
          color: active
              ? (isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary)
              : (isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextMuted),
        ),
      ),
    );
  }
}
