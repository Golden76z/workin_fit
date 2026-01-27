import 'package:json_annotation/json_annotation.dart';

part 'tabata_config_model.g.dart';

/// Configuration for a Tabata-style interval workout.
@JsonSerializable()
class TabataConfigModel {
  /// ID of the exercise this configuration refers to.
  final String exerciseId;

  /// Work interval duration in seconds.
  final int workTime;

  /// Rest interval duration in seconds.
  final int restTime;

  /// Number of work/rest rounds to perform.
  final int rounds;

  const TabataConfigModel({
    required this.exerciseId,
    required this.workTime,
    required this.restTime,
    required this.rounds,
  });

  /// Creates a new instance from a JSON map.
  factory TabataConfigModel.fromJson(Map<String, dynamic> json) =>
      _$TabataConfigModelFromJson(json);

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() => _$TabataConfigModelToJson(this);

  /// Firestore helper: create a model from raw Firestore data.
  factory TabataConfigModel.fromFirestore(Map<String, dynamic> data) =>
      TabataConfigModel.fromJson(data);

  /// Firestore helper: convert this model to a map suitable for writing.
  Map<String, dynamic> toFirestore() => toJson();

  /// Returns a copy of this configuration with the given fields updated.
  TabataConfigModel copyWith({
    String? exerciseId,
    int? workTime,
    int? restTime,
    int? rounds,
  }) {
    return TabataConfigModel(
      exerciseId: exerciseId ?? this.exerciseId,
      workTime: workTime ?? this.workTime,
      restTime: restTime ?? this.restTime,
      rounds: rounds ?? this.rounds,
    );
  }
}

