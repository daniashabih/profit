import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/measurement_model.dart';
import '../../providers/progress_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/fit_flow_button.dart';
import '../../widgets/common/fit_flow_text_field.dart';

class AddMeasurementDialog extends StatefulWidget {
  const AddMeasurementDialog({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddMeasurementDialog(),
    );
  }

  @override
  State<AddMeasurementDialog> createState() => _AddMeasurementDialogState();
}

class _AddMeasurementDialogState extends State<AddMeasurementDialog> {
  final _weightController = TextEditingController();
  final _waistController = TextEditingController();
  final _chestController = TextEditingController();
  final _armsController = TextEditingController();
  final _thighsController = TextEditingController();
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _weightController.dispose();
    _waistController.dispose();
    _chestController.dispose();
    _armsController.dispose();
    _thighsController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveMeasurement() {
    if (!_formKey.currentState!.validate()) return;

    final weight = double.tryParse(_weightController.text.trim()) ?? 74.5;
    final waist = double.tryParse(_waistController.text.trim()) ?? 83.0;
    final chest = double.tryParse(_chestController.text.trim()) ?? 103.0;
    final arms = double.tryParse(_armsController.text.trim()) ?? 35.5;
    final thighs = double.tryParse(_thighsController.text.trim()) ?? 57.0;

    final measurement = BodyMeasurementModel(
      id: const Uuid().v4(),
      date: DateTime.now(),
      weightKg: weight,
      waistCm: waist,
      chestCm: chest,
      armsCm: arms,
      thighsCm: thighs,
      note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
    );

    context.read<ProgressProvider>().addMeasurement(measurement);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Body measurements logged successfully! 📏'),
        backgroundColor: Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Form(
        key: _formKey,
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
              const SizedBox(height: 18),
              const Text(
                'Record Measurements',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 20),

              // Weight
              FitFlowTextField(
                controller: _weightController,
                labelText: 'Weight (kg)',
                hintText: 'e.g. 74.5',
                prefixIcon: Icons.monitor_weight_outlined,
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter weight';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Waist & Chest
              Row(
                children: [
                  Expanded(
                    child: FitFlowTextField(
                      controller: _waistController,
                      labelText: 'Waist (cm)',
                      hintText: '83.5',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FitFlowTextField(
                      controller: _chestController,
                      labelText: 'Chest (cm)',
                      hintText: '103.5',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Arms & Thighs
              Row(
                children: [
                  Expanded(
                    child: FitFlowTextField(
                      controller: _armsController,
                      labelText: 'Arms (cm)',
                      hintText: '35.5',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FitFlowTextField(
                      controller: _thighsController,
                      labelText: 'Thighs (cm)',
                      hintText: '57.5',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Note
              FitFlowTextField(
                controller: _noteController,
                labelText: 'Note (Optional)',
                hintText: 'e.g. Morning fasted weigh-in',
                prefixIcon: Icons.edit_note_rounded,
              ),
              const SizedBox(height: 24),

              FitFlowButton(
                text: 'Save Measurements',
                onPressed: _saveMeasurement,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
