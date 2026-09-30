import '../models/user_model.dart';
import '../models/trainer_member_model.dart';
import '../core/enums/user_role.dart';

/// FirestoreService defines standard Firestore schemas, collection endpoints,
/// and document structures for Cloud Firestore integration.
class FirestoreService {
  static const String colUsers = 'users';
  static const String colWorkouts = 'workouts';
  static const String colExercises = 'exercises';
  static const String colNutritionLogs = 'nutrition_logs';
  static const String colMeasurements = 'measurements';
  static const String colTrainers = 'trainers';
  static const String colTrainerMembers = 'trainer_members';
  static const String colMemberships = 'memberships';
  static const String colAchievements = 'achievements';
  static const String colNotifications = 'notifications';

  /// Standard path for a user document: users/{uid}
  static String userDocPath(String uid) => '$colUsers/$uid';

  /// Standard path for trainer-member document: trainer_members/{docId}
  static String trainerMemberDocPath(String docId) => '$colTrainerMembers/$docId';

  /// Creates a Firestore-compliant user document payload adhering to role requirements.
  /// Protects against unauthorized role escalation on the client side.
  static Map<String, dynamic> createUserDocumentPayload({
    required String uid,
    required String name,
    required String email,
    required UserRole role,
    TrainerProfile? trainerProfile,
    String? phoneNumber,
    String? gymLocation,
    int? age,
    String? gender,
    String? activityLevel,
    double? currentWeightKg,
    double? heightCm,
    String? goal,
  }) {
    // Client-side guard: Prevent unauthorized self-assignment of admin role
    final safeRole = role == UserRole.admin ? UserRole.self : role;

    final payload = <String, dynamic>{
      'uid': uid,
      'id': uid,
      'name': name,
      'email': email,
      'role': safeRole.name, // 'self' or 'trainer'
      'trainerStatus': safeRole == UserRole.trainer ? 'approved' : null,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    if (trainerProfile != null) {
      payload['trainerProfile'] = trainerProfile.toMap();
    }
    if (phoneNumber != null) {
      payload['phoneNumber'] = phoneNumber;
    }
    if (gymLocation != null) {
      payload['gymLocation'] = gymLocation;
    }
    if (age != null) {
      payload['age'] = age;
    }
    if (gender != null) {
      payload['gender'] = gender;
    }
    if (activityLevel != null) {
      payload['activityLevel'] = activityLevel;
    }
    if (currentWeightKg != null) {
      payload['currentWeightKg'] = currentWeightKg;
    }
    if (heightCm != null) {
      payload['heightCm'] = heightCm;
    }
    if (goal != null) {
      payload['goal'] = goal;
    }

    return payload;
  }

  /// Creates a payload for trainer_members collection
  static Map<String, dynamic> createTrainerMemberPayload(TrainerMemberModel relationship) {
    return relationship.toMap();
  }
}
