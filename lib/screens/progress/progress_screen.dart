import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/progress_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/charts/weight_line_chart.dart';
import 'add_measurement_dialog.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int _selectedTab = 0; // 0: Weight, 1: Body Fat, 2: Measurements

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progressProv = context.watch<ProgressProvider>();

    final measurements = progressProv.measurements;
    final latest = measurements.isNotEmpty ? measurements.last : null;

    final tabs = ['Weight', 'Body Fat', 'Measurements'];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Your Journey',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'Add Record',
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
            // Segmented Pills: [Weight] [Body Fat] [Measurements] (Screen 8 in mockup)
            Row(
              children: List.generate(tabs.length, (idx) {
                final isSelected = _selectedTab == idx;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = idx),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      margin: EdgeInsets.only(right: idx < tabs.length - 1 ? 8 : 0),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryLime
                            : (isDark ? AppColors.darkSurface : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryLime
                              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          tabs[idx],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? const Color(0xFF0F172A)
                                : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // Weight Line Chart Card (Screen 8 in mockup)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161A20) : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: WeightLineChart(
                measurements: measurements,
                targetWeight: progressProv.targetWeight,
              ),
            ),
            const SizedBox(height: 28),

            // Section: "This Month" (Screen 8 in mockup)
            const Text(
              'This Month',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 14),

            // 2x2 Grid of dark rounded cards (Screen 8 in mockup)
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.fitness_center_rounded,
                    title: 'Workouts',
                    value: '18',
                    iconColor: AppColors.primaryLime,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.access_time_rounded,
                    title: 'Training Time',
                    value: '12h 40m',
                    iconColor: AppColors.primaryLime,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.shield_rounded,
                    title: 'Total Volume',
                    value: '24,580 kg',
                    iconColor: AppColors.primaryLime,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.local_fire_department_rounded,
                    title: 'Calories',
                    value: '8,420',
                    iconColor: Colors.orange,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Measurements Details (if tab 2 selected)
            if (_selectedTab == 2 && latest != null) ...[
              const Text(
                'Body Measurements',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161A20) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCircMeasure('Weight', '${latest.weightKg} kg', isDark),
                    _buildCircMeasure('Waist', '${latest.waistCm} cm', isDark),
                    _buildCircMeasure('Chest', '${latest.chestCm} cm', isDark),
                    _buildCircMeasure('Arms', '${latest.armsCm} cm', isDark),
                    _buildCircMeasure('Thighs', '${latest.thighsCm} cm', isDark),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161A20) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
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
          width: 50,
          height: 50,
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
