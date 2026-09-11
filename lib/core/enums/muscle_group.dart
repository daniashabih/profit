enum MuscleGroup {
  chest,
  back,
  legs,
  arms,
  shoulders,
  core,
  fullBody;

  String get displayName {
    switch (this) {
      case MuscleGroup.chest:
        return 'Chest';
      case MuscleGroup.back:
        return 'Back';
      case MuscleGroup.legs:
        return 'Legs';
      case MuscleGroup.arms:
        return 'Arms';
      case MuscleGroup.shoulders:
        return 'Shoulders';
      case MuscleGroup.core:
        return 'Core';
      case MuscleGroup.fullBody:
        return 'Full Body';
    }
  }

  String get iconName {
    switch (this) {
      case MuscleGroup.chest:
        return 'fitness_center';
      case MuscleGroup.back:
        return 'accessibility_new';
      case MuscleGroup.legs:
        return 'directions_run';
      case MuscleGroup.arms:
        return 'sports_gymnastics';
      case MuscleGroup.shoulders:
        return 'sports_kabaddi';
      case MuscleGroup.core:
        return 'self_improvement';
      case MuscleGroup.fullBody:
        return 'bolt';
    }
  }
}
