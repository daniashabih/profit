import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trainer_provider.dart';
import '../../models/trainer_member_model.dart';
import '../../models/workout_model.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/profit_logo.dart';
import '../../widgets/common/fit_flow_card.dart';
import '../../widgets/common/fit_flow_button.dart';
import '../main_navigation.dart';
import '../auth/login_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ROOT FIX NOTES (2026-10-01):
//
// Previous bug: _buildHomeTab() (and all other tab builders) were plain methods
// that returned a full Scaffold widget. These were called directly inside the
// parent build() method to populate an IndexedStack inside an outer Scaffold.
// This created nested Scaffolds whose inner bodies rendered blank/invisible
// because:
//   1. Provider.of() called inside build() caused rebuild loops at init time.
//   2. Nested Scaffold in an IndexedStack body does not properly inherit
//      MediaQuery viewPadding/insets, making inner Scaffold content invisible.
//
// Fix: Each tab is now a proper StatelessWidget or StatefulWidget that owns its
// own build lifecycle, Provider lookups, and layout. The outer TrainerDashboard
// shell only manages tab index + bottom nav + routing. No nested Scaffolds.
// ─────────────────────────────────────────────────────────────────────────────

class TrainerDashboardScreen extends StatefulWidget {
  final int initialIndex;

  const TrainerDashboardScreen({super.key, this.initialIndex = 0});

  @override
  State<TrainerDashboardScreen> createState() => _TrainerDashboardScreenState();
}

class _TrainerDashboardScreenState extends State<TrainerDashboardScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    debugPrint('[TrainerDashboard] initState — initialIndex: ${widget.initialIndex}');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Bind trainer provider to the authenticated user once after dependencies resolve
    final authProv = context.read<AuthProvider?>();
    final trainerProv = context.read<TrainerProvider?>();
    final uid = authProv?.user?.id;
    debugPrint('[TrainerDashboard] didChangeDependencies — uid: $uid, role: ${authProv?.user?.role}');
    if (uid != null && trainerProv != null) {
      trainerProv.bindTrainer(uid);
    }
  }

  void _onTabChanged(int index) {
    debugPrint('[TrainerDashboard] Tab changed: $_currentIndex → $index');
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    debugPrint('[TrainerDashboard] build() — currentIndex: $_currentIndex');

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _TrainerHomeTab(onTabChanged: _onTabChanged),
          _TrainerMembersTab(onTabChanged: _onTabChanged),
          _TrainerPlansTab(onTabChanged: _onTabChanged),
          _TrainerProgressTab(onTabChanged: _onTabChanged),
          _TrainerProfileTab(onTabChanged: _onTabChanged),
        ],
      ),
      bottomNavigationBar: _TrainerBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTTOM NAVIGATION — Trainer-specific destinations
// ─────────────────────────────────────────────────────────────────────────────

class _TrainerBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _TrainerBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = [
      _NavItem(Icons.dashboard_rounded, 'Home'),
      _NavItem(Icons.groups_rounded, 'Clients'),
      _NavItem(Icons.assignment_rounded, 'Programs'),
      _NavItem(Icons.trending_up_rounded, 'Progress'),
      _NavItem(Icons.person_rounded, 'Profile'),
    ];

    return Container(
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
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isSelected = currentIndex == index;
              final item = items[index];
              return InkWell(
                onTap: () => onTap(index),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        size: 22,
                        color: isSelected ? AppColors.primaryLime : AppColors.darkTextMuted,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
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
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 0 — TRAINER HOME (proper StatefulWidget, no nested Scaffold)
// ─────────────────────────────────────────────────────────────────────────────

class _TrainerHomeTab extends StatefulWidget {
  final ValueChanged<int> onTabChanged;
  const _TrainerHomeTab({required this.onTabChanged});

  @override
  State<_TrainerHomeTab> createState() => _TrainerHomeTabState();
}

class _TrainerHomeTabState extends State<_TrainerHomeTab> {
  // ── Dialogs ────────────────────────────────────────────────────────────────

  void _showAddClientDialog(TrainerProvider? trainerProv) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final goalCtrl = TextEditingController(text: 'Build Lean Muscle');
    final weightCtrl = TextEditingController(text: '75');
    final heightCtrl = TextEditingController(text: '175');
    final phoneCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkBorder : AppColors.gray300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Add New Client', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(
                    'Enter client details to monitor workouts, BMI, and nutrition.',
                    style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Client Full Name *', hintText: 'e.g. Marcus Vance'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Enter client name' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email Address *', hintText: 'client@example.com'),
                    validator: (v) => v == null || !v.contains('@') ? 'Enter valid email' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: goalCtrl,
                    decoration: const InputDecoration(labelText: 'Fitness Goal', hintText: 'e.g. Fat Loss & Hypertrophy'),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: TextFormField(controller: weightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Weight (kg)', hintText: '75'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(controller: heightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Height (cm)', hintText: '175'))),
                  ]),
                  const SizedBox(height: 12),
                  TextFormField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone Number (optional)', hintText: '+1 (555) 000-0000')),
                  const SizedBox(height: 12),
                  TextFormField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Coaching Notes', hintText: 'Injuries, dietary requirements...')),
                  const SizedBox(height: 20),
                  FitFlowButton(
                    text: 'Add Client to Roster',
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;
                      final authProv = context.read<AuthProvider?>();
                      final trainerId = authProv?.user?.id ?? 'trainer_01';
                      final newClient = ClientModel(
                        id: 'cm_${DateTime.now().millisecondsSinceEpoch}',
                        trainerId: trainerId,
                        memberId: 'usr_${DateTime.now().millisecondsSinceEpoch}',
                        memberName: nameCtrl.text.trim(),
                        memberEmail: emailCtrl.text.trim(),
                        memberGoal: goalCtrl.text.trim().isNotEmpty ? goalCtrl.text.trim() : 'General Fitness',
                        assignedPlan: 'Upper/Lower 4-Day Split',
                        status: 'active',
                        clientWeightKg: double.tryParse(weightCtrl.text.trim()) ?? 75.0,
                        clientHeightCm: double.tryParse(heightCtrl.text.trim()) ?? 175.0,
                        phone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : null,
                        notes: notesCtrl.text.trim().isNotEmpty ? notesCtrl.text.trim() : null,
                        progressPercent: 0.1,
                      );
                      trainerProv?.addClient(newClient);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Client ${newClient.memberName} added successfully! 🚀'), behavior: SnackBarBehavior.floating),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCreatePlanDialog(TrainerProvider? trainerProv) {
    final titleCtrl = TextEditingController();
    final categoryCtrl = TextEditingController(text: 'Hypertrophy');
    final daysCtrl = TextEditingController(text: '4');

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(children: [
            Icon(Icons.add_task_rounded, color: AppColors.primaryLime, size: 24),
            SizedBox(width: 10),
            Text('Create Workout Plan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ]),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Plan Name', hintText: 'e.g. 5-Day Power Split')),
              const SizedBox(height: 14),
              TextField(controller: categoryCtrl, decoration: const InputDecoration(labelText: 'Category', hintText: 'e.g. Hypertrophy, Strength, HIIT')),
              const SizedBox(height: 14),
              TextField(controller: daysCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Days Per Week', hintText: 'e.g. 4')),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryLime, foregroundColor: const Color(0xFF0F172A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              onPressed: () {
                final title = titleCtrl.text.trim();
                if (title.isNotEmpty) {
                  final newPlan = WorkoutModel(
                    id: 'plan_${DateTime.now().millisecondsSinceEpoch}',
                    title: title,
                    subtitle: '${categoryCtrl.text.trim()} Program',
                    durationMinutes: 45,
                    category: categoryCtrl.text.trim(),
                    intensity: 'Intermediate',
                    estimatedCalories: 350,
                    isTemplate: true,
                    exercises: [],
                  );
                  trainerProv?.createWorkoutPlan(newPlan);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Plan "$title" created! 📋'), behavior: SnackBarBehavior.floating),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProv = context.watch<AuthProvider?>();
    final trainerProv = context.watch<TrainerProvider?>();
    final user = authProv?.user;
    final trainerName = (user?.name.isNotEmpty == true) ? user!.name : 'Coach';
    final profile = user?.trainerProfile;

    debugPrint('[TrainerHomeTab] build — user: ${user?.name}, role: ${user?.role}, trainerProv: $trainerProv');

    final clients = trainerProv?.clients ?? _defaultClients();
    final activeClients = clients.where((c) => c.status.toLowerCase() == 'active').toList();
    final pendingClients = clients.where((c) => c.status.toLowerCase() == 'pending').toList();
    final plans = trainerProv?.workoutPlans ?? [];

    // Loading state
    if (trainerProv?.isLoading == true && clients.isEmpty) {
      return _buildLoadingState(isDark);
    }

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // ── App Bar ──
          SliverAppBar(
            pinned: true,
            backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
            surfaceTintColor: Colors.transparent,
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
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.sports_gymnastics_rounded, size: 14, color: AppColors.primaryLime),
                  SizedBox(width: 4),
                  Text('TRAINER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.8, color: AppColors.primaryLime)),
                ]),
              ),
              IconButton(
                icon: const Icon(Icons.person_add_rounded, color: AppColors.primaryLime),
                tooltip: 'Add Client',
                onPressed: () => _showAddClientDialog(trainerProv),
              ),
              const SizedBox(width: 4),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Greeting Header ──
                _buildGreetingHeader(trainerName, isDark),
                const SizedBox(height: 18),

                // ── Trainer Profile Summary Card ──
                _buildTrainerProfileCard(trainerName, profile, isDark),
                const SizedBox(height: 20),

                // ── TODAY Section Header ──
                _buildSectionHeader('TODAY'),
                const SizedBox(height: 12),

                // ── 4 KPI Cards ──
                Row(children: [
                  Expanded(child: _buildMetricCard(title: 'Total Clients', value: '${clients.length}', subtext: '+2 this month', icon: Icons.groups_rounded, accentColor: AppColors.primaryLime, isDark: isDark)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMetricCard(title: 'Active', value: '${activeClients.length}', subtext: 'High compliance', icon: Icons.check_circle_outline_rounded, accentColor: AppColors.proteinColor, isDark: isDark)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _buildMetricCard(title: 'Programs', value: '${plans.length}', subtext: 'Active routines', icon: Icons.assignment_outlined, accentColor: AppColors.carbsColor, isDark: isDark)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMetricCard(title: 'Pending', value: '${pendingClients.length}', subtext: 'Needs review', icon: Icons.person_add_alt_rounded, accentColor: Colors.amber, isDark: isDark)),
                ]),
                const SizedBox(height: 24),

                // ── QUICK ACTIONS ──
                _buildSectionHeader('QUICK ACTIONS'),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _buildQuickActionButton(icon: Icons.add_circle_outline_rounded, title: 'Create Program', subtitle: 'New routine', isDark: isDark, onTap: () => _showCreatePlanDialog(trainerProv))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildQuickActionButton(icon: Icons.people_alt_outlined, title: 'Add Client', subtitle: 'Client roster', isDark: isDark, onTap: () => _showAddClientDialog(trainerProv))),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _buildQuickActionButton(icon: Icons.calendar_today_rounded, title: 'View Schedule', subtitle: 'Session plan', isDark: isDark, onTap: () => widget.onTabChanged(2))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildQuickActionButton(icon: Icons.insights_rounded, title: 'Progress', subtitle: 'Client stats', isDark: isDark, onTap: () => widget.onTabChanged(3))),
                ]),
                const SizedBox(height: 24),

                // ── CLIENTS Section ──
                if (clients.isNotEmpty) ...[
                  _buildSectionHeaderWithAction('CLIENTS', 'See All', () => widget.onTabChanged(1)),
                  const SizedBox(height: 12),
                  _buildRecentClientsSection(activeClients.take(3).toList(), isDark),
                  const SizedBox(height: 24),
                ],

                // ── PENDING REQUESTS ──
                if (pendingClients.isNotEmpty) ...[
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    _buildSectionHeader('PENDING REQUESTS'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.amber.withOpacity(0.18), borderRadius: BorderRadius.circular(10)),
                      child: Text('${pendingClients.length} New', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.amber)),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  _buildPendingRequestsSection(pendingClients, trainerProv, isDark),
                  const SizedBox(height: 24),
                ],

                // ── TODAY'S SESSIONS (Static illustration) ──
                _buildSectionHeader("TODAY'S SESSIONS"),
                const SizedBox(height: 12),
                _buildTodaysSessionsSection(isDark),
                const SizedBox(height: 24),

                // ── RECENT ACTIVITY ──
                _buildSectionHeader('RECENT MEMBER ACTIVITY'),
                const SizedBox(height: 12),
                _buildRecentActivitySection(activeClients, isDark),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primaryLime),
            const SizedBox(height: 16),
            Text(
              'Loading your dashboard...',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingHeader(String trainerName, bool isDark) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, $trainerName! 👋',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage your clients and coaching.',
          style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
        ),
      ],
    );
  }

  Widget _buildTrainerProfileCard(String trainerName, dynamic profile, bool isDark) {
    return FitFlowCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primaryLime.withOpacity(0.2),
            child: Text(
              trainerName.isNotEmpty ? trainerName[0].toUpperCase() : 'T',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primaryLime),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trainerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(
                  profile?.specialization?.isNotEmpty == true ? profile.specialization : 'Certified Fitness Coach',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                ),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                  const SizedBox(width: 2),
                  const Text('4.9', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.primaryLime.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      '${profile?.experienceYears ?? 4}+ Yrs Exp',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primaryLime),
                    ),
                  ),
                ]),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onPressed: () => widget.onTabChanged(4),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.2));
  }

  Widget _buildSectionHeaderWithAction(String title, String actionLabel, VoidCallback onAction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        TextButton(
          onPressed: onAction,
          child: Text(actionLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryLime)),
        ),
      ],
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
          Icon(icon, size: 18, color: accentColor),
        ]),
        const SizedBox(height: 10),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(subtext, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: accentColor)),
      ]),
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
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primaryLime.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: AppColors.primaryLime, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
            Text(subtitle, style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
          ])),
        ]),
      ),
    );
  }

  Widget _buildRecentClientsSection(List<ClientModel> clients, bool isDark) {
    if (clients.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Column(children: [
          Icon(Icons.people_outline_rounded, size: 40, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
          const SizedBox(height: 8),
          const Text('No active clients yet', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 4),
          Text('Add clients to track their progress.', style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
        ]),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        children: clients.asMap().entries.map((entry) {
          final idx = entry.key;
          final client = entry.value;
          final isLast = idx == clients.length - 1;
          return Column(children: [
            _buildClientRow(client, isDark),
            if (!isLast) Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildClientRow(ClientModel client, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.primaryLime.withOpacity(0.18),
          child: Text(
            client.memberName.isNotEmpty ? client.memberName[0].toUpperCase() : 'C',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primaryLime),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(client.memberName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          Text(client.memberGoal, style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: client.progressPercent,
              minHeight: 4,
              backgroundColor: isDark ? AppColors.darkSurfaceElevated : AppColors.gray200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryLime),
            ),
          ),
        ])),
        const SizedBox(width: 8),
        Text(
          '${(client.progressPercent * 100).toInt()}%',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryLime),
        ),
        const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.darkTextMuted),
      ]),
    );
  }

  Widget _buildPendingRequestsSection(List<ClientModel> pendingClients, TrainerProvider? trainerProv, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: pendingClients.length,
        separatorBuilder: (_, _) => Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        itemBuilder: (context, index) {
          final member = pendingClients[index];
          return Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.amber.withOpacity(0.2),
                child: Text(
                  member.memberName.isNotEmpty ? member.memberName[0].toUpperCase() : 'P',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.amber),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(member.memberName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                Text('Goal: ${member.memberGoal}', style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
              ])),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLime,
                  foregroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  trainerProv?.acceptPendingClient(member.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Accepted ${member.memberName} into coaching! 🚀'), behavior: SnackBarBehavior.floating),
                  );
                },
                child: const Text('Accept', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
              ),
            ]),
          );
        },
      ),
    );
  }

  Widget _buildTodaysSessionsSection(bool isDark) {
    final sessions = [
      _SessionData('10:00 AM', 'Upper Body Session', 'Alex Rivera'),
      _SessionData('11:30 AM', 'Strength Training', 'James Wilson'),
      _SessionData('2:00 PM', 'Metabolic HIIT', 'Sarah Connor'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        children: sessions.asMap().entries.map((entry) {
          final idx = entry.key;
          final session = entry.value;
          final isLast = idx == sessions.length - 1;
          return Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLime.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(session.time, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryLime)),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(session.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                  Text(session.client, style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                ])),
                const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.darkTextMuted),
              ]),
            ),
            if (!isLast) Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildRecentActivitySection(List<ClientModel> clients, bool isDark) {
    final activities = [
      _ActivityData('A', 'Alex Rivera', 'Completed Leg Day 4x Hypertrophy', '15m ago', Icons.check_circle_rounded, AppColors.primaryLime),
      _ActivityData('S', 'Sarah Connor', 'Logged nutrition: 2,150 kcal (Hit target)', '1h ago', Icons.restaurant_rounded, AppColors.proteinColor),
      _ActivityData('J', 'James Wilson', 'Recorded body weight: 91.0 kg (BMI 26.6)', '3h ago', Icons.monitor_weight_outlined, AppColors.carbsColor),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        children: activities.asMap().entries.map((entry) {
          final idx = entry.key;
          final activity = entry.value;
          final isLast = idx == activities.length - 1;
          return Column(children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: activity.iconColor.withOpacity(0.15),
                  child: Text(activity.avatarChar, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: activity.iconColor)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(activity.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 1),
                  Text(activity.action, style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                ])),
                Text(activity.time, style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
              ]),
            ),
            if (!isLast) Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ]);
        }).toList(),
      ),
    );
  }

  // Default fallback client data if provider is unavailable
  List<ClientModel> _defaultClients() => [
    ClientModel(id: 'm_01', trainerId: 'trainer_01', memberId: 'usr_alex', memberName: 'Alex Rivera', memberEmail: 'alex.rivera@example.com', memberGoal: 'Build Muscle & Bulk', assignedPlan: 'Upper/Lower 4-Day Split', streakDays: 8, progressPercent: 0.85, status: 'active', clientWeightKg: 82.5, clientHeightCm: 180.0, clientAge: 26, clientGender: 'Male', clientActivityLevel: 'very_active', phone: '+1 (555) 234-5678', notes: 'Targeting 200g protein daily.'),
    ClientModel(id: 'm_02', trainerId: 'trainer_01', memberId: 'usr_sarah', memberName: 'Sarah Connor', memberEmail: 'sarah.c@example.com', memberGoal: 'Fat Loss & Conditioning', assignedPlan: 'Metabolic HIIT & Cardio', streakDays: 12, progressPercent: 0.92, status: 'active', clientWeightKg: 64.0, clientHeightCm: 168.0, clientAge: 29, clientGender: 'Female', clientActivityLevel: 'moderately_active', phone: '+1 (555) 345-6789', notes: 'High compliance. Preparing for 10k run.'),
    ClientModel(id: 'm_03', trainerId: 'trainer_01', memberId: 'usr_james', memberName: 'James Wilson', memberEmail: 'j.wilson@example.com', memberGoal: 'Strength & 1RM Gains', assignedPlan: 'Push / Pull / Legs', streakDays: 4, progressPercent: 0.65, status: 'active', clientWeightKg: 91.0, clientHeightCm: 185.0, clientAge: 32, clientGender: 'Male', clientActivityLevel: 'very_active', phone: '+1 (555) 456-7890', notes: 'Squat 1RM increasing steadily.'),
    ClientModel(id: 'm_04', trainerId: 'trainer_01', memberId: 'usr_maya', memberName: 'Maya Lin', memberEmail: 'maya.lin@example.com', memberGoal: 'General Health & Tone', assignedPlan: 'Full Body 3x Weekly', streakDays: 1, progressPercent: 0.30, status: 'pending', clientWeightKg: 58.5, clientHeightCm: 162.0, clientAge: 24, clientGender: 'Female', clientActivityLevel: 'lightly_active', phone: '+1 (555) 567-8901', notes: 'Requested onboarding call.'),
    ClientModel(id: 'm_05', trainerId: 'trainer_01', memberId: 'usr_david', memberName: 'David Chen', memberEmail: 'd.chen@example.com', memberGoal: 'Hypertrophy & Mobility', assignedPlan: 'Custom Routine', streakDays: 0, progressPercent: 0.10, status: 'pending', clientWeightKg: 76.0, clientHeightCm: 175.0, clientAge: 30, clientGender: 'Male', clientActivityLevel: 'moderately_active', phone: '+1 (555) 678-9012', notes: 'Needs custom nutrition macro target.'),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1 — CLIENTS (was Members)
// ─────────────────────────────────────────────────────────────────────────────

class _TrainerMembersTab extends StatefulWidget {
  final ValueChanged<int> onTabChanged;
  const _TrainerMembersTab({required this.onTabChanged});

  @override
  State<_TrainerMembersTab> createState() => _TrainerMembersTabState();
}

class _TrainerMembersTabState extends State<_TrainerMembersTab> {
  void _confirmDeleteClient(ClientModel client, TrainerProvider? trainerProv) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
          SizedBox(width: 8),
          Text('Delete Client?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        ]),
        content: Text('Remove "${client.memberName}" from your client roster? This cannot be undone.',
            style: TextStyle(fontSize: 14, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              Navigator.pop(ctx);
              trainerProv?.deleteClient(client.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Removed ${client.memberName} from roster.'), behavior: SnackBarBehavior.floating),
              );
            },
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _showClientDetailsModal(ClientModel client, TrainerProvider? trainerProv) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bmiVal = client.clientBmi;
    final bmiCategory = client.clientBmiCategory ?? 'Normal Weight';
    final proteinRec = client.clientProteinRecommendation;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? AppColors.darkBorder : AppColors.gray300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Row(children: [
              CircleAvatar(radius: 26, backgroundColor: AppColors.primaryLime.withOpacity(0.2),
                  child: Text(client.memberName.isNotEmpty ? client.memberName[0].toUpperCase() : 'C',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primaryLime))),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(client.memberName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                Text(client.memberEmail, style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                if (client.phone != null && client.phone!.isNotEmpty)
                  Text(client.phone!, style: const TextStyle(fontSize: 11, color: AppColors.primaryLime)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: client.status.toLowerCase() == 'active' ? AppColors.primaryLime.withOpacity(0.15) : Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(client.status.toUpperCase(),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                        color: client.status.toLowerCase() == 'active' ? AppColors.primaryLime : Colors.amber)),
              ),
            ]),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: isDark ? AppColors.darkSurfaceElevated : AppColors.gray100, borderRadius: BorderRadius.circular(18)),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _metricCell('Weight', '${client.clientWeightKg?.toStringAsFixed(1) ?? '75'} kg', isDark),
                  _metricCell('Height', '${client.clientHeightCm?.toStringAsFixed(0) ?? '175'} cm', isDark),
                  _metricCell('BMI', bmiVal?.toStringAsFixed(1) ?? '24.5', isDark, accent: AppColors.primaryLime),
                  _metricCell('Category', bmiCategory, isDark),
                ]),
                const Divider(height: 20),
                Row(children: [
                  const Icon(Icons.restaurant_rounded, size: 16, color: AppColors.primaryLime),
                  const SizedBox(width: 8),
                  Text('Daily Protein: ${proteinRec?.targetGrams.toInt() ?? 140}g', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  const Spacer(),
                  Text('(${proteinRec?.minGrams.toInt() ?? 120}-${proteinRec?.maxGrams.toInt() ?? 160}g)',
                      style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
                ]),
              ]),
            ),
            if (client.notes != null && client.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Coaching Notes', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
              const SizedBox(height: 4),
              Text(client.notes!, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
            ],
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: FitFlowButton(text: 'Change Plan', icon: Icons.assignment_outlined, isOutlined: true, height: 44, onPressed: () => Navigator.pop(ctx))),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                onPressed: () { Navigator.pop(ctx); _confirmDeleteClient(client, trainerProv); },
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _metricCell(String label, String value, bool isDark, {Color? accent}) {
    return Column(children: [
      Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: accent ?? (isDark ? Colors.white : Colors.black87))),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trainerProv = context.watch<TrainerProvider?>();
    final clients = trainerProv?.clients ?? [];

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('My Clients', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryLime, foregroundColor: const Color(0xFF0F172A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                  label: const Text('Add Client', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          // List
          Expanded(
            child: clients.isEmpty
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.groups_rounded, size: 48, color: AppColors.primaryLime),
                    const SizedBox(height: 12),
                    const Text('No clients added yet', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 6),
                    const Text('Add your first athlete to start tracking.', style: TextStyle(fontSize: 12)),
                  ]))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: clients.length,
                    itemBuilder: (context, index) {
                      final member = clients[index];
                      final isPending = member.status.toLowerCase() == 'pending';
                      final statusColor = isPending ? Colors.amber : AppColors.primaryLime;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            GestureDetector(
                              onTap: () => _showClientDetailsModal(member, trainerProv),
                              child: CircleAvatar(
                                radius: 22,
                                backgroundColor: AppColors.primaryLime.withOpacity(0.18),
                                child: Text(member.memberName.isNotEmpty ? member.memberName[0].toUpperCase() : 'M',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primaryLime)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: GestureDetector(
                              onTap: () => _showClientDetailsModal(member, trainerProv),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(member.memberName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                                const SizedBox(height: 2),
                                Text(member.memberGoal, style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                              ]),
                            )),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                              child: Text(member.status.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: statusColor)),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                              onPressed: () => _confirmDeleteClient(member, trainerProv),
                            ),
                          ]),
                          const SizedBox(height: 12),
                          Row(children: [
                            Expanded(child: FitFlowButton(text: 'Details', icon: Icons.insights_rounded, isOutlined: true, height: 38, onPressed: () => _showClientDetailsModal(member, trainerProv))),
                          ]),
                        ]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 2 — PROGRAMS (was Plans)
// ─────────────────────────────────────────────────────────────────────────────

class _TrainerPlansTab extends StatefulWidget {
  final ValueChanged<int> onTabChanged;
  const _TrainerPlansTab({required this.onTabChanged});

  @override
  State<_TrainerPlansTab> createState() => _TrainerPlansTabState();
}

class _TrainerPlansTabState extends State<_TrainerPlansTab> {
  void _showCreatePlanDialog(TrainerProvider? trainerProv) {
    final titleCtrl = TextEditingController();
    final categoryCtrl = TextEditingController(text: 'Hypertrophy');
    final daysCtrl = TextEditingController(text: '4');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(children: [
          Icon(Icons.add_task_rounded, color: AppColors.primaryLime, size: 24),
          SizedBox(width: 10),
          Text('Create Workout Plan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        ]),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Plan Name', hintText: 'e.g. 5-Day Power Split')),
          const SizedBox(height: 14),
          TextField(controller: categoryCtrl, decoration: const InputDecoration(labelText: 'Category', hintText: 'e.g. Hypertrophy, Strength, HIIT')),
          const SizedBox(height: 14),
          TextField(controller: daysCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Days Per Week', hintText: 'e.g. 4')),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryLime, foregroundColor: const Color(0xFF0F172A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            onPressed: () {
              final title = titleCtrl.text.trim();
              if (title.isNotEmpty) {
                trainerProv?.createWorkoutPlan(WorkoutModel(
                  id: 'plan_${DateTime.now().millisecondsSinceEpoch}',
                  title: title,
                  subtitle: '${categoryCtrl.text.trim()} Program',
                  durationMinutes: 45,
                  category: categoryCtrl.text.trim(),
                  intensity: 'Intermediate',
                  estimatedCalories: 350,
                  isTemplate: true,
                  exercises: [],
                ));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Plan "$title" created! 📋'), behavior: SnackBarBehavior.floating),
                );
              }
            },
            child: const Text('Save Plan', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trainerProv = context.watch<TrainerProvider?>();
    final plans = trainerProv?.workoutPlans ?? [];

    return SafeArea(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Programs', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryLime, foregroundColor: const Color(0xFF0F172A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('New Plan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
              onPressed: () => _showCreatePlanDialog(trainerProv),
            ),
          ]),
        ),
        Expanded(
          child: plans.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.assignment_outlined, size: 48, color: AppColors.primaryLime),
                  const SizedBox(height: 12),
                  const Text('No programs yet', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryLime, foregroundColor: const Color(0xFF0F172A)),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Create Plan'),
                    onPressed: () => _showCreatePlanDialog(trainerProv),
                  ),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: plans.length,
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.primaryLime.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
                          child: const Icon(Icons.fitness_center_rounded, color: AppColors.primaryLime, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(plan.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text('${plan.category} • ${plan.durationMinutes} min', style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                          const SizedBox(height: 4),
                          Text(plan.intensity, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryLime)),
                        ])),
                        IconButton(
                          icon: const Icon(Icons.more_vert_rounded),
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Options for "${plan.title}"'), behavior: SnackBarBehavior.floating)),
                        ),
                      ]),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 3 — PROGRESS
// ─────────────────────────────────────────────────────────────────────────────

class _TrainerProgressTab extends StatelessWidget {
  final ValueChanged<int> onTabChanged;
  const _TrainerProgressTab({required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trainerProv = context.watch<TrainerProvider?>();
    final clients = trainerProv?.clients ?? [];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Client Progress', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),

          FitFlowCard(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Member Weekly Compliance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('Overall group completed 91% of scheduled sets this week.',
                  style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
              const SizedBox(height: 16),
              ClipRRect(borderRadius: BorderRadius.circular(8), child: const LinearProgressIndicator(value: 0.91, minHeight: 10, backgroundColor: AppColors.gray200, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLime))),
              const SizedBox(height: 12),
              const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Target: 85%', style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
                Text('Current: 91% 🎯', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryLime)),
              ]),
            ]),
          ),
          const SizedBox(height: 20),

          Row(children: [
            Expanded(child: _metricCard('Volume Lifted', '184k kg', 'Team aggregate', Icons.fitness_center_rounded, AppColors.primaryLime, isDark)),
            const SizedBox(width: 12),
            Expanded(child: _metricCard('Workouts Logged', '94', 'This week', Icons.fact_check_rounded, AppColors.carbsColor, isDark)),
          ]),
          const SizedBox(height: 24),

          const Text('TOP CLIENT STREAKS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: clients.isEmpty
                ? const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No clients yet.', style: TextStyle(fontWeight: FontWeight.w600))))
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: clients.take(5).length,
                    separatorBuilder: (_, _) => Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    itemBuilder: (context, idx) {
                      final m = clients[idx];
                      return ListTile(
                        leading: CircleAvatar(backgroundColor: AppColors.primaryLime.withOpacity(0.18),
                            child: Text(m.memberName.isNotEmpty ? m.memberName[0].toUpperCase() : 'M',
                                style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryLime))),
                        title: Text(m.memberName, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(m.assignedPlan, style: const TextStyle(fontSize: 12)),
                        trailing: Text('${m.streakDays} Days 🔥', style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.orangeAccent)),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  Widget _metricCard(String title, String value, String subtext, IconData icon, Color accent, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
          Icon(icon, size: 18, color: accent),
        ]),
        const SizedBox(height: 10),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(subtext, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: accent)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 4 — PROFILE
// ─────────────────────────────────────────────────────────────────────────────

class _TrainerProfileTab extends StatelessWidget {
  final ValueChanged<int> onTabChanged;
  const _TrainerProfileTab({required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProv = context.watch<AuthProvider?>();
    final user = authProv?.user;
    final trainerName = (user?.name.isNotEmpty == true) ? user!.name : 'Coach';
    final profile = user?.trainerProfile;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(children: [
          const Text('Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),

          Center(child: Column(children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.primaryLime.withOpacity(0.2),
              child: Text(trainerName.isNotEmpty ? trainerName[0].toUpperCase() : 'T',
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.primaryLime)),
            ),
            const SizedBox(height: 12),
            Text(trainerName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(user?.email ?? 'trainer@profit.app',
                style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: AppColors.primaryLime.withOpacity(0.18), borderRadius: BorderRadius.circular(12)),
              child: Text(
                profile?.specialization.isNotEmpty == true ? profile!.specialization : 'Strength & Conditioning',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryLime),
              ),
            ),
          ])),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(children: [
              _profileRow('Experience', '${profile?.experienceYears ?? 4} Years Coaching', Icons.military_tech_rounded, isDark),
              Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              _profileRow('Gym / Location', profile?.gymLocation ?? 'PROFIT Elite Center, Downtown', Icons.location_on_rounded, isDark),
              Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              _profileRow('Phone', profile?.phoneNumber ?? '+1 (555) 019-2834', Icons.phone_rounded, isDark),
            ]),
          ),
          const SizedBox(height: 20),

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
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MainNavigation())),
            ),
          ),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.error, fontSize: 14)),
              onTap: () async {
                debugPrint('[TrainerProfile] Sign Out tapped');
                await authProv?.signOut();
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
        ]),
      ),
    );
  }

  Widget _profileRow(String label, String value, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Icon(icon, size: 18, color: AppColors.primaryLime),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class _SessionData {
  final String time, title, client;
  const _SessionData(this.time, this.title, this.client);
}

class _ActivityData {
  final String avatarChar, name, action, time;
  final IconData icon;
  final Color iconColor;
  const _ActivityData(this.avatarChar, this.name, this.action, this.time, this.icon, this.iconColor);
}
