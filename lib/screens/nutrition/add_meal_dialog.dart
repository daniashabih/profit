import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/enums/meal_type.dart';
import '../../models/nutrition_model.dart';
import '../../providers/nutrition_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/fit_flow_button.dart';
import '../../widgets/common/fit_flow_text_field.dart';

class AddMealDialog extends StatefulWidget {
  final MealType initialMealType;

  const AddMealDialog({super.key, this.initialMealType = MealType.breakfast});

  static void show(BuildContext context, {MealType initialMealType = MealType.breakfast}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddMealDialog(initialMealType: initialMealType),
    );
  }

  @override
  State<AddMealDialog> createState() => _AddMealDialogState();
}

class _AddMealDialogState extends State<AddMealDialog> {
  late MealType _selectedType;
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialMealType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _saveMeal() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final calories = int.tryParse(_caloriesController.text.trim()) ?? 0;
    final protein = double.tryParse(_proteinController.text.trim()) ?? 0.0;
    final carbs = double.tryParse(_carbsController.text.trim()) ?? 0.0;
    final fat = double.tryParse(_fatController.text.trim()) ?? 0.0;

    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $period';

    final mealItem = MealItemModel(
      id: const Uuid().v4(),
      name: name,
      mealType: _selectedType,
      calories: calories,
      proteinGrams: protein,
      carbsGrams: carbs,
      fatGrams: fat,
      time: timeStr,
    );

    context.read<NutritionProvider>().addMeal(mealItem);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $name (${mealItem.calories} kcal)'),
        backgroundColor: const Color(0xFF1E293B),
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
                'Log Food / Meal',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),

              // Meal Type Selector Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: MealType.values.map((type) {
                    final isSelected = _selectedType == type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(type.displayName),
                        selected: isSelected,
                        selectedColor: AppColors.primaryLime,
                        backgroundColor: isDark
                            ? AppColors.darkSurfaceElevated
                            : AppColors.gray100,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: isSelected
                              ? const Color(0xFF111827)
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedType = type);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Meal Name
              FitFlowTextField(
                controller: _nameController,
                labelText: 'Food or Meal Name',
                hintText: 'e.g. Scrambled Eggs & Avocado Toast',
                prefixIcon: Icons.restaurant_rounded,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter meal name';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Calories
              FitFlowTextField(
                controller: _caloriesController,
                labelText: 'Calories (kcal)',
                hintText: 'e.g. 450',
                prefixIcon: Icons.local_fire_department_rounded,
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter calories';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Macros Row
              Row(
                children: [
                  Expanded(
                    child: FitFlowTextField(
                      controller: _proteinController,
                      labelText: 'Protein (g)',
                      hintText: '30',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FitFlowTextField(
                      controller: _carbsController,
                      labelText: 'Carbs (g)',
                      hintText: '45',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FitFlowTextField(
                      controller: _fatController,
                      labelText: 'Fat (g)',
                      hintText: '12',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              FitFlowButton(
                text: 'Save Meal',
                onPressed: _saveMeal,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
