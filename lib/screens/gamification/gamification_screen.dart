import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/progress_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/fit_flow_card.dart';
import '../../core/utils/formatters.dart';

class GamificationScreen extends StatelessWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progressProv = context.watch<ProgressProvider>();
    final achievements = progressProv.achievements;
    final personalRecords = progressProv.personalRecords;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Achievements & Records',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Streak Showcase
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF231E15), const Color(0xFF191612)]
                      : [const Color(0xFFFFFBEB), Colors.white],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('🔥', style: TextStyle(fontSize: 34)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '5-Day Active Streak',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'You\'re performing better than 84% of PROFIT members this week!',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // BADGES & MILESTONES
            const Text(
              'BADGES & MILESTONES',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 14),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: achievements.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, index) {
                final ach = achievements[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: ach.isUnlocked
                          ? AppColors.primaryLime.withOpacity(0.4)
                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      width: ach.isUnlocked ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: ach.isUnlocked
                              ? AppColors.primaryLime.withOpacity(0.15)
                              : (isDark ? AppColors.darkSurfaceElevated : AppColors.gray200),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            ach.iconEmoji,
                            style: TextStyle(
                              fontSize: 26,
                              color: ach.isUnlocked ? null : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        ach.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ach.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.3,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Progress bar or unlocked badge
                      if (ach.isUnlocked)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLime.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'UNLOCKED ✓',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryLime,
                            ),
                          ),
                        )
                      else
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ach.progressRatio,
                            minHeight: 5,
                            backgroundColor: isDark ? AppColors.darkSurfaceElevated : AppColors.gray200,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryLime),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 28),

            // PERSONAL RECORDS (PRs)
            const Text(
              'PERSONAL RECORDS (1RM)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: personalRecords.length,
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                itemBuilder: (context, idx) {
                  final pr = personalRecords[idx];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceElevated : AppColors.gray100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.military_tech_rounded, color: AppColors.primaryLime, size: 22),
                    ),
                    title: Text(
                      pr.exerciseName,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    subtitle: Text(
                      'Achieved on ${Formatters.formatDate(pr.achievedDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${pr.weightKg} kg',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryLime,
                          ),
                        ),
                        Text(
                          '${pr.reps} reps',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
