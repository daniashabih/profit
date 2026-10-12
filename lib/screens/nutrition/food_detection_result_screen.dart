import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/enums/meal_type.dart';
import '../../models/food_post_model.dart';
import '../../providers/food_journal_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/fit_flow_button.dart';
import '../../widgets/common/fit_flow_card.dart';
import 'meal_nutrition_detail_screen.dart';

class FoodDetectionResultScreen extends StatefulWidget {
  final String postId;
  final MealType mealType;
  final String mealTitle;
  final String notes;
  final DateTime mealDateTime;
  final Uint8List? imageBytes;
  final String? existingImageUrl;
  final List<DetectedFoodItem> initialFoods;
  final double confidence;
  final bool isManualEntryMode;

  const FoodDetectionResultScreen({
    super.key,
    required this.postId,
    required this.mealType,
    required this.mealTitle,
    required this.notes,
    required this.mealDateTime,
    this.imageBytes,
    this.existingImageUrl,
    required this.initialFoods,
    required this.confidence,
    this.isManualEntryMode = false,
  });

  @override
  State<FoodDetectionResultScreen> createState() => _FoodDetectionResultScreenState();
}

class _FoodDetectionResultScreenState extends State<FoodDetectionResultScreen> {
  late List<DetectedFoodItem> _foods;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _foods = List.from(widget.initialFoods);
  }

  int get _totalCalories => _foods.fold(0, (sum, f) => sum + f.calories);
  double get _totalProtein => double.parse(_foods.fold(0.0, (sum, f) => sum + f.protein).toStringAsFixed(1));
  double get _totalCarbs => double.parse(_foods.fold(0.0, (sum, f) => sum + f.carbs).toStringAsFixed(1));
  double get _totalFat => double.parse(_foods.fold(0.0, (sum, f) => sum + f.fat).toStringAsFixed(1));
  double get _totalFiber => double.parse(_foods.fold(0.0, (sum, f) => sum + f.fiber).toStringAsFixed(1));

  void _editPortion(int index) {
    final item = _foods[index];
    final controller = TextEditingController(text: item.portionGrams.round().toString());

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Edit Portion: ${item.name}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adjusting portion automatically recalculates calories, protein, and macros proportionally.',
                style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Serving Weight (grams)',
                  suffixText: 'g',
                ),
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
                foregroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final grams = double.tryParse(controller.text.trim()) ?? item.portionGrams;
                if (grams > 0) {
                  setState(() {
                    _foods[index] = item.scaleToGrams(grams);
                  });
                }
                Navigator.pop(ctx);
              },
              child: const Text('Update Portion', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        );
      },
    );
  }

  void _editFoodDetails(int index) {
    final item = _foods[index];
    final nameCtrl = TextEditingController(text: item.name);
    final calsCtrl = TextEditingController(text: item.calories.toString());
    final proteinCtrl = TextEditingController(text: item.protein.toStringAsFixed(1));
    final carbsCtrl = TextEditingController(text: item.carbs.toStringAsFixed(1));
    final fatCtrl = TextEditingController(text: item.fat.toStringAsFixed(1));
    final fiberCtrl = TextEditingController(text: item.fiber.toStringAsFixed(1));

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Edit Food Details', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Food Name')),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: TextField(controller: calsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Calories (kcal)'))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: proteinCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Protein (g)'))),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: TextField(controller: carbsCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Carbs (g)'))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: fatCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Fat (g)'))),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(controller: fiberCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Fiber (g)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLime,
                foregroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final updated = item.copyWith(
                  name: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : item.name,
                  calories: int.tryParse(calsCtrl.text.trim()) ?? item.calories,
                  protein: double.tryParse(proteinCtrl.text.trim()) ?? item.protein,
                  carbs: double.tryParse(carbsCtrl.text.trim()) ?? item.carbs,
                  fat: double.tryParse(fatCtrl.text.trim()) ?? item.fat,
                  fiber: double.tryParse(fiberCtrl.text.trim()) ?? item.fiber,
                  isAiDetected: false,
                );
                setState(() => _foods[index] = updated);
                Navigator.pop(ctx);
              },
              child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        );
      },
    );
  }

  void _addNewFoodDialog() {
    final nameCtrl = TextEditingController();
    final portionCtrl = TextEditingController(text: '100 g');
    final calsCtrl = TextEditingController(text: '150');
    final proteinCtrl = TextEditingController(text: '10');
    final carbsCtrl = TextEditingController(text: '15');
    final fatCtrl = TextEditingController(text: '4');
    final fiberCtrl = TextEditingController(text: '2');

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add Food Item', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Food Name', hintText: 'e.g. Boiled Egg, Olive Oil')),
                const SizedBox(height: 10),
                TextField(controller: portionCtrl, decoration: const InputDecoration(labelText: 'Portion Description', hintText: 'e.g. 100 g, 1 tbsp')),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: TextField(controller: calsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Calories'))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: proteinCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Protein (g)'))),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: TextField(controller: carbsCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Carbs (g)'))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: fatCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Fat (g)'))),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(controller: fiberCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Fiber (g)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLime,
                foregroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isNotEmpty) {
                  final newItem = DetectedFoodItem(
                    id: 'item_${DateTime.now().millisecondsSinceEpoch}',
                    name: name,
                    portion: portionCtrl.text.trim().isNotEmpty ? portionCtrl.text.trim() : '1 serving',
                    portionGrams: 100.0,
                    calories: int.tryParse(calsCtrl.text.trim()) ?? 150,
                    protein: double.tryParse(proteinCtrl.text.trim()) ?? 10.0,
                    carbs: double.tryParse(carbsCtrl.text.trim()) ?? 15.0,
                    fat: double.tryParse(fatCtrl.text.trim()) ?? 4.0,
                    fiber: double.tryParse(fiberCtrl.text.trim()) ?? 2.0,
                    isAiDetected: false,
                  );
                  setState(() => _foods.add(newItem));
                }
                Navigator.pop(ctx);
              },
              child: const Text('Add Food', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        );
      },
    );
  }

  void _removeFood(int index) {
    if (_foods.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one food item must remain in this post.')),
      );
      return;
    }
    setState(() => _foods.removeAt(index));
  }

  Future<void> _saveAndConfirmPost() async {
    setState(() => _isSaving = true);
    final journalProv = context.read<FoodJournalProvider>();

    try {
      final savedPost = await journalProv.saveFoodPost(
        postId: widget.postId,
        mealType: widget.mealType,
        title: widget.mealTitle,
        notes: widget.notes,
        mealDate: widget.mealDateTime,
        items: _foods,
        imageBytes: widget.imageBytes,
        existingImageUrl: widget.existingImageUrl,
        userVerified: true,
      );

      if (!mounted) return;
      setState(() => _isSaving = false);

      // Navigate to meal detail dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MealNutritionDetailScreen(post: savedPost),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save post: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          widget.isManualEntryMode ? 'Food Items Entry' : 'Food Detection Confirmation',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryLime),
            tooltip: 'Add Food',
            onPressed: _addNewFoodDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── DISCLAIMER BANNER (MANDATORY REQUIREMENT) ──
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceElevated : AppColors.gray100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryLime.withOpacity(0.35)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: AppColors.primaryLime, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI estimated nutrition',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primaryLime),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Values are estimates and may vary depending on ingredients and portion size. Please verify or correct food items and servings below before saving.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── LIVE TOTALS PREVIEW CARD ──
            FitFlowCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.mealTitle.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLime.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$_totalCalories kcal',
                          style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryLime, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _macroIndicator('Protein', '${_totalProtein}g', AppColors.proteinColor, isDark),
                      _macroIndicator('Carbs', '${_totalCarbs}g', AppColors.carbsColor, isDark),
                      _macroIndicator('Fat', '${_totalFat}g', AppColors.fatColor, isDark),
                      _macroIndicator('Fiber', '${_totalFiber}g', Colors.tealAccent, isDark),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── DETECTED FOOD ITEMS SECTION ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Food Detected & Portions', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                TextButton.icon(
                  onPressed: _addNewFoodDialog,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Food', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // List of detected foods
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _foods.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final item = _foods[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Serving: ${item.portion}${item.cookingMethod != null ? ' • ${item.cookingMethod}' : ''}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${item.calories} kcal',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.primaryLime),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Small macro pills
                      Wrap(
                        spacing: 8,
                        children: [
                          _pill('${item.protein}g Protein', AppColors.proteinColor, isDark),
                          _pill('${item.carbs}g Carbs', AppColors.carbsColor, isDark),
                          _pill('${item.fat}g Fat', AppColors.fatColor, isDark),
                          _pill('${item.fiber}g Fiber', Colors.tealAccent, isDark),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      // Action Buttons: [ Edit Food ] [ Edit Portion ] [ Remove Food ]
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                            icon: const Icon(Icons.scale_rounded, size: 14),
                            label: const Text('Edit Portion', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            onPressed: () => _editPortion(i),
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                            icon: const Icon(Icons.edit_outlined, size: 14),
                            label: const Text('Edit Food', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            onPressed: () => _editFoodDetails(i),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                            tooltip: 'Remove',
                            onPressed: () => _removeFood(i),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // ── SAVE & CONFIRM BUTTON ──
            if (_isSaving)
              const Center(child: CircularProgressIndicator(color: AppColors.primaryLime))
            else
              FitFlowButton(
                text: 'Confirm & View Nutrition',
                icon: Icons.check_circle_outline_rounded,
                height: 52,
                onPressed: _saveAndConfirmPost,
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _macroIndicator(String label, String value, Color color, bool isDark) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _pill(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}
