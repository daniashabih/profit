import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/self_trainer_cycle_provider.dart';
import '../../services/bmi_service.dart';

/// Modal dialog allowing the athlete to edit weight, height, goal, target weight,
/// and training frequency. Automatically triggers BMI recalculation and offers
/// the option to regenerate the current plan without destroying historical records.
class EditFitnessProfileDialog extends StatefulWidget {
  const EditFitnessProfileDialog({super.key});

  @override
  State<EditFitnessProfileDialog> createState() => _EditFitnessProfileDialogState();
}

class _EditFitnessProfileDialogState extends State<EditFitnessProfileDialog> {
  late double _weightKg;
  late double _heightCm;
  late double _targetWeightKg;
  late String _goal;
  late int _trainingDays;
  bool _regeneratePlan = false;
  bool _isSaving = false;

  final List<String> _goals = [
    'Lose Weight',
    'Build Muscle',
    'Maintain Weight',
    'Improve Fitness',
  ];

  @override
  void initState() {
    super.initState();
    final prov = context.read<SelfTrainerCycleProvider>();
    _weightKg = prov.currentWeight;
    _heightCm = prov.heightCm;
    _targetWeightKg = prov.targetWeight;
    _goal = prov.goalType;
    _trainingDays = prov.fitnessProfile?.trainingDaysPerWeek ?? 4;
  }

  Future<void> _handleSave() async {
    final cycleProv = context.read<SelfTrainerCycleProvider>();
    setState(() => _isSaving = true);

    try {
      // 1. Update weight (which also updates BMI and creates a new BMI record)
      await cycleProv.updateWeight(_weightKg);

      // 2. If user chose to regenerate plan due to goal/training day change
      if (_regeneratePlan) {
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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
            const SizedBox(height: 16),

            // Live BMI recalculation badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryLime.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recalculated BMI', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  Text(
                    '$liveBmi ($liveCategory)',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.primaryLime),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Weight Control
            _buildNumberStepper(
              label: 'Current Weight',
              value: '${_weightKg.toStringAsFixed(1)} kg',
              onMinus: () => setState(() => _weightKg = double.parse((_weightKg - 0.5).toStringAsFixed(1))),
              onPlus: () => setState(() => _weightKg = double.parse((_weightKg + 0.5).toStringAsFixed(1))),
              isDark: isDark,
            ),
            const SizedBox(height: 14),

            // Target Weight Control
            _buildNumberStepper(
              label: 'Target Weight',
              value: '${_targetWeightKg.toStringAsFixed(1)} kg',
              onMinus: () => setState(() => _targetWeightKg = double.parse((_targetWeightKg - 0.5).toStringAsFixed(1))),
              onPlus: () => setState(() => _targetWeightKg = double.parse((_targetWeightKg + 0.5).toStringAsFixed(1))),
              isDark: isDark,
            ),
            const SizedBox(height: 18),

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
                        _regeneratePlan = true; // Auto-suggest plan regen
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Training Days
            Text('Training Frequency', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? Colors.white70 : Colors.black87)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [2, 3, 4, 5, 6].map((days) {
                final selected = _trainingDays == days;
                return GestureDetector(
                  onTap: () => setState(() {
                    _trainingDays = days;
                    _regeneratePlan = true;
                  }),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primaryLime : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                      borderRadius: BorderRadius.circular(12),
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
            const SizedBox(height: 18),

            // Regenerate Plan Option
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _regeneratePlan,
              activeColor: AppColors.primaryLime,
              checkColor: Colors.black,
              title: const Text(
                'Regenerate Workout & Meal Plan',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              subtitle: const Text(
                'Creates a fresh schedule for this cycle while keeping past history intact.',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              onChanged: (val) => setState(() => _regeneratePlan = val ?? false),
            ),
            const SizedBox(height: 20),

            // Actions
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
              width: 72,
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
