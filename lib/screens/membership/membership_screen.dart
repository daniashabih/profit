import 'package:flutter/material.dart';
import '../../models/membership_model.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/fit_flow_button.dart';

class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  final UserMembershipModel userMembership = UserMembershipModel(
    tierName: 'PREMIUM',
    expiryDate: DateTime(2026, 9, 23),
    daysRemaining: 184,
    totalDays: 365,
    activeFeatures: [
      'Access to workout plans',
      'Nutrition & macro plans',
      'Advanced progress analytics',
      'Dedicated 1-on-1 trainer support',
      'Exclusive video content & guides',
      'AI Fitness Coach unlimited chats',
    ],
  );

  final List<MembershipPlanModel> plans = const [
    MembershipPlanModel(
      id: 'plan_monthly',
      name: 'ProFit Monthly',
      price: '\$14.99',
      period: '/ month',
      billingDescription: 'Billed monthly, cancel anytime',
      features: [
        'Full gym & fitness floor access',
        'Basic exercise tracker & plans',
        'Calorie & macro tracking',
        'Locker room & shower access',
      ],
    ),
    MembershipPlanModel(
      id: 'plan_annual',
      name: 'ProFit VIP Annual',
      price: '\$99.99',
      period: '/ year',
      billingDescription: 'Save 45% • Equivalent to \$8.33/mo',
      isPopular: true,
      features: [
        'All ProFit Monthly features',
        '1-on-1 Certified trainer consultation',
        'Customized nutrition & macro roadmaps',
        'All group fitness & HIIT classes',
        'Spa & hydrotherapy recovery access',
      ],
    ),
    MembershipPlanModel(
      id: 'plan_lifetime',
      name: 'ProFit Black Lifetime',
      price: '\$249.99',
      period: 'one-time',
      billingDescription: 'Pay once, lifetime unlimited VIP access',
      features: [
        'Unlimited access to all ProFit clubs worldwide',
        'Unlimited AI Coach & nutrition roadmap updates',
        'Dedicated VIP locker & trainer priority',
        'ProFit performance welcome kit',
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
          'Your Membership',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CURRENT PREMIUM STATUS CARD (Exact mockup layout)
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E2614), const Color(0xFF161C10)]
                      : [const Color(0xFFF7FEE7), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLime,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '👑 ',
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              'PREMIUM',
                              style: TextStyle(
                                color: Color(0xFF111827),
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceElevated : AppColors.gray100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${userMembership.daysRemaining} Days Remaining',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Expires: 23 September 2026',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${(userMembership.progressPercentage * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryLime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 22),

                  // Features list with checkmarks
                  const Text(
                    'INCLUDED WITH YOUR PLAN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...userMembership.activeFeatures.map((feat) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 20,
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
                    text: 'Renew Membership',
                    height: 50,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('ProFit Premium Membership renewed! 🌟'),
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

            // AVAILABLE PLANS FOR UPGRADE OR EXTENSION
            const Text(
              'OTHER PLANS',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose or upgrade your plan to unlock more personal coaching and facilities.',
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
