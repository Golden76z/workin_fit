import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/features/auth/domain/auth_provider.dart';
import 'package:workin_fit/models/leaderboard_entry.dart';
import 'package:workin_fit/providers/friend_providers.dart';
import 'package:workin_fit/services/leaderboard_service.dart';

enum LeaderboardType { streak, workouts }

final leaderboardServiceProvider = Provider<LeaderboardService>(
  (ref) => LeaderboardService(),
);

/// FutureProvider.family keyed by [LeaderboardType].
///
/// Watches [friendsStreamProvider] so the leaderboard automatically
/// re-computes whenever the user's friend list changes.
final friendLeaderboardProvider =
    FutureProvider.family<List<LeaderboardEntry>, LeaderboardType>(
  (ref, type) async {
    // Re-run whenever friends list changes.
    final friends = ref.watch(friendsStreamProvider).valueOrNull ?? [];
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) return [];

    final firestoreService = ref.read(firestoreServiceProvider);
    final profile = await firestoreService.getUserProfile(currentUser.uid);
    final username = profile?['username'] as String? ??
        currentUser.displayName ??
        currentUser.email?.split('@').first ??
        'Me';

    final service = ref.read(leaderboardServiceProvider);

    if (type == LeaderboardType.streak) {
      return service.getStreakLeaderboard(
        currentUserId: currentUser.uid,
        currentUsername: username,
        currentPhotoUrl: currentUser.photoURL,
        friends: friends,
      );
    } else {
      return service.getWorkoutsLeaderboard(
        currentUserId: currentUser.uid,
        currentUsername: username,
        currentPhotoUrl: currentUser.photoURL,
        friends: friends,
      );
    }
  },
);
