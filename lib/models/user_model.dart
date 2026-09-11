import '../core/enums/user_role.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final UserRole role;
  final String fitnessLevel;
  final String goal;
  final double currentWeightKg;
  final double startWeightKg;
  final double targetWeightKg;
  final double heightCm;
  final int streakDays;
  final int totalWorkouts;
  final int totalTrainingMinutes;
  final double totalVolumeKg;
  final int totalCaloriesBurned;
  final String membershipTier;
  final int membershipDaysRemaining;
  final DateTime membershipExpiryDate;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl = '',
    this.role = UserRole.member,
    this.fitnessLevel = 'Intermediate',
    this.goal = 'Build Lean Muscle & Strength',
    this.currentWeightKg = 74.5,
    this.startWeightKg = 81.0,
    this.targetWeightKg = 72.0,
    this.heightCm = 178.0,
    this.streakDays = 5,
    this.totalWorkouts = 28,
    this.totalTrainingMinutes = 1140,
    this.totalVolumeKg = 18450,
    this.totalCaloriesBurned = 9800,
    this.membershipTier = 'PREMIUM',
    this.membershipDaysRemaining = 184,
    DateTime? membershipExpiryDate,
  }) : membershipExpiryDate = membershipExpiryDate ??
            DateTime.now().add(const Duration(days: 184));

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    UserRole? role,
    String? fitnessLevel,
    String? goal,
    double? currentWeightKg,
    double? startWeightKg,
    double? targetWeightKg,
    double? heightCm,
    int? streakDays,
    int? totalWorkouts,
    int? totalTrainingMinutes,
    double? totalVolumeKg,
    int? totalCaloriesBurned,
    String? membershipTier,
    int? membershipDaysRemaining,
    DateTime? membershipExpiryDate,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      goal: goal ?? this.goal,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      startWeightKg: startWeightKg ?? this.startWeightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      heightCm: heightCm ?? this.heightCm,
      streakDays: streakDays ?? this.streakDays,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      totalTrainingMinutes:
          totalTrainingMinutes ?? this.totalTrainingMinutes,
      totalVolumeKg: totalVolumeKg ?? this.totalVolumeKg,
      totalCaloriesBurned: totalCaloriesBurned ?? this.totalCaloriesBurned,
      membershipTier: membershipTier ?? this.membershipTier,
      membershipDaysRemaining:
          membershipDaysRemaining ?? this.membershipDaysRemaining,
      membershipExpiryDate:
          membershipExpiryDate ?? this.membershipExpiryDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'role': role.name,
      'fitnessLevel': fitnessLevel,
      'goal': goal,
      'currentWeightKg': currentWeightKg,
      'startWeightKg': startWeightKg,
      'targetWeightKg': targetWeightKg,
      'heightCm': heightCm,
      'streakDays': streakDays,
      'totalWorkouts': totalWorkouts,
      'totalTrainingMinutes': totalTrainingMinutes,
      'totalVolumeKg': totalVolumeKg,
      'totalCaloriesBurned': totalCaloriesBurned,
      'membershipTier': membershipTier,
      'membershipDaysRemaining': membershipDaysRemaining,
      'membershipExpiryDate': membershipExpiryDate.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == map['role'],
        orElse: () => UserRole.member,
      ),
      fitnessLevel: map['fitnessLevel'] ?? 'Intermediate',
      goal: map['goal'] ?? 'Build Muscle',
      currentWeightKg: (map['currentWeightKg'] as num?)?.toDouble() ?? 70.0,
      startWeightKg: (map['startWeightKg'] as num?)?.toDouble() ?? 75.0,
      targetWeightKg: (map['targetWeightKg'] as num?)?.toDouble() ?? 68.0,
      heightCm: (map['heightCm'] as num?)?.toDouble() ?? 175.0,
      streakDays: map['streakDays'] ?? 0,
      totalWorkouts: map['totalWorkouts'] ?? 0,
      totalTrainingMinutes: map['totalTrainingMinutes'] ?? 0,
      totalVolumeKg: (map['totalVolumeKg'] as num?)?.toDouble() ?? 0.0,
      totalCaloriesBurned: map['totalCaloriesBurned'] ?? 0,
      membershipTier: map['membershipTier'] ?? 'FREE',
      membershipDaysRemaining: map['membershipDaysRemaining'] ?? 0,
      membershipExpiryDate: map['membershipExpiryDate'] != null
          ? DateTime.parse(map['membershipExpiryDate'])
          : DateTime.now(),
    );
  }
}
