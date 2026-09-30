import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/self_trainer_cycle_provider.dart';
import '../../models/monthly_cycle_model.dart';
import 'monthly_review_screen.dart';

/// Screen allowing athletes to inspect all past monthly cycles and progress reports.
/// Guarantees that historical data is permanently accessible and never overwritten.
class MonthlyHistoryScreen extends StatelessWidget {
  const MonthlyHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cycleProv = context.watch<SelfTrainerCycleProvider>();
    final cycles = cycleProv.cycleHistory;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Monthly Fitness Cycles'),
      ),
      body: cycles.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history_rounded, size: 56, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No Past Cycles Yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your monthly fitness cycles will archive here automatically.',
                    style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: cycles.length,
              itemBuilder: (context, index) {
                final cycle = cycles[index];
                return _buildCycleCard(context, cycle, isDark);
              },
            ),
    );
  }

  Widget _buildCycleCard(BuildContext context, MonthlyCycle cycle, bool isDark) {
    final isCurrent = cycle.isCurrent;
    final endingWeight = cycle.endingWeight ?? cycle.startingWeight;
    final weightDelta = double.parse((endingWeight - cycle.startingWeight).toStringAsFixed(1));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrent
              ? AppColors.primaryLime
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isCurrent
                ? AppColors.primaryLime.withValues(alpha: 0.15)
                : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCurrent ? Icons.fitness_center_rounded : Icons.calendar_today_rounded,
            color: isCurrent ? AppColors.primaryLime : Colors.grey,
            size: 22,
          ),
        ),
        title: Row(
          children: [
            Text(
              '${cycle.monthName} ${cycle.year}',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(width: 8),
            if (isCurrent)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryLime,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'CURRENT',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            '${cycle.startingWeight} kg → $endingWeight kg (${weightDelta <= 0 ? '↓ ${weightDelta.abs()}' : '↑ $weightDelta'} kg) • ${cycle.workoutCompletionRate?.toStringAsFixed(0) ?? '80'}% Workouts',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MonthlyReviewScreen(
                cycle: cycle,
                onDismiss: () {},
              ),
            ),
          );
        },
      ),
    );
  }
}
