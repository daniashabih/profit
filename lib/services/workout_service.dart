import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_model.dart';
import '../models/workout_set_model.dart';
import '../core/errors/app_error.dart';

/// WorkoutService provides full dynamic Cloud Firestore CRUD and streams for the
/// 'workouts' collection, adhering to firestore.rules isValidWorkout validator.
class WorkoutService {
  final FirebaseFirestore? _firestore;

  WorkoutService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? (Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null);

  static const String colWorkouts = 'workouts';

  /// Streams workouts owned by a specific athlete or created for a client
  Stream<List<WorkoutModel>> streamUserWorkouts(String userId) {
    if (_firestore == null) return const Stream.empty();
    return _firestore
        .collection(colWorkouts)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        if (!data.containsKey('id') || (data['id']?.toString().isEmpty ?? true)) {
          data['id'] = doc.id;
        }
        return WorkoutModel.fromMap(data);
      }).toList();
    });
  }

  /// Fetches workouts owned by a specific user once
  Future<List<WorkoutModel>> getUserWorkouts(String userId) async {
    if (_firestore == null) return [];
    try {
      final snapshot = await _firestore
          .collection(colWorkouts)
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        if (!data.containsKey('id') || (data['id']?.toString().isEmpty ?? true)) {
          data['id'] = doc.id;
        }
        return WorkoutModel.fromMap(data);
      }).toList();
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Streams workout plan templates available across the app
  Stream<List<WorkoutModel>> streamTemplateWorkouts() {
    if (_firestore == null) return const Stream.empty();
    return _firestore
        .collection(colWorkouts)
        .where('isTemplate', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        if (!data.containsKey('id') || (data['id']?.toString().isEmpty ?? true)) {
          data['id'] = doc.id;
        }
        return WorkoutModel.fromMap(data);
      }).toList();
    });
  }

  /// Creates a new workout or plan in Firestore
  Future<void> createWorkout(WorkoutModel workout) async {
    if (_firestore == null) return;
    try {
      final docRef = workout.id.isNotEmpty
          ? _firestore.collection(colWorkouts).doc(workout.id)
          : _firestore.collection(colWorkouts).doc();

      final payload = workout.toFirestoreMap();
      payload['id'] = docRef.id;

      await docRef.set(payload, SetOptions(merge: true));
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Updates an existing workout
  Future<void> updateWorkout(WorkoutModel workout) async {
    if (_firestore == null) return;
    try {
      final payload = workout.toFirestoreMap();
      payload['updatedAt'] = DateTime.now().toIso8601String();
      await _firestore.collection(colWorkouts).doc(workout.id).update(payload);
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Deletes a workout from Firestore
  Future<void> deleteWorkout(String workoutId) async {
    if (_firestore == null) return;
    try {
      await _firestore.collection(colWorkouts).doc(workoutId).delete();
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Toggles today's completion status for a workout
  Future<void> toggleWorkoutComplete(String workoutId, bool isCompleted) async {
    if (_firestore == null) return;
    try {
      await _firestore.collection(colWorkouts).doc(workoutId).update({
        'isCompletedToday': isCompleted,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Updates a set for an exercise within a workout
  Future<void> updateExerciseSet(
    String workoutId,
    String exerciseId,
    int setIndex,
    WorkoutSetModel updatedSet,
  ) async {
    if (_firestore == null) return;
    try {
      final doc = await _firestore.collection(colWorkouts).doc(workoutId).get();
      if (!doc.exists || doc.data() == null) return;

      final workout = WorkoutModel.fromMap(doc.data()!);
      final exIndex = workout.exercises.indexWhere((e) => e.id == exerciseId);
      if (exIndex != -1) {
        final exercise = workout.exercises[exIndex];
        if (setIndex < exercise.setsList.length) {
          exercise.setsList[setIndex] = updatedSet;
          exercise.isCompleted = exercise.setsList.every((s) => s.isCompleted);
        }
        await updateWorkout(workout);
      }
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Adds an exercise set in a workout
  Future<void> addExerciseSet(String workoutId, String exerciseId) async {
    if (_firestore == null) return;
    try {
      final doc = await _firestore.collection(colWorkouts).doc(workoutId).get();
      if (!doc.exists || doc.data() == null) return;

      final workout = WorkoutModel.fromMap(doc.data()!);
      final exIndex = workout.exercises.indexWhere((e) => e.id == exerciseId);
      if (exIndex != -1) {
        final exercise = workout.exercises[exIndex];
        final newSetNum = exercise.setsList.length + 1;
        final lastWeight = exercise.setsList.isNotEmpty ? exercise.setsList.last.weightKg : 20.0;
        final lastReps = exercise.setsList.isNotEmpty ? exercise.setsList.last.reps : 10;

        exercise.setsList.add(WorkoutSetModel(
          setNumber: newSetNum,
          weightKg: lastWeight,
          reps: lastReps,
          isCompleted: false,
        ));
        await updateWorkout(workout);
      }
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Marks an exercise complete within a workout
  Future<void> markExerciseComplete(String workoutId, String exerciseId) async {
    if (_firestore == null) return;
    try {
      final doc = await _firestore.collection(colWorkouts).doc(workoutId).get();
      if (!doc.exists || doc.data() == null) return;

      final workout = WorkoutModel.fromMap(doc.data()!);
      final exIndex = workout.exercises.indexWhere((e) => e.id == exerciseId);
      if (exIndex != -1) {
        final exercise = workout.exercises[exIndex];
        for (final s in exercise.setsList) {
          s.isCompleted = true;
        }
        exercise.isCompleted = true;
        await updateWorkout(workout);
      }
    } catch (e) {
      throw AppError.fromException(e);
    }
  }
}
