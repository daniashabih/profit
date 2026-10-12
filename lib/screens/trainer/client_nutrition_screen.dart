import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/food_post_model.dart';
import '../../models/trainer_member_model.dart';
import '../../models/user_model.dart';
import '../../services/client_service.dart';
import '../../services/food_post_service.dart';
import '../../services/nutrition_analytics_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/fit_flow_card.dart';
import '../nutrition/meal_nutrition_detail_screen.dart';

class ClientNutritionScreen extends StatefulWidget {
  final ClientModel client;

  const ClientNutritionScreen({super.key, required this.client});

  @override
  State<ClientNutritionScreen> createState() => _ClientNutritionScreenState();
}

class _ClientNutritionScreenState extends State<ClientNutritionScreen> {
  final _foodPostService = FoodPostService();
  final _clientService = ClientService();

  UserModel? _clientProfile;
  List<FoodPost> _clientPosts = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadClientData();
  }

  Future<void> _loadClientData() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _clientService.getClientFullProfile(widget.client.memberId);
      final posts = await _foodPostService.getFoodPostsForDateRange(
        widget.client.memberId,
        DateTime.now().subtract(const Duration(days: 30)),
        DateTime.now(),
      );

      if (mounted) {
        setState(() {
          _clientProfile = profile;
          _clientPosts = posts;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final client = widget.client;

    final dateStr = _selectedDate.toIso8601String().split('T').first;
    final dayPosts = _clientPosts.where((p) {
      return p.mealDate.toIso8601String().split('T').first == dateStr;
    }).toList();

    final daySummary = NutritionAnalyticsService.calculateDailySummary(
      date: _selectedDate,
      postsForDate: dayPosts,
      user: _clientProfile,
    );

    final monthlyReport = NutritionAnalyticsService.calculateMonthlyReport(
      monthId: '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}',
      monthName: DateFormat('MMMM').format(_selectedDate),
      year: _selectedDate.year,
      monthlyPosts: _clientPosts,
      user: _clientProfile,
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('${client.memberName}\'s Nutrition', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryLime))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── CLIENT PROFILE & BODY METRICS CARD ──
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: AppColors.primaryLime.withOpacity(0.2),
                              child: Text(
                                client.memberName.isNotEmpty ? client.memberName[0].toUpperCase() : 'C',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primaryLime),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(client.memberName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Goal: ${client.memberGoal.isNotEmpty ? client.memberGoal : "General Fitness"}',
                                    style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLime.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text('ASSIGNED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryLime)),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _kpi('Current', '${client.clientWeightKg?.toStringAsFixed(1) ?? '75'} kg', isDark),
                            _kpi('Target', '${_clientProfile?.targetWeightKg.toStringAsFixed(1) ?? '70'} kg', isDark),
                            _kpi('BMI', client.clientBmi?.toStringAsFixed(1) ?? '24.2', isDark, accent: AppColors.primaryLime),
                            _kpi('Target Protein', '${client.clientProteinRecommendation?.targetGrams.round() ?? 130}g', isDark, accent: AppColors.proteinColor),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── DATE SELECTOR ──
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded),
                          onPressed: () {
                            setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1)));
                          },
                        ),
                        Text(
                          DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded),
                          onPressed: () {
                            setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1)));
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── DAILY INTAKE SUMMARY ──
                  FitFlowCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('DAILY CLIENT INTAKE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.6)),
                            Text('${daySummary.totalCalories} / ${daySummary.targetCalories} kcal',
                                style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryLime, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _macroCell('Protein', '${daySummary.totalProtein}g', AppColors.proteinColor, isDark),
                            _macroCell('Carbs', '${daySummary.totalCarbs}g', AppColors.carbsColor, isDark),
                            _macroCell('Fat', '${daySummary.totalFat}g', AppColors.fatColor, isDark),
                            _macroCell('Fiber', '${daySummary.totalFiber}g', Colors.tealAccent, isDark),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── FOOD JOURNAL (Breakfast, Lunch, Dinner, Snacks) ──
                  const Text('CLIENT FOOD JOURNAL & TIMELINE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 0.6)),
                  const SizedBox(height: 10),

                  if (dayPosts.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      child: Center(
                        child: Text(
                          'No food logged by client on ${DateFormat('MMM d').format(_selectedDate)}.',
                          style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                        ),
                      ),
                    )
                  else
                    ...dayPosts.map((post) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: isDark ? AppColors.darkSurfaceElevated : AppColors.gray200,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: post.imageUrl.isNotEmpty
                                ? Image.network(post.imageUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Center(child: Text(post.mealType.emoji)))
                                : Center(child: Text(post.mealType.emoji)),
                          ),
                          title: Text(post.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                          subtitle: Text(
                            '${post.mealType.displayName} • ${post.calories} kcal • ${post.protein}g protein',
                            style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => MealNutritionDetailScreen(post: post)),
                            );
                          },
                        ),
                      );
                    }),

                  const SizedBox(height: 20),

                  // ── MONTHLY NUTRITION TRENDS CARD ──
                  FitFlowCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('MONTHLY NUTRITION REPORT', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.6)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _kpi('Protein Adherence', '${monthlyReport.proteinTargetAchievement.round()}%', isDark, accent: AppColors.proteinColor)),
                            Expanded(child: _kpi('Meal Logging', '${monthlyReport.mealLoggingConsistency.round()}%', isDark, accent: AppColors.primaryLime)),
                            Expanded(child: _kpi('Avg Daily Protein', '${monthlyReport.averageProtein.round()}g', isDark)),
                          ],
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

  Widget _kpi(String label, String value, bool isDark, {Color? accent}) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: accent ?? (isDark ? Colors.white : Colors.black87))),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
      ],
    );
  }

  Widget _macroCell(String label, String val, Color color, bool isDark) {
    return Column(
      children: [
        Text(val, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
      ],
    );
  }
}
