import '../core/enums/muscle_group.dart';
import '../core/enums/exercise_difficulty.dart';
import '../models/exercise_model.dart';
import '../models/workout_set_model.dart';

abstract class ExerciseRepository {
  List<ExerciseModel> getAllExercises();
  List<ExerciseModel> searchExercises({
    String? query,
    MuscleGroup? muscleGroup,
    String? equipment,
    ExerciseDifficulty? difficulty,
    bool? favoritesOnly,
  });
  void toggleFavorite(String exerciseId);
}

class LocalExerciseRepository implements ExerciseRepository {
  final List<ExerciseModel> _exercises = [
    ExerciseModel(
      id: 'ex_bench_press',
      name: 'Barbell Bench Press',
      muscleGroup: MuscleGroup.chest,
      equipment: 'Barbell',
      difficulty: ExerciseDifficulty.intermediate,
      sets: 4,
      reps: 10,
      restTimeSeconds: 90,
      imageUrl: 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=600',
      instructions: [
        'Lie flat on bench with feet planted firmly on the ground.',
        'Grip bar slightly wider than shoulder width.',
        'Lower bar slowly to mid-chest with elbows at ~45 degrees.',
        'Press upward explosively while keeping shoulder blades retracted.',
      ],
      setsList: [
        WorkoutSetModel(setNumber: 1, weightKg: 60.0, reps: 12, isCompleted: true),
        WorkoutSetModel(setNumber: 2, weightKg: 70.0, reps: 10, isCompleted: true),
        WorkoutSetModel(setNumber: 3, weightKg: 75.0, reps: 8, isCompleted: false),
        WorkoutSetModel(setNumber: 4, weightKg: 80.0, reps: 6, isCompleted: false),
      ],
    ),
    ExerciseModel(
      id: 'ex_shoulder_press',
      name: 'Dumbbell Shoulder Press',
      muscleGroup: MuscleGroup.shoulders,
      equipment: 'Dumbbell',
      difficulty: ExerciseDifficulty.intermediate,
      sets: 3,
      reps: 12,
      restTimeSeconds: 60,
      imageUrl: 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=600',
      instructions: [
        'Sit upright on a 90-degree inclined bench with dumbbells at ear level.',
        'Press dumbbells overhead until arms are nearly fully extended.',
        'Pause for a second at the top, then lower under control.',
      ],
      setsList: [
        WorkoutSetModel(setNumber: 1, weightKg: 18.0, reps: 12, isCompleted: true),
        WorkoutSetModel(setNumber: 2, weightKg: 20.0, reps: 10, isCompleted: true),
        WorkoutSetModel(setNumber: 3, weightKg: 22.0, reps: 8, isCompleted: false),
      ],
    ),
    ExerciseModel(
      id: 'ex_lat_pulldown',
      name: 'Cable Lat Pulldown',
      muscleGroup: MuscleGroup.back,
      equipment: 'Cable',
      difficulty: ExerciseDifficulty.beginner,
      sets: 3,
      reps: 12,
      restTimeSeconds: 60,
      imageUrl: 'https://images.unsplash.com/photo-1605296867304-46d5465a13f1?w=600',
      instructions: [
        'Grip wide bar with palms facing forward.',
        'Pull bar down towards upper chest while arching upper back slightly.',
        'Squeeze lats at the bottom, then return slowly.',
      ],
      setsList: [
        WorkoutSetModel(setNumber: 1, weightKg: 45.0, reps: 12, isCompleted: true),
        WorkoutSetModel(setNumber: 2, weightKg: 50.0, reps: 12, isCompleted: false),
        WorkoutSetModel(setNumber: 3, weightKg: 55.0, reps: 10, isCompleted: false),
      ],
    ),
    ExerciseModel(
      id: 'ex_dumbbell_row',
      name: 'One-Arm Dumbbell Row',
      muscleGroup: MuscleGroup.back,
      equipment: 'Dumbbell',
      difficulty: ExerciseDifficulty.beginner,
      sets: 3,
      reps: 10,
      restTimeSeconds: 60,
      imageUrl: 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=600',
      instructions: [
        'Place one knee and hand on bench with back flat.',
        'Pull dumbbell upward towards hip, keeping elbow close to torso.',
        'Lower under strict control.',
      ],
      setsList: [
        WorkoutSetModel(setNumber: 1, weightKg: 22.0, reps: 10, isCompleted: false),
        WorkoutSetModel(setNumber: 2, weightKg: 24.0, reps: 10, isCompleted: false),
        WorkoutSetModel(setNumber: 3, weightKg: 26.0, reps: 8, isCompleted: false),
      ],
    ),
    ExerciseModel(
      id: 'ex_barbell_squat',
      name: 'Barbell Back Squat',
      muscleGroup: MuscleGroup.legs,
      equipment: 'Barbell',
      difficulty: ExerciseDifficulty.advanced,
      sets: 4,
      reps: 8,
      restTimeSeconds: 120,
      imageUrl: 'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=600',
      instructions: [
        'Rest bar across upper back muscles (traps).',
        'Feet shoulder-width apart, toes pointed slightly outward.',
        'Hinge hips and bend knees down to at least parallel.',
        'Drive up through whole foot while maintaining braced core.',
      ],
      setsList: [
        WorkoutSetModel(setNumber: 1, weightKg: 80.0, reps: 10, isCompleted: false),
        WorkoutSetModel(setNumber: 2, weightKg: 90.0, reps: 8, isCompleted: false),
        WorkoutSetModel(setNumber: 3, weightKg: 100.0, reps: 8, isCompleted: false),
        WorkoutSetModel(setNumber: 4, weightKg: 105.0, reps: 6, isCompleted: false),
      ],
    ),
    ExerciseModel(
      id: 'ex_leg_press',
      name: 'Incline Leg Press',
      muscleGroup: MuscleGroup.legs,
      equipment: 'Machine',
      difficulty: ExerciseDifficulty.beginner,
      sets: 3,
      reps: 12,
      restTimeSeconds: 75,
      imageUrl: 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=600',
      instructions: [
        'Sit on machine with feet flat on the sled shoulder-width apart.',
        'Release safety pins and lower weight until knees form 90 degree angle.',
        'Push sled upward smoothly without locking knees at the top.',
      ],
      setsList: [
        WorkoutSetModel(setNumber: 1, weightKg: 120.0, reps: 12, isCompleted: false),
        WorkoutSetModel(setNumber: 2, weightKg: 140.0, reps: 12, isCompleted: false),
        WorkoutSetModel(setNumber: 3, weightKg: 150.0, reps: 10, isCompleted: false),
      ],
    ),
    ExerciseModel(
      id: 'ex_plank',
      name: 'Forearm Core Plank',
      muscleGroup: MuscleGroup.core,
      equipment: 'No Equipment',
      difficulty: ExerciseDifficulty.beginner,
      sets: 3,
      reps: 45, // seconds
      restTimeSeconds: 45,
      imageUrl: 'https://images.unsplash.com/photo-1566241142559-40e1dab266c6?w=600',
      instructions: [
        'Place forearms on mat with elbows under shoulders.',
        'Extend legs back with toes supporting lower body.',
        'Squeeze glutes and brace abs tightly in a straight line.',
        'Breathe steadily without letting hips sag.',
      ],
      setsList: [
        WorkoutSetModel(setNumber: 1, weightKg: 0.0, reps: 45, isCompleted: false),
        WorkoutSetModel(setNumber: 2, weightKg: 0.0, reps: 45, isCompleted: false),
        WorkoutSetModel(setNumber: 3, weightKg: 0.0, reps: 60, isCompleted: false),
      ],
    ),
    ExerciseModel(
      id: 'ex_incline_dumbbell_press',
      name: 'Incline Dumbbell Press',
      muscleGroup: MuscleGroup.chest,
      equipment: 'Dumbbell',
      difficulty: ExerciseDifficulty.intermediate,
      sets: 3,
      reps: 10,
      restTimeSeconds: 60,
      imageUrl: 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=600',
      instructions: ['Set bench to 30 degrees incline.', 'Press dumbbells upward over chest.'],
    ),
    ExerciseModel(
      id: 'ex_cable_flyes',
      name: 'Standing Cable Chest Flyes',
      muscleGroup: MuscleGroup.chest,
      equipment: 'Cable',
      difficulty: ExerciseDifficulty.intermediate,
      sets: 3,
      reps: 15,
      restTimeSeconds: 45,
      imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=600',
      instructions: ['Step forward with pulleys at shoulder level.', 'Bring hands together in hugging arc.'],
    ),
    ExerciseModel(
      id: 'ex_bicep_curl',
      name: 'Dumbbell Bicep Curls',
      muscleGroup: MuscleGroup.arms,
      equipment: 'Dumbbell',
      difficulty: ExerciseDifficulty.beginner,
      sets: 3,
      reps: 12,
      restTimeSeconds: 45,
      imageUrl: 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=600',
      instructions: ['Hold dumbbells at sides with palms forward.', 'Curl upward keeping elbows pinned.'],
    ),
    ExerciseModel(
      id: 'ex_tricep_rope_pushdown',
      name: 'Cable Tricep Rope Pushdown',
      muscleGroup: MuscleGroup.arms,
      equipment: 'Cable',
      difficulty: ExerciseDifficulty.beginner,
      sets: 3,
      reps: 12,
      restTimeSeconds: 45,
      imageUrl: 'https://images.unsplash.com/photo-1605296867304-46d5465a13f1?w=600',
      instructions: ['Attach rope to high pulley.', 'Push down and spread rope ends at the bottom.'],
    ),
    ExerciseModel(
      id: 'ex_romanian_deadlift',
      name: 'Dumbbell Romanian Deadlift',
      muscleGroup: MuscleGroup.legs,
      equipment: 'Dumbbell',
      difficulty: ExerciseDifficulty.intermediate,
      sets: 3,
      reps: 10,
      restTimeSeconds: 75,
      imageUrl: 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=600',
      instructions: ['Hold dumbbells at thighs.', 'Hinge hips backwards with slight knee bend.'],
    ),
    ExerciseModel(
      id: 'ex_pushups',
      name: 'Standard Push-Ups',
      muscleGroup: MuscleGroup.chest,
      equipment: 'No Equipment',
      difficulty: ExerciseDifficulty.beginner,
      sets: 3,
      reps: 15,
      restTimeSeconds: 45,
      imageUrl: 'https://images.unsplash.com/photo-1566241142559-40e1dab266c6?w=600',
      instructions: ['Hands slightly wider than shoulders.', 'Lower body until chest grazes floor.'],
    ),
  ];

  @override
  List<ExerciseModel> getAllExercises() => List.unmodifiable(_exercises);

  @override
  List<ExerciseModel> searchExercises({
    String? query,
    MuscleGroup? muscleGroup,
    String? equipment,
    ExerciseDifficulty? difficulty,
    bool? favoritesOnly,
  }) {
    return _exercises.where((ex) {
      if (query != null && query.trim().isNotEmpty) {
        final q = query.toLowerCase().trim();
        final matchesName = ex.name.toLowerCase().contains(q);
        final matchesMuscle = ex.muscleGroup.displayName.toLowerCase().contains(q);
        final matchesEquip = ex.equipment.toLowerCase().contains(q);
        if (!matchesName && !matchesMuscle && !matchesEquip) return false;
      }

      if (muscleGroup != null && ex.muscleGroup != muscleGroup) {
        return false;
      }

      if (equipment != null && equipment != 'All Equipment') {
        if (ex.equipment.toLowerCase() != equipment.toLowerCase()) {
          return false;
        }
      }

      if (difficulty != null && ex.difficulty != difficulty) {
        return false;
      }

      if (favoritesOnly == true && !ex.isFavorite) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  void toggleFavorite(String exerciseId) {
    final index = _exercises.indexWhere((e) => e.id == exerciseId);
    if (index != -1) {
      _exercises[index].isFavorite = !_exercises[index].isFavorite;
    }
  }
}
