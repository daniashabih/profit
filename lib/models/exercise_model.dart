import '../core/enums/muscle_group.dart';
import '../core/enums/exercise_difficulty.dart';
import 'workout_set_model.dart';

class ExerciseModel {
  final String id;
  final String? userId;
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
  final DateTime createdAt;
  final DateTime updatedAt;
  bool isFavorite;
  bool isCompleted;
  List<WorkoutSetModel> setsList;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    required this.difficulty,
    this.userId,
    this.sets = 3,
    this.reps = 10,
    this.restTimeSeconds = 60,
    this.imageUrl = '',
    this.videoUrl = '',
    this.instructions = const [],
    this.isFavorite = false,
    this.isCompleted = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<WorkoutSetModel>? setsList,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        setsList = setsList ??
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
    String? userId,
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
    DateTime? createdAt,
    DateTime? updatedAt,
    List<WorkoutSetModel>? setsList,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      setsList: setsList ?? this.setsList.map((s) => s.copyWith()).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      if (userId != null) 'userId': userId,
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Cloud Firestore payload strictly adhering to firestore.rules isValidExercise
  Map<String, dynamic> toFirestoreMap([String? ownerUid]) {
    final map = <String, dynamic>{
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
    final effectiveUid = userId ?? ownerUid;
    if (effectiveUid != null && effectiveUid.isNotEmpty) {
      map['userId'] = effectiveUid;
    }
    return map;
  }

  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
      id: map['id']?.toString() ?? '',
      userId: map['userId']?.toString(),
      name: map['name']?.toString() ?? '',
      muscleGroup: MuscleGroup.values.firstWhere(
        (m) => m.name == map['muscleGroup'],
        orElse: () => MuscleGroup.chest,
      ),
      equipment: map['equipment']?.toString() ?? 'No Equipment',
      difficulty: ExerciseDifficulty.values.firstWhere(
        (d) => d.name == map['difficulty'],
        orElse: () => ExerciseDifficulty.beginner,
      ),
      sets: (map['sets'] as num?)?.toInt() ?? 3,
      reps: (map['reps'] as num?)?.toInt() ?? 10,
      restTimeSeconds: (map['restTimeSeconds'] as num?)?.toInt() ?? 60,
      imageUrl: map['imageUrl']?.toString() ?? '',
      videoUrl: map['videoUrl']?.toString() ?? '',
      instructions: (map['instructions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isFavorite: map['isFavorite'] == true,
      isCompleted: map['isCompleted'] == true,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      setsList: (map['setsList'] as List<dynamic>?)
              ?.map((item) => WorkoutSetModel.fromMap(Map<String, dynamic>.from(item as Map)))
              .toList() ??
          [],
    );
  }
}
