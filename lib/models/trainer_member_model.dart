import '../core/utils/fitness_calculators.dart';

/// Relationship model linking an authorized Trainer to an assigned Client/Member.
/// Prepares the data architecture for 1-to-many Trainer -> Client management,
/// client BMI visibility for the assigned trainer, and client progress monitoring.
class TrainerMemberModel {
  final String id;
  final String trainerId;
  final String memberId;
  final String memberName;
  final String memberEmail;
  final String memberAvatarUrl;
  final String memberGoal;
  final String assignedPlan;
  final String status; // 'active', 'pending', 'inactive'
  final DateTime createdAt;
  final double progressPercent;
  final int streakDays;
  final double? clientWeightKg;
  final double? clientHeightCm;
  final int? clientAge;
  final String? clientGender;
  final String? clientActivityLevel;

  final double? goalWeightKg;
  final String? phone;
  final String? notes;

  /// Alias for memberId for explicit client relationship semantics
  String get clientId => memberId;
  String get userId => memberId;

  /// Authorized trainer access to client BMI
  double? get clientBmi =>
      (clientWeightKg != null && clientHeightCm != null && clientHeightCm! > 0)
          ? FitnessCalculators.calculateBmi(clientWeightKg!, clientHeightCm!)
          : null;

  /// Authorized trainer access to client BMI category
  String? get clientBmiCategory =>
      clientBmi != null ? FitnessCalculators.getBmiCategory(clientBmi!) : null;

  /// Authorized trainer access to client daily protein estimate
  ProteinRecommendation? get clientProteinRecommendation =>
      clientWeightKg != null
          ? FitnessCalculators.calculateDailyProteinRecommendation(
              weightKg: clientWeightKg!,
              fitnessGoal: memberGoal,
              activityLevel: clientActivityLevel,
            )
          : null;

  TrainerMemberModel({
    required this.id,
    required this.trainerId,
    required this.memberId,
    required this.memberName,
    this.memberEmail = '',
    this.memberAvatarUrl = '',
    this.memberGoal = 'Build Lean Muscle',
    this.assignedPlan = 'Upper/Lower 4-Day Split',
    this.status = 'active',
    DateTime? createdAt,
    this.progressPercent = 0.75,
    this.streakDays = 0,
    this.clientWeightKg,
    this.clientHeightCm,
    this.clientAge,
    this.clientGender,
    this.clientActivityLevel,
    this.goalWeightKg,
    this.phone,
    this.notes,
  }) : createdAt = createdAt ?? DateTime.now();

  TrainerMemberModel copyWith({
    String? id,
    String? trainerId,
    String? memberId,
    String? memberName,
    String? memberEmail,
    String? memberAvatarUrl,
    String? memberGoal,
    String? assignedPlan,
    String? status,
    DateTime? createdAt,
    double? progressPercent,
    int? streakDays,
    double? clientWeightKg,
    double? clientHeightCm,
    int? clientAge,
    String? clientGender,
    String? clientActivityLevel,
    double? goalWeightKg,
    String? phone,
    String? notes,
  }) {
    return TrainerMemberModel(
      id: id ?? this.id,
      trainerId: trainerId ?? this.trainerId,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      memberEmail: memberEmail ?? this.memberEmail,
      memberAvatarUrl: memberAvatarUrl ?? this.memberAvatarUrl,
      memberGoal: memberGoal ?? this.memberGoal,
      assignedPlan: assignedPlan ?? this.assignedPlan,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      progressPercent: progressPercent ?? this.progressPercent,
      streakDays: streakDays ?? this.streakDays,
      clientWeightKg: clientWeightKg ?? this.clientWeightKg,
      clientHeightCm: clientHeightCm ?? this.clientHeightCm,
      clientAge: clientAge ?? this.clientAge,
      clientGender: clientGender ?? this.clientGender,
      clientActivityLevel: clientActivityLevel ?? this.clientActivityLevel,
      goalWeightKg: goalWeightKg ?? this.goalWeightKg,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trainerId': trainerId,
      'memberId': memberId,
      'clientId': memberId,
      'memberName': memberName,
      'memberEmail': memberEmail,
      'memberAvatarUrl': memberAvatarUrl,
      'memberGoal': memberGoal,
      'assignedPlan': assignedPlan,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'progressPercent': progressPercent,
      'streakDays': streakDays,
      if (clientWeightKg != null) 'clientWeightKg': clientWeightKg,
      if (clientHeightCm != null) 'clientHeightCm': clientHeightCm,
      if (clientAge != null) 'clientAge': clientAge,
      if (clientGender != null) 'clientGender': clientGender,
      if (clientActivityLevel != null) 'clientActivityLevel': clientActivityLevel,
      if (goalWeightKg != null) 'goalWeightKg': goalWeightKg,
      if (phone != null) 'phone': phone,
      if (notes != null) 'notes': notes,
    };
  }

  /// Cloud Firestore payload strictly adhering to firestore.rules isValidTrainerMember
  Map<String, dynamic> toFirestoreMap() {
    return {
      'id': id,
      'trainerId': trainerId,
      'memberId': memberId,
      'clientId': clientId,
      'memberName': memberName,
      'memberEmail': memberEmail,
      'memberAvatarUrl': memberAvatarUrl,
      'memberGoal': memberGoal,
      'assignedPlan': assignedPlan,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'progressPercent': progressPercent.clamp(0.0, 1.0),
    };
  }

  factory TrainerMemberModel.fromMap(Map<String, dynamic> map) {
    return TrainerMemberModel(
      id: map['id']?.toString() ?? '',
      trainerId: map['trainerId']?.toString() ?? '',
      memberId: map['memberId']?.toString() ?? map['clientId']?.toString() ?? '',
      memberName: map['memberName']?.toString() ?? '',
      memberEmail: map['memberEmail']?.toString() ?? '',
      memberAvatarUrl: map['memberAvatarUrl']?.toString() ?? '',
      memberGoal: map['memberGoal']?.toString() ?? 'General Fitness',
      assignedPlan: map['assignedPlan']?.toString() ?? 'Custom Routine',
      status: map['status']?.toString() ?? 'active',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      progressPercent: (map['progressPercent'] as num?)?.toDouble() ?? 0.0,
      streakDays: (map['streakDays'] as num?)?.toInt() ?? 0,
      clientWeightKg: (map['clientWeightKg'] as num?)?.toDouble(),
      clientHeightCm: (map['clientHeightCm'] as num?)?.toDouble(),
      clientAge: (map['clientAge'] as num?)?.toInt(),
      clientGender: map['clientGender']?.toString(),
      clientActivityLevel: map['clientActivityLevel']?.toString(),
      goalWeightKg: (map['goalWeightKg'] as num?)?.toDouble(),
      phone: map['phone']?.toString(),
      notes: map['notes']?.toString(),
    );
  }
}

/// ClientModel alias for semantic parity with Trainer -> Client requirements
typedef ClientModel = TrainerMemberModel;
