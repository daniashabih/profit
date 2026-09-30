import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/trainer_member_model.dart';
import '../core/enums/user_role.dart';
import '../core/errors/app_error.dart';

import 'client_service.dart';
import 'workout_service.dart';
import 'meal_service.dart';
import 'progress_service.dart';

/// FirestoreService provides production-ready Cloud Firestore integration for PROFIT,
/// handling user documents, security validations, and collection access.
class FirestoreService {
  final FirebaseFirestore _firestore;
  late final ClientService clients;
  late final WorkoutService workouts;
  late final MealService meals;
  late final ProgressService progress;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    clients = ClientService(firestore: _firestore);
    workouts = WorkoutService(firestore: _firestore);
    meals = MealService(firestore: _firestore);
    progress = ProgressService(firestore: _firestore);
  }

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

  /// Fetches a user profile from Cloud Firestore: users/{uid}
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection(colUsers).doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return UserModel.fromMap(doc.data()!);
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Creates or updates a user document in Cloud Firestore: users/{uid}
  Future<void> createUserProfile(UserModel user) async {
    try {
      final payload = user.toFirestoreMap();
      await _firestore
          .collection(colUsers)
          .doc(user.id)
          .set(payload, SetOptions(merge: true));
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Updates specific profile fields for a user in Cloud Firestore
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      final updateData = Map<String, dynamic>.from(data);
      updateData['updatedAt'] = DateTime.now().toIso8601String();
      await _firestore.collection(colUsers).doc(uid).update(updateData);
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Checks if a user profile document exists in Cloud Firestore
  Future<bool> userExists(String uid) async {
    try {
      final doc = await _firestore.collection(colUsers).doc(uid).get();
      return doc.exists;
    } catch (_) {
      return false;
    }
  }

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
      'fullName': name,
      'name': name,
      'email': email,
      'role': safeRole.firestoreValue, // 'self_trainer' or 'trainer'
      'profileImage': '',
      'avatarUrl': '',
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
