import 'package:hive/hive.dart';
// part 'exercices.g.dart';

@HiveType(typeId: 0)
class Exercise {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String imageMuscleUrl;

  @HiveField(4)
  final String imageTutorialUrl;

  @HiveField(5)
  final List<String> muscleGroups;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.imageMuscleUrl,
    required this.imageTutorialUrl,
    required this.muscleGroups,
  }); 
}