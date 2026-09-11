class TrainerModel {
  final String id;
  final String name;
  final String avatarUrl;
  final String certification;
  final double rating;
  final int reviewsCount;
  final String bio;
  final String assignedWorkoutPlan;
  final String assignedDietPlan;
  final List<String> weeklyTargets;
  final String specialty;

  TrainerModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.certification,
    this.rating = 4.9,
    this.reviewsCount = 128,
    this.bio = 'Passionate fitness coach specialized in hypertrophy, functional strength, and nutrition programming.',
    this.assignedWorkoutPlan = 'Upper/Lower 4-Day Hypertrophy Split',
    this.assignedDietPlan = 'High Protein Lean Bulk (2,400 kcal)',
    this.weeklyTargets = const [
      'Complete 4 strength sessions',
      'Hit 150g protein daily',
      'Minimum 8,000 steps daily',
      'Sleep 7+ hours per night',
    ],
    this.specialty = 'Strength & Conditioning',
  });
}
