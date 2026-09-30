import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/workout_log_model.dart';

/// Service managing actual workout execution tracking and Cloud Firestore persistence: workoutLogs/{logId}
class WorkoutLogService {
  final FirebaseFirestore? _firestore;

  final List<WorkoutLog> _localLogs = [];

  WorkoutLogService({FirebaseFirestore? firestore})
      : _firestore = firestore ??
            (Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null);

  /// Saves a completed daily workout session with actual performance data
  Future<WorkoutLog> logWorkoutSession(WorkoutLog log) async {
    _localLogs.add(log);

    if (_firestore != null && log.userId.isNotEmpty) {
      try {
        await _firestore.collection('workoutLogs').doc(log.id).set(log.toMap());
      } catch (e) {
        // Fallback for mock/test runs
      }
    }

    return log;
  }

  /// Fetches workout logs for a user within a specified date range
  Future<List<WorkoutLog>> getWorkoutLogs({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_firestore != null && userId.isNotEmpty) {
      try {
        Query query = _firestore
            .collection('workoutLogs')
            .where('userId', isEqualTo: userId);

        if (startDate != null) {
          query = query.where('completedAt', isGreaterThanOrEqualTo: startDate.toIso8601String());
        }
        if (endDate != null) {
          query = query.where('completedAt', isLessThanOrEqualTo: endDate.toIso8601String());
        }

        final snapshot = await query.get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((doc) => WorkoutLog.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id))
              .toList();
        }
      } catch (_) {}
    }

    return _localLogs.where((l) {
      if (l.userId != userId) return false;
      if (startDate != null && l.completedAt.isBefore(startDate)) return false;
      if (endDate != null && l.completedAt.isAfter(endDate)) return false;
      return true;
    }).toList();
  }

  /// Streams today's workout log for the user, if one exists
  Stream<WorkoutLog?> streamTodayLog(String userId) {
    final todayStr = DateTime.now().toIso8601String().split('T').first;

    if (_firestore == null || userId.isEmpty) {
      final match = _localLogs.where((l) => l.userId == userId && l.dateString == todayStr).lastOrNull;
      return Stream.value(match);
    }

    return _firestore
        .collection('workoutLogs')
        .where('userId', isEqualTo: userId)
        .where('dateString', isEqualTo: todayStr)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return WorkoutLog.fromMap(snapshot.docs.first.data(), docId: snapshot.docs.first.id);
    });
  }

  /// Calculates monthly workout completion percentage for a given month and scheduled count
  Future<double> calculateMonthlyCompletionRate({
    required String userId,
    required DateTime monthStart,
    required DateTime monthEnd,
    required int scheduledWorkoutsCount,
  }) async {
    if (scheduledWorkoutsCount <= 0) return 100.0;

    final logs = await getWorkoutLogs(
      userId: userId,
      startDate: monthStart,
      endDate: monthEnd,
    );

    final completedCount = logs.where((l) => l.completedExercises > 0).length;
    final rate = (completedCount / scheduledWorkoutsCount) * 100.0;
    return rate.clamp(0.0, 100.0);
  }
}
