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
    // Get the type; fall back to field-inference for legacy Firestore docs
    // that were stored without the 'type' field.
    final rawType = json['type'] as String?;
    WorkoutType type;
    if (rawType != null) {
      type = WorkoutType.values.byName(rawType);
    } else if (json.containsKey('exercises')) {
      type = WorkoutType.circuit;
    } else if (json.containsKey('workTime') || json.containsKey('rounds')) {
      type = WorkoutType.tabata;
    } else if (json.containsKey('duration') && !json.containsKey('reps')) {
      type = WorkoutType.timed;
    } else {
      type = WorkoutType.sets;
    }

    switch (type) {
      case WorkoutType.sets:
        return SetsConfig.fromJson(json);
      case WorkoutType.tabata:
        return TabataConfig.fromJson(json);
      case WorkoutType.timed:
        return TimedConfig.fromJson(json);
      case WorkoutType.circuit:
        return CircuitConfig.fromJson(json);
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
  Map<String, dynamic> toJson() {
    final json = _$SetsConfigToJson(this);
    json['type'] = type.name;
    return json;
  }
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

  @HiveField(5)
  final int sets;

  @HiveField(6)
  final int restBetweenSets;

  TabataConfig({
    required super.exerciseId,
    required this.workTime,
    required this.restTime,
    required this.rounds,
    this.sets = 1,
    this.restBetweenSets = 60,
  }) : super(type: WorkoutType.tabata);

  /// Total work time per set in seconds
  int get totalWorkTime => workTime * rounds;

  /// Total rest time per set in seconds
  int get totalRestTime => restTime * rounds;

  /// Duration of a single set in seconds
  int get singleSetDuration => totalWorkTime + totalRestTime;

  /// Total duration in seconds (all sets + rest between sets)
  int get totalDuration {
    if (sets <= 1) return singleSetDuration;
    return (singleSetDuration * sets) + ((sets - 1) * restBetweenSets);
  }

  factory TabataConfig.fromJson(Map<String, dynamic> json) =>
      _$TabataConfigFromJson(json);

  @override
  Map<String, dynamic> toJson() {
    final json = _$TabataConfigToJson(this);
    json['type'] = type.name;
    return json;
  }
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
  Map<String, dynamic> toJson() {
    final json = _$TimedConfigToJson(this);
    json['type'] = type.name;
    return json;
  }
}

/// A circuit: a list of exercises performed back-to-back, repeated [rounds] times.
/// [exerciseId] is set to '' since a circuit has no single exercise.
@HiveType(typeId: 7)
class CircuitConfig extends WorkoutConfig {
  /// Display name for the circuit (e.g. "Cardio Blast").
  @HiveField(2)
  final String name;

  /// The exercises inside one loop of this circuit.
  @HiveField(3)
  final List<WorkoutConfig> exercises;

  /// How many full loops of the exercise list to perform.
  @HiveField(4)
  final int rounds;

  /// Rest between individual exercises within a single round (seconds).
  @HiveField(5)
  final int restBetweenExercises;

  /// Rest between full rounds (seconds).
  @HiveField(6)
  final int restBetweenRounds;

  CircuitConfig({
    required this.name,
    required this.exercises,
    required this.rounds,
    this.restBetweenExercises = 0,
    this.restBetweenRounds = 60,
  }) : super(exerciseId: '', type: WorkoutType.circuit);

  /// Total duration estimate in seconds.
  int get totalDuration {
    int perRound = 0;
    for (final ex in exercises) {
      if (ex is SetsConfig) {
        perRound += ex.estimatedTotalTime;
      } else if (ex is TabataConfig) {
        perRound += ex.totalDuration;
      } else if (ex is TimedConfig) {
        perRound += ex.totalDuration;
      }
      perRound += restBetweenExercises;
    }
    // Remove one trailing rest-between-exercises from the last exercise.
    if (exercises.isNotEmpty) perRound -= restBetweenExercises;

    final int roundRestTotal = (rounds - 1) * restBetweenRounds;
    return perRound * rounds + roundRestTotal;
  }

  factory CircuitConfig.fromJson(Map<String, dynamic> json) {
    final exercisesRaw = json['exercises'] as List<dynamic>? ?? [];
    return CircuitConfig(
      name: json['name'] as String? ?? 'Circuit',
      exercises: exercisesRaw
          .map((e) => WorkoutConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
      rounds: (json['rounds'] as num?)?.toInt() ?? 3,
      restBetweenExercises:
          (json['restBetweenExercises'] as num?)?.toInt() ?? 0,
      restBetweenRounds: (json['restBetweenRounds'] as num?)?.toInt() ?? 60,
    );
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type.name,
        'name': name,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'rounds': rounds,
        'restBetweenExercises': restBetweenExercises,
        'restBetweenRounds': restBetweenRounds,
      };
}