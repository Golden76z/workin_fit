import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/features/auth/domain/auth_provider.dart';
import 'package:workin_fit/models/achievement.dart';
import 'package:workin_fit/services/achievement_service.dart';

final achievementServiceProvider = Provider<AchievementService>(
  (ref) => AchievementService(ref.read(firestoreServiceProvider)),
);

/// All achievements with unlock status for the current user.
final achievementsProvider =
    FutureProvider.autoDispose<List<Achievement>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.read(achievementServiceProvider).loadAchievements(user.uid);
});

/// Current stat values per category (used for progress display).
final achievementStatsProvider =
    FutureProvider.autoDispose<Map<AchievementCategory, int>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return {};
  return ref.read(achievementServiceProvider).loadStats(user.uid);
});
