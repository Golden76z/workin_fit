import 'package:json_annotation/json_annotation.dart';

part 'workout_set_model.g.dart';

/// Configuration for a traditional sets-and-reps style workout.
@JsonSerializable()
class WorkoutSetModel {
  /// ID of the exercise this configuration refers to.
  final String exerciseId;

  /// Number of sets to perform.
  final int sets;

  /// Number of repetitions per set.
  final int reps;

  /// Rest time between sets in seconds.
  final int restTime;

  const WorkoutSetModel({
    required this.exerciseId,
    required this.sets,
    required this.reps,
    required this.restTime,
  });

  /// Creates a new instance from a JSON map.
  factory WorkoutSetModel.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSetModelFromJson(json);

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() => _$WorkoutSetModelToJson(this);

  /// Firestore helper: create a model from raw Firestore data.
  factory WorkoutSetModel.fromFirestore(Map<String, dynamic> data) =>
      WorkoutSetModel.fromJson(data);

  /// Firestore helper: convert this model to a map suitable for writing.
  Map<String, dynamic> toFirestore() => toJson();

  /// Returns a copy of this configuration with the given fields updated.
  WorkoutSetModel copyWith({
    String? exerciseId,
    int? sets,
    int? reps,
    int? restTime,
  }) {
    return WorkoutSetModel(
      exerciseId: exerciseId ?? this.exerciseId,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      restTime: restTime ?? this.restTime,
    );
  }
}

