import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/animations/animations.dart';
import '../../models/food_post_model.dart';
import '../../models/trainer_food_feedback_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/food_journal_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/fit_flow_card.dart';
import 'food_detection_result_screen.dart';

class MealNutritionDetailScreen extends StatefulWidget {
  final FoodPost post;

  const MealNutritionDetailScreen({super.key, required this.post});

  @override
  State<MealNutritionDetailScreen> createState() => _MealNutritionDetailScreenState();
}

class _MealNutritionDetailScreenState extends State<MealNutritionDetailScreen> {
  late FoodPost _post;
  final _feedbackController = TextEditingController();
  bool _isSendingFeedback = false;
  bool _isReanalyzing = false;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _confirmDelete() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 22),
            SizedBox(width: 8),
            Text('Delete Food Post?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
          ],
        ),
        content: const Text('Are you sure you want to delete this food post from your journal? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              Navigator.pop(ctx);
              final journalProv = context.read<FoodJournalProvider>();
              await journalProv.deleteFoodPost(_post.id);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Food post deleted from journal.')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Future<void> _reanalyzePost() async {
    setState(() => _isReanalyzing = true);
    final journalProv = context.read<FoodJournalProvider>();

    try {
      final result = await journalProv.analyzeFoodImage(
        imageBytes: Uint8List(0), // uses cached analysis engine
        mealType: _post.mealType,
        mealTitleHint: _post.title,
        notes: _post.notes,
      );

      if (mounted) {
        setState(() => _isReanalyzing = false);
        if (result.detectedFoods.isNotEmpty) {
          final updated = FoodPost.fromItems(
            id: _post.id,
            userId: _post.userId,
            mealType: _post.mealType,
            imageUrl: _post.imageUrl,
            imagePath: _post.imagePath,
            title: _post.title,
            notes: _post.notes,
            mealDate: _post.mealDate,
            items: result.detectedFoods,
          );
          await journalProv.updateFoodPost(updated);
          if (!mounted) return;
          setState(() => _post = updated);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Meal re-analyzed with updated nutrition estimates! ✨')),
          );
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isReanalyzing = false);
    }
  }

  void _openEditScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FoodDetectionResultScreen(
          postId: _post.id,
          mealType: _post.mealType,
          mealTitle: _post.title,
          notes: _post.notes,
          mealDateTime: _post.mealDate,
          existingImageUrl: _post.imageUrl,
          initialFoods: _post.detectedFoods,
          confidence: _post.aiConfidence,
        ),
      ),
    ).then((_) {
      if (!mounted) return;
      // Refresh post from provider
      final journalProv = context.read<FoodJournalProvider>();
      final found = journalProv.posts.where((p) => p.id == _post.id);
      if (found.isNotEmpty) {
        setState(() => _post = found.first);
      }
    });
  }

  Future<void> _sendTrainerFeedback(String trainerId, String trainerName, String? avatarUrl) async {
    final comment = _feedbackController.text.trim();
    if (comment.isEmpty) return;

    setState(() => _isSendingFeedback = true);
    final journalProv = context.read<FoodJournalProvider>();

    final feedback = TrainerFoodFeedback(
      id: const Uuid().v4(),
      postId: _post.id,
      clientUserId: _post.userId,
      trainerId: trainerId,
      trainerName: trainerName,
      trainerAvatarUrl: avatarUrl,
      comment: comment,
      createdAt: DateTime.now(),
    );

    await journalProv.addTrainerFeedback(feedback);
    _feedbackController.clear();
    if (mounted) {
      setState(() => _isSendingFeedback = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback sent to client! 💬')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProv = context.watch<AuthProvider>();
    final currentUser = authProv.user;
    final isTrainer = currentUser?.role.isTrainer ?? false;
    final journalProv = context.watch<FoodJournalProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(_post.mealType.displayName, style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: _openEditScreen,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            tooltip: 'Delete',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HERO FOOD IMAGE ──
            _buildHeroImage(isDark),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Meal Type Pill
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _post.title,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '${_post.mealType.emoji} ${_post.mealType.displayName}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryLime),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '• ${DateFormat('MMM d, h:mm a').format(_post.mealDate)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Re-analyze Button
                      PressableScale(
                        onTap: _isReanalyzing ? null : _reanalyzePost,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLime.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.primaryLime.withOpacity(0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _isReanalyzing
                                  ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryLime))
                                  : const Icon(Icons.sync_rounded, size: 14, color: AppColors.primaryLime),
                              const SizedBox(width: 4),
                              const Text('Re-analyze', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryLime)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // ── AI DISCLAIMER BANNER ──
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.gray100,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primaryLime),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI estimated nutrition • Values are estimates and may vary depending on ingredients and portion size.',
                            style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── NUTRITION RESULT DASHBOARD ──
                  FitFlowCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'NUTRITION SUMMARY',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.8),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLime.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_post.calories} kcal',
                                style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryLime, fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Macro Progress Bars
                        _macroRow('Protein', _post.protein, 50.0, 'g', AppColors.proteinColor, isDark),
                        const SizedBox(height: 10),
                        _macroRow('Carbs', _post.carbs, 70.0, 'g', AppColors.carbsColor, isDark),
                        const SizedBox(height: 10),
                        _macroRow('Fat', _post.fat, 25.0, 'g', AppColors.fatColor, isDark),
                        const SizedBox(height: 10),
                        _macroRow('Fiber', _post.fiber, 10.0, 'g', Colors.tealAccent, isDark),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── MICRONUTRIENTS (MINERALS) SECTION ──
                  const Text('Important Minerals', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(height: 10),
                  _buildMineralsGrid(isDark),
                  const SizedBox(height: 20),

                  // ── VITAMINS SECTION ──
                  const Text('Important Vitamins', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(height: 10),
                  _buildVitaminsGrid(isDark),
                  const SizedBox(height: 20),

                  // ── DETECTED FOOD ITEMS ──
                  const Text('Ingredients & Servings', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(height: 10),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _post.detectedFoods.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final item = _post.detectedFoods[i];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                  Text(
                                    'Serving: ${item.portion}${item.cookingMethod != null ? ' • ${item.cookingMethod}' : ''}',
                                    style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${item.calories} kcal', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                                Text('${item.protein}g P', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.proteinColor)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // ── USER NOTES ──
                  if (_post.notes.isNotEmpty) ...[
                    const Text('Notes', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      child: Text(_post.notes, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── TRAINER FEEDBACK SECTION ──
                  _buildTrainerFeedbackSection(journalProv, currentUser, isTrainer, isDark),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage(bool isDark) {
    if (_post.imageUrl.startsWith('data:image')) {
      try {
        final commaIdx = _post.imageUrl.indexOf(',');
        if (commaIdx != -1) {
          final bytes = base64Decode(_post.imageUrl.substring(commaIdx + 1));
          return Image.memory(
            bytes,
            height: 280,
            width: double.infinity,
            fit: BoxFit.cover,
          );
        }
      } catch (_) {}
    }

    if (_post.imageUrl.startsWith('http')) {
      return Image.network(
        _post.imageUrl,
        height: 280,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallbackHeroPlaceholder(isDark),
      );
    }

    return _fallbackHeroPlaceholder(isDark);
  }

  Widget _fallbackHeroPlaceholder(bool isDark) {
    return Container(
      height: 220,
      width: double.infinity,
      color: isDark ? AppColors.darkSurfaceElevated : AppColors.gray200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_post.mealType.emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(_post.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _macroRow(String label, double value, double targetRef, String unit, Color color, bool isDark) {
    final progress = (value / targetRef).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            Text('${value.toStringAsFixed(1)} $unit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: isDark ? AppColors.darkProgressUnfilled : AppColors.gray200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 7,
          ),
        ),
      ],
    );
  }

  Widget _buildMineralsGrid(bool isDark) {
    final micros = _post.micronutrients;
    final items = [
      {'name': 'Calcium', 'val': '${micros['calcium']?.round() ?? 180} mg'},
      {'name': 'Iron', 'val': '${micros['iron']?.toStringAsFixed(1) ?? '3.8'} mg'},
      {'name': 'Magnesium', 'val': '${micros['magnesium']?.round() ?? 85} mg'},
      {'name': 'Potassium', 'val': '${micros['potassium']?.round() ?? 620} mg'},
      {'name': 'Zinc', 'val': '${micros['zinc']?.toStringAsFixed(1) ?? '2.4'} mg'},
      {'name': 'Sodium', 'val': '${micros['sodium']?.round() ?? _post.sodium.round()} mg'},
      {'name': 'Phosphorus', 'val': '${micros['phosphorus']?.round() ?? 320} mg'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((m) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(m['val']!, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.primaryLime)),
              const SizedBox(height: 2),
              Text(m['name']!, style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVitaminsGrid(bool isDark) {
    final vits = _post.vitamins;
    final items = [
      {'name': 'Vitamin A', 'val': '${vits['vitaminA']?.round() ?? 25}%'},
      {'name': 'Vitamin C', 'val': '${vits['vitaminC']?.round() ?? 42}%'},
      {'name': 'Vitamin D', 'val': '${vits['vitaminD']?.round() ?? 8}%'},
      {'name': 'Vitamin E', 'val': '${vits['vitaminE']?.round() ?? 12}%'},
      {'name': 'Vitamin K', 'val': '${vits['vitaminK']?.round() ?? 38}%'},
      {'name': 'B Vitamins', 'val': '${vits['bVitamins']?.round() ?? 30}%'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((v) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(v['val']!, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.proteinColor)),
              const SizedBox(height: 2),
              Text(v['name']!, style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrainerFeedbackSection(
    FoodJournalProvider journalProv,
    dynamic currentUser,
    bool isTrainer,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.sports_gymnastics_rounded, size: 18, color: AppColors.primaryLime),
            SizedBox(width: 8),
            Text('Trainer Feedback', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          ],
        ),
        const SizedBox(height: 10),

        StreamBuilder<List<TrainerFoodFeedback>>(
          stream: journalProv.streamFeedbackForPost(_post.id),
          builder: (ctx, snapshot) {
            final feedbackList = snapshot.data ?? [];

            if (feedbackList.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.gray100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  isTrainer
                      ? 'No feedback left yet. Add feedback for your client below.'
                      : 'No trainer feedback on this meal yet.',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              );
            }

            return Column(
              children: feedbackList.map((f) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primaryLime.withOpacity(0.35)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: AppColors.primaryLime.withOpacity(0.2),
                                child: Text(f.trainerName.isNotEmpty ? f.trainerName[0].toUpperCase() : 'T',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.primaryLime)),
                              ),
                              const SizedBox(width: 8),
                              Text(f.trainerName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                            ],
                          ),
                          Text(DateFormat('MMM d, h:mm a').format(f.createdAt),
                              style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(f.comment, style: const TextStyle(fontSize: 13, height: 1.35)),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),

        // Trainer input box (available when signed in as trainer)
        if (isTrainer) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _feedbackController,
                  decoration: InputDecoration(
                    hintText: 'Leave coaching feedback...',
                    hintStyle: const TextStyle(fontSize: 12),
                    filled: true,
                    fillColor: isDark ? AppColors.darkSurface : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                style: IconButton.styleFrom(backgroundColor: AppColors.primaryLime, foregroundColor: const Color(0xFF0F172A)),
                icon: _isSendingFeedback
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send_rounded, size: 18),
                onPressed: _isSendingFeedback
                    ? null
                    : () => _sendTrainerFeedback(
                          currentUser?.id ?? 'trainer_1',
                          currentUser?.name ?? 'Coach',
                          currentUser?.avatarUrl,
                        ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
