import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workin_fit/core/constants/app_constants.dart';
import 'package:workin_fit/models/friend.dart';
import 'package:workin_fit/models/leaderboard_entry.dart';
import 'package:workin_fit/services/firestore_service.dart';

/// Fetches leaderboard data for the current user and their friends.
///
/// NOTE: This reads other users' subcollections. Ensure Firestore security
/// rules allow authenticated users to read any user's workout_history and
/// exercise_monthly collections (or scope to friends only server-side).
class LeaderboardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Returns a streak leaderboard for the current user + their friends,
  /// sorted by current streak descending, with ranks assigned.
  Future<List<LeaderboardEntry>> getStreakLeaderboard({
    required String currentUserId,
    required String currentUsername,
    required List<Friend> friends,
    String? currentPhotoUrl,
  }) async {
    final entries = await Future.wait([
      _fetchStreakEntry(
        userId: currentUserId,
        username: currentUsername,
        photoUrl: currentPhotoUrl,
        isCurrentUser: true,
      ),
      ...friends.map(
        (f) => _fetchStreakEntry(
          userId: f.userId,
          username: f.username,
          photoUrl: f.photoUrl,
          isCurrentUser: false,
        ),
      ),
    ]);

    return _rank(entries);
  }

  /// Returns a total-workouts leaderboard for the current user + their friends,
  /// sorted by total workout count descending, with ranks assigned.
  Future<List<LeaderboardEntry>> getWorkoutsLeaderboard({
    required String currentUserId,
    required String currentUsername,
    required List<Friend> friends,
    String? currentPhotoUrl,
  }) async {
    final entries = await Future.wait([
      _fetchWorkoutsEntry(
        userId: currentUserId,
        username: currentUsername,
        photoUrl: currentPhotoUrl,
        isCurrentUser: true,
      ),
      ...friends.map(
        (f) => _fetchWorkoutsEntry(
          userId: f.userId,
          username: f.username,
          photoUrl: f.photoUrl,
          isCurrentUser: false,
        ),
      ),
    ]);

    return _rank(entries);
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<_RawEntry> _fetchStreakEntry({
    required String userId,
    required String username,
    required bool isCurrentUser,
    String? photoUrl,
  }) async {
    try {
      // Reuse the shared streak logic via FirestoreService.
      final streak = await FirestoreService().getStreakData(userId: userId);
      final value = streak['currentStreak'] as int? ?? 0;
      return _RawEntry(
        userId: userId,
        username: username,
        photoUrl: photoUrl,
        value: value,
        isCurrentUser: isCurrentUser,
      );
    } catch (_) {
      return _RawEntry(
        userId: userId,
        username: username,
        photoUrl: photoUrl,
        value: 0,
        isCurrentUser: isCurrentUser,
      );
    }
  }

  Future<_RawEntry> _fetchWorkoutsEntry({
    required String userId,
    required String username,
    required bool isCurrentUser,
    String? photoUrl,
  }) async {
    try {
      final value = await _countTotalWorkouts(userId);
      return _RawEntry(
        userId: userId,
        username: username,
        photoUrl: photoUrl,
        value: value,
        isCurrentUser: isCurrentUser,
      );
    } catch (_) {
      return _RawEntry(
        userId: userId,
        username: username,
        photoUrl: photoUrl,
        value: 0,
        isCurrentUser: isCurrentUser,
      );
    }
  }

  /// Sums `totalWorkouts` across all exercise_monthly documents for a user.
  /// This is cheaper than fetching every workout_history document.
  Future<int> _countTotalWorkouts(String userId) async {
    final snapshot = await _db
        .collection(FirebaseConstants.usersCollection)
        .doc(userId)
        .collection(FirebaseConstants.exerciseMonthlyCollection)
        .get();

    int total = 0;
    for (final doc in snapshot.docs) {
      total += (doc.data()['totalWorkouts'] as num?)?.toInt() ?? 0;
    }
    return total;
  }

  /// Sorts raw entries by value descending and assigns rank (ties share rank).
  List<LeaderboardEntry> _rank(List<_RawEntry> raw) {
    final sorted = List<_RawEntry>.from(raw)
      ..sort((a, b) => b.value.compareTo(a.value));

    final List<LeaderboardEntry> result = [];
    int rank = 1;
    for (int i = 0; i < sorted.length; i++) {
      // Ties get the same rank; next distinct value skips ranks.
      if (i > 0 && sorted[i].value < sorted[i - 1].value) {
        rank = i + 1;
      }
      result.add(LeaderboardEntry(
        userId: sorted[i].userId,
        username: sorted[i].username,
        value: sorted[i].value,
        rank: rank,
        isCurrentUser: sorted[i].isCurrentUser,
        photoUrl: sorted[i].photoUrl,
      ),);
    }
    return result;
  }
}

class _RawEntry {
  final String userId;
  final String username;
  final String? photoUrl;
  final int value;
  final bool isCurrentUser;

  const _RawEntry({
    required this.userId,
    required this.username,
    required this.value,
    required this.isCurrentUser,
    this.photoUrl,
  });
}
