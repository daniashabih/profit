import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/profit_logo.dart';
import '../../widgets/common/fit_flow_card.dart';
import '../../widgets/common/fit_flow_button.dart';
import '../main_navigation.dart';
import '../auth/login_screen.dart';

class TrainerDashboardScreen extends StatefulWidget {
  final int initialIndex;

  const TrainerDashboardScreen({super.key, this.initialIndex = 0});

  @override
  State<TrainerDashboardScreen> createState() => _TrainerDashboardScreenState();
}

class _TrainerDashboardScreenState extends State<TrainerDashboardScreen> {
  late int _currentIndex;

  // Local state for interactive demo data
  int _pendingCount = 2;
  final List<_TrainerMemberItem> _members = [
    _TrainerMemberItem(
      id: 'm_01',
      name: 'Alex Rivera',
      email: 'alex.rivera@example.com',
      goal: 'Build Muscle & Bulk',
      assignedPlan: 'Upper/Lower 4-Day Split',
      streakDays: 8,
      progressPercent: 0.85,
      status: 'Active',
      statusColor: AppColors.primaryLime,
      avatarChar: 'A',
    ),
    _TrainerMemberItem(
      id: 'm_02',
      name: 'Sarah Connor',
      email: 'sarah.c@example.com',
      goal: 'Fat Loss & Conditioning',
      assignedPlan: 'Metabolic HIIT & Cardio',
      streakDays: 12,
      progressPercent: 0.92,
      status: 'Active',
      statusColor: AppColors.primaryLime,
      avatarChar: 'S',
    ),
    _TrainerMemberItem(
      id: 'm_03',
      name: 'James Wilson',
      email: 'j.wilson@example.com',
      goal: 'Strength & 1RM Gains',
      assignedPlan: 'Push / Pull / Legs',
      streakDays: 4,
      progressPercent: 0.65,
      status: 'Active',
      statusColor: AppColors.primaryLime,
      avatarChar: 'J',
    ),
    _TrainerMemberItem(
      id: 'm_04',
      name: 'Maya Lin',
      email: 'maya.lin@example.com',
      goal: 'General Health & Tone',
      assignedPlan: 'Full Body 3x Weekly',
      streakDays: 1,
      progressPercent: 0.30,
      status: 'Pending',
      statusColor: Colors.amber,
      avatarChar: 'M',
    ),
    _TrainerMemberItem(
      id: 'm_05',
      name: 'David Chen',
      email: 'd.chen@example.com',
      goal: 'Hypertrophy & Mobility',
      assignedPlan: 'Custom Routine',
      streakDays: 0,
      progressPercent: 0.10,
      status: 'Pending',
      statusColor: Colors.amber,
      avatarChar: 'D',
    ),
  ];

  final List<_WorkoutPlanItem> _workoutPlans = [
    _WorkoutPlanItem(
      title: 'Upper/Lower 4-Day Split',
      category: 'Hypertrophy',
      daysPerWeek: 4,
      assignedMembers: 8,
      difficulty: 'Intermediate',
    ),
    _WorkoutPlanItem(
      title: 'Metabolic HIIT & Fat Burn',
      category: 'Cardio & Conditioning',
      daysPerWeek: 3,
      assignedMembers: 6,
      difficulty: 'All Levels',
    ),
    _WorkoutPlanItem(
      title: 'Push / Pull / Legs Strength',
      category: 'Power & Mass',
      daysPerWeek: 5,
      assignedMembers: 5,
      difficulty: 'Advanced',
    ),
    _WorkoutPlanItem(
      title: 'Beginner Full Body Foundation',
      category: 'Mobility & Habit',
      daysPerWeek: 3,
      assignedMembers: 4,
      difficulty: 'Beginner',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _showCreatePlanDialog() {
    final titleController = TextEditingController();
    final categoryController = TextEditingController(text: 'Hypertrophy');
    final daysController = TextEditingController(text: '4');

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.add_task_rounded, color: AppColors.primaryLime, size: 24),
              SizedBox(width: 10),
              Text('Create Workout Plan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Plan Name',
                    hintText: 'e.g. 5-Day Power Split',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    hintText: 'e.g. Hypertrophy, Strength, HIIT',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: daysController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Days Per Week',
                    hintText: 'e.g. 4',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLime,
                foregroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                if (titleController.text.trim().isNotEmpty) {
                  setState(() {
                    _workoutPlans.insert(
                      0,
                      _WorkoutPlanItem(
                        title: titleController.text.trim(),
                        category: categoryController.text.trim(),
                        daysPerWeek: int.tryParse(daysController.text.trim()) ?? 4,
                        assignedMembers: 0,
                        difficulty: 'Intermediate',
                      ),
                    );
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Plan "${titleController.text.trim()}" created successfully! 📋'),
                      backgroundColor: const Color(0xFF1E293B),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Save Plan', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        );
      },
    );
  }

  void _showAssignPlanDialog(_TrainerMemberItem member) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
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
              Text(
                'Assign Plan to ${member.name}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Select a workout plan tailored for ${member.name}\'s goal: ${member.goal}',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ..._workoutPlans.map((plan) {
                final isCurrent = member.assignedPlan == plan.title;
                return ListTile(
                  dense: true,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  tileColor: isCurrent ? AppColors.primaryLime.withOpacity(0.12) : null,
                  leading: const Icon(Icons.fitness_center_rounded, color: AppColors.primaryLime, size: 20),
                  title: Text(plan.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  subtitle: Text('${plan.category} • ${plan.daysPerWeek} days/wk', style: const TextStyle(fontSize: 11)),
                  trailing: isCurrent ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryLime) : null,
                  onTap: () {
                    setState(() {
                      member.assignedPlan = plan.title;
                      member.status = 'Active';
                      member.statusColor = AppColors.primaryLime;
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Assigned "${plan.title}" to ${member.name}! 💪'),
                        backgroundColor: const Color(0xFF1E293B),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tabs = [
      _buildHomeTab(isDark),
      _buildMembersTab(isDark),
      _buildPlansTab(isDark),
      _buildProgressTab(isDark),
      _buildProfileTab(isDark),
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.dashboard_rounded, 'Home'),
                _buildNavItem(1, Icons.groups_rounded, 'Members'),
                _buildNavItem(2, Icons.assignment_rounded, 'Plans'),
                _buildNavItem(3, Icons.trending_up_rounded, 'Progress'),
                _buildNavItem(4, Icons.person_rounded, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => _onTabChanged(index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? AppColors.primaryLime : AppColors.darkTextMuted,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.primaryLime : AppColors.darkTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= TAB 0: HOME =================
  Widget _buildHomeTab(bool isDark) {
    final authProv = context.watch<AuthProvider>();
    final user = authProv.user;
    final trainerName = user?.name.isNotEmpty == true ? user!.name : 'Coach';
    final profile = user?.trainerProfile;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const ProFitLogo(size: 24, showText: true, fontSize: 18),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryLime.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryLime.withOpacity(0.5)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sports_gymnastics_rounded, size: 14, color: AppColors.primaryLime),
                SizedBox(width: 4),
                Text(
                  'TRAINER',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: AppColors.primaryLime,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new alerts. All members up to date!')),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Text(
              'Welcome Back, $trainerName! 👋',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage your athletes, review workout completions, and track progress.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 18),

            // Trainer Profile Summary Card
            FitFlowCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primaryLime.withOpacity(0.2),
                    child: Text(
                      trainerName.isNotEmpty ? trainerName[0].toUpperCase() : 'T',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryLime,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trainerName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profile?.specialization.isNotEmpty == true
                              ? profile!.specialization
                              : 'Certified Fitness Coach',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                            const SizedBox(width: 2),
                            const Text('4.9', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLime.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${profile?.experienceYears ?? 4}+ Yrs Exp',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryLime,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onPressed: () => _onTabChanged(4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4 KPI Cards: Total Members, Active Members, Workout Plans, Pending Requests
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Total Members',
                    value: '${_members.length}',
                    subtext: '+2 this month',
                    icon: Icons.groups_rounded,
                    accentColor: AppColors.primaryLime,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Active Members',
                    value: '${_members.where((m) => m.status == 'Active').length}',
                    subtext: '80% adherence',
                    icon: Icons.check_circle_outline_rounded,
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
                    title: 'Workout Plans',
                    value: '${_workoutPlans.length}',
                    subtext: '4 active splits',
                    icon: Icons.assignment_outlined,
                    accentColor: AppColors.carbsColor,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Pending Requests',
                    value: '$_pendingCount',
                    subtext: 'Needs review',
                    icon: Icons.person_add_alt_rounded,
                    accentColor: Colors.amber,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // QUICK ACTIONS SECTION
            const Text(
              'QUICK ACTIONS',
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
                  child: _buildQuickActionButton(
                    icon: Icons.add_circle_outline_rounded,
                    title: 'Create Plan',
                    subtitle: 'New routine',
                    isDark: isDark,
                    onTap: _showCreatePlanDialog,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.people_alt_outlined,
                    title: 'View Members',
                    subtitle: 'Client roster',
                    isDark: isDark,
                    onTap: () => _onTabChanged(1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.library_books_outlined,
                    title: 'Manage Plans',
                    subtitle: 'Edit templates',
                    isDark: isDark,
                    onTap: () => _onTabChanged(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.insights_rounded,
                    title: 'View Progress',
                    subtitle: 'Client stats',
                    isDark: isDark,
                    onTap: () => _onTabChanged(3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // PENDING REQUESTS WIDGET (if any)
            if (_pendingCount > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'PENDING REQUESTS',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$_pendingCount New',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.amber),
                    ),
                  ),
                ],
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
                  itemCount: _members.where((m) => m.status == 'Pending').length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                  itemBuilder: (context, index) {
                    final pendingMember = _members.where((m) => m.status == 'Pending').toList()[index];
                    return Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.amber.withOpacity(0.2),
                            child: Text(
                              pendingMember.avatarChar,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.amber),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pendingMember.name,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                                ),
                                Text(
                                  'Goal: ${pendingMember.goal}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.close_rounded, color: AppColors.error, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _members.remove(pendingMember);
                                    if (_pendingCount > 0) _pendingCount--;
                                  });
                                },
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryLime,
                                  foregroundColor: const Color(0xFF0F172A),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () {
                                  setState(() {
                                    pendingMember.status = 'Active';
                                    pendingMember.statusColor = AppColors.primaryLime;
                                    if (_pendingCount > 0) _pendingCount--;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Accepted ${pendingMember.name} into coaching! 🚀')),
                                  );
                                },
                                child: const Text('Accept', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // RECENT MEMBER ACTIVITY
            const Text(
              'RECENT MEMBER ACTIVITY',
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
              child: Column(
                children: [
                  _buildActivityTile(
                    avatarChar: 'A',
                    name: 'Alex Rivera',
                    action: 'Completed Leg Day 4x Hypertrophy',
                    time: '15m ago',
                    icon: Icons.check_circle_rounded,
                    iconColor: AppColors.primaryLime,
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),
                  _buildActivityTile(
                    avatarChar: 'S',
                    name: 'Sarah Connor',
                    action: 'Logged nutrition: 2,150 kcal (Hit target)',
                    time: '1h ago',
                    icon: Icons.restaurant_rounded,
                    iconColor: AppColors.proteinColor,
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),
                  _buildActivityTile(
                    avatarChar: 'J',
                    name: 'James Wilson',
                    action: 'Recorded body weight: 78.2 kg (-1.2 kg)',
                    time: '3h ago',
                    icon: Icons.monitor_weight_outlined,
                    iconColor: AppColors.carbsColor,
                    isDark: isDark,
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

  // ================= TAB 1: MEMBERS =================
  Widget _buildMembersTab(bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('My Members', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Member invite link copied to clipboard! 📋')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: _members.length,
        itemBuilder: (context, index) {
          final member = _members[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
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
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primaryLime.withOpacity(0.18),
                      child: Text(
                        member.avatarChar,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryLime,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(member.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text(
                            member.goal,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: member.statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        member.status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: member.statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ASSIGNED PLAN',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            member.assignedPlan,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'STREAK',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${member.streakDays} Days 🔥',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.orangeAccent),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: member.progressPercent,
                    minHeight: 6,
                    backgroundColor: isDark ? AppColors.darkSurfaceElevated : AppColors.gray200,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryLime),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: FitFlowButton(
                        text: 'Assign Plan',
                        icon: Icons.assignment_outlined,
                        isOutlined: true,
                        height: 38,
                        onPressed: () => _showAssignPlanDialog(member),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FitFlowButton(
                        text: 'Message',
                        icon: Icons.chat_bubble_outline_rounded,
                        height: 38,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Opening chat with ${member.name}... 💬')),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= TAB 2: PLANS =================
  Widget _buildPlansTab(bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Workout & Diet Plans', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _showCreatePlanDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ROUTINES & TEMPLATES',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                TextButton.icon(
                  onPressed: _showCreatePlanDialog,
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 16, color: AppColors.primaryLime),
                  label: const Text(
                    'New Plan',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryLime),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._workoutPlans.map((plan) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLime.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.fitness_center_rounded,
                        color: AppColors.primaryLime,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(plan.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text(
                            '${plan.category} • ${plan.daysPerWeek} days/week',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${plan.assignedMembers} active athletes assigned',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryLime),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert_rounded),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Options for "${plan.title}"')),
                        );
                      },
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ================= TAB 3: PROGRESS =================
  Widget _buildProgressTab(bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Client Progress', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FitFlowCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Member Weekly Compliance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(
                    'Overall group completed 91% of scheduled sets this week.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: const LinearProgressIndicator(
                      value: 0.91,
                      minHeight: 10,
                      backgroundColor: AppColors.gray200,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLime),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Target: 85%', style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
                      Text('Current: 91% 🎯', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryLime)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Volume Lifted',
                    value: '184k kg',
                    subtext: 'Team aggregate',
                    icon: Icons.fitness_center_rounded,
                    accentColor: AppColors.primaryLime,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Workouts Logged',
                    value: '94',
                    subtext: 'This week',
                    icon: Icons.fact_check_rounded,
                    accentColor: AppColors.carbsColor,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'TOP CLIENT STREAKS',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.2),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                separatorBuilder: (_, _) => Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                itemBuilder: (context, idx) {
                  final m = _members[idx];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryLime.withOpacity(0.18),
                      child: Text(m.avatarChar, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryLime)),
                    ),
                    title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(m.assignedPlan, style: const TextStyle(fontSize: 12)),
                    trailing: Text('${m.streakDays} Days 🔥', style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.orangeAccent)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= TAB 4: PROFILE =================
  Widget _buildProfileTab(bool isDark) {
    final authProv = context.watch<AuthProvider>();
    final user = authProv.user;
    final trainerName = user?.name.isNotEmpty == true ? user!.name : 'Coach';
    final profile = user?.trainerProfile;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Trainer Profile', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.primaryLime.withOpacity(0.2),
                    child: Text(
                      trainerName.isNotEmpty ? trainerName[0].toUpperCase() : 'T',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryLime,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    trainerName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'trainer@profit.app',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLime.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      profile?.specialization.isNotEmpty == true
                          ? profile!.specialization
                          : 'Strength & Conditioning',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryLime,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Profile info card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Column(
                children: [
                  _buildProfileRow(
                    'Experience',
                    '${profile?.experienceYears ?? 1} Years Coaching',
                    Icons.military_tech_rounded,
                    isDark,
                  ),
                  _buildDivider(isDark),
                  _buildProfileRow(
                    'Gym / Location',
                    profile?.gymLocation ?? 'PROFIT Elite Center, Downtown',
                    Icons.location_on_rounded,
                    isDark,
                  ),
                  _buildDivider(isDark),
                  _buildProfileRow(
                    'Phone',
                    profile?.phoneNumber ?? '+1 (555) 019-2834',
                    Icons.phone_rounded,
                    isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Switch to Member Mode (allows trainer to test member view)
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: ListTile(
                leading: const Icon(Icons.fitness_center_rounded, color: AppColors.primaryLime),
                title: const Text('Switch to Member View', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: const Text('Experience workout tracking as a member', style: TextStyle(fontSize: 11)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MainNavigation()),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Sign Out
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                title: const Text(
                  'Sign Out',
                  style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.error, fontSize: 14),
                ),
                onTap: () async {
                  await authProv.signOut();
                  if (!mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
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

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
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
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryLime.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primaryLime, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile({
    required String avatarChar,
    required String name,
    required String action,
    required String time,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: iconColor.withOpacity(0.15),
            child: Text(avatarChar, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: iconColor)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                const SizedBox(height: 1),
                Text(
                  action,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, String value, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryLime),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
    );
  }
}

class _TrainerMemberItem {
  final String id;
  final String name;
  final String email;
  final String goal;
  String assignedPlan;
  final int streakDays;
  final double progressPercent;
  String status;
  Color statusColor;
  final String avatarChar;

  _TrainerMemberItem({
    required this.id,
    required this.name,
    required this.email,
    required this.goal,
    required this.assignedPlan,
    required this.streakDays,
    required this.progressPercent,
    required this.status,
    required this.statusColor,
    required this.avatarChar,
  });
}

class _WorkoutPlanItem {
  final String title;
  final String category;
  final int daysPerWeek;
  final int assignedMembers;
  final String difficulty;

  _WorkoutPlanItem({
    required this.title,
    required this.category,
    required this.daysPerWeek,
    required this.assignedMembers,
    required this.difficulty,
  });
}
