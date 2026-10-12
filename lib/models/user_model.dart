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
  final bool fitnessSetupCompleted;
  final bool profileCompleted;
  final int trainingDaysPerWeek;
  final int? workoutDuration;
  final double? proteinTarget;
  final String? assignedTrainerId;
  final String? assignedWorkoutPlan;
  final String? assignedDietPlan;

  String get uid => id;
  String get fullName => name;
  String get profileImage => avatarUrl;
  String get goalType => goal;
  String get fitnessGoal => goal;
  double get weightKg => currentWeightKg;
  int get workoutDays => trainingDaysPerWeek;
  bool get isProfileCompleted => profileCompleted || fitnessSetupCompleted;

  /// Computed Body Mass Index (BMI) using standard formula: weight(kg) / height(m)^2
  double get bmi => FitnessCalculators.calculateBmi(currentWeightKg, heightCm);

  /// Human-readable BMI category
  String get bmiCategory => FitnessCalculators.getBmiCategory(bmi);

  /// Full BMI evaluation object including healthy boundary ranges
  BmiResult get bmiResult => FitnessCalculators.evaluateBmi(
        weightKg: currentWeightKg,
        heightCm: heightCm,
      );

  final bool hasEnteredHeight;
  final bool hasEnteredWeight;
  final bool hasEnteredGoal;
  final bool hasEnteredTargetWeight;
  final bool hasEnteredWorkoutPreferences;

  int get completedProfileSteps {
    if (isProfileCompleted) return 8;
    int steps = 0;
    // Step 1: Basic info (Name and valid numeric Age)
    if (name.trim().isNotEmpty && age != null && age! > 0) steps++;
    // Step 2: Gender
    if (gender != null && gender!.trim().isNotEmpty) steps++;
    // Step 3: Height
    if (hasEnteredHeight || (heightCm > 0 && age != null && gender != null)) steps++;
    // Step 4: Current Weight
    if (hasEnteredWeight || (currentWeightKg > 0 && age != null && gender != null)) steps++;
    // Step 5: Fitness Goal
    if (hasEnteredGoal || (goal.trim().isNotEmpty && goal != 'Build Muscle' && goal != 'Build Lean Muscle & Strength' && age != null)) steps++;
    // Step 6: Auto BMI
    if ((hasEnteredHeight && hasEnteredWeight) || (heightCm > 0 && currentWeightKg > 0 && age != null && gender != null)) steps++;
    // Step 7: Target Weight
    if (hasEnteredTargetWeight || (targetWeightKg > 0 && age != null && gender != null && hasEnteredGoal)) steps++;
    // Step 8: Workout Preferences
    if (hasEnteredWorkoutPreferences || (workoutDuration != null)) steps++;
    return steps.clamp(0, 8);
  }

  double get profileCompletionPercentage {
    if (isProfileCompleted) return 1.0;
    return (completedProfileSteps / 8.0).clamp(0.0, 1.0);
  }

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
    this.fitnessSetupCompleted = false,
    this.profileCompleted = false,
    this.trainingDaysPerWeek = 4,
    this.workoutDuration,
    this.proteinTarget,
    this.hasEnteredHeight = false,
    this.hasEnteredWeight = false,
    this.hasEnteredGoal = false,
    this.hasEnteredTargetWeight = false,
    this.hasEnteredWorkoutPreferences = false,
    this.assignedTrainerId,
    this.assignedWorkoutPlan,
    this.assignedDietPlan,
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
    bool? fitnessSetupCompleted,
    bool? profileCompleted,
    int? trainingDaysPerWeek,
    int? workoutDuration,
    double? proteinTarget,
    bool? hasEnteredHeight,
    bool? hasEnteredWeight,
    bool? hasEnteredGoal,
    bool? hasEnteredTargetWeight,
    bool? hasEnteredWorkoutPreferences,
    String? assignedTrainerId,
    String? assignedWorkoutPlan,
    String? assignedDietPlan,
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
      fitnessSetupCompleted:
          fitnessSetupCompleted ?? this.fitnessSetupCompleted,
      profileCompleted:
          profileCompleted ?? this.profileCompleted,
      trainingDaysPerWeek:
          trainingDaysPerWeek ?? this.trainingDaysPerWeek,
      workoutDuration:
          workoutDuration ?? this.workoutDuration,
      proteinTarget:
          proteinTarget ?? this.proteinTarget,
      hasEnteredHeight:
          hasEnteredHeight ?? this.hasEnteredHeight,
      hasEnteredWeight:
          hasEnteredWeight ?? this.hasEnteredWeight,
      hasEnteredGoal:
          hasEnteredGoal ?? this.hasEnteredGoal,
      hasEnteredTargetWeight:
          hasEnteredTargetWeight ?? this.hasEnteredTargetWeight,
      hasEnteredWorkoutPreferences:
          hasEnteredWorkoutPreferences ?? this.hasEnteredWorkoutPreferences,
      assignedTrainerId: assignedTrainerId ?? this.assignedTrainerId,
      assignedWorkoutPlan: assignedWorkoutPlan ?? this.assignedWorkoutPlan,
      assignedDietPlan: assignedDietPlan ?? this.assignedDietPlan,
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
      'goalType': goal,
      'fitnessGoal': goal,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      'activityLevel': activityLevel,
      'currentWeightKg': currentWeightKg,
      'weightKg': currentWeightKg,
      'startWeightKg': startWeightKg,
      'targetWeightKg': targetWeightKg,
      'heightCm': heightCm,
      'bmi': bmi,
      'bmiCategory': bmiCategory,
      'fitnessSetupCompleted': isProfileCompleted,
      'profileCompleted': isProfileCompleted,
      'trainingDaysPerWeek': trainingDaysPerWeek,
      'workoutDays': trainingDaysPerWeek,
      if (workoutDuration != null) 'workoutDuration': workoutDuration,
      if (proteinTarget != null) 'proteinTarget': proteinTarget,
      'streakDays': streakDays,
      'totalWorkouts': totalWorkouts,
      'totalTrainingMinutes': totalTrainingMinutes,
      'totalVolumeKg': totalVolumeKg,
      'totalCaloriesBurned': totalCaloriesBurned,
      'membershipTier': membershipTier,
      'membershipDaysRemaining': membershipDaysRemaining,
      'membershipExpiryDate': membershipExpiryDate.toIso8601String(),
      if (assignedTrainerId != null) 'assignedTrainerId': assignedTrainerId,
      if (assignedWorkoutPlan != null) 'assignedWorkoutPlan': assignedWorkoutPlan,
      if (assignedDietPlan != null) 'assignedDietPlan': assignedDietPlan,
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
    final isCompleted = map['profileCompleted'] == true || map['fitnessSetupCompleted'] == true;
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
      goal: map['fitnessGoal']?.toString() ?? map['goalType']?.toString() ?? map['goal']?.toString() ?? 'Build Muscle',
      age: (map['age'] as num?)?.toInt(),
      gender: map['gender']?.toString(),
      activityLevel: map['activityLevel']?.toString() ?? 'moderately_active',
      currentWeightKg: (map['currentWeightKg'] as num?)?.toDouble() ?? (map['weightKg'] as num?)?.toDouble() ?? 70.0,
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
      fitnessSetupCompleted: isCompleted,
      profileCompleted: isCompleted,
      trainingDaysPerWeek: (map['workoutDays'] as num?)?.toInt() ?? (map['trainingDaysPerWeek'] as num?)?.toInt() ?? 4,
      workoutDuration: (map['workoutDuration'] as num?)?.toInt(),
      proteinTarget: (map['proteinTarget'] as num?)?.toDouble(),
      hasEnteredHeight: isCompleted || (map.containsKey('heightCm') && map['heightCm'] != null),
      hasEnteredWeight: isCompleted || (map.containsKey('currentWeightKg') && map['currentWeightKg'] != null) || (map.containsKey('weightKg') && map['weightKg'] != null),
      hasEnteredGoal: isCompleted || (map.containsKey('fitnessGoal') && map['fitnessGoal'] != null) || (map.containsKey('goal') && map['goal'] != null),
      hasEnteredTargetWeight: isCompleted || (map.containsKey('targetWeightKg') && map['targetWeightKg'] != null),
      hasEnteredWorkoutPreferences: isCompleted || (map.containsKey('workoutDuration') && map['workoutDuration'] != null) || (map.containsKey('workoutDays') && map['workoutDays'] != null),
      assignedTrainerId: map['assignedTrainerId']?.toString(),
      assignedWorkoutPlan: map['assignedWorkoutPlan']?.toString(),
      assignedDietPlan: map['assignedDietPlan']?.toString(),
    );
  }
}
