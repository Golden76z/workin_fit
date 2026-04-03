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
}
