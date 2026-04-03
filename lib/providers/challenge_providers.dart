import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/data/daily_challenges_catalog.dart';
import 'package:workin_fit/models/daily_challenge.dart';
import 'package:workin_fit/providers/workout_providers.dart';
import 'package:workin_fit/services/firestore_service.dart';

/// Today's 3 challenges derived from the catalog — no network call required.
final todaysChallengesProvider = Provider<List<DailyChallenge>>((ref) {
  return DailyChallengesCatalog.forDate(DateTime.now());
});

/// Completion state for a specific challenge ID for the current user today.
/// Returns true if the challenge has been marked complete, false otherwise.
final challengeCompletionProvider =
    FutureProvider.family<bool, String>((ref, challengeId) async {
  final String? userId = ref.watch(currentUserIdProvider);
  if (userId == null) return false;
  final FirestoreService firestore = ref.watch(firestoreServiceProvider);
  try {
    return await firestore.getChallengeCompletion(
      userId: userId,
      challengeId: challengeId,
      date: DateTime.now(),
    );
  } catch (_) {
    return false;
  }
});

/// Actions: mark a challenge as completed or uncompleted.
final challengeActionsProvider =
    Provider<ChallengeActions>((ref) => ChallengeActions(ref));

class ChallengeActions {
  final Ref ref;
  ChallengeActions(this.ref);

  Future<void> markCompleted(String challengeId) async {
    final String? userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    await ref.read(firestoreServiceProvider).setChallengeCompleted(
          userId: userId,
          challengeId: challengeId,
          date: DateTime.now(),
          completed: true,
        );
    ref.invalidate(challengeCompletionProvider(challengeId));
  }

  Future<void> markUncompleted(String challengeId) async {
    final String? userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    await ref.read(firestoreServiceProvider).setChallengeCompleted(
          userId: userId,
          challengeId: challengeId,
          date: DateTime.now(),
          completed: false,
        );
    ref.invalidate(challengeCompletionProvider(challengeId));
  }
}
