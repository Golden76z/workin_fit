import 'package:hive/hive.dart';
import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/models/muscle_database.dart';

part 'exercices.g.dart';

@HiveType(typeId: 0)
class Exercise {
  // Basic informations
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String description;

  // 2 images to show muscles trained and how to do the ex
  @HiveField(3)
  final String imageMuscleUrl;
  @HiveField(4)
  final String imageTutorialUrl;

  // Main muscles that are training 
  @HiveField(5)
  final List<String> primaryMuscleIds;
  // Mainly muscles that supports the body/movement 
  @HiveField(6)
  final List<String> secondaryMuscleIds;
  
  // Helper getters
  List<Muscle> get primaryMuscles => 
      primaryMuscleIds.map((id) => MuscleDatabase.getMuscleById(id)!)
                      .toList();
  
  List<Muscle> get secondaryMuscles => 
      secondaryMuscleIds.map((id) => MuscleDatabase.getMuscleById(id)!)
                       .toList();
  
  // Get all categories involved
  List<MuscleCategory> get categories {
    final allMuscles = [...primaryMuscles, ...secondaryMuscles];
    return allMuscles.map((m) => m.category).toSet().toList();
  }

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.imageMuscleUrl,
    required this.imageTutorialUrl,
    required this.primaryMuscleIds,
    required this.secondaryMuscleIds,
  });
}