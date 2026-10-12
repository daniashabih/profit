import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/enums/meal_type.dart';
import '../../models/food_post_model.dart';
import '../../providers/food_journal_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/fit_flow_button.dart';
import 'food_detection_result_screen.dart';

class AddFoodPostScreen extends StatefulWidget {
  final MealType? initialMealType;

  const AddFoodPostScreen({super.key, this.initialMealType});

  @override
  State<AddFoodPostScreen> createState() => _AddFoodPostScreenState();
}

class _AddFoodPostScreenState extends State<AddFoodPostScreen> {
  final _picker = ImagePicker();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  MealType _selectedMealType = MealType.lunch;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  Uint8List? _imageBytes;
  bool _isAnalyzing = false;
  String? _analysisError;

  @override
  void initState() {
    super.initState();
    if (widget.initialMealType != null) {
      _selectedMealType = widget.initialMealType!;
    } else {
      // Auto-select meal type based on time of day
      final hour = DateTime.now().hour;
      if (hour >= 5 && hour < 11) {
        _selectedMealType = MealType.breakfast;
      } else if (hour >= 11 && hour < 16) {
        _selectedMealType = MealType.lunch;
      } else if (hour >= 16 && hour < 22) {
        _selectedMealType = MealType.dinner;
      } else {
        _selectedMealType = MealType.snack;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 82,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _analysisError = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _startAiAnalysis() async {
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please take a photo or select an image from gallery.')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysisError = null;
    });

    final journalProv = context.read<FoodJournalProvider>();
    final result = await journalProv.analyzeFoodImage(
      imageBytes: _imageBytes!,
      mealType: _selectedMealType,
      mealTitleHint: _titleController.text.trim().isNotEmpty ? _titleController.text.trim() : null,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
    );

    if (!mounted) return;
    setState(() => _isAnalyzing = false);

    if (result.status == FoodAnalysisStatus.completed || result.status == FoodAnalysisStatus.needs_review) {
      final combinedDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final title = _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : '${_selectedMealType.displayName} Meal';

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FoodDetectionResultScreen(
            postId: const Uuid().v4(),
            mealType: _selectedMealType,
            mealTitle: title,
            notes: _notesController.text.trim(),
            mealDateTime: combinedDateTime,
            imageBytes: _imageBytes,
            initialFoods: result.detectedFoods,
            confidence: result.confidence,
          ),
        ),
      );
    } else {
      setState(() {
        _analysisError = result.errorMessage ?? 'We couldn\'t analyze this meal. You can enter the foods manually.';
      });
    }
  }

  void _openManualEntry() {
    final combinedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final title = _titleController.text.trim().isNotEmpty
        ? _titleController.text.trim()
        : '${_selectedMealType.displayName} Meal';

    // Start with a clean generic customizable food item
    final defaultItem = DetectedFoodItem(
      id: 'manual_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Custom Food Item',
      portion: '1 serving (150 g)',
      portionGrams: 150,
      calories: 250,
      protein: 20.0,
      carbs: 25.0,
      fat: 8.0,
      fiber: 4.0,
      isAiDetected: false,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FoodDetectionResultScreen(
          postId: const Uuid().v4(),
          mealType: _selectedMealType,
          mealTitle: title,
          notes: _notesController.text.trim(),
          mealDateTime: combinedDateTime,
          imageBytes: _imageBytes,
          initialFoods: [defaultItem],
          confidence: 1.0,
          isManualEntryMode: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Add Food Post', style: TextStyle(fontWeight: FontWeight.w800)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── PHOTO SELECTION BOX ──
            Center(
              child: GestureDetector(
                onTap: () => _showPhotoSourceBottomSheet(isDark),
                child: Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.gray100,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: _imageBytes != null ? AppColors.primaryLime : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      width: _imageBytes != null ? 2 : 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _imageBytes != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.memory(_imageBytes!, fit: BoxFit.cover),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.65),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.edit_rounded, size: 14, color: AppColors.primaryLime),
                                    SizedBox(width: 4),
                                    Text('Change Photo', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLime.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt_rounded, size: 38, color: AppColors.primaryLime),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Take Photo or Upload Food Image',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Camera & Gallery supported with auto-compression',
                              style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Quick Camera / Gallery Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                    icon: const Icon(Icons.camera_alt_outlined, color: AppColors.primaryLime, size: 18),
                    label: const Text('Camera', style: TextStyle(fontWeight: FontWeight.w700)),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                    icon: const Icon(Icons.photo_library_outlined, color: AppColors.primaryLime, size: 18),
                    label: const Text('Gallery', style: TextStyle(fontWeight: FontWeight.w700)),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // ── MEAL TYPE SELECTOR ──
            const Text('Meal Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MealType.values.map((type) {
                final isSelected = _selectedMealType == type;
                return ChoiceChip(
                  label: Text('${type.emoji}  ${type.displayName}'),
                  selected: isSelected,
                  selectedColor: AppColors.primaryLime,
                  backgroundColor: isDark ? AppColors.darkSurface : AppColors.gray100,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: isSelected
                        ? const Color(0xFF0F172A)
                        : (isDark ? Colors.white70 : Colors.black87),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? AppColors.primaryLime : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _selectedMealType = type);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ── MEAL TITLE (OPTIONAL) ──
            const Text('Meal Title (Optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'e.g. Chicken Rice Lunch, Protein Shake',
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
              ),
            ),
            const SizedBox(height: 18),

            // ── DATE & TIME PICKER ──
            const Text('Date & Time', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primaryLime),
                          const SizedBox(width: 8),
                          Text(DateFormat('MMM dd, yyyy').format(_selectedDate), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _pickTime,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primaryLime),
                          const SizedBox(width: 8),
                          Text(_selectedTime.format(context), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // ── NOTES (OPTIONAL) ──
            const Text('Notes (Optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'e.g. Post-workout meal, extra olive oil on salad',
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
              ),
            ),
            const SizedBox(height: 24),

            // ── ERROR / FALLBACK STATE ──
            if (_analysisError != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.error.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _analysisError!,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FitFlowButton(
                      text: 'Enter Manually',
                      icon: Icons.edit_note_rounded,
                      height: 42,
                      onPressed: _openManualEntry,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── ANALYZE FOOD ACTION ──
            if (_isAnalyzing) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryLime.withOpacity(0.4)),
                ),
                child: const Column(
                  children: [
                    CircularProgressIndicator(color: AppColors.primaryLime),
                    SizedBox(height: 14),
                    Text(
                      'Analyzing your meal...',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Detecting ingredients, portion sizes & macros',
                      style: TextStyle(fontSize: 12, color: AppColors.darkTextSecondary),
                    ),
                  ],
                ),
              ),
            ] else ...[
              FitFlowButton(
                text: 'Analyze Food',
                icon: Icons.auto_awesome_rounded,
                height: 52,
                onPressed: _startAiAnalysis,
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: _openManualEntry,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Food Manually', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showPhotoSourceBottomSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 18),
            const Text('Upload Food Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0x2276FF03), child: Icon(Icons.camera_alt_rounded, color: AppColors.primaryLime)),
              title: const Text('Take Photo with Camera', style: TextStyle(fontWeight: FontWeight.w700)),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0x2276FF03), child: Icon(Icons.photo_library_rounded, color: AppColors.primaryLime)),
              title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w700)),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
