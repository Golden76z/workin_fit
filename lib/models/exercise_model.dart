import 'package:json_annotation/json_annotation.dart';

part 'exercise_model.g.dart';

/// Core exercise data used for Firestore and API serialization.
///
/// This model is intentionally simple and uses only JSON‑friendly types.
/// For richer domain logic or local persistence see the existing `Exercise`
/// Hive model in `exercise.dart`.
@JsonSerializable()
class ExerciseModel {
  /// Unique exercise identifier (usually the Firestore document ID).
  final String id;

  /// Display name of the exercise (e.g. "Push Up").
  final String name;

  /// Description of how to perform the exercise safely and effectively.
  final String description;

  /// Targeted muscle groups, stored as simple strings
  /// (e.g. "chest", "triceps", "shoulders").
  final List<String> muscleGroups;

  /// URL to an image or GIF demonstrating the exercise.
  final String imageUrl;

  /// Difficulty string such as 'beginner', 'intermediate', or 'advanced'.
  final String difficulty;

  /// Optional extra tips, cues, or coaching notes.
  final String? tips;

  const ExerciseModel({
    required this.id,
    required this.name,
    required this.description,
    required this.muscleGroups,
    required this.imageUrl,
    required this.difficulty,
    this.tips,
  });

  /// Creates a new instance from a JSON map.
  factory ExerciseModel.fromJson(Map<String, dynamic> json) =>
      _$ExerciseModelFromJson(json);

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() => _$ExerciseModelToJson(this);

  /// Firestore helper: create a model from raw Firestore data.
  ///
  /// Optionally allows overriding the `id` with the document ID.
  factory ExerciseModel.fromFirestore(
    Map<String, dynamic> data, {
    String? id,
  }) {
    final merged = Map<String, dynamic>.from(data);
    if (id != null) {
      merged['id'] = id;
    }
    return ExerciseModel.fromJson(merged);
  }

  /// Firestore helper: convert this model to a map suitable for writing.
  Map<String, dynamic> toFirestore() => toJson();

  /// Returns a copy of this exercise with the given fields updated.
  ExerciseModel copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? muscleGroups,
    String? imageUrl,
    String? difficulty,
    String? tips,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      imageUrl: imageUrl ?? this.imageUrl,
      difficulty: difficulty ?? this.difficulty,
      tips: tips ?? this.tips,
    );
  }
}

