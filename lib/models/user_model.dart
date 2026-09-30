import '../core/enums/user_role.dart';
import '../core/utils/fitness_calculators.dart';

class TrainerProfile {
  final String bio;
  final String specialization;
  final int experienceYears;
  final List<String> certifications;
  final List<String> availability;
  final List<String> trainingCategories;
  final String? gymLocation;
  final String? phoneNumber;

  const TrainerProfile({
    this.bio = '',
    this.specialization = '',
    this.experienceYears = 0,
    this.certifications = const [],
    this.availability = const [],
    this.trainingCategories = const [],
    this.gymLocation,
    this.phoneNumber,
  });

  TrainerProfile copyWith({
    String? bio,
    String? specialization,
    int? experienceYears,
    List<String>? certifications,
    List<String>? availability,
    List<String>? trainingCategories,
    String? gymLocation,
    String? phoneNumber,
  }) {
    return TrainerProfile(
      bio: bio ?? this.bio,
      specialization: specialization ?? this.specialization,
      experienceYears: experienceYears ?? this.experienceYears,
      certifications: certifications ?? this.certifications,
      availability: availability ?? this.availability,
      trainingCategories: trainingCategories ?? this.trainingCategories,
      gymLocation: gymLocation ?? this.gymLocation,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bio': bio,
      'specialization': specialization,
      'experienceYears': experienceYears,
      'certifications': certifications,
      'availability': availability,
      'trainingCategories': trainingCategories,
      'gymLocation': gymLocation,
      'phoneNumber': phoneNumber,
    };
  }

  factory TrainerProfile.fromMap(Map<String, dynamic> map) {
    return TrainerProfile(
      bio: map['bio']?.toString() ?? '',
      specialization: map['specialization']?.toString() ?? '',
      experienceYears: (map['experienceYears'] as num?)?.toInt() ?? 0,
      certifications: (map['certifications'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      availability: (map['availability'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      trainingCategories: (map['trainingCategories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      gymLocation: map['gymLocation']?.toString(),
      phoneNumber: map['phoneNumber']?.toString(),
    );
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final UserRole role;
  final TrainerProfile? trainerProfile;
  final String? trainerStatus; // "pending", "approved", "rejected"
  final String? phoneNumber;
  final String? gymLocation;
  final DateTime createdAt;
  final String fitnessLevel;
  final String goal;
  final int? age;
  final String? gender;
  final String activityLevel; // sedentary, lightly_active, moderately_active, very_active
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

  String get uid => id;
  String get fullName => name;
  String get profileImage => avatarUrl;

  /// Computed Body Mass Index (BMI) using standard formula: weight(kg) / height(m)^2
  double get bmi => FitnessCalculators.calculateBmi(currentWeightKg, heightCm);

  /// Human-readable BMI category
  String get bmiCategory => FitnessCalculators.getBmiCategory(bmi);

  /// Full BMI evaluation object including healthy boundary ranges
  BmiResult get bmiResult => FitnessCalculators.evaluateBmi(
        weightKg: currentWeightKg,
        heightCm: heightCm,
      );

  /// Evidence-based daily protein recommendation based on body weight, goal, and activity
  ProteinRecommendation get proteinRecommendation =>
      FitnessCalculators.calculateDailyProteinRecommendation(
        weightKg: currentWeightKg,
        fitnessGoal: goal,
        activityLevel: activityLevel,
      );

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl = '',
    this.role = UserRole.self,
    this.trainerProfile,
    this.trainerStatus,
    this.phoneNumber,
    this.gymLocation,
    DateTime? createdAt,
    this.fitnessLevel = 'Intermediate',
    this.goal = 'Build Lean Muscle & Strength',
    this.age,
    this.gender,
    this.activityLevel = 'moderately_active',
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
  })  : createdAt = createdAt ?? DateTime.now(),
        membershipExpiryDate = membershipExpiryDate ??
            DateTime.now().add(const Duration(days: 184));

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    UserRole? role,
    TrainerProfile? trainerProfile,
    String? trainerStatus,
    String? phoneNumber,
    String? gymLocation,
    DateTime? createdAt,
    String? fitnessLevel,
    String? goal,
    int? age,
    String? gender,
    String? activityLevel,
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
      trainerProfile: trainerProfile ?? this.trainerProfile,
      trainerStatus: trainerStatus ?? this.trainerStatus,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gymLocation: gymLocation ?? this.gymLocation,
      createdAt: createdAt ?? this.createdAt,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      goal: goal ?? this.goal,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
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
      'uid': id,
      'name': name,
      'fullName': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'profileImage': avatarUrl,
      'role': role.name, // 'self', 'trainer', or 'admin'
      if (trainerProfile != null) 'trainerProfile': trainerProfile!.toMap(),
      if (trainerStatus != null) 'trainerStatus': trainerStatus,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (gymLocation != null) 'gymLocation': gymLocation,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'fitnessLevel': fitnessLevel,
      'goal': goal,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      'activityLevel': activityLevel,
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

  /// Cloud Firestore payload adhering to 'self_trainer' role specification
  Map<String, dynamic> toFirestoreMap() {
    final map = toMap();
    if (role == UserRole.self) {
      map['role'] = 'self_trainer';
    }
    return map;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['uid']?.toString() ?? map['id']?.toString() ?? '',
      name: map['fullName']?.toString() ?? map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      avatarUrl: map['profileImage']?.toString() ?? map['avatarUrl']?.toString() ?? '',
      // Safe fallback: Missing, empty, or legacy 'member' safely maps to 'self'
      role: UserRole.fromString(map['role']?.toString()),
      trainerProfile: map['trainerProfile'] != null
          ? TrainerProfile.fromMap(
              Map<String, dynamic>.from(map['trainerProfile'] as Map))
          : null,
      trainerStatus: map['trainerStatus']?.toString(),
      phoneNumber: map['phoneNumber']?.toString(),
      gymLocation: map['gymLocation']?.toString(),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      fitnessLevel: map['fitnessLevel']?.toString() ?? 'Intermediate',
      goal: map['goal']?.toString() ?? 'Build Muscle',
      age: (map['age'] as num?)?.toInt(),
      gender: map['gender']?.toString(),
      activityLevel: map['activityLevel']?.toString() ?? 'moderately_active',
      currentWeightKg: (map['currentWeightKg'] as num?)?.toDouble() ?? 70.0,
      startWeightKg: (map['startWeightKg'] as num?)?.toDouble() ?? 75.0,
      targetWeightKg: (map['targetWeightKg'] as num?)?.toDouble() ?? 68.0,
      heightCm: (map['heightCm'] as num?)?.toDouble() ?? 175.0,
      streakDays: (map['streakDays'] as num?)?.toInt() ?? 0,
      totalWorkouts: (map['totalWorkouts'] as num?)?.toInt() ?? 0,
      totalTrainingMinutes:
          (map['totalTrainingMinutes'] as num?)?.toInt() ?? 0,
      totalVolumeKg: (map['totalVolumeKg'] as num?)?.toDouble() ?? 0.0,
      totalCaloriesBurned:
          (map['totalCaloriesBurned'] as num?)?.toInt() ?? 0,
      membershipTier: map['membershipTier']?.toString() ?? 'FREE',
      membershipDaysRemaining:
          (map['membershipDaysRemaining'] as num?)?.toInt() ?? 0,
      membershipExpiryDate: map['membershipExpiryDate'] != null
          ? DateTime.tryParse(map['membershipExpiryDate'].toString()) ??
              DateTime.now()
          : DateTime.now(),
    );
  }
}
