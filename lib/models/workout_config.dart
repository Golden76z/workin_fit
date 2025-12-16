import 'package:hive/hive.dart';
import 'package:workin_fit/models/enums.dart';

part 'workout_config.g.dart';

/// Base class for workout configuration
@HiveType(typeId: 2)
class WorkoutConfig extends HiveObject {
  @HiveField(0)
  final WorkoutType type;
  
  @HiveField(1)
  final String exerciseId;

  WorkoutConfig({
    required this.type,
    required this.exerciseId,
  });
}

/// Configuration for set-based workouts (e.g., 4 sets of 10 push-ups)
@HiveType(typeId: 3)
class SetsConfig extends WorkoutConfig {
  /// Number of sets (e.g., 4)
  @HiveField(2)
  final int sets;
  
  /// Number of reps per set (e.g., 10)
  @HiveField(3)
  final int reps;
  
  /// Rest time between sets in seconds (default 60s)
  @HiveField(4)
  final int restBetweenSets;
  
  /// Optional: target weight (for weighted exercises)
  @HiveField(5)
  final double? weight;
  
  /// Optional: weight unit (kg, lbs)
  @HiveField(6)
  final String? weightUnit;

  SetsConfig({
    required super.exerciseId,
    required this.sets,
    required this.reps,
    this.restBetweenSets = 60, // Default from your requirements
    this.weight,
    this.weightUnit,
  }) : super(
          type: WorkoutType.sets,
        );

  /// Total volume calculation
  int get totalReps => sets * reps;
  
  /// Estimated duration in seconds (excluding rest)
  /// Assumes ~3 seconds per rep
  int get estimatedWorkDuration => totalReps * 3;
  
  /// Total rest time in seconds
  int get totalRestTime => (sets - 1) * restBetweenSets;
  
  /// Total estimated time for this exercise
  int get estimatedTotalTime => estimatedWorkDuration + totalRestTime;
}

/// Configuration for Tabata/HIIT workouts (e.g., 20s work, 10s rest, 8 rounds)
@HiveType(typeId: 4)
class TabataConfig extends WorkoutConfig {
  /// Work interval in seconds (e.g., 20)
  @HiveField(2)
  final int workTime;
  
  /// Rest interval in seconds (e.g., 10)
  @HiveField(3)
  final int restTime;
  
  /// Number of rounds (e.g., 8)
  @HiveField(4)
  final int rounds;

  TabataConfig({
    required super.exerciseId,
    required this.workTime,
    required this.restTime,
    required this.rounds,
  }) : super(
          type: WorkoutType.tabata,
        );

  /// Total work time in seconds
  int get totalWorkTime => workTime * rounds;
  
  /// Total rest time in seconds
  int get totalRestTime => restTime * rounds;
  
  /// Total duration in seconds
  int get totalDuration => totalWorkTime + totalRestTime;
}

/// Configuration for timed exercises (e.g., 60s plank)
@HiveType(typeId: 5)
class TimedConfig extends WorkoutConfig {
  /// Duration in seconds
  @HiveField(2)
  final int duration;

  TimedConfig({
    required super.exerciseId,
    required this.duration,
  }) : super(
          type: WorkoutType.timed,
        );

  int get totalDuration => duration;
}