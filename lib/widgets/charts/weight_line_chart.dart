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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final monthNames = ['Jun', 'Jul', 'Aug', 'Sep'];

    // Seed points matching Mockup Screen 8: Jun (72), Jul (70.8), Aug (69.8), Sep (69.0)
    final spots = <FlSpot>[
      const FlSpot(0, 72.0),
      const FlSpot(1, 70.8),
      const FlSpot(2, 69.8),
      const FlSpot(3, 69.0),
    ];

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
                  if (idx >= 0 && idx < monthNames.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        monthNames[idx],
                        style: TextStyle(
                          fontSize: 12,
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
                  if (value % 2 == 0 && value >= 64 && value <= 72) {
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
          maxX: 3,
          minY: 64,
          maxY: 74,
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
      ),
    );
  }
}
