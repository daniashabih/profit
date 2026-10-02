import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/measurement_model.dart';
import '../../theme/app_colors.dart';

class WeightLineChart extends StatelessWidget {
  final List<BodyMeasurementModel> measurements;
  final double targetWeight;

  const WeightLineChart({
    super.key,
    required this.measurements,
    required this.targetWeight,
  });

  @override
  Widget build(BuildContext context) {
    if (measurements.isEmpty) {
      return const Center(
        child: Text(
          'No measurements yet.\\nAdd one to see your progress!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Sort measurements by date just in case
    final sortedMeasurements = List<BodyMeasurementModel>.from(measurements)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Map to FlSpot
    final spots = <FlSpot>[];
    for (int i = 0; i < sortedMeasurements.length; i++) {
      spots.add(FlSpot(i.toDouble(), sortedMeasurements[i].weightKg));
    }

    // Min/Max for Y-axis
    double minWeight = sortedMeasurements.map((m) => m.weightKg).reduce((a, b) => a < b ? a : b);
    double maxWeight = sortedMeasurements.map((m) => m.weightKg).reduce((a, b) => a > b ? a : b);
    
    // Add some padding to Y-axis
    minWeight = (minWeight - 2).floorToDouble();
    maxWeight = (maxWeight + 2).ceilToDouble();
    if (minWeight == maxWeight) {
      minWeight -= 2;
      maxWeight += 2;
    }

    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return AspectRatio(
      aspectRatio: 1.85,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 2,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: isDark
                    ? AppColors.darkBorder.withOpacity(0.4)
                    : AppColors.lightBorder,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < sortedMeasurements.length) {
                    final date = sortedMeasurements[idx].date;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '${monthNames[date.month - 1]} ${date.day}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 2,
                reservedSize: 42,
                getTitlesWidget: (value, meta) {
                  if (value % 2 == 0 && value >= minWeight && value <= maxWeight) {
                    return Text(
                      '${value.toInt()}kg',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (sortedMeasurements.length - 1).toDouble() > 0 ? (sortedMeasurements.length - 1).toDouble() : 1.0,
          minY: minWeight,
          maxY: maxWeight,
          lineBarsData: [
            // User Weight Curve (Smooth Green curve with dots)
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.4,
              color: AppColors.primaryLime,
              barWidth: 3.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 5.5,
                    color: AppColors.primaryLime,
                    strokeWidth: 2.5,
                    strokeColor: isDark ? const Color(0xFF161A20) : Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryLime.withOpacity(0.2),
                    AppColors.primaryLime.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      ),
    );
  }
}
