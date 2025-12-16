import 'package:hive/hive.dart';

part 'enums.g.dart';

/// Type of workout for an exercise
@HiveType(typeId: 10)
enum WorkoutType {
  @HiveField(0)
  sets, // Traditional sets and reps (e.g., 4 sets of 10 reps)
  
  @HiveField(1)
  tabata, // Interval training (e.g., 20s work, 10s rest, 8 rounds)
  
  @HiveField(2)
  timed, // Single timed exercise (e.g., 60s plank)
}

/// Difficulty level for exercises and programs
@HiveType(typeId: 11)
enum DifficultyLevel {
  @HiveField(0)
  beginner,
  
  @HiveField(1)
  intermediate,
  
  @HiveField(2)
  advanced,
}

/// Muscle groups targeted by exercises
@HiveType(typeId: 12)
enum MuscleGroup {
  @HiveField(0)
  chest,
  
  @HiveField(1)
  shoulders,
  
  @HiveField(2)
  triceps,
  
  @HiveField(3)
  biceps,
  
  @HiveField(4)
  back,
  
  @HiveField(5)
  forearms,
  
  @HiveField(6)
  quads,
  
  @HiveField(7)
  hamstrings,
  
  @HiveField(8)
  calves,
  
  @HiveField(9)
  glutes,
  
  @HiveField(10)
  abs,
  
  @HiveField(11)
  obliques,
  
  @HiveField(12)
  lowerBack,
  
  @HiveField(13)
  cardio,
}