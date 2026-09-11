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

    if (measurements.isEmpty) {
      return const Center(child: Text('No measurement data recorded yet.'));
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < measurements.length; i++) {
      spots.add(FlSpot(i.toDouble(), measurements[i].weightKg));
    }

    final double minWeight = measurements
        .map((m) => m.weightKg)
        .fold(targetWeight, (min, w) => w < min ? w : min) - 2;
    final double maxWeight = measurements
        .map((m) => m.weightKg)
        .fold(targetWeight, (max, w) => w > max ? w : max) + 2;

    return AspectRatio(
      aspectRatio: 1.8,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 2,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: isDark
                    ? AppColors.darkBorder.withOpacity(0.5)
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
                  final index = value.toInt();
                  if (index >= 0 && index < measurements.length) {
                    final date = measurements[index].date;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '${date.month}/${date.day}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
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
                interval: 4,
                reservedSize: 36,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}kg',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (measurements.length - 1).toDouble(),
          minY: minWeight,
          maxY: maxWeight,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipRoundedRadius: 12,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    '${spot.y.toStringAsFixed(1)} kg',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            // Target Weight Line
            LineChartBarData(
              spots: [
                FlSpot(0, targetWeight),
                FlSpot((measurements.length - 1).toDouble(), targetWeight),
              ],
              isCurved: false,
              color: AppColors.info.withOpacity(0.6),
              barWidth: 2,
              isStrokeCapRound: true,
              dashArray: [6, 6],
              dotData: const FlDotData(show: false),
            ),
            // User Weight Curve
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: AppColors.primaryLime,
              barWidth: 3.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 5,
                    color: AppColors.primaryLime,
                    strokeWidth: 2,
                    strokeColor: isDark ? AppColors.darkBackground : Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryLime.withOpacity(0.25),
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
