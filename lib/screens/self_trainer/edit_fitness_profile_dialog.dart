import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/self_trainer_cycle_provider.dart';
import '../../services/bmi_service.dart';
import '../../core/utils/fitness_calculators.dart';

/// Modal dialog allowing the athlete to edit Age, Gender, Height, Weight,
/// Goal, Target Weight, Workout Days, and Workout Duration.
/// Automatically recalculates BMI & category, and offers the option
/// "Update my workout plan" without destroying historical data.
class EditFitnessProfileDialog extends StatefulWidget {
  const EditFitnessProfileDialog({super.key});

  @override
  State<EditFitnessProfileDialog> createState() => _EditFitnessProfileDialogState();
}

class _EditFitnessProfileDialogState extends State<EditFitnessProfileDialog> {
  late int _age;
  late String _gender;
  late double _weightKg;
  late double _heightCm;
  late double _targetWeightKg;
  late String _goal;
  late int _trainingDays;
  late int _workoutDuration;
  bool _updateWorkoutPlan = false;
  bool _isSaving = false;

  final List<String> _goals = [
    'Lose Weight',
    'Build Muscle',
    'Maintain Weight',
    'Improve Fitness',
    'Improve Strength',
  ];

  final List<String> _genders = [
    'Male',
    'Female',
    'Prefer not to say',
  ];

  final List<int> _durations = [30, 45, 60, 90];

  @override
  void initState() {
    super.initState();
    final cycleProv = context.read<SelfTrainerCycleProvider>();
    final authProv = context.read<AuthProvider>();
    final user = authProv.user;

    _age = user?.age ?? cycleProv.fitnessProfile?.age ?? 25;
    _gender = user?.gender ?? cycleProv.fitnessProfile?.gender ?? 'Male';
    _weightKg = cycleProv.currentWeight > 0 ? cycleProv.currentWeight : (user?.currentWeightKg ?? 70.0);
    _heightCm = cycleProv.heightCm > 0 ? cycleProv.heightCm : (user?.heightCm ?? 175.0);
    _targetWeightKg = cycleProv.targetWeight > 0 ? cycleProv.targetWeight : (user?.targetWeightKg ?? 65.0);
    _goal = cycleProv.goalType.isNotEmpty ? cycleProv.goalType : (user?.goal ?? 'Lose Weight');
    if (!_goals.contains(_goal)) {
      _goals.add(_goal);
    }
    _trainingDays = cycleProv.fitnessProfile?.trainingDaysPerWeek ?? user?.trainingDaysPerWeek ?? 4;
    _workoutDuration = user?.workoutDuration ?? cycleProv.fitnessProfile?.workoutDuration ?? 45;
  }

  Future<void> _handleSave() async {
    final cycleProv = context.read<SelfTrainerCycleProvider>();
    final authProv = context.read<AuthProvider>();
    final user = authProv.user;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      final proteinRec = FitnessCalculators.calculateDailyProteinRecommendation(
        weightKg: _weightKg,
        fitnessGoal: _goal,
      );

      // 1. Update weight (logs to progressRecords & BMI history without destroying history)
      await cycleProv.updateWeight(_weightKg);

      // 2. Update user profile in Firestore
      final updatedUser = user.copyWith(
        age: _age,
        gender: _gender,
        heightCm: _heightCm,
        currentWeightKg: _weightKg,
        targetWeightKg: _targetWeightKg,
        goal: _goal,
        trainingDaysPerWeek: _trainingDays,
        workoutDuration: _workoutDuration,
        proteinTarget: proteinRec.targetGrams,
      );
      await authProv.saveUserProfile(updatedUser);

      // 3. If user opted to update workout plan
      if (_updateWorkoutPlan) {
        await cycleProv.regenerateCurrentPlan(
          newGoal: _goal,
          newDaysPerWeek: _trainingDays,
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fitness profile updated successfully.'),
          backgroundColor: AppColors.primaryLime,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final liveBmi = BmiService.calculateBmi(_weightKg, _heightCm);
    final liveCategory = BmiService.getBmiCategory(liveBmi);

    return Dialog(
      backgroundColor: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Fitness Profile',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Live Recalculated BMI Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primaryLime.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primaryLime.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Recalculated BMI', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    Text(
                      '${liveBmi.toStringAsFixed(1)} ($liveCategory)',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.primaryLime),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Age & Gender Row
              Row(
                children: [
                  Expanded(
                    child: _buildNumberStepper(
                      label: 'Age',
                      value: '$_age',
                      onMinus: () {
                        if (_age > 14) setState(() => _age--);
                      },
                      onPlus: () {
                        if (_age < 95) setState(() => _age++);
                      },
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Gender Selector
              Text('Gender', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? Colors.white70 : Colors.black87)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _gender,
                    isExpanded: true,
                    dropdownColor: isDark ? AppColors.darkCardBackground : Colors.white,
                    items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _gender = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Height Stepper
              _buildNumberStepper(
                label: 'Height',
                value: '${_heightCm.toStringAsFixed(1)} cm',
                onMinus: () {
                  if (_heightCm > 100) {
                    setState(() => _heightCm = double.parse((_heightCm - 1.0).toStringAsFixed(1)));
                  }
                },
                onPlus: () {
                  if (_heightCm < 240) {
                    setState(() => _heightCm = double.parse((_heightCm + 1.0).toStringAsFixed(1)));
                  }
                },
                isDark: isDark,
              ),
              const SizedBox(height: 14),

              // Weight Stepper
              _buildNumberStepper(
                label: 'Current Weight',
                value: '${_weightKg.toStringAsFixed(1)} kg',
                onMinus: () {
                  if (_weightKg > 35) {
                    setState(() => _weightKg = double.parse((_weightKg - 0.5).toStringAsFixed(1)));
                  }
                },
                onPlus: () {
                  if (_weightKg < 250) {
                    setState(() => _weightKg = double.parse((_weightKg + 0.5).toStringAsFixed(1)));
                  }
                },
                isDark: isDark,
              ),
              const SizedBox(height: 14),

              // Target Weight Stepper
              _buildNumberStepper(
                label: 'Target Weight',
                value: '${_targetWeightKg.toStringAsFixed(1)} kg',
                onMinus: () {
                  if (_targetWeightKg > 35) {
                    setState(() => _targetWeightKg = double.parse((_targetWeightKg - 0.5).toStringAsFixed(1)));
                  }
                },
                onPlus: () {
                  if (_targetWeightKg < 200) {
                    setState(() => _targetWeightKg = double.parse((_targetWeightKg + 0.5).toStringAsFixed(1)));
                  }
                },
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              // Primary Goal Dropdown
              Text('Primary Goal', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? Colors.white70 : Colors.black87)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _goal,
                    isExpanded: true,
                    dropdownColor: isDark ? AppColors.darkCardBackground : Colors.white,
                    items: _goals.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _goal = val;
                          _updateWorkoutPlan = true;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Training Frequency
              Text('Workout Days / Week', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? Colors.white70 : Colors.black87)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [2, 3, 4, 5, 6].map((days) {
                  final selected = _trainingDays == days;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _trainingDays = days;
                      _updateWorkoutPlan = true;
                    }),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primaryLime : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? AppColors.primaryLime : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$days',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: selected ? Colors.black : (isDark ? Colors.white : Colors.black),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Workout Duration
              Text('Workout Duration', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? Colors.white70 : Colors.black87)),
              const SizedBox(height: 8),
              Row(
                children: _durations.map((dur) {
                  final isSel = _workoutDuration == dur;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: OutlinedButton(
                        onPressed: () => setState(() => _workoutDuration = dur),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: isSel ? AppColors.primaryLime : Colors.transparent,
                          foregroundColor: isSel ? Colors.black : (isDark ? Colors.white : Colors.black),
                          side: BorderSide(
                            color: isSel ? AppColors.primaryLime : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('$dur m', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Update My Workout Plan Option
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _updateWorkoutPlan,
                activeColor: AppColors.primaryLime,
                checkColor: Colors.black,
                title: const Text(
                  'Update my workout plan',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                subtitle: const Text(
                  'Generates a fresh workout plan matching your new goal and days. Past historical workout records are never deleted.',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                onChanged: (val) => setState(() => _updateWorkoutPlan = val ?? false),
              ),
              const SizedBox(height: 20),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLime,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberStepper({
    required String label,
    required String value,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? Colors.white70 : Colors.black87)),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: AppColors.primaryLime, size: 24),
              onPressed: onMinus,
            ),
            SizedBox(
              width: 80,
              child: Center(
                child: Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryLime, size: 24),
              onPressed: onPlus,
            ),
          ],
        ),
      ],
    );
  }
}
