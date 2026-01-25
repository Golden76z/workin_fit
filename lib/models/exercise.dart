import 'package:hive/hive.dart';
import 'package:workin_fit/models/enums.dart';

part 'exercise.g.dart';

@HiveType(typeId: 0)
class Exercise {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String description;
  
  /// URL to image showing which muscles are targeted
  @HiveField(3)
  final String imageMuscleUrl;
  
  /// URL to image/GIF showing how to perform the exercise
  @HiveField(4)
  final String imageTutorialUrl;
  
  /// List of muscle groups this exercise targets
  @HiveField(5)
  final List<MuscleGroup> muscleGroups;
  
  /// Difficulty level
  @HiveField(6)
  final DifficultyLevel difficulty;
  
  /// Optional tips for beginners
  @HiveField(7)
  final String? beginnerTips;
  
  /// Equipment needed (empty list = bodyweight)
  @HiveField(8)
  final List<String> equipment;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.imageMuscleUrl,
    required this.imageTutorialUrl,
    required this.muscleGroups,
    required this.difficulty,
    this.beginnerTips,
    this.equipment = const [],
  });

  // Helper methods
  bool get isBodyweight => equipment.isEmpty;
  
  String get muscleGroupsDisplay => 
      muscleGroups.map((m) => m.name).join(', ');

  // JSON serialization for Firestore
  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageMuscleUrl: json['imageMuscleUrl'] as String,
      imageTutorialUrl: json['imageTutorialUrl'] as String,
      muscleGroups: (json['muscleGroups'] as List<dynamic>)
          .map((e) {
            final name = e is String ? e : e.toString();
            return MuscleGroup.values.firstWhere(
              (mg) => mg.name == name,
              orElse: () => MuscleGroup.abs, // Default fallback
            );
          })
          .toList(),
      difficulty: DifficultyLevel.values.firstWhere(
        (d) => d.name == (json['difficulty'] as String),
        orElse: () => DifficultyLevel.beginner,
      ),
      beginnerTips: json['beginnerTips'] as String?,
      equipment: (json['equipment'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageMuscleUrl': imageMuscleUrl,
      'imageTutorialUrl': imageTutorialUrl,
      'muscleGroups': muscleGroups.map((m) => m.name).toList(),
      'difficulty': difficulty.name,
      'beginnerTips': beginnerTips,
      'equipment': equipment,
    };
  }
}

