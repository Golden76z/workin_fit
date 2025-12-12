import 'package:hive/hive.dart';

// The way you want to practice a specific exercice
@HiveType(typeId: 10)
enum WorkOutType {
  @HiveField(0)
  sets,

  @HiveField(1)
  tabata,

  @HiveField(2)
  timed,
}

// Rank of difficulty of exercices (easier recommandations)
@HiveType(typeId: 11)
enum DifficultyLevel {
  @HiveField(0)
  beginner,

  @HiveField(1)
  intermediate,

  @HiveField(2)
  advanced,
}

// Global area for filters and informations
@HiveType(typeId: 12)
enum MuscleCategory {
  // Upper body
  @HiveField(0)
  neck,
  @HiveField(1)
  chest,
  @HiveField(2)
  shoulders,
  @HiveField(3)
  back,

  // Arms
  @HiveField(4)
  biceps,
  @HiveField(5)
  triceps,
  @HiveField(6)
  forearms,

  // Lower trunc
  @HiveField(7)
  abs,
  @HiveField(8)
  glutes,

  // Legs fields
  @HiveField(9)
  quads,
  @HiveField(10)
  hamstrings,
  @HiveField(11)
  calves,

  // Global
  @HiveField(12)
  core,
  @HiveField(13)
  cardio,
}

@HiveType(typeId: 13)
class Muscle {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String commonName;  // For user display
  
  @HiveField(3)
  final MuscleCategory category;
  
  @HiveField(4)
  final bool isPrimary;  // Primary vs secondary muscle
  
  Muscle({
    required this.id,
    required this.name,
    required this.commonName,
    required this.category,
    this.isPrimary = false,
  });
}