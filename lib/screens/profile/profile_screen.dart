import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/animations/animations.dart';
import '../../core/constants/app_constants.dart';
import '../../core/enums/user_role.dart';
import '../../core/responsive/breakpoints.dart';
import '../../models/food_post_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/food_journal_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/role_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/fit_flow_button.dart';
import '../../widgets/common/fit_flow_card.dart';
import '../../widgets/common/profit_logo.dart';
import '../nutrition/add_food_post_screen.dart';
import '../nutrition/daily_nutrition_dashboard_screen.dart';
import '../nutrition/meal_nutrition_detail_screen.dart';
import '../nutrition/monthly_nutrition_report_screen.dart';
import '../nutrition/nutrition_insights_screen.dart';
import '../trainer/trainer_screen.dart';
import '../membership/membership_screen.dart';
import '../progress/progress_screen.dart';
import '../notifications/notifications_screen.dart';
import '../settings/settings_screen.dart';
import '../gamification/gamification_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../trainer/trainer_dashboard_screen.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTab = 0; // 0: Food Posts, 1: Nutrition Hub, 2: Account & Menu

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final foodProv = Provider.of<FoodJournalProvider?>(context, listen: false);
    if (authProv.user != null && foodProv != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          foodProv.bindUser(authProv.user!.id);
        }
      });
    }
  }

  String _getUsername(UserModel? user) {
    if (user == null) return 'user';
    if (user.email.isNotEmpty && user.email.contains('@')) {
      final prefix = user.email.split('@').first.toLowerCase();
      if (prefix.isNotEmpty) return prefix;
    }
    return user.name.toLowerCase().replaceAll(' ', '');
  }

  void _showEditProfileDialog(BuildContext context) {
    final authProv = context.read<AuthProvider>();
    final user = authProv.user;
    final nameController = TextEditingController(text: user?.name ?? 'User');
    final goalController = TextEditingController(text: user?.goal ?? '');
    final weightController = TextEditingController(
      text: user?.currentWeightKg != null && user!.currentWeightKg > 0
          ? user.currentWeightKg.toStringAsFixed(1)
          : '',
    );
    final heightController = TextEditingController(
      text: user?.heightCm != null && user!.heightCm > 0
          ? user.heightCm.toStringAsFixed(0)
          : '',
    );

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w800)),
          content: SingleChildScrollView(
            child: Column(
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
                const SizedBox(height: 12),
                TextField(
                  controller: weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Current Weight (kg)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: heightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Height (cm)'),
                ),
              ],
            ),
          ),
          actions: [
            PressableScale(
              onTap: () => Navigator.pop(ctx),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text('Cancel'),
              ),
            ),
            PressableScale(
              onTap: () async {
                final newName = nameController.text.trim();
                final newGoal = goalController.text.trim();
                final newWeight = double.tryParse(weightController.text.trim());
                final newHeight = double.tryParse(heightController.text.trim());
                Navigator.pop(ctx);
                final success = await authProv.updateProfileDetails(
                  name: newName.isNotEmpty ? newName : null,
                  goal: newGoal.isNotEmpty ? newGoal : null,
                  currentWeightKg: newWeight,
                  heightCm: newHeight,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Profile updated successfully!'
                          : 'Failed to update profile'),
                    ),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primaryLime,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
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
    final foodProv = context.watch<FoodJournalProvider?>();
    final user = authProv.user;
    final isTrainer = (user?.role ?? roleProv.currentRole).isTrainer;

    final foodPosts = foodProv?.userPosts ?? [];
    final currentWeight = (user?.currentWeightKg != null && user!.currentWeightKg > 0)
        ? user.currentWeightKg
        : (progressProv.currentWeight > 0 ? progressProv.currentWeight : 69.0);
    final targetWeight = (user?.targetWeightKg != null && user!.targetWeightKg > 0)
        ? user.targetWeightKg
        : 55.0;
    final bmiVal = user?.bmi ?? 24.2;

    final postsCount = foodPosts.length;
    final workoutsCount = user?.totalWorkouts ?? 0;
    final progressCount = progressProv.measurements.length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        actions: [
          if (isTrainer)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLime.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryLime.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.sports_gymnastics_rounded,
                    size: 14,
                    color: AppColors.primaryLime,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'TRAINER',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.primaryLime : const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),
          PressableScale(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.settings_outlined),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: ResponsiveBreakpoints.maxContentWidth,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveBreakpoints.horizontalPadding(context),
              vertical: 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. TOP PROFILE SECTION (Social-style Fitness Profile)
                StaggeredEntrance(
                  index: 0,
                  child: Center(
                    child: Column(
                      children: [
                        // Profile Photo with Lime Border
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
                        const SizedBox(height: 12),

                        // User Name
                        Text(
                          user?.name ?? 'User',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),

                        // Username handle e.g. @dania
                        Text(
                          '@${_getUsername(user)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryLime,
                          ),
                        ),

                        // Trainer Tag if Trainer
                        if (isTrainer) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLime.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primaryLime.withOpacity(0.4)),
                            ),
                            child: const Text(
                              'ROLE: TRAINER',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: AppColors.primaryLime,
                              ),
                            ),
                          ),
                        ],

                        if (user?.goal.isNotEmpty == true) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurfaceElevated : AppColors.gray100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '🎯 ${user!.goal}',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),

                        // Weight, Target, BMI Stats Pill Card
                        FitFlowCard(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMetricCol('Weight', '${currentWeight.toStringAsFixed(0)} kg', isDark),
                              _buildVerticalDivider(isDark),
                              _buildMetricCol('Target', '${targetWeight.toStringAsFixed(0)} kg', isDark),
                              _buildVerticalDivider(isDark),
                              _buildMetricCol('BMI', bmiVal.toStringAsFixed(1), isDark, accent: AppColors.primaryLime),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Posts | Workouts | Progress Stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem('Posts', '$postsCount', isDark),
                            _buildVerticalDivider(isDark),
                            _buildStatItem('Workouts', '$workoutsCount', isDark),
                            _buildVerticalDivider(isDark),
                            _buildStatItem('Progress', '$progressCount', isDark),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // [ Edit Profile ]  and  [ + Add Food ] Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: FitFlowButton(
                                text: 'Edit Profile',
                                icon: Icons.edit_outlined,
                                isOutlined: true,
                                height: 42,
                                onPressed: () => _showEditProfileDialog(context),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FitFlowButton(
                                text: '+ Add Food',
                                icon: Icons.add_photo_alternate_rounded,
                                height: 42,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AddFoodPostScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // SEGMENTED TABS: [Food Grid] [Nutrition Hub] [Account & Menu]
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.gray100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildTabButton(
                        index: 0,
                        title: 'Food Posts',
                        icon: Icons.grid_on_rounded,
                        isDark: isDark,
                      ),
                      _buildTabButton(
                        index: 1,
                        title: 'Nutrition Hub',
                        icon: Icons.analytics_outlined,
                        isDark: isDark,
                      ),
                      _buildTabButton(
                        index: 2,
                        title: 'Account',
                        icon: Icons.person_outline_rounded,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // TAB 0: SOCIAL-STYLE FOOD GRID
                if (_selectedTab == 0) ...[
                  if (foodPosts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.restaurant_menu_rounded,
                            size: 52,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No Food Posts Yet',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Track meals with AI nutrition detection and build your daily food journal.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FitFlowButton(
                            text: '+ Add First Food Post',
                            icon: Icons.add_a_photo_outlined,
                            height: 40,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddFoodPostScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: foodPosts.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 6,
                        childAspectRatio: 1.0,
                      ),
                      itemBuilder: (ctx, idx) {
                        final post = foodPosts[idx];
                        return _buildFoodGridTile(context, post, isDark);
                      },
                    ),
                  const SizedBox(height: 16),
                  // Quick shortcut to Daily Timeline
                  PressableScale(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DailyNutritionDashboardScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceElevated : AppColors.gray100,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.timeline_rounded, size: 18, color: AppColors.primaryLime),
                          SizedBox(width: 8),
                          Text(
                            'View Daily Timeline & Targets',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryLime,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // TAB 1: NUTRITION HUB & ANALYTICS
                if (_selectedTab == 1) ...[
                  // Daily Dashboard Card
                  _buildNutritionHubCard(
                    title: 'Daily Nutrition Dashboard',
                    subtitle: 'Today’s calories, macros, timeline and remaining targets',
                    icon: Icons.today_rounded,
                    accentColor: AppColors.primaryLime,
                    isDark: isDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DailyNutritionDashboardScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Nutrition Insights Card
                  _buildNutritionHubCard(
                    title: 'Nutrition Insights',
                    subtitle: 'Weekly macro trends, fiber, and AI nutrition habits',
                    icon: Icons.insights_rounded,
                    accentColor: const Color(0xFF64B5F6),
                    isDark: isDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NutritionInsightsScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Monthly Nutrition Report Card
                  _buildNutritionHubCard(
                    title: 'Monthly Nutrition Analysis',
                    subtitle: 'Cycle consistency, workout vs rest day nutrition & target progress',
                    icon: Icons.calendar_month_rounded,
                    accentColor: const Color(0xFFFFB74D),
                    isDark: isDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MonthlyNutritionReportScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Responsive Fitness Foundation (BMI & Protein Estimates)
                  FitFlowCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.analytics_outlined, size: 18, color: AppColors.primaryLime),
                            const SizedBox(width: 8),
                            Text(
                              'Body Metrics & Nutrition Estimates',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkSurfaceElevated : AppColors.gray100,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'BMI',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user?.bmi.toStringAsFixed(1) ?? '—',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.primaryLime,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      user?.bmiCategory ?? '—',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? Colors.white70 : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkSurfaceElevated : AppColors.gray100,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Daily Protein',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user != null ? '${user.proteinRecommendation.targetGrams.toInt()}g' : '—',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.primaryLime,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      user != null
                                          ? 'Target (${user.proteinRecommendation.minGrams.toInt()}-${user.proteinRecommendation.maxGrams.toInt()}g)'
                                          : 'Target (—)',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? Colors.white70 : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Estimates calculated via Profit fitness engine based on body weight and activity level.',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontStyle: FontStyle.italic,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // TAB 2: ACCOUNT & MENU
                if (_selectedTab == 2) ...[
                  // Trainer / Admin Portal Access
                  if (user?.role == UserRole.trainer || roleProv.isTrainer) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      child: PressableScale(
                        child: ListTile(
                          tileColor: AppColors.primaryLime.withOpacity(0.15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: const BorderSide(color: AppColors.primaryLime),
                          ),
                          leading: const Icon(Icons.sports_gymnastics_rounded, color: AppColors.primaryLime),
                          title: const Text(
                            'Open Trainer Dashboard',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                          subtitle: const Text(
                            'Manage clients, workout splits & food journals',
                            style: TextStyle(fontSize: 11),
                          ),
                          trailing: const Icon(Icons.arrow_forward_rounded, color: AppColors.primaryLime),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const TrainerDashboardScreen()),
                            );
                          },
                        ),
                      ),
                    ),
                  ] else if (user?.role == UserRole.admin || roleProv.isAdmin) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      child: PressableScale(
                        child: ListTile(
                          tileColor: AppColors.primaryLime.withOpacity(0.15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: const BorderSide(color: AppColors.primaryLime),
                          ),
                          leading: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.primaryLime),
                          title: const Text(
                            'Open Admin Operations',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                          subtitle: const Text(
                            'Manage memberships, staff & analytics',
                            style: TextStyle(fontSize: 11),
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
                    ),
                  ],

                  // Menu Items Card
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
                  const SizedBox(height: 16),

                  // Sign Out Button
                  PressableScale(
                    child: Container(
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
                  ),
                  const SizedBox(height: 20),

                  // PROFIT Brand Footer
                  Center(
                    child: Column(
                      children: [
                        const ProFitLogo(
                          size: 36,
                          showText: true,
                          showTagline: true,
                          fontSize: 16,
                          taglineFontSize: 11,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Version ${AppConstants.appVersion}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required String title,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.darkSurfaceElevated : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? AppColors.primaryLime
                    : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? (isDark ? Colors.white : Colors.black87)
                      : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodGridTile(BuildContext context, FoodPost post, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MealNutritionDetailScreen(post: post),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Food Image or Fallback
            if (post.imageUrl.isNotEmpty)
              Image.network(
                post.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildFallbackFoodTile(post, isDark),
              )
            else
              _buildFallbackFoodTile(post, isDark),

            // Gradient and Calorie / Protein Overlay
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.85),
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${post.calories.toInt()} kcal',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${post.protein.toInt()}g P',
                      style: const TextStyle(
                        color: AppColors.primaryLime,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),

            // Meal Emoji Badge in Top-Right
            Positioned(
              top: 5,
              right: 5,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  post.mealType.emoji,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackFoodTile(FoodPost post, bool isDark) {
    return Container(
      color: isDark ? AppColors.darkSurfaceElevated : AppColors.gray200,
      child: Center(
        child: Text(
          post.mealType.emoji,
          style: const TextStyle(fontSize: 32),
        ),
      ),
    );
  }

  Widget _buildNutritionHubCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCol(String label, String value, bool isDark, {Color? accent}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: accent ?? (isDark ? Colors.white : Colors.black87),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
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
    return PressableScale(
      child: ListTile(
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
      ),
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
