// lib/models/session.dart
import 'package:hive/hive.dart';
import 'package:workin_fit/models/workout_config.dart';
import 'package:workin_fit/models/enums.dart';

part 'session.g.dart';

@HiveType(typeId: 1)
class Session extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String? description;
  
  /// List of workout configurations (can be mixed: sets, tabata, timed)
  @HiveField(3)
  final List<WorkoutConfig> workouts;
  
  /// Rest time between different exercises in seconds (default 120s)
  @HiveField(4)
  final int restBetweenExercises;
  
  /// Time given to get into position before exercise starts (default 5s)
  @HiveField(5)
  final int transitionTime;
  
  /// Difficulty level of the session
  @HiveField(6)
  final DifficultyLevel difficulty;
  
  /// Whether this is a custom session created by user
  @HiveField(7)
  final bool isCustom;
  
  /// User ID if custom session (null for preset sessions)
  @HiveField(8)
  final String? userId;
  
  /// Created timestamp
  @HiveField(9)
  final DateTime createdAt;

  Session({
    required this.id,
    required this.name,
    required this.workouts, required this.difficulty, this.description,
    this.restBetweenExercises = 120, // From your requirements
    this.transitionTime = 5, // From your requirements
    this.isCustom = false,
    this.userId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Total number of exercises in session
  int get exerciseCount => workouts.length;
  
  /// Estimated total duration in seconds (including rest and transitions)
  int get estimatedDuration {
    int workoutTime = 0;
    
    for (var workout in workouts) {
      if (workout is SetsConfig) {
        workoutTime += workout.estimatedTotalTime;
      } else if (workout is TabataConfig) {
        workoutTime += workout.totalDuration;
      } else if (workout is TimedConfig) {
        workoutTime += workout.totalDuration;
      }
    }
    
    // Add rest between exercises and transitions
    final int totalRest = (exerciseCount - 1) * restBetweenExercises;
    final int totalTransitions = exerciseCount * transitionTime;
    
    return workoutTime + totalRest + totalTransitions;
  }
  
  /// Human-readable duration (e.g., "45 min")
  String get durationDisplay {
    final int minutes = (estimatedDuration / 60).ceil();
    return '$minutes min';
  }
  
  /// Check if session contains specific workout type
  bool hasWorkoutType(WorkoutType type) {
    return workouts.any((w) => w.type == type);
  }
  
  /// Get all unique exercise IDs
  List<String> get exerciseIds {
    return workouts.map((w) => w.exerciseId).toSet().toList();
  }
}