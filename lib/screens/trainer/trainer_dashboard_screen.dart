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

class TrainerDashboardScreen extends StatefulWidget {
  final int initialIndex;

  const TrainerDashboardScreen({super.key, this.initialIndex = 0});

  @override
  State<TrainerDashboardScreen> createState() => _TrainerDashboardScreenState();
}

class _TrainerDashboardScreenState extends State<TrainerDashboardScreen> {
  late int _currentIndex;
  bool _initializedTrainer = false;

  // Local fallback items in case TrainerProvider is not registered in the widget tree (e.g. tests)
  final List<ClientModel> _fallbackClients = [
    ClientModel(
      id: 'm_01',
      trainerId: 'trainer_01',
      memberId: 'usr_alex',
      memberName: 'Alex Rivera',
      memberEmail: 'alex.rivera@example.com',
      memberGoal: 'Build Muscle & Bulk',
      assignedPlan: 'Upper/Lower 4-Day Split',
      streakDays: 8,
      progressPercent: 0.85,
      status: 'active',
      clientWeightKg: 82.5,
      clientHeightCm: 180.0,
      clientAge: 26,
      clientGender: 'Male',
      clientActivityLevel: 'very_active',
      phone: '+1 (555) 234-5678',
      notes: 'Targeting 200g protein daily. Solid bench progression.',
    ),
    ClientModel(
      id: 'm_02',
      trainerId: 'trainer_01',
      memberId: 'usr_sarah',
      memberName: 'Sarah Connor',
      memberEmail: 'sarah.c@example.com',
      memberGoal: 'Fat Loss & Conditioning',
      assignedPlan: 'Metabolic HIIT & Cardio',
      streakDays: 12,
      progressPercent: 0.92,
      status: 'active',
      clientWeightKg: 64.0,
      clientHeightCm: 168.0,
      clientAge: 29,
      clientGender: 'Female',
      clientActivityLevel: 'moderately_active',
      phone: '+1 (555) 345-6789',
      notes: 'High compliance. Preparing for 10k run.',
    ),
    ClientModel(
      id: 'm_03',
      trainerId: 'trainer_01',
      memberId: 'usr_james',
      memberName: 'James Wilson',
      memberEmail: 'j.wilson@example.com',
      memberGoal: 'Strength & 1RM Gains',
      assignedPlan: 'Push / Pull / Legs',
      streakDays: 4,
      progressPercent: 0.65,
      status: 'active',
      clientWeightKg: 91.0,
      clientHeightCm: 185.0,
      clientAge: 32,
      clientGender: 'Male',
      clientActivityLevel: 'very_active',
      phone: '+1 (555) 456-7890',
      notes: 'Squat 1RM increasing steadily. Focus on mobility.',
    ),
    ClientModel(
      id: 'm_04',
      trainerId: 'trainer_01',
      memberId: 'usr_maya',
      memberName: 'Maya Lin',
      memberEmail: 'maya.lin@example.com',
      memberGoal: 'General Health & Tone',
      assignedPlan: 'Full Body 3x Weekly',
      streakDays: 1,
      progressPercent: 0.30,
      status: 'pending',
      clientWeightKg: 58.5,
      clientHeightCm: 162.0,
      clientAge: 24,
      clientGender: 'Female',
      clientActivityLevel: 'lightly_active',
      phone: '+1 (555) 567-8901',
      notes: 'Requested onboarding call.',
    ),
    ClientModel(
      id: 'm_05',
      trainerId: 'trainer_01',
      memberId: 'usr_david',
      memberName: 'David Chen',
      memberEmail: 'd.chen@example.com',
      memberGoal: 'Hypertrophy & Mobility',
      assignedPlan: 'Custom Routine',
      streakDays: 0,
      progressPercent: 0.10,
      status: 'pending',
      clientWeightKg: 76.0,
      clientHeightCm: 175.0,
      clientAge: 30,
      clientGender: 'Male',
      clientActivityLevel: 'moderately_active',
      phone: '+1 (555) 678-9012',
      notes: 'Needs custom nutrition macro target.',
    ),
  ];

  final List<WorkoutModel> _fallbackPlans = [
    WorkoutModel(
      id: 'plan_01',
      title: 'Upper/Lower 4-Day Split',
      subtitle: 'Optimal for hypertrophy and strength',
      durationMinutes: 45,
      category: 'Hypertrophy',
      intensity: 'Intermediate',
      estimatedCalories: 380,
      isTemplate: true,
      exercises: [],
    ),
    WorkoutModel(
      id: 'plan_02',
      title: 'Metabolic HIIT & Fat Burn',
      subtitle: 'High energy conditioning',
      durationMinutes: 30,
      category: 'Cardio & Conditioning',
      intensity: 'All Levels',
      estimatedCalories: 410,
      isTemplate: true,
      exercises: [],
    ),
    WorkoutModel(
      id: 'plan_03',
      title: 'Push / Pull / Legs Strength',
      subtitle: 'Max volume 5-day cycle',
      durationMinutes: 55,
      category: 'Power & Mass',
      intensity: 'Advanced',
      estimatedCalories: 450,
      isTemplate: true,
      exercises: [],
    ),
    WorkoutModel(
      id: 'plan_04',
      title: 'Beginner Full Body Foundation',
      subtitle: 'Core compound movement mechanics',
      durationMinutes: 35,
      category: 'Mobility & Habit',
      intensity: 'Beginner',
      estimatedCalories: 290,
      isTemplate: true,
      exercises: [],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedTrainer) {
      _initializedTrainer = true;
      final authProv = Provider.of<AuthProvider?>(context, listen: false);
      final trainerProv = Provider.of<TrainerProvider?>(context, listen: false);
      if (authProv?.user != null && trainerProv != null) {
        trainerProv.bindTrainer(authProv!.user!.id);
      }
    }
  }

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
  }

  List<ClientModel> _getClients(TrainerProvider? prov) =>
      prov != null ? prov.clients : _fallbackClients;

  List<WorkoutModel> _getPlans(TrainerProvider? prov) =>
      prov != null ? prov.workoutPlans : _fallbackPlans;

  int _getTotalMembers(TrainerProvider? prov) =>
      prov != null ? prov.totalMembers : _fallbackClients.length;

  int _getActiveMembers(TrainerProvider? prov) => prov != null
      ? prov.activeMembers
      : _fallbackClients.where((c) => c.status.toLowerCase() == 'active').length;

  int _getPendingMembers(TrainerProvider? prov) => prov != null
      ? prov.pendingMembers
      : _fallbackClients.where((c) => c.status.toLowerCase() == 'pending').length;

  // -------------------------------------------------------------
  // DESTRUCTIVE ACTION: Delete Client Confirmation Dialog
  // -------------------------------------------------------------
  void _confirmDeleteClient(ClientModel client, TrainerProvider? trainerProv) {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
              SizedBox(width: 8),
              Text('Delete Client?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            ],
          ),
          content: Text(
            'Are you sure you want to remove "${client.memberName}" from your client roster? This action cannot be undone.',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                if (trainerProv != null) {
                  trainerProv.deleteClient(client.id);
                } else {
                  setState(() {
                    _fallbackClients.removeWhere((c) => c.id == client.id);
                  });
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Removed ${client.memberName} from client roster.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        );
      },
    );
  }

  // -------------------------------------------------------------
  // DIALOG: Add Client
  // -------------------------------------------------------------
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
            left: 24,
            right: 24,
            top: 24,
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
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkBorder : AppColors.gray300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Add New Client',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Enter client details to monitor workouts, BMI, and nutrition.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
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
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: weightCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Weight (kg)', hintText: '75'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: heightCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Height (cm)', hintText: '175'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Phone Number (optional)', hintText: '+1 (555) 000-0000'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: notesCtrl,
                    decoration: const InputDecoration(labelText: 'Coaching Notes', hintText: 'Injuries, dietary requirements...'),
                  ),
                  const SizedBox(height: 20),
                  FitFlowButton(
                    text: 'Add Client to Roster',
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;
                      final authProv = Provider.of<AuthProvider?>(context, listen: false);
                      final trainerId = authProv?.user?.id ?? 'trainer_01';
                      final clientWeight = double.tryParse(weightCtrl.text.trim()) ?? 75.0;
                      final clientHeight = double.tryParse(heightCtrl.text.trim()) ?? 175.0;

                      final newClient = ClientModel(
                        id: 'cm_${DateTime.now().millisecondsSinceEpoch}',
                        trainerId: trainerId,
                        memberId: 'usr_${DateTime.now().millisecondsSinceEpoch}',
                        memberName: nameCtrl.text.trim(),
                        memberEmail: emailCtrl.text.trim(),
                        memberGoal: goalCtrl.text.trim().isNotEmpty ? goalCtrl.text.trim() : 'General Fitness',
                        assignedPlan: 'Upper/Lower 4-Day Split',
                        status: 'active',
                        clientWeightKg: clientWeight,
                        clientHeightCm: clientHeight,
                        phone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : null,
                        notes: notesCtrl.text.trim().isNotEmpty ? notesCtrl.text.trim() : null,
                        progressPercent: 0.1,
                      );

                      if (trainerProv != null) {
                        trainerProv.addClient(newClient);
                      } else {
                        setState(() {
                          _fallbackClients.insert(0, newClient);
                        });
                      }

                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Client ${newClient.memberName} added successfully! 🚀'),
                          behavior: SnackBarBehavior.floating,
                        ),
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

  // -------------------------------------------------------------
  // DIALOG: Create Workout Plan
  // -------------------------------------------------------------
  void _showCreatePlanDialog(TrainerProvider? trainerProv) {
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
                final title = titleController.text.trim();
                if (title.isNotEmpty) {
                  final newPlan = WorkoutModel(
                    id: 'plan_${DateTime.now().millisecondsSinceEpoch}',
                    title: title,
                    subtitle: '${categoryController.text.trim()} Program',
                    durationMinutes: 45,
                    category: categoryController.text.trim(),
                    intensity: 'Intermediate',
                    estimatedCalories: 350,
                    isTemplate: true,
                    exercises: [],
                  );

                  if (trainerProv != null) {
                    trainerProv.createWorkoutPlan(newPlan);
                  } else {
                    setState(() {
                      _fallbackPlans.insert(0, newPlan);
                    });
                  }

                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Plan "$title" created successfully! 📋'),
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

  // -------------------------------------------------------------
  // DIALOG: Assign Plan to Client
  // -------------------------------------------------------------
  void _showAssignPlanDialog(ClientModel member, TrainerProvider? trainerProv) {
    final plans = _getPlans(trainerProv);

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
                'Assign Plan to ${member.memberName}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Select a routine tailored for ${member.memberName}\'s goal: ${member.memberGoal}',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ...plans.map((plan) {
                final isCurrent = member.assignedPlan == plan.title;
                return ListTile(
                  dense: true,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  tileColor: isCurrent ? AppColors.primaryLime.withOpacity(0.12) : null,
                  leading: const Icon(Icons.fitness_center_rounded, color: AppColors.primaryLime, size: 20),
                  title: Text(plan.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  subtitle: Text('${plan.category} • ${plan.durationMinutes} min', style: const TextStyle(fontSize: 11)),
                  trailing: isCurrent ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryLime) : null,
                  onTap: () {
                    if (trainerProv != null) {
                      trainerProv.assignPlanToClient(member.id, plan.title);
                    } else {
                      setState(() {
                        final idx = _fallbackClients.indexWhere((c) => c.id == member.id);
                        if (idx != -1) {
                          _fallbackClients[idx] = member.copyWith(assignedPlan: plan.title, status: 'active');
                        }
                      });
                    }
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Assigned "${plan.title}" to ${member.memberName}! 💪'),
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

  // -------------------------------------------------------------
  // MODAL: Client Details (BMI, Protein, Notes, Progress)
  // -------------------------------------------------------------
  void _showClientDetailsModal(ClientModel client, TrainerProvider? trainerProv) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final bmiVal = client.clientBmi;
        final bmiCategory = client.clientBmiCategory ?? 'Normal Weight';
        final proteinRec = client.clientProteinRecommendation;

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
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : AppColors.gray300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primaryLime.withOpacity(0.2),
                    child: Text(
                      client.memberName.isNotEmpty ? client.memberName[0].toUpperCase() : 'C',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primaryLime),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(client.memberName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                        Text(client.memberEmail, style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                        if (client.phone != null && client.phone!.isNotEmpty)
                          Text(client.phone!, style: const TextStyle(fontSize: 11, color: AppColors.primaryLime)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: client.status.toLowerCase() == 'active' ? AppColors.primaryLime.withOpacity(0.15) : Colors.amber.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      client.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: client.status.toLowerCase() == 'active' ? AppColors.primaryLime : Colors.amber,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Health & Metrics Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceElevated : AppColors.gray100,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildClientMetricCell('Weight', '${client.clientWeightKg?.toStringAsFixed(1) ?? '75'} kg', isDark),
                        _buildClientMetricCell('Height', '${client.clientHeightCm?.toStringAsFixed(0) ?? '175'} cm', isDark),
                        _buildClientMetricCell('BMI', bmiVal?.toStringAsFixed(1) ?? '24.5', isDark, accentColor: AppColors.primaryLime),
                        _buildClientMetricCell('Category', bmiCategory, isDark),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.restaurant_rounded, size: 16, color: AppColors.primaryLime),
                        const SizedBox(width: 8),
                        Text(
                          'Daily Protein Target: ${proteinRec?.targetGrams.toInt() ?? 140}g',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                        const Spacer(),
                        Text(
                          '(${proteinRec?.minGrams.toInt() ?? 120}-${proteinRec?.maxGrams.toInt() ?? 160}g)',
                          style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (client.notes != null && client.notes!.isNotEmpty) ...[
                Text('Coaching Notes', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
                const SizedBox(height: 4),
                Text(client.notes!, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
                const SizedBox(height: 16),
              ],

              Row(
                children: [
                  Expanded(
                    child: FitFlowButton(
                      text: 'Change Plan',
                      icon: Icons.assignment_outlined,
                      isOutlined: true,
                      height: 44,
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showAssignPlanDialog(client, trainerProv);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                    tooltip: 'Remove Client',
                    onPressed: () {
                      Navigator.pop(ctx);
                      _confirmDeleteClient(client, trainerProv);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClientMetricCell(String label, String value, bool isDark, {Color? accentColor}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: accentColor ?? (isDark ? Colors.white : Colors.black87),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trainerProv = Provider.of<TrainerProvider?>(context);

    final tabs = [
      _buildHomeTab(isDark, trainerProv),
      _buildMembersTab(isDark, trainerProv),
      _buildPlansTab(isDark, trainerProv),
      _buildProgressTab(isDark, trainerProv),
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
  Widget _buildHomeTab(bool isDark, TrainerProvider? trainerProv) {
    final authProv = Provider.of<AuthProvider?>(context);
    final user = authProv?.user;
    final trainerName = user?.name.isNotEmpty == true ? user!.name : 'Coach';
    final profile = user?.trainerProfile;

    final clients = _getClients(trainerProv);
    final pendingClients = clients.where((c) => c.status.toLowerCase() == 'pending').toList();

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
            icon: const Icon(Icons.person_add_rounded, color: AppColors.primaryLime),
            tooltip: 'Add Client',
            onPressed: () => _showAddClientDialog(trainerProv),
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
                    value: '${_getTotalMembers(trainerProv)}',
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
                    value: '${_getActiveMembers(trainerProv)}',
                    subtext: 'High compliance',
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
                    value: '${_getPlans(trainerProv).length}',
                    subtext: 'Active programs',
                    icon: Icons.assignment_outlined,
                    accentColor: AppColors.carbsColor,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Pending Requests',
                    value: '${_getPendingMembers(trainerProv)}',
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
                    onTap: () => _showCreatePlanDialog(trainerProv),
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

            // PENDING REQUESTS SECTION (if any)
            if (pendingClients.isNotEmpty) ...[
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
                      '${pendingClients.length} New',
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
                  itemCount: pendingClients.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                  itemBuilder: (context, index) {
                    final pendingMember = pendingClients[index];
                    return Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.amber.withOpacity(0.2),
                            child: Text(
                              pendingMember.memberName.isNotEmpty ? pendingMember.memberName[0].toUpperCase() : 'P',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.amber),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pendingMember.memberName,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                                ),
                                Text(
                                  'Goal: ${pendingMember.memberGoal}',
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
                                onPressed: () => _confirmDeleteClient(pendingMember, trainerProv),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryLime,
                                  foregroundColor: const Color(0xFF0F172A),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () {
                                  if (trainerProv != null) {
                                    trainerProv.acceptPendingClient(pendingMember.id);
                                  } else {
                                    setState(() {
                                      final idx = _fallbackClients.indexWhere((c) => c.id == pendingMember.id);
                                      if (idx != -1) {
                                        _fallbackClients[idx] = pendingMember.copyWith(status: 'active');
                                      }
                                    });
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Accepted ${pendingMember.memberName} into coaching! 🚀')),
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
                    action: 'Recorded body weight: 91.0 kg (BMI 26.6)',
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
  Widget _buildMembersTab(bool isDark, TrainerProvider? trainerProv) {
    final clients = _getClients(trainerProv);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('My Members', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primaryLime),
            tooltip: 'Add Client',
            onPressed: () => _showAddClientDialog(trainerProv),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: clients.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.groups_rounded, size: 48, color: AppColors.primaryLime),
                  const SizedBox(height: 12),
                  const Text('No clients added yet', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 6),
                  const Text('Add your first athlete to start tracking progress.', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLime,
                      foregroundColor: const Color(0xFF0F172A),
                    ),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Client'),
                    onPressed: () => _showAddClientDialog(trainerProv),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _showClientDetailsModal(member, trainerProv),
                            child: CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.primaryLime.withOpacity(0.18),
                              child: Text(
                                member.memberName.isNotEmpty ? member.memberName[0].toUpperCase() : 'M',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryLime,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _showClientDetailsModal(member, trainerProv),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(member.memberName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 2),
                                  Text(
                                    member.memberGoal,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              member.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: statusColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                            tooltip: 'Delete Client',
                            onPressed: () => _confirmDeleteClient(member, trainerProv),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // BMI & Protein Badges for Trainer Visibility
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurfaceElevated : AppColors.gray100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.monitor_weight_outlined, size: 12, color: AppColors.primaryLime),
                                const SizedBox(width: 4),
                                Text(
                                  'BMI: ${member.clientBmi?.toStringAsFixed(1) ?? '23.8'}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurfaceElevated : AppColors.gray100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.restaurant_rounded, size: 12, color: AppColors.proteinColor),
                                const SizedBox(width: 4),
                                Text(
                                  'Target: ${member.clientProteinRecommendation?.targetGrams.toInt() ?? 140}g Protein',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                                ),
                              ],
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
                              onPressed: () => _showAssignPlanDialog(member, trainerProv),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FitFlowButton(
                              text: 'Details',
                              icon: Icons.insights_rounded,
                              height: 38,
                              onPressed: () => _showClientDetailsModal(member, trainerProv),
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
  Widget _buildPlansTab(bool isDark, TrainerProvider? trainerProv) {
    final plans = _getPlans(trainerProv);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Workout & Diet Plans', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showCreatePlanDialog(trainerProv),
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
                  onPressed: () => _showCreatePlanDialog(trainerProv),
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 16, color: AppColors.primaryLime),
                  label: const Text(
                    'New Plan',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryLime),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...plans.map((plan) {
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
                            '${plan.category} • ${plan.durationMinutes} min',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            plan.intensity,
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
  Widget _buildProgressTab(bool isDark, TrainerProvider? trainerProv) {
    final clients = _getClients(trainerProv);

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
                itemCount: clients.take(3).length,
                separatorBuilder: (_, _) => Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                itemBuilder: (context, idx) {
                  final m = clients[idx];
                  return ListTile(
                    onTap: () => _showClientDetailsModal(m, trainerProv),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryLime.withOpacity(0.18),
                      child: Text(
                        m.memberName.isNotEmpty ? m.memberName[0].toUpperCase() : 'M',
                        style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryLime),
                      ),
                    ),
                    title: Text(m.memberName, style: const TextStyle(fontWeight: FontWeight.w700)),
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
    final authProv = Provider.of<AuthProvider?>(context);
    final user = authProv?.user;
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
                    '${profile?.experienceYears ?? 4} Years Coaching',
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

            // Switch to Member Mode
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
                  if (authProv != null) {
                    await authProv.signOut();
                  }
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
