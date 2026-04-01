import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/services/sync_service.dart';
import 'package:workin_fit/services/firestore_service.dart';
import 'package:workin_fit/services/local_storage_service.dart';
import 'package:workin_fit/models/active_program_state.dart';
import 'package:workin_fit/models/session.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/program.dart';
import 'package:workin_fit/features/auth/domain/auth_provider.dart';

// ===== SERVICE PROVIDERS =====

final syncServiceProvider = Provider<SyncService>((ref) => SyncService());

final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

final localStorageServiceProvider =
    Provider<LocalStorageService>((ref) => LocalStorageService());

// ===== USER ID PROVIDER =====

/// Current user ID provider (derived from auth state)
final currentUserIdProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.uid;
});

// ===== EXERCISES =====

/// All exercises provider (cache-first strategy)
final exercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final syncService = ref.watch(syncServiceProvider);
  try {
    return await syncService.getExercises();
  } catch (e) {
    // Error handling is done in sync service, returns cached data
    rethrow;
  }
});

/// Exercise by ID provider
final exerciseByIdProvider = FutureProvider.family<Exercise?, String>(
  (ref, exerciseId) async {
    final syncService = ref.watch(syncServiceProvider);
    try {
      return await syncService.getExerciseById(exerciseId);
    } catch (e) {
      // Returns cached if available
      rethrow;
    }
  },
);

/// Search exercises provider
final searchExercisesProvider = FutureProvider.family<List<Exercise>, String>(
  (ref, query) async {
    final syncService = ref.watch(syncServiceProvider);
    if (query.trim().isEmpty) {
      // Return all exercises if query is empty
      return await ref.watch(exercisesProvider.future);
    }
    try {
      return await syncService.searchExercises(query);
    } catch (e) {
      // Fallback to empty list or cached results
      return [];
    }
  },
);

/// Exercises stream provider (real-time updates)
final exercisesStreamProvider = StreamProvider<List<Exercise>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.exercisesStream();
});

// ===== SESSIONS =====

/// User sessions provider (offline-first)
final userSessionsProvider = FutureProvider<List<Session>>((ref) async {
  final syncService = ref.watch(syncServiceProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) return [];

  try {
    return await syncService.getSessions(userId);
  } catch (e) {
    // Returns cached sessions on error
    rethrow;
  }
});

/// Preset sessions used by curated programs.
final presetSessionsProvider = FutureProvider<List<Session>>((ref) async {
  final syncService = ref.watch(syncServiceProvider);
  try {
    return await syncService.getPresetSessions();
  } catch (_) {
    return [];
  }
});

/// Sessions available for programs (preset + user custom sessions).
final programSessionsProvider = FutureProvider<List<Session>>((ref) async {
  List<Session> userSessions = [];
  List<Session> presetSessions = [];
  try {
    userSessions = await ref.watch(userSessionsProvider.future);
  } catch (_) {}
  try {
    presetSessions = await ref.watch(presetSessionsProvider.future);
  } catch (_) {}
  final Map<String, Session> byId = <String, Session>{};
  for (final session in presetSessions) {
    byId[session.id] = session;
  }
  for (final session in userSessions) {
    byId[session.id] = session;
  }
  return byId.values.toList(growable: false);
});

/// Session by ID provider
final sessionByIdProvider = FutureProvider.family<Session?, String>(
  (ref, sessionId) async {
    final firestoreService = ref.watch(firestoreServiceProvider);
    final userId = ref.watch(currentUserIdProvider);

    if (userId == null) return null;

    try {
      return await firestoreService.getSessionById(userId, sessionId);
    } catch (e) {
      // Try cache via sync service
      final syncService = ref.watch(syncServiceProvider);
      final sessions = await syncService.getSessions(userId);
      try {
        return sessions.firstWhere((s) => s.id == sessionId);
      } catch (e) {
        return null;
      }
    }
  },
);

/// User sessions stream provider (real-time updates)
final userSessionsStreamProvider = StreamProvider<List<Session>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    return Stream.value([]);
  }

  return firestoreService.userSessionsStream(userId);
});

/// Session actions provider (CRUD operations)
final sessionActionsProvider =
    Provider<SessionActions>((ref) => SessionActions(ref));

class SessionActions {
  final Ref ref;
  SessionActions(this.ref);

  Future<void> createSession(Session session) async {
    final syncService = ref.read(syncServiceProvider);
    final userId = ref.read(currentUserIdProvider);

    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await syncService.createSession(userId, session);
      // Invalidate providers to refresh data
      ref.invalidate(userSessionsProvider);
      ref.invalidate(userSessionsStreamProvider);
    } catch (e) {
      // Error is handled in sync service, but we can rethrow for UI handling
      rethrow;
    }
  }

  Future<void> updateSession(Session session) async {
    final syncService = ref.read(syncServiceProvider);
    final userId = ref.read(currentUserIdProvider);

    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await syncService.updateSession(userId, session);
      ref.invalidate(userSessionsProvider);
      ref.invalidate(sessionByIdProvider(session.id));
      ref.invalidate(userSessionsStreamProvider);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteSession(String sessionId) async {
    final syncService = ref.read(syncServiceProvider);
    final userId = ref.read(currentUserIdProvider);

    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await syncService.deleteSession(userId, sessionId);
      ref.invalidate(userSessionsProvider);
      ref.invalidate(sessionByIdProvider(sessionId));
      ref.invalidate(userSessionsStreamProvider);
    } catch (e) {
      rethrow;
    }
  }
}

// ===== PROGRAMS =====

/// Programs provider (preset + user's custom programs)
final programsProvider = FutureProvider<List<Program>>((ref) async {
  final syncService = ref.watch(syncServiceProvider);
  final userId = ref.watch(currentUserIdProvider);

  try {
    return await syncService.getPrograms(userId: userId);
  } catch (e) {
    // Returns cached programs on error
    rethrow;
  }
});

/// Program by ID provider
final programByIdProvider = FutureProvider.family<Program?, String>(
  (ref, programId) async {
    final syncService = ref.watch(syncServiceProvider);
    final userId = ref.watch(currentUserIdProvider);

    try {
      return await syncService.getProgramById(programId, userId: userId);
    } catch (e) {
      // Returns cached program if available
      rethrow;
    }
  },
);

/// Subscribe to program updates (real-time stream)
final programStreamProvider = StreamProvider.family<Program?, String>(
  (ref, programId) {
    final firestoreService = ref.watch(firestoreServiceProvider);
    final userId = ref.watch(currentUserIdProvider);

    return firestoreService.subscribeToProgram(programId, userId: userId);
  },
);

/// Program actions provider (CRUD operations)
final programActionsProvider =
    Provider<ProgramActions>((ref) => ProgramActions(ref));

class ProgramActions {
  final Ref ref;
  ProgramActions(this.ref);

  Future<void> createProgram(Program program) async {
    final syncService = ref.read(syncServiceProvider);
    final userId = ref.read(currentUserIdProvider);

    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await syncService.createProgram(userId, program);
      ref.invalidate(programsProvider);
      ref.invalidate(programByIdProvider(program.id));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProgram(Program program) async {
    final syncService = ref.read(syncServiceProvider);
    final userId = ref.read(currentUserIdProvider);

    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await syncService.updateProgram(userId, program);
      ref.invalidate(programsProvider);
      ref.invalidate(programByIdProvider(program.id));
      ref.invalidate(programStreamProvider(program.id));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProgram(String programId) async {
    final syncService = ref.read(syncServiceProvider);
    final userId = ref.read(currentUserIdProvider);

    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await syncService.deleteProgram(userId, programId);
      ref.invalidate(programsProvider);
      ref.invalidate(programByIdProvider(programId));
    } catch (e) {
      rethrow;
    }
  }
}

// ===== ACTIVE PROGRAM & SESSION TRACKING =====

/// Active program subscription state persisted in Firestore user profile.
final activeProgramStateProvider = StreamProvider<ActiveProgramState?>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    return Stream.value(null);
  }

  return firestoreService.activeProgramStateStream(userId);
});

/// Active program actions (subscribe / unsubscribe).
final activeProgramActionsProvider = Provider<ActiveProgramActions>(
  (ref) => ActiveProgramActions(ref),
);

class ActiveProgramActions {
  final Ref ref;
  ActiveProgramActions(this.ref);

  Future<void> subscribe({
    required String programId,
    required DateTime startDate,
  }) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await ref.read(firestoreServiceProvider).subscribeUserToProgram(
          userId: userId,
          programId: programId,
          startDate: startDate,
        );

    ref.invalidate(activeProgramStateProvider);
  }

  Future<void> unsubscribe() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await ref.read(firestoreServiceProvider).unsubscribeUserFromProgram(userId);
    ref.invalidate(activeProgramStateProvider);
  }
}

/// Session IDs the user has started today (in-memory, resets on restart)
final completedTodaySessionIdsProvider =
    StateProvider<Set<String>>((ref) => const {});

// ===== STREAK =====

/// Streak data derived from the user's workout history.
/// Returns a map with keys: currentStreak, bestStreak, lastSevenDays.
final streakDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final String? userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return <String, dynamic>{
      'currentStreak': 0,
      'bestStreak': 0,
      'lastSevenDays': List<bool>.filled(7, false),
    };
  }
  final FirestoreService firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getStreakData(userId: userId);
});

// ===== SYNC OPERATIONS =====

/// Sync pending changes provider
final syncPendingChangesProvider = FutureProvider<void>((ref) async {
  final syncService = ref.watch(syncServiceProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) return;

  try {
    await syncService.syncPendingChanges(userId);
    // Invalidate all providers to refresh data
    ref.invalidate(userSessionsProvider);
    ref.invalidate(programsProvider);
  } catch (e) {
    // Error is logged in sync service
    rethrow;
  }
});

/// Manual sync action provider
final syncActionsProvider = Provider<SyncActions>((ref) => SyncActions(ref));

class SyncActions {
  final Ref ref;
  SyncActions(this.ref);

  Future<void> syncNow() async {
    final syncService = ref.read(syncServiceProvider);
    final userId = ref.read(currentUserIdProvider);

    if (userId == null) return;

    try {
      await syncService.syncPendingChanges(userId);
      // Invalidate providers to refresh
      ref.invalidate(userSessionsProvider);
      ref.invalidate(programsProvider);
      ref.invalidate(exercisesProvider);
    } catch (e) {
      rethrow;
    }
  }
}
