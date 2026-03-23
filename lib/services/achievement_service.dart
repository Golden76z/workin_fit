import 'package:workin_fit/models/achievement.dart';
import 'package:workin_fit/services/firestore_service.dart';

/// Checks user stats against achievement definitions, persists newly unlocked
/// ones, and returns the list of freshly unlocked achievements.
class AchievementService {
  final FirestoreService _db;

  AchievementService(this._db);

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Loads all achievements for [userId] with unlock state.
  ///
  /// Returns every [Achievement] in [kAchievementDefinitions], marking each
  /// as locked or unlocked based on what's stored in Firestore.
  Future<List<Achievement>> loadAchievements(String userId) async {
    final unlockedIds = await _db.getUnlockedAchievementIds(userId);
    return kAchievementDefinitions.map((def) {
      if (unlockedIds.contains(def.id)) {
        return Achievement(definition: def, isUnlocked: true);
      }
      return Achievement(definition: def, isUnlocked: false);
    }).toList();
  }

  /// Fetches current user stats and computes progress for each category.
  ///
  /// Returns a map of [AchievementCategory] → current value.
  Future<Map<AchievementCategory, int>> loadStats(String userId) async {
    final results = await Future.wait([
      _db.getTotalWorkoutCount(userId),
      _db.getTotalDoneReps(userId),
      _db.getProgramsCompleted(userId),
      _db.getStreakData(userId: userId),
    ]);

    final totalWorkouts = results[0] as int;
    final totalReps = results[1] as int;
    final programsDone = results[2] as int;
    final streakData = results[3] as Map<String, dynamic>;
    final bestStreak = streakData['bestStreak'] as int? ?? 0;

    return {
      AchievementCategory.totalWorkouts: totalWorkouts,
      AchievementCategory.exerciseMastery: totalReps,
      AchievementCategory.programsCompleted: programsDone,
      AchievementCategory.streakMilestone: bestStreak,
    };
  }

  /// Checks current stats against all definitions and unlocks any newly earned
  /// achievements. Returns the list of achievements that were just unlocked
  /// (empty if nothing new).
  Future<List<Achievement>> checkAndUnlock(String userId) async {
    final alreadyUnlocked = await _db.getUnlockedAchievementIds(userId);
    final stats = await loadStats(userId);

    final List<Achievement> newlyUnlocked = [];
    final now = DateTime.now();

    for (final def in kAchievementDefinitions) {
      if (alreadyUnlocked.contains(def.id)) continue;

      final current = stats[def.category] ?? 0;
      if (current >= def.targetValue) {
        await _db.unlockAchievement(
          userId: userId,
          achievementId: def.id,
          unlockedAt: now,
        );
        newlyUnlocked.add(Achievement(
          definition: def,
          isUnlocked: true,
          unlockedAt: now,
        ),);
      }
    }

    return newlyUnlocked;
  }
}
