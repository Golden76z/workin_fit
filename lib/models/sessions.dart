import 'package:hive/hive.dart';
import 'package:workin_fit/models/exercices.dart';

@HiveType(typeId: 1)
class Session {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int restTime;

  // Fixed at 0 but usefull for tabata sets
  @HiveField(2)
  final int changingPositionTime;

  // List of exercices 
  @HiveField(3)
  late final List<Exercise> exercices;

  Session({
    required this.id,
    required this.restTime,
    required this.changingPositionTime,
    required this.exercices,
  });
}