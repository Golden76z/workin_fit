import 'package:hive/hive.dart';
import 'package:workin_fit/models/enums.dart';

part 'program.g.dart';

@HiveType(typeId: 6)
class Program extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String description;
  
  /// List of session IDs in order
  @HiveField(3)
  final List<String> sessionIds;
  
  /// Duration in weeks
  @HiveField(4)
  final int durationWeeks;
  
  /// Difficulty level
  @HiveField(5)
  final DifficultyLevel difficulty;
  
  /// Program goals/objectives
  @HiveField(6)
  final List<String> goals;
  
  /// Days per week
  @HiveField(7)
  final int daysPerWeek;
  
  /// Image URL for program
  @HiveField(8)
  final String? imageUrl;
  
  /// Whether this is a custom program
  @HiveField(9)
  final bool isCustom;
  
  /// User ID if custom program
  @HiveField(10)
  final String? userId;
  
  @HiveField(11)
  final DateTime createdAt;

  Program({
    required this.id,
    required this.name,
    required this.description,
    required this.sessionIds,
    required this.durationWeeks,
    required this.difficulty,
    required this.goals,
    required this.daysPerWeek,
    this.imageUrl,
    this.isCustom = false,
    this.userId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Total number of sessions in program
  int get totalSessions => sessionIds.length;
  
  /// Total duration in days
  int get totalDays => durationWeeks * 7;
}