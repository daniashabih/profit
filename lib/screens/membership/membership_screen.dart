import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/animations/animations.dart';
import '../../models/membership_model.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/fit_flow_button.dart';
import '../../widgets/common/profit_logo.dart';

class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  final List<MembershipPlanModel> plans = const [
    MembershipPlanModel(
      id: 'plan_monthly',
      name: 'PROFIT Monthly',
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
      name: 'PROFIT VIP Annual',
      price: '\$99.99',
      period: '/ year',
      billingDescription: 'Save 45% • Equivalent to \$8.33/mo',
      isPopular: true,
      features: [
        'All PROFIT Monthly features',
        '1-on-1 Certified trainer consultation',
        'Customized nutrition & macro roadmaps',
        'All group fitness & HIIT classes',
        'Spa & hydrotherapy recovery access',
      ],
    ),
    MembershipPlanModel(
      id: 'plan_lifetime',
      name: 'PROFIT Black Lifetime',
      price: '\$249.99',
      period: 'one-time',
      billingDescription: 'Pay once, lifetime unlimited VIP access',
      features: [
        'Unlimited access to all PROFIT clubs worldwide',
        'Unlimited AI Coach & nutrition roadmap updates',
        'Dedicated VIP locker & trainer priority',
        'PROFIT performance welcome kit',
      ],
    ),
  ];

  int _selectedPlanIndex = 1; // Default to Annual Best Value

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProv = context.watch<AuthProvider>();
    final user = authProv.user;

    if (authProv.isLoading || user == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          title: const Text(
            'Your Membership',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
        ),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primaryLime)),
      );
    }

    final hasMembership = user.membershipTier != 'free' && user.membershipExpiryDate.isAfter(DateTime.now());
    
    // Fallback/calculated data
    final String tierName = user.membershipTier.toUpperCase();
    final DateTime expiry = user.membershipExpiryDate;
    final int daysRemaining = user.membershipDaysRemaining;
    
    // Calculate progress if it was a 1-year membership approximately
    double progress = 0.0;
    progress = (365.0 - daysRemaining.toDouble()) / 365.0;
    if (progress < 0) progress = 0;
    if (progress > 1) progress = 1;

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
            // CURRENT STATUS CARD
            if (hasMembership) StaggeredEntrance(
              index: 0,
              child: Container(
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const ProFitLogo(
                                size: 16,
                                showText: false,
                                logoColor: Color(0xFF111827),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                tierName,
                                style: const TextStyle(
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
                            '$daysRemaining Days Remaining',
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
                        Text(
                          'Expires: ${expiry.day} ${expiry.month} ${expiry.year}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
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
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: progress),
                        duration: AppAnimationConstants.medium,
                        curve: AppAnimationConstants.curveAthletic,
                        builder: (context, value, _) {
                          return LinearProgressIndicator(
                            value: value,
                            minHeight: 8,
                            backgroundColor: isDark ? const Color(0xFF263309) : AppColors.gray200,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryLime),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 22),

                  // Button: RENEW MEMBERSHIP
                  FitFlowButton(
                    text: 'Renew Membership',
                    height: 50,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Coming soon — payment integration pending'),
                          backgroundColor: Color(0xFF1E293B),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ) else StaggeredEntrance(
            index: 0,
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: const Column(
                children: [
                  Icon(Icons.stars_rounded, size: 48, color: AppColors.primaryLime),
                  SizedBox(height: 12),
                  Text(
                    'No Active Membership',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Upgrade your plan to unlock premium features, personal coaching, and full facility access.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // AVAILABLE PLANS FOR UPGRADE OR EXTENSION
          StaggeredEntrance(
            index: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AVAILABLE PLANS',
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
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Plans list
          ...List.generate(plans.length, (index) {
            final plan = plans[index];
            final isSelected = _selectedPlanIndex == index;

            return StaggeredEntrance(
              index: 2 + index,
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: PressableScale(
                  onTap: () => setState(() => _selectedPlanIndex = index),
                  child: AnimatedContainer(
                    duration: AppAnimationConstants.fast,
                    curve: AppAnimationConstants.curveEaseOut,
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
