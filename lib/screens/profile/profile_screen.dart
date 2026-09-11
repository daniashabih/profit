import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/enums/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/role_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/fit_flow_card.dart';
import '../trainer/trainer_screen.dart';
import '../membership/membership_screen.dart';
import '../progress/progress_screen.dart';
import '../notifications/notifications_screen.dart';
import '../settings/settings_screen.dart';
import '../gamification/gamification_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showRoleSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final currentRole = ctx.watch<RoleProvider>().currentRole;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Switch Active Role (Demo / Testing)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Experience PROFIT as a Gym Member, Certified Trainer, or Club Administrator.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 18),
              ...UserRole.values.map((role) {
                final isSelected = currentRole == role;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    tileColor: isSelected
                        ? AppColors.primaryLime.withOpacity(0.12)
                        : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primaryLime
                            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                    ),
                    leading: Icon(
                      role == UserRole.member
                          ? Icons.person_rounded
                          : (role == UserRole.trainer
                              ? Icons.sports_gymnastics_rounded
                              : Icons.admin_panel_settings_rounded),
                      color: isSelected ? AppColors.primaryLime : null,
                    ),
                    title: Text(
                      role.displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isSelected ? AppColors.primaryLime : null,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryLime)
                        : null,
                    onTap: () {
                      ctx.read<RoleProvider>().setRole(role);
                      Navigator.pop(ctx);
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final authProv = context.read<AuthProvider>();
    final user = authProv.user;
    final nameController = TextEditingController(text: user?.name ?? 'Dania Shabih');
    final goalController = TextEditingController(text: user?.goal ?? 'Weight Loss');

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: goalController,
                decoration: const InputDecoration(labelText: 'Fitness Goal'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLime,
                foregroundColor: const Color(0xFF111827),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully!')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProv = context.watch<AuthProvider>();
    final progressProv = context.watch<ProgressProvider>();
    final roleProv = context.watch<RoleProvider>();
    final user = authProv.user;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        actions: [
          // Role switch badge button
          GestureDetector(
            onTap: () => _showRoleSelector(context),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLime.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryLime.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.swap_horiz_rounded, size: 14, color: AppColors.primaryLime),
                  const SizedBox(width: 4),
                  Text(
                    roleProv.currentRole.displayName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.primaryLime : const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // PROFILE HERO SECTION (Matching Screen 12 mockup)
            Center(
              child: Column(
                children: [
                  // Avatar with Lime Border
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryLime, width: 2.5),
                    ),
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: isDark ? AppColors.darkSurfaceElevated : AppColors.gray200,
                      backgroundImage: (user?.avatarUrl.isNotEmpty ?? false)
                          ? NetworkImage(user!.avatarUrl)
                          : null,
                      child: (user?.avatarUrl.isEmpty ?? true)
                          ? const Icon(Icons.person_rounded, size: 48, color: AppColors.primaryLime)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user?.name ?? 'Dania Shabih',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Beginner • Fitness',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // "Edit Profile" Pill Button
                  GestureDetector(
                    onTap: () => _showEditProfileDialog(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceElevated : AppColors.gray100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 14,
                            color: isDark ? AppColors.primaryLime : const Color(0xFF111827),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.primaryLime : const Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4-COLUMN STATS CARD (Matching Screen 12 mockup: Goal | Current | Target | Height)
            FitFlowCard(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Goal', 'Weight Loss', isDark),
                  _buildVerticalDivider(isDark),
                  _buildStatItem('Current', '${progressProv.currentWeight.toStringAsFixed(0)} kg', isDark),
                  _buildVerticalDivider(isDark),
                  _buildStatItem('Target', '${progressProv.targetWeight.toStringAsFixed(0)} kg', isDark),
                  _buildVerticalDivider(isDark),
                  _buildStatItem('Height', "5'0\"", isDark),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Trainer / Admin Portal Access (if active role or available)
            if (!roleProv.isMember) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: ListTile(
                  tileColor: AppColors.primaryLime.withOpacity(0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: AppColors.primaryLime),
                  ),
                  leading: const Icon(Icons.dashboard_customize_rounded, color: AppColors.primaryLime),
                  title: Text(
                    roleProv.isTrainer ? 'Open Trainer Portal' : 'Open Admin Operations',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                  subtitle: Text(
                    roleProv.isTrainer ? 'Manage clients and diet routines' : 'Manage memberships, staff & analytics',
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: const Icon(Icons.arrow_forward_rounded, color: AppColors.primaryLime),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                    );
                  },
                ),
              ),
            ],

            // MENU ITEMS (Matching Screen 12: My Plans, My Membership, Measurements, Workout History, Notifications, Settings, Help & Support)
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.assignment_outlined,
                    title: 'My Plans',
                    isDark: isDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TrainerScreen()),
                      );
                    },
                  ),
                  _buildDivider(isDark),
                  _buildMenuItem(
                    icon: Icons.card_membership_rounded,
                    title: 'My Membership',
                    isDark: isDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MembershipScreen()),
                      );
                    },
                  ),
                  _buildDivider(isDark),
                  _buildMenuItem(
                    icon: Icons.show_chart_rounded,
                    title: 'Measurements',
                    isDark: isDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProgressScreen()),
                      );
                    },
                  ),
                  _buildDivider(isDark),
                  _buildMenuItem(
                    icon: Icons.history_rounded,
                    title: 'Workout History',
                    isDark: isDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GamificationScreen()),
                      );
                    },
                  ),
                  _buildDivider(isDark),
                  _buildMenuItem(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    isDark: isDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                      );
                    },
                  ),
                  _buildDivider(isDark),
                  _buildMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    isDark: isDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                  _buildDivider(isDark),
                  _buildMenuItem(
                    icon: Icons.help_outline_rounded,
                    title: 'Help & Support',
                    isDark: isDark,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Connecting to PROFIT 24/7 Support Desk...')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Sign Out Button
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                title: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                onTap: () async {
                  await authProv.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      width: 1,
      height: 28,
      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceElevated : AppColors.gray100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: AppColors.primaryLime),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 60,
      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
    );
  }
}
