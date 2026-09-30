import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/fitness_profile_model.dart';
import '../models/user_model.dart';
import 'bmi_service.dart';

/// Service responsible for managing user fitness profiles in Cloud Firestore: fitnessProfiles/{uid}
/// and syncing relevant fields with users/{uid}.
class FitnessProfileService {
  final FirebaseFirestore? _firestore;
  final BmiService _bmiService;

  // Local cache for test or offline execution
  final Map<String, FitnessProfile> _localProfiles = {};

  FitnessProfileService({
    FirebaseFirestore? firestore,
    BmiService? bmiService,
  })  : _firestore = firestore ??
            (Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null),
        _bmiService = bmiService ?? BmiService(firestore: firestore);

  /// Saves the complete personalized fitness profile to Cloud Firestore
  /// and synchronizes core demographic and goal properties to users/{uid}.
  Future<FitnessProfile> saveFitnessProfile(FitnessProfile profile) async {
    _localProfiles[profile.userId] = profile;

    // Log the initial BMI record
    await _bmiService.logBmiRecord(
      userId: profile.userId,
      weightKg: profile.currentWeightKg,
      heightCm: profile.heightCm,
    );

    if (_firestore != null && profile.userId.isNotEmpty) {
      try {
        final batch = _firestore!.batch();

        // 1. Set fitnessProfiles/{uid}
        final profileRef = _firestore!.collection('fitnessProfiles').doc(profile.userId);
        batch.set(profileRef, profile.toMap(), SetOptions(merge: true));

        // 2. Sync to users/{uid}
        final userRef = _firestore!.collection('users').doc(profile.userId);
        final userUpdate = <String, dynamic>{
          'uid': profile.userId,
          'id': profile.userId,
          'fullName': profile.fullName,
          'age': profile.age,
          'gender': profile.gender,
          'heightCm': profile.heightCm,
          'currentWeightKg': profile.currentWeightKg,
          'targetWeightKg': profile.targetWeightKg,
          'goal': profile.goalType,
          'goalType': profile.goalType,
          'bmi': profile.bmi,
          'bmiCategory': profile.bmiCategory,
          'trainingDaysPerWeek': profile.trainingDaysPerWeek,
          'fitnessLevel': profile.fitnessLevel,
          'activityLevel': profile.activityLevel,
          'fitnessSetupCompleted': true,
          'role': 'self_trainer',
          'updatedAt': DateTime.now().toIso8601String(),
        };
        batch.set(userRef, userUpdate, SetOptions(merge: true));

        await batch.commit();
      } catch (e) {
        // Fallback gracefully for local/mock operations
      }
    }

    return profile;
  }

  /// Retrieves a user's fitness profile from Cloud Firestore or local cache
  Future<FitnessProfile?> getFitnessProfile(String userId) async {
    if (userId.isEmpty) return null;

    if (_firestore != null) {
      try {
        final doc = await _firestore!.collection('fitnessProfiles').doc(userId).get();
        if (doc.exists && doc.data() != null) {
          final profile = FitnessProfile.fromMap(doc.data()!, fallbackUserId: userId);
          _localProfiles[userId] = profile;
          return profile;
        }

        // Fallback: check users/{uid}
        final userDoc = await _firestore!.collection('users').doc(userId).get();
        if (userDoc.exists && userDoc.data() != null) {
          final user = UserModel.fromMap(userDoc.data()!);
          if (user.fitnessSetupCompleted) {
            final profile = FitnessProfile(
              userId: user.id,
              fullName: user.name,
              age: user.age ?? 25,
              gender: user.gender ?? 'Other',
              heightCm: user.heightCm,
              currentWeightKg: user.currentWeightKg,
              targetWeightKg: user.targetWeightKg,
              goalType: user.goal,
              bmi: user.bmi,
              bmiCategory: user.bmiCategory,
              trainingDaysPerWeek: user.trainingDaysPerWeek,
              fitnessLevel: user.fitnessLevel,
              activityLevel: user.activityLevel,
              fitnessSetupCompleted: true,
              createdAt: user.createdAt,
              updatedAt: DateTime.now(),
            );
            _localProfiles[userId] = profile;
            return profile;
          }
        }
      } catch (_) {}
    }

    return _localProfiles[userId];
  }

  /// Updates weight and height, recalculates BMI, saves a new BMI record,
  /// and updates both fitnessProfiles/{uid} and users/{uid}.
  Future<FitnessProfile?> updateBodyMetrics({
    required String userId,
    required double newWeightKg,
    double? newHeightCm,
  }) async {
    final existing = await getFitnessProfile(userId);
    if (existing == null) return null;

    final height = newHeightCm ?? existing.heightCm;
    final newBmi = BmiService.calculateBmi(newWeightKg, height);
    final newCategory = BmiService.getBmiCategory(newBmi);

    final updated = existing.copyWith(
      currentWeightKg: newWeightKg,
      heightCm: height,
      bmi: newBmi,
      bmiCategory: newCategory,
      updatedAt: DateTime.now(),
    );

    return saveFitnessProfile(updated);
  }
}
