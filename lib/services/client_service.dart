import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trainer_member_model.dart';
import '../models/user_model.dart';
import '../models/measurement_model.dart';
import '../models/nutrition_model.dart';
import '../models/workout_model.dart';
import '../core/errors/app_error.dart';

/// ClientService handles dynamic Cloud Firestore CRUD and streams for the
/// 'trainer_members' collection and authorized trainer access to client metrics.
class ClientService {
  final FirebaseFirestore? _firestore;

  ClientService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? (Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null);

  static const String colTrainerMembers = 'trainer_members';
  static const String colUsers = 'users';
  static const String colMeasurements = 'measurements';
  static const String colNutritionLogs = 'nutrition_logs';
  static const String colWorkouts = 'workouts';

  /// Streams active trainer-member relationships for a specific trainer
  Stream<List<ClientModel>> streamClientsForTrainer(String trainerId) {
    if (_firestore == null) return const Stream.empty();
    return _firestore
        .collection(colTrainerMembers)
        .where('trainerId', isEqualTo: trainerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        if (!data.containsKey('id') || (data['id']?.toString().isEmpty ?? true)) {
          data['id'] = doc.id;
        }
        return ClientModel.fromMap(data);
      }).toList();
    });
  }

  /// Fetches the client roster for a trainer once
  Future<List<ClientModel>> getClientsForTrainer(String trainerId) async {
    if (_firestore == null) return [];
    try {
      final snapshot = await _firestore
          .collection(colTrainerMembers)
          .where('trainerId', isEqualTo: trainerId)
          .get();

      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        if (!data.containsKey('id') || (data['id']?.toString().isEmpty ?? true)) {
          data['id'] = doc.id;
        }
        return ClientModel.fromMap(data);
      }).toList();
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Adds a new client to the trainer's roster
  Future<void> addClient(ClientModel client) async {
    if (_firestore == null) return;
    try {
      final docRef = client.id.isNotEmpty
          ? _firestore.collection(colTrainerMembers).doc(client.id)
          : _firestore.collection(colTrainerMembers).doc('${client.trainerId}_${client.memberId}');

      final payload = client.toFirestoreMap();
      payload['id'] = docRef.id;

      await docRef.set(payload, SetOptions(merge: true));
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Updates an existing client's relationship data (plan, status, progress)
  Future<void> updateClient(ClientModel client) async {
    if (_firestore == null) return;
    try {
      final docId = client.id.isNotEmpty
          ? client.id
          : '${client.trainerId}_${client.memberId}';

      final payload = client.toFirestoreMap();
      payload['updatedAt'] = DateTime.now().toIso8601String();

      await _firestore.collection(colTrainerMembers).doc(docId).update(payload);
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Assigns a workout plan to an athlete
  Future<void> assignPlanToClient(String relationshipId, String planTitle) async {
    if (_firestore == null) return;
    try {
      await _firestore.collection(colTrainerMembers).doc(relationshipId).update({
        'assignedPlan': planTitle,
        'status': 'active',
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Deletes a client relationship from Firestore
  Future<void> deleteClient(String relationshipId) async {
    if (_firestore == null) return;
    try {
      await _firestore.collection(colTrainerMembers).doc(relationshipId).delete();
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Fetches the client's underlying UserModel profile (weight, height, BMI)
  Future<UserModel?> getClientFullProfile(String clientUid) async {
    if (_firestore == null) return null;
    try {
      final doc = await _firestore.collection(colUsers).doc(clientUid).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc.data()!);
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Fetches client's measurement history for trainer progress monitoring
  Future<List<BodyMeasurementModel>> getClientMeasurements(String clientUid) async {
    if (_firestore == null) return [];
    try {
      final snapshot = await _firestore
          .collection(colMeasurements)
          .where('userId', isEqualTo: clientUid)
          .get();

      final list = snapshot.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data());
        if (!data.containsKey('id') || (data['id']?.toString().isEmpty ?? true)) {
          data['id'] = docIdOrDefault(d.id);
        }
        return BodyMeasurementModel.fromMap(data);
      }).toList();

      list.sort((a, b) => a.date.compareTo(b.date));
      return list;
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  static String docIdOrDefault(String id) => id;

  /// Fetches client's today nutrition log for trainer macro monitoring
  Future<DailyNutritionModel?> getClientTodayNutrition(String clientUid) async {
    if (_firestore == null) return null;
    try {
      final todayStr = DateTime.now().toIso8601String().split('T').first;
      final snapshot = await _firestore
          .collection(colNutritionLogs)
          .where('userId', isEqualTo: clientUid)
          .where('date', isEqualTo: todayStr)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      final data = Map<String, dynamic>.from(snapshot.docs.first.data());
      data['id'] = snapshot.docs.first.id;
      return DailyNutritionModel.fromMap(data);
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Fetches client's assigned workouts
  Future<List<WorkoutModel>> getClientWorkouts(String clientUid) async {
    if (_firestore == null) return [];
    try {
      final snapshot = await _firestore
          .collection(colWorkouts)
          .where('userId', isEqualTo: clientUid)
          .get();

      return snapshot.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data());
        data['id'] = d.id;
        return WorkoutModel.fromMap(data);
      }).toList();
    } catch (e) {
      throw AppError.fromException(e);
    }
  }
}
