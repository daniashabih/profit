class MembershipPlanModel {
  final String id;
  final String name;
  final String price;
  final String period;
  final String billingDescription;
  final bool isPopular;
  final List<String> features;

  const MembershipPlanModel({
    required this.id,
    required this.name,
    required this.price,
    required this.period,
    required this.billingDescription,
    this.isPopular = false,
    required this.features,
  });
}

class UserMembershipModel {
  final String tierName;
  final int daysRemaining;
  final int totalDays;
  final DateTime expiryDate;
  final List<String> activeFeatures;

  UserMembershipModel({
    this.tierName = 'PREMIUM',
    this.daysRemaining = 184,
    this.totalDays = 365,
    DateTime? expiryDate,
    this.activeFeatures = const [
      'Access to workout plans',
      'Nutrition & macro plans',
      'Advanced progress analytics',
      'Dedicated 1-on-1 trainer support',
      'Exclusive video content & guides',
      'AI Fitness Coach unlimited chats',
    ],
  }) : expiryDate = expiryDate ?? DateTime.now().add(const Duration(days: 184));

  double get progressPercentage =>
      totalDays == 0 ? 0.0 : ((totalDays - daysRemaining) / totalDays).clamp(0.0, 1.0);
}
