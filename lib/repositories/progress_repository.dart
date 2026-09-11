import '../models/measurement_model.dart';
import '../models/achievement_model.dart';

abstract class ProgressRepository {
  List<BodyMeasurementModel> getMeasurementsHistory();
  void addMeasurement(BodyMeasurementModel measurement);
  List<AchievementModel> getAchievements();
  List<PersonalRecordModel> getPersonalRecords();
  List<bool> getWeeklyWorkoutActivity(); // M, T, W, T, F, S, S
}

class LocalProgressRepository implements ProgressRepository {
  final List<BodyMeasurementModel> _measurements = [
    BodyMeasurementModel(
      id: 'm_1',
      date: DateTime(2026, 6, 1),
      weightKg: 72.0,
      waistCm: 84.0,
      chestCm: 96.0,
      armsCm: 32.0,
      thighsCm: 56.0,
      note: 'Starting journey',
    ),
    BodyMeasurementModel(
      id: 'm_2',
      date: DateTime(2026, 7, 1),
      weightKg: 70.8,
      waistCm: 82.5,
      chestCm: 95.0,
      armsCm: 31.5,
      thighsCm: 55.0,
    ),
    BodyMeasurementModel(
      id: 'm_3',
      date: DateTime(2026, 8, 1),
      weightKg: 69.8,
      waistCm: 81.0,
      chestCm: 94.5,
      armsCm: 31.0,
      thighsCm: 54.0,
    ),
    BodyMeasurementModel(
      id: 'm_4',
      date: DateTime(2026, 9, 11),
      weightKg: 69.0,
      waistCm: 80.0,
      chestCm: 94.0,
      armsCm: 30.5,
      thighsCm: 53.5,
      note: 'Current weight: 69.0 kg',
    ),
  ];

  final List<AchievementModel> _achievements = [
    AchievementModel(
      id: 'ach_1',
      title: 'First Workout',
      description: 'Completed your first training session on ProFit.',
      iconEmoji: '🏆',
      isUnlocked: true,
      currentProgress: 1,
      targetProgress: 1,
      unit: 'workout',
      unlockedAt: DateTime.now().subtract(const Duration(days: 35)),
    ),
    AchievementModel(
      id: 'ach_2',
      title: '7 Day Streak',
      description: 'Maintained active training and nutrition logging for 7 days in a row.',
      iconEmoji: '🔥',
      isUnlocked: true,
      currentProgress: 7,
      targetProgress: 7,
      unit: 'days',
      unlockedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    AchievementModel(
      id: 'ach_3',
      title: '100 KG Club',
      description: 'Lifted a total accumulated volume or 1RM exceeding 100 kg on Barbell Squat.',
      iconEmoji: '💪',
      isUnlocked: true,
      currentProgress: 105,
      targetProgress: 100,
      unit: 'kg',
      unlockedAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
    AchievementModel(
      id: 'ach_4',
      title: '10 Workouts Milestone',
      description: 'Crushed 10 complete workouts inside the gym.',
      iconEmoji: '🏃',
      isUnlocked: true,
      currentProgress: 28,
      targetProgress: 10,
      unit: 'workouts',
      unlockedAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    AchievementModel(
      id: 'ach_5',
      title: 'Iron Consistency',
      description: 'Log 30 distinct workout sessions.',
      iconEmoji: '⭐',
      isUnlocked: false,
      currentProgress: 28,
      targetProgress: 30,
      unit: 'workouts',
    ),
    AchievementModel(
      id: 'ach_6',
      title: 'Macro Master',
      description: 'Hit daily protein and calorie targets 14 days straight.',
      iconEmoji: '🥗',
      isUnlocked: false,
      currentProgress: 11,
      targetProgress: 14,
      unit: 'days',
    ),
  ];

  final List<PersonalRecordModel> _personalRecords = [
    PersonalRecordModel(
      exerciseName: 'Barbell Bench Press',
      weightKg: 85.0,
      reps: 5,
      achievedDate: DateTime.now().subtract(const Duration(days: 12)),
    ),
    PersonalRecordModel(
      exerciseName: 'Barbell Back Squat',
      weightKg: 110.0,
      reps: 6,
      achievedDate: DateTime.now().subtract(const Duration(days: 6)),
    ),
    PersonalRecordModel(
      exerciseName: 'Dumbbell Shoulder Press',
      weightKg: 24.0,
      reps: 8,
      achievedDate: DateTime.now().subtract(const Duration(days: 15)),
    ),
    PersonalRecordModel(
      exerciseName: 'Incline Leg Press',
      weightKg: 160.0,
      reps: 10,
      achievedDate: DateTime.now().subtract(const Duration(days: 22)),
    ),
  ];

  @override
  List<BodyMeasurementModel> getMeasurementsHistory() => List.unmodifiable(_measurements);

  @override
  void addMeasurement(BodyMeasurementModel measurement) {
    _measurements.add(measurement);
    _measurements.sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  List<AchievementModel> getAchievements() => List.unmodifiable(_achievements);

  @override
  List<PersonalRecordModel> getPersonalRecords() => List.unmodifiable(_personalRecords);

  @override
  List<bool> getWeeklyWorkoutActivity() {
    // Activity for: M, T, W, T, F, S, S
    // Completed Mon, Tue, Thu, Fri, Sat (example for 5 day streak)
    return [true, true, false, true, true, true, false];
  }
}
