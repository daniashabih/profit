import '../core/enums/muscle_group.dart';
import '../core/enums/exercise_difficulty.dart';
import 'workout_set_model.dart';

class ExerciseModel {
  final String id;
  final String name;
  final MuscleGroup muscleGroup;
  final String equipment;
  final ExerciseDifficulty difficulty;
  final int sets;
  final int reps;
  final int restTimeSeconds;
  final String imageUrl;
  final String videoUrl;
  final List<String> instructions;
  bool isFavorite;
  bool isCompleted;
  List<WorkoutSetModel> setsList;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    required this.difficulty,
    this.sets = 3,
    this.reps = 10,
    this.restTimeSeconds = 60,
    this.imageUrl = '',
    this.videoUrl = '',
    this.instructions = const [],
    this.isFavorite = false,
    this.isCompleted = false,
    List<WorkoutSetModel>? setsList,
  }) : setsList = setsList ??
            List.generate(
              sets,
              (index) => WorkoutSetModel(
                setNumber: index + 1,
                weightKg: 20.0,
                reps: reps,
              ),
            );

  int get completedSetsCount => setsList.where((s) => s.isCompleted).length;

  double get completionProgress =>
      setsList.isEmpty ? 0.0 : (completedSetsCount / setsList.length);

  ExerciseModel copyWith({
    String? id,
    String? name,
    MuscleGroup? muscleGroup,
    String? equipment,
    ExerciseDifficulty? difficulty,
    int? sets,
    int? reps,
    int? restTimeSeconds,
    String? imageUrl,
    String? videoUrl,
    List<String>? instructions,
    bool? isFavorite,
    bool? isCompleted,
    List<WorkoutSetModel>? setsList,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      equipment: equipment ?? this.equipment,
      difficulty: difficulty ?? this.difficulty,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      restTimeSeconds: restTimeSeconds ?? this.restTimeSeconds,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      instructions: instructions ?? this.instructions,
      isFavorite: isFavorite ?? this.isFavorite,
      isCompleted: isCompleted ?? this.isCompleted,
      setsList: setsList ?? this.setsList.map((s) => s.copyWith()).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'muscleGroup': muscleGroup.name,
      'equipment': equipment,
      'difficulty': difficulty.name,
      'sets': sets,
      'reps': reps,
      'restTimeSeconds': restTimeSeconds,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'instructions': instructions,
      'isFavorite': isFavorite,
      'isCompleted': isCompleted,
      'setsList': setsList.map((s) => s.toMap()).toList(),
    };
  }

  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      muscleGroup: MuscleGroup.values.firstWhere(
        (m) => m.name == map['muscleGroup'],
        orElse: () => MuscleGroup.chest,
      ),
      equipment: map['equipment'] ?? 'No Equipment',
      difficulty: ExerciseDifficulty.values.firstWhere(
        (d) => d.name == map['difficulty'],
        orElse: () => ExerciseDifficulty.beginner,
      ),
      sets: map['sets'] ?? 3,
      reps: map['reps'] ?? 10,
      restTimeSeconds: map['restTimeSeconds'] ?? 60,
      imageUrl: map['imageUrl'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      instructions: List<String>.from(map['instructions'] ?? []),
      isFavorite: map['isFavorite'] ?? false,
      isCompleted: map['isCompleted'] ?? false,
      setsList: (map['setsList'] as List<dynamic>?)
              ?.map((item) => WorkoutSetModel.fromMap(item))
              .toList() ??
          [],
    );
  }
}
