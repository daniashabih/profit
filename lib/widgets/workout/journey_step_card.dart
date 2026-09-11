import 'package:flutter/material.dart';
import '../../models/exercise_model.dart';
import '../../theme/app_colors.dart';

class JourneyStepCard extends StatelessWidget {
  final int stepIndex; // 0-indexed (0 -> '01')
  final ExerciseModel exercise;
  final bool isLast;
  final VoidCallback onTap;

  const JourneyStepCard({
    super.key,
    required this.stepIndex,
    required this.exercise,
    this.isLast = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stepNumber = (stepIndex + 1).toString().padLeft(2, '0');
    final isCompleted = exercise.isCompleted;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline indicator
          SizedBox(
            width: 48,
            child: Column(
              children: [
                // Step node circle
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.primaryLime
                        : (isDark ? AppColors.darkSurfaceElevated : AppColors.gray200),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted
                          ? AppColors.primaryLime
                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(
                            Icons.check_rounded,
                            size: 20,
                            color: Color(0xFF111827),
                          )
                        : Text(
                            stepNumber,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                  ),
                ),
                // Connector line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: isCompleted
                          ? AppColors.primaryLime.withOpacity(0.5)
                          : (isDark ? AppColors.darkBorder : AppColors.gray300),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Exercise Details Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isCompleted
                            ? AppColors.primaryLime.withOpacity(0.3)
                            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        width: isCompleted ? 1.5 : 1,
                      ),
                      boxShadow: isDark
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Row(
                      children: [
                        // Exercise Thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 64,
                            height: 64,
                            color: isDark
                                ? AppColors.darkSurfaceElevated
                                : AppColors.gray100,
                            child: exercise.imageUrl.isNotEmpty
                                ? Image.network(
                                    exercise.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildFallbackIcon(),
                                  )
                                : _buildFallbackIcon(),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Text info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.darkSurfaceElevated
                                          : AppColors.gray100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      exercise.muscleGroup.displayName,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${exercise.sets} sets • ${exercise.reps} reps',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? AppColors.darkTextMuted
                                          : AppColors.lightTextMuted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Right status chevron / check
                        Icon(
                          isCompleted
                              ? Icons.check_circle_rounded
                              : Icons.chevron_right_rounded,
                          color: isCompleted
                              ? AppColors.primaryLime
                              : (isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.lightTextMuted),
                          size: 22,
                        ),
                      ],
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

  Widget _buildFallbackIcon() {
    return const Center(
      child: Icon(
        Icons.fitness_center_rounded,
        color: AppColors.primaryLime,
        size: 28,
      ),
    );
  }
}
