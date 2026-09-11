/// FirestoreService defines standard Firestore schemas and collection endpoints
/// for Cloud Firestore integration.
class FirestoreService {
  static const String colUsers = 'users';
  static const String colWorkouts = 'workouts';
  static const String colExercises = 'exercises';
  static const String colNutritionLogs = 'nutrition_logs';
  static const String colMeasurements = 'measurements';
  static const String colTrainers = 'trainers';
  static const String colMemberships = 'memberships';
  static const String colAchievements = 'achievements';
  static const String colNotifications = 'notifications';

  // Future Firestore query methods:
  // e.g. FirebaseFirestore.instance.collection(colUsers).doc(userId)...
}
