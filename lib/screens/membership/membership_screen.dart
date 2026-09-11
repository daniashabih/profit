import 'package:flutter/material.dart';
import '../../models/membership_model.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/fit_flow_button.dart';
import '../../core/utils/formatters.dart';

class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  final UserMembershipModel userMembership = UserMembershipModel();

  final List<MembershipPlanModel> plans = const [
    MembershipPlanModel(
      id: 'plan_monthly',
      name: 'FitFlow Pro Monthly',
      price: '\$14.99',
      period: '/ month',
      billingDescription: 'Billed monthly, cancel anytime',
      features: [
        'Full exercise library & customized workouts',
        'Daily calorie & macro tracking',
        'Interactive charts & weight logs',
        'AI Fitness Coach unlimited recommendations',
      ],
    ),
    MembershipPlanModel(
      id: 'plan_annual',
      name: 'FitFlow Elite Annual',
      price: '\$99.99',
      period: '/ year',
      billingDescription: 'Save 45% • Equivalent to \$8.33/mo',
      isPopular: true,
      features: [
        'Everything in Pro Monthly',
        '1-on-1 Dedicated certified trainer access',
        'Tailored diet & hypertrophy programs',
        'VIP early access to new video exercises',
        'Offline workout logging mode',
      ],
    ),
    MembershipPlanModel(
      id: 'plan_lifetime',
      name: 'FitFlow VIP Lifetime',
      price: '\$249.99',
      period: 'one-time',
      billingDescription: 'Pay once, full lifetime VIP membership',
      features: [
        'Lifetime unlimited access forever',
        'All future AI features included',
        'Direct priority WhatsApp/chat trainer line',
        'Custom gym gear starter pack',
      ],
    ),
  ];

  int _selectedPlanIndex = 1; // Default to Annual Best Value

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text(
          'FitFlow Membership',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CURRENT PREMIUM STATUS CARD
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E2614), const Color(0xFF161C10)]
                      : [const Color(0xFFF7FEE7), Colors.white],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.primaryLime.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLime,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'PREMIUM',
                          style: TextStyle(
                            color: Color(0xFF111827),
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      Text(
                        '${userMembership.daysRemaining} days remaining',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Expires on ${Formatters.formatFullDate(userMembership.expiryDate)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: userMembership.progressPercentage,
                      minHeight: 8,
                      backgroundColor: isDark ? const Color(0xFF263309) : AppColors.gray200,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryLime),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Features list with checkmarks
                  ...userMembership.activeFeatures.map((feat) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: AppColors.primaryLime,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              feat,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),

                  // Button: RENEW MEMBERSHIP
                  FitFlowButton(
                    text: 'RENEW MEMBERSHIP',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Membership renewed for 1 full year! 🌟'),
                          backgroundColor: Color(0xFF1E293B),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // AVAILABLE PLANS FOR SUBSCRIPTION INTEGRATION
            const Text(
              'UPGRADE OR EXTEND',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a membership tier to unlock personalized coaching and advanced analytics.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Plans list
            ...List.generate(plans.length, (index) {
              final plan = plans[index];
              final isSelected = _selectedPlanIndex == index;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () => setState(() => _selectedPlanIndex = index),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryLime
                              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                plan.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (plan.isPopular)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLime.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'BEST VALUE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryLime,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                plan.price,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                plan.period,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            plan.billingDescription,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          ...plan.features.map((feat) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.check, size: 16, color: AppColors.primaryLime),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      feat,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
