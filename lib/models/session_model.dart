import 'package:json_annotation/json_annotation.dart';

import 'tabata_config_model.dart';
import 'workout_set_model.dart';

part 'session_model.g.dart';

/// High-level workout session definition used for Firestore and APIs.
///
/// This model is separate from the Hive-backed `Session` in `session.dart`
/// and focuses on JSON-serializable fields only.
@JsonSerializable(explicitToJson: true)
class SessionModel {
  /// Unique session identifier (usually the Firestore document ID).
  final String id;

  /// Display name of the session (e.g. "Full Body Starter").
  final String name;

  /// Optional rich description of the session.
  final String? description;

  /// Mixed list of set-based and Tabata workouts.
  ///
  /// Each entry is stored as a JSON map produced by either
  /// [WorkoutSetModel.toJson] or [TabataConfigModel.toJson].
  final List<Map<String, dynamic>> exercises;

  /// Estimated duration of the session in seconds.
  final int duration;

  /// Difficulty string such as 'beginner', 'intermediate', or 'advanced'.
  final String difficulty;

  const SessionModel({
    required this.id,
    required this.name,
    required this.exercises,
    required this.duration,
    required this.difficulty,
    this.description,
  });

  /// Creates a new instance from a JSON map.
  factory SessionModel.fromJson(Map<String, dynamic> json) =>
      _$SessionModelFromJson(json);

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() => _$SessionModelToJson(this);

  /// Firestore helper: create a model from raw Firestore data.
  ///
  /// Optionally allows overriding the `id` with the document ID.
  factory SessionModel.fromFirestore(
    Map<String, dynamic> data, {
    String? id,
  }) {
    final merged = Map<String, dynamic>.from(data);
    if (id != null) {
      merged['id'] = id;
    }
    return SessionModel.fromJson(merged);
  }

  /// Firestore helper: convert this model to a map suitable for writing.
  Map<String, dynamic> toFirestore() => toJson();

  /// Returns a copy of this session with the given fields updated.
  SessionModel copyWith({
    String? id,
    String? name,
    String? description,
    List<Map<String, dynamic>>? exercises,
    int? duration,
    String? difficulty,
  }) {
    return SessionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      duration: duration ?? this.duration,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  /// Helper to map exercises into strongly-typed models.
  ///
  /// This is useful when you know whether you expect a set-based or Tabata
  /// configuration for a given index.
  WorkoutSetModel asWorkoutSet(int index) =>
      WorkoutSetModel.fromJson(exercises[index]);

  /// Helper to map exercises into strongly-typed Tabata configs.
  TabataConfigModel asTabataConfig(int index) =>
      TabataConfigModel.fromJson(exercises[index]);
}

