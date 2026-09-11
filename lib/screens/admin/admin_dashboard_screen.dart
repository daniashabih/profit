import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/enums/user_role.dart';
import '../../providers/role_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/fit_flow_card.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final roleProv = context.watch<RoleProvider>();
    final isTrainerRole = roleProv.isTrainer;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          isTrainerRole ? 'Trainer Portal' : 'Admin Operations',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header stats
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: isTrainerRole ? 'Assigned Clients' : 'Active Members',
                    value: isTrainerRole ? '18' : '1,420',
                    icon: Icons.groups_rounded,
                    accentColor: AppColors.primaryLime,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    title: isTrainerRole ? 'Pending Plans' : 'Monthly Revenue',
                    value: isTrainerRole ? '4' : '\$38.4k',
                    icon: isTrainerRole ? Icons.pending_actions_rounded : Icons.monetization_on_rounded,
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
                  child: _buildMetricTile(
                    title: isTrainerRole ? 'Client Adherence' : 'Gym Attendance',
                    value: isTrainerRole ? '92%' : '840 / day',
                    icon: Icons.how_to_reg_rounded,
                    accentColor: AppColors.carbsColor,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    title: isTrainerRole ? 'Avg Rating' : 'Active Trainers',
                    value: isTrainerRole ? '4.95 ★' : '24',
                    icon: Icons.star_rounded,
                    accentColor: Colors.amber,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // MANAGEMENT SECTIONS
            Text(
              isTrainerRole ? 'CLIENT MANAGEMENT' : 'ADMIN CONTROLS',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            if (isTrainerRole) ...[
              _buildActionTile(
                icon: Icons.fitness_center_rounded,
                title: 'Create & Assign Workout Plan',
                subtitle: 'Assemble sequential exercise pathways for clients',
                isDark: isDark,
                onTap: () => _showFeedback(context, 'Opened Workout Plan Builder'),
              ),
              _buildActionTile(
                icon: Icons.restaurant_rounded,
                title: 'Create Diet & Macro Plan',
                subtitle: 'Specify daily calories, protein, carbs, and fats',
                isDark: isDark,
                onTap: () => _showFeedback(context, 'Opened Nutrition Plan Builder'),
              ),
              _buildActionTile(
                icon: Icons.track_changes_rounded,
                title: 'Track Client Progress & PRs',
                subtitle: 'Inspect weekly weight curves and 1RM milestones',
                isDark: isDark,
                onTap: () => _showFeedback(context, 'Opened Client Progress Monitor'),
              ),
              _buildActionTile(
                icon: Icons.flag_rounded,
                title: 'Set Weekly Goals',
                subtitle: 'Assign customized workout streaks & step targets',
                isDark: isDark,
                onTap: () => _showFeedback(context, 'Opened Goal Assignment Panel'),
              ),
            ] else ...[
              _buildActionTile(
                icon: Icons.people_alt_rounded,
                title: 'Manage Members & Subscriptions',
                subtitle: 'Search member accounts, renewals, and tier statuses',
                isDark: isDark,
                onTap: () => _showFeedback(context, 'Opened Members Management'),
              ),
              _buildActionTile(
                icon: Icons.sports_gymnastics_rounded,
                title: 'Manage Trainers Roster',
                subtitle: 'Assign clients, view certifications, and track ratings',
                isDark: isDark,
                onTap: () => _showFeedback(context, 'Opened Trainer Management'),
              ),
              _buildActionTile(
                icon: Icons.video_library_rounded,
                title: 'Manage Exercises & Library',
                subtitle: 'Add new exercise variations, muscle groups, and videos',
                isDark: isDark,
                onTap: () => _showFeedback(context, 'Opened Exercise Database Manager'),
              ),
              _buildActionTile(
                icon: Icons.credit_card_rounded,
                title: 'Manage Payments & Memberships',
                subtitle: 'Monitor recurring billing, revenue, and churn metrics',
                isDark: isDark,
                onTap: () => _showFeedback(context, 'Opened Billing Gateway Reports'),
              ),
              _buildActionTile(
                icon: Icons.campaign_rounded,
                title: 'Broadcast Push Notifications',
                subtitle: 'Send club announcements, holiday schedules, and alerts',
                isDark: isDark,
                onTap: () => _showFeedback(context, 'Opened Notification Broadcast Composer'),
              ),
              _buildActionTile(
                icon: Icons.bar_chart_rounded,
                title: 'View System Analytics & Reports',
                subtitle: 'Export CSV attendance logs, retention curves, and KPIs',
                isDark: isDark,
                onTap: () => _showFeedback(context, 'Generated Club Analytics Report'),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$message (Production feature ready)'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
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
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              Icon(icon, size: 18, color: accentColor),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceElevated : AppColors.gray100,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primaryLime, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      ),
    );
  }
}
