import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/fit_flow_card.dart';
import '../../widgets/charts/weight_line_chart.dart';
import '../../core/utils/formatters.dart';
import 'add_measurement_dialog.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progressProv = context.watch<ProgressProvider>();
    final authProv = context.watch<AuthProvider>();
    final user = authProv.user;

    final measurements = progressProv.measurements;
    final latest = measurements.isNotEmpty ? measurements.last : null;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Progress Analytics',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Record Measurements',
            icon: const Icon(Icons.add_chart_rounded, color: AppColors.primaryLime, size: 24),
            onPressed: () => AddMeasurementDialog.show(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // WEIGHT JOURNEY SECTION
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'WEIGHT JOURNEY',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                GestureDetector(
                  onTap: () => AddMeasurementDialog.show(context),
                  child: const Text(
                    '+ Log Weight',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryLime,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Line chart card
            FitFlowCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Three weight targets summary: Current, Starting, Target
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildWeightBadge('Current', '${progressProv.currentWeight.toStringAsFixed(1)} kg', AppColors.primaryLime, isDark),
                      _buildWeightBadge('Starting', '${progressProv.startingWeight.toStringAsFixed(1)} kg', isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary, isDark),
                      _buildWeightBadge('Target', '${progressProv.targetWeight.toStringAsFixed(1)} kg', AppColors.info, isDark),
                    ],
                  ),
                  const SizedBox(height: 24),
                  WeightLineChart(
                    measurements: measurements,
                    targetWeight: progressProv.targetWeight,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // OVERALL STATS (Workouts, Training Time, Total Volume, Calories)
            const Text(
              'TRAINING STATS',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.fitness_center_rounded,
                    title: 'Workouts',
                    value: '${user?.totalWorkouts ?? 28}',
                    subtitle: 'Completed',
                    accentColor: AppColors.primaryLime,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.access_time_rounded,
                    title: 'Training Time',
                    value: '${((user?.totalTrainingMinutes ?? 1140) / 60).toStringAsFixed(1)} hrs',
                    subtitle: 'Active time',
                    accentColor: AppColors.proteinColor,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.shield_rounded,
                    title: 'Total Volume',
                    value: '${((user?.totalVolumeKg ?? 18450) / 1000).toStringAsFixed(1)} t',
                    subtitle: 'Total lifted',
                    accentColor: AppColors.carbsColor,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.local_fire_department_rounded,
                    title: 'Calories',
                    value: Formatters.formatCalories(user?.totalCaloriesBurned ?? 9800),
                    subtitle: 'Burned total',
                    accentColor: AppColors.fatColor,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // BODY MEASUREMENTS TRACKING (Weight, Waist, Chest, Arms, Thighs)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'BODY MEASUREMENTS',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                GestureDetector(
                  onTap: () => AddMeasurementDialog.show(context),
                  child: const Text(
                    '+ Record',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryLime,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (latest != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Latest Record: ${Formatters.formatDate(latest.date)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                        if (latest.note != null)
                          Text(
                            latest.note!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildCircMeasure('Weight', '${latest.weightKg} kg', isDark),
                        _buildCircMeasure('Waist', '${latest.waistCm} cm', isDark),
                        _buildCircMeasure('Chest', '${latest.chestCm} cm', isDark),
                        _buildCircMeasure('Arms', '${latest.armsCm} cm', isDark),
                        _buildCircMeasure('Thighs', '${latest.thighsCm} cm', isDark),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightBadge(String label, String value, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color accentColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              Icon(icon, size: 18, color: accentColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircMeasure(String label, String value, bool isDark) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceElevated : AppColors.gray100,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Center(
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }
}
