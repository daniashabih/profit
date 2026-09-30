/// Model representing a user's persistent fitness profile in Cloud Firestore: fitnessProfiles/{uid}
class FitnessProfile {
  final String userId;
  final String fullName;
  final int age;
  final String gender;
  final double heightCm;
  final double currentWeightKg;
  final double targetWeightKg;
  final String goalType; // 'Lose Weight', 'Build Muscle', 'Maintain Weight', 'Improve Fitness'
  final double bmi;
  final String bmiCategory;
  final int trainingDaysPerWeek; // 2, 3, 4, 5, 6
  final String fitnessLevel; // 'Beginner', 'Intermediate', 'Advanced'
  final String activityLevel;
  final bool fitnessSetupCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FitnessProfile({
    required this.userId,
    this.fullName = '',
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.currentWeightKg,
    required this.targetWeightKg,
    required this.goalType,
    required this.bmi,
    required this.bmiCategory,
    this.trainingDaysPerWeek = 4,
    this.fitnessLevel = 'Beginner',
    this.activityLevel = 'moderately_active',
    this.fitnessSetupCompleted = true,
    required this.createdAt,
    required this.updatedAt,
  });

  FitnessProfile copyWith({
    String? userId,
    String? fullName,
    int? age,
    String? gender,
    double? heightCm,
    double? currentWeightKg,
    double? targetWeightKg,
    String? goalType,
    double? bmi,
    String? bmiCategory,
    int? trainingDaysPerWeek,
    String? fitnessLevel,
    String? activityLevel,
    bool? fitnessSetupCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FitnessProfile(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      goalType: goalType ?? this.goalType,
      bmi: bmi ?? this.bmi,
      bmiCategory: bmiCategory ?? this.bmiCategory,
      trainingDaysPerWeek: trainingDaysPerWeek ?? this.trainingDaysPerWeek,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      activityLevel: activityLevel ?? this.activityLevel,
      fitnessSetupCompleted: fitnessSetupCompleted ?? this.fitnessSetupCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': userId,
      'userId': userId,
      'fullName': fullName,
      'age': age,
      'gender': gender,
      'heightCm': heightCm,
      'currentWeightKg': currentWeightKg,
      'targetWeightKg': targetWeightKg,
      'goalType': goalType,
      'bmi': bmi,
      'bmiCategory': bmiCategory,
      'trainingDaysPerWeek': trainingDaysPerWeek,
      'fitnessLevel': fitnessLevel,
      'activityLevel': activityLevel,
      'fitnessSetupCompleted': fitnessSetupCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory FitnessProfile.fromMap(Map<String, dynamic> map, {String? fallbackUserId}) {
    return FitnessProfile(
      userId: map['userId']?.toString() ?? map['id']?.toString() ?? fallbackUserId ?? '',
      fullName: map['fullName']?.toString() ?? '',
      age: (map['age'] as num?)?.toInt() ?? 25,
      gender: map['gender']?.toString() ?? 'Other',
      heightCm: (map['heightCm'] as num?)?.toDouble() ?? 170.0,
      currentWeightKg: (map['currentWeightKg'] as num?)?.toDouble() ?? 70.0,
      targetWeightKg: (map['targetWeightKg'] as num?)?.toDouble() ?? 65.0,
      goalType: map['goalType']?.toString() ?? 'Improve Fitness',
      bmi: (map['bmi'] as num?)?.toDouble() ?? 24.2,
      bmiCategory: map['bmiCategory']?.toString() ?? 'Healthy Weight',
      trainingDaysPerWeek: (map['trainingDaysPerWeek'] as num?)?.toInt() ?? 4,
      fitnessLevel: map['fitnessLevel']?.toString() ?? 'Beginner',
      activityLevel: map['activityLevel']?.toString() ?? 'moderately_active',
      fitnessSetupCompleted: map['fitnessSetupCompleted'] == true,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
