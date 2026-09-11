class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String iconEmoji;
  final bool isUnlocked;
  final double currentProgress;
  final double targetProgress;
  final String unit;
  final DateTime? unlockedAt;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconEmoji,
    this.isUnlocked = false,
    this.currentProgress = 0,
    this.targetProgress = 1,
    this.unit = '',
    this.unlockedAt,
  });

  double get progressRatio =>
      targetProgress == 0 ? 0 : (currentProgress / targetProgress).clamp(0.0, 1.0);
}

class PersonalRecordModel {
  final String exerciseName;
  final double weightKg;
  final int reps;
  final DateTime achievedDate;

  const PersonalRecordModel({
    required this.exerciseName,
    required this.weightKg,
    required this.reps,
    required this.achievedDate,
  });
}
