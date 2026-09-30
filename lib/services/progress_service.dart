import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/measurement_model.dart';
import '../core/errors/app_error.dart';

/// ProgressService provides dynamic Cloud Firestore CRUD and streams for the
/// 'measurements' collection, strictly adhering to firestore.rules isValidMeasurement.
class ProgressService {
  final FirebaseFirestore _firestore;

  ProgressService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String colMeasurements = 'measurements';
  static const String colUsers = 'users';

  /// Streams measurements for a user, sorted chronologically
  Stream<List<BodyMeasurementModel>> streamMeasurements(String userId) {
    return _firestore
        .collection(colMeasurements)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        if (!data.containsKey('id') || (data['id']?.toString().isEmpty ?? true)) {
          data['id'] = doc.id;
        }
        return BodyMeasurementModel.fromMap(data);
      }).toList();

      list.sort((a, b) => a.date.compareTo(b.date));
      return list;
    });
  }

  /// Fetches historical measurements once
  Future<List<BodyMeasurementModel>> getMeasurements(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(colMeasurements)
          .where('userId', isEqualTo: userId)
          .get();

      final list = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        if (!data.containsKey('id') || (data['id']?.toString().isEmpty ?? true)) {
          data['id'] = doc.id;
        }
        return BodyMeasurementModel.fromMap(data);
      }).toList();

      list.sort((a, b) => a.date.compareTo(b.date));
      return list;
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Adds a new measurement entry and updates user's currentWeightKg if weight was logged
  Future<void> addMeasurement(String userId, BodyMeasurementModel measurement) async {
    try {
      final docRef = measurement.id.isNotEmpty
          ? _firestore.collection(colMeasurements).doc(measurement.id)
          : _firestore.collection(colMeasurements).doc();

      final payload = measurement.toFirestoreMap(userId);
      payload['id'] = docRef.id;

      await docRef.set(payload, SetOptions(merge: true));

      // Also update currentWeightKg on users/{userId} for live BMI synchronization
      if (measurement.weightKg > 0) {
        await _firestore.collection(colUsers).doc(userId).update({
          'currentWeightKg': measurement.weightKg,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Deletes a measurement record
  Future<void> deleteMeasurement(String measurementId) async {
    try {
      await _firestore.collection(colMeasurements).doc(measurementId).delete();
    } catch (e) {
      throw AppError.fromException(e);
    }
  }
}
