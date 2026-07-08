import 'package:workin_fit/models/enums.dart';

/// A single daily challenge shown on the home screen.
///
/// Challenges are defined statically in [DailyChallengesCatalog] and do not
/// require Hive caching — only completion state is persisted (in Firestore).
class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final DailyChallengeType type;
  final DifficultyLevel difficulty;

  /// Target value: reps, seconds, or session count.
  final int target;

  /// Human-readable unit: 'reps', 'seconds', or 'sessions'.
  final String unit;

  /// Exercise ID for [DailyChallengeType.exercise] challenges; null otherwise.
  final String? exerciseId;

  /// Session ID for [DailyChallengeType.session] challenges; null otherwise.
  final String? sessionId;

  /// Points awarded on completion (for future gamification use).
  final int rewardPoints;

  const DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.target,
    required this.unit,
    this.exerciseId,
    this.sessionId,
    this.rewardPoints = 10,
  });

  /// Build a challenge from a Firestore document map. [id] overrides any `id`
  /// field with the document id when provided. Enum fields fall back to sane
  /// defaults for forward compatibility.
  factory DailyChallenge.fromFirestore(
    Map<String, dynamic> data, {
    String? id,
  }) {
    return DailyChallenge(
      id: id ?? data['id'] as String,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      type: DailyChallengeType.values.firstWhere(
        (DailyChallengeType t) => t.name == (data['type'] as String?),
        orElse: () => DailyChallengeType.exercise,
      ),
      difficulty: DifficultyLevel.values.firstWhere(
        (DifficultyLevel d) => d.name == (data['difficulty'] as String?),
        orElse: () => DifficultyLevel.beginner,
      ),
      target: (data['target'] as num?)?.toInt() ?? 0,
      unit: data['unit'] as String? ?? 'reps',
      exerciseId: data['exerciseId'] as String?,
      sessionId: data['sessionId'] as String?,
      rewardPoints: (data['rewardPoints'] as num?)?.toInt() ?? 10,
    );
  }

  /// Serialize for writing to Firestore (the `id` is the document id and is
  /// omitted from the payload).
  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'title': title,
      'description': description,
      'type': type.name,
      'difficulty': difficulty.name,
      'target': target,
      'unit': unit,
      'exerciseId': exerciseId,
      'sessionId': sessionId,
      'rewardPoints': rewardPoints,
    };
  }

  DailyChallenge copyWith({
    String? id,
    String? title,
    String? description,
    DailyChallengeType? type,
    DifficultyLevel? difficulty,
    int? target,
    String? unit,
    String? exerciseId,
    String? sessionId,
    int? rewardPoints,
  }) {
    return DailyChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      target: target ?? this.target,
      unit: unit ?? this.unit,
      exerciseId: exerciseId ?? this.exerciseId,
      sessionId: sessionId ?? this.sessionId,
      rewardPoints: rewardPoints ?? this.rewardPoints,
    );
  }
}
