import 'package:hive/hive.dart';
import 'package:workin_fit/models/enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout_config.g.dart';

@JsonSerializable()
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

  // JSON serialization
  factory WorkoutConfig.fromJson(Map<String, dynamic> json) {
    // Dispatch to correct subclass based on type
    final type = WorkoutType.values.byName(json['type']);
    switch (type) {
      case WorkoutType.sets:
        return SetsConfig.fromJson(json);
      case WorkoutType.tabata:
        return TabataConfig.fromJson(json);
      case WorkoutType.timed:
        return TimedConfig.fromJson(json);
    }
  }

  Map<String, dynamic> toJson() => _$WorkoutConfigToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 3)
class SetsConfig extends WorkoutConfig {
  @HiveField(2)
  final int sets;
  
  @HiveField(3)
  final int reps;
  
  @HiveField(4)
  final int restBetweenSets;
  
  @HiveField(5)
  final double? weight;
  
  @HiveField(6)
  final String? weightUnit;

  SetsConfig({
    required super.exerciseId,
    required this.sets,
    required this.reps,
    this.restBetweenSets = 60,
    this.weight,
    this.weightUnit,
  }) : super(type: WorkoutType.sets);

  /// Total volume calculation
  int get totalReps => sets * reps;
  
  /// Estimated duration in seconds (excluding rest)
  /// Assumes ~3 seconds per rep
  int get estimatedWorkDuration => totalReps * 3;
  
  /// Total rest time in seconds
  int get totalRestTime => (sets - 1) * restBetweenSets;
  
  /// Total estimated time for this exercise
  int get estimatedTotalTime => estimatedWorkDuration + totalRestTime;

  factory SetsConfig.fromJson(Map<String, dynamic> json) => 
      _$SetsConfigFromJson(json);
  
  @override
  Map<String, dynamic> toJson() => _$SetsConfigToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 4)
class TabataConfig extends WorkoutConfig {
  @HiveField(2)
  final int workTime;
  
  @HiveField(3)
  final int restTime;
  
  @HiveField(4)
  final int rounds;

  TabataConfig({
    required super.exerciseId,
    required this.workTime,
    required this.restTime,
    required this.rounds,
  }) : super(type: WorkoutType.tabata);

  /// Total work time in seconds
  int get totalWorkTime => workTime * rounds;
  
  /// Total rest time in seconds
  int get totalRestTime => restTime * rounds;
  
  /// Total duration in seconds
  int get totalDuration => totalWorkTime + totalRestTime;

  factory TabataConfig.fromJson(Map<String, dynamic> json) => 
      _$TabataConfigFromJson(json);
  
  @override
  Map<String, dynamic> toJson() => _$TabataConfigToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 5)
class TimedConfig extends WorkoutConfig {
  @HiveField(2)
  final int duration;

  TimedConfig({
    required super.exerciseId,
    required this.duration,
  }) : super(type: WorkoutType.timed);

  int get totalDuration => duration;

  factory TimedConfig.fromJson(Map<String, dynamic> json) => 
      _$TimedConfigFromJson(json);
  
  @override
  Map<String, dynamic> toJson() => _$TimedConfigToJson(this);
}