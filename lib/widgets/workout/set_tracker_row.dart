import 'package:flutter/material.dart';
import '../../models/workout_set_model.dart';
import '../../theme/app_colors.dart';

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

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: set.isCompleted
            ? (isDark
                ? AppColors.primaryLime.withOpacity(0.08)
                : AppColors.primaryLime.withOpacity(0.12))
            : (isDark ? AppColors.darkSurfaceElevated : AppColors.gray100),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: set.isCompleted
              ? AppColors.primaryLime.withOpacity(0.4)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Set #
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppColors.darkSurface : Colors.white,
            ),
            child: Center(
              child: Text(
                '${set.setNumber}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Weight Column
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildNumberButton(
                  icon: Icons.remove,
                  onTap: () {
                    if (set.weightKg > 2.5) {
                      onSetChanged(set.copyWith(weightKg: set.weightKg - 2.5));
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '${set.weightKg.toStringAsFixed(set.weightKg % 1 == 0 ? 0 : 1)} kg',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _buildNumberButton(
                  icon: Icons.add,
                  onTap: () {
                    onSetChanged(set.copyWith(weightKg: set.weightKg + 2.5));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Reps Column
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildNumberButton(
                  icon: Icons.remove,
                  onTap: () {
                    if (set.reps > 1) {
                      onSetChanged(set.copyWith(reps: set.reps - 1));
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '${set.reps} reps',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _buildNumberButton(
                  icon: Icons.add,
                  onTap: () {
                    onSetChanged(set.copyWith(reps: set.reps + 1));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Status checkmark
          GestureDetector(
            onTap: () {
              onSetChanged(set.copyWith(isCompleted: !set.isCompleted));
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
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
                      : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                  width: 2,
                ),
              ),
              child: Center(
                child: set.isCompleted
                    ? const Icon(
                        Icons.check_rounded,
                        size: 20,
                        color: Color(0xFF111827),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16),
        ),
      ),
    );
  }
}
