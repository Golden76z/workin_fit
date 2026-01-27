import 'package:json_annotation/json_annotation.dart';

part 'program_model.g.dart';

/// Training program definition, composed of multiple sessions.
@JsonSerializable()
class ProgramModel {
  /// Unique program identifier (usually the Firestore document ID).
  final String id;

  /// Display name of the program (e.g. "4-Week Beginner Strength").
  final String name;

  /// Detailed description of the program goals and structure.
  final String description;

  /// Ordered list of session IDs that belong to this program.
  final List<String> sessionIds;

  /// Duration of the program in weeks.
  final int durationWeeks;

  /// Difficulty string such as 'beginner', 'intermediate', or 'advanced'.
  final String difficulty;

  /// High-level goals (e.g. "fat loss", "strength", "mobility").
  final List<String> goals;

  const ProgramModel({
    required this.id,
    required this.name,
    required this.description,
    required this.sessionIds,
    required this.durationWeeks,
    required this.difficulty,
    required this.goals,
  });

  /// Creates a new instance from a JSON map.
  factory ProgramModel.fromJson(Map<String, dynamic> json) =>
      _$ProgramModelFromJson(json);

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() => _$ProgramModelToJson(this);

  /// Firestore helper: create a model from raw Firestore data.
  ///
  /// Optionally allows overriding the `id` with the document ID.
  factory ProgramModel.fromFirestore(
    Map<String, dynamic> data, {
    String? id,
  }) {
    final merged = Map<String, dynamic>.from(data);
    if (id != null) {
      merged['id'] = id;
    }
    return ProgramModel.fromJson(merged);
  }

  /// Firestore helper: convert this model to a map suitable for writing.
  Map<String, dynamic> toFirestore() => toJson();

  /// Returns a copy of this program with the given fields updated.
  ProgramModel copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? sessionIds,
    int? durationWeeks,
    String? difficulty,
    List<String>? goals,
  }) {
    return ProgramModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sessionIds: sessionIds ?? this.sessionIds,
      durationWeeks: durationWeeks ?? this.durationWeeks,
      difficulty: difficulty ?? this.difficulty,
      goals: goals ?? this.goals,
    );
  }
}

