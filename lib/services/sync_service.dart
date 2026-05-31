import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:workin_fit/data/preset_program_catalog.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/session.dart';
import 'package:workin_fit/models/program.dart';
import 'package:workin_fit/services/firestore_service.dart';
import 'package:workin_fit/services/local_storage_service.dart';

class SyncService {
  static const Duration _exerciseBackgroundSyncMinInterval = Duration(minutes: 15);

  final FirestoreService _firestoreService;
  final LocalStorageService _localService;
  final Connectivity _connectivity;

  bool _exerciseBackgroundSyncInFlight = false;
  DateTime? _lastExerciseBackgroundSyncAt;

  SyncService({
    FirestoreService? firestoreService,
    LocalStorageService? localService,
    Connectivity? connectivity,
  })  : _firestoreService = firestoreService ?? FirestoreService(),
        _localService = localService ?? LocalStorageService(),
        _connectivity = connectivity ?? Connectivity();

  // ===== SESSIONS =====

  /// Get sessions (offline-first)
  Future<List<Session>> getSessions(String userId) async {
    try {
      // Check connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      final isOnline =
          connectivityResult.any((r) => r != ConnectivityResult.none);

      if (isOnline) {
        // Fetch from Firestore
        final sessions = await _firestoreService.getSessions(userId);

        // Cache locally
        for (var session in sessions) {
          await _localService.saveSessionLocally(session);
        }

        return sessions;
      } else {
        // Return cached data
        return await _localService.getLocalSessions();
      }
    } catch (e, st) {
      debugPrint('[SyncService.getSessions] ERROR: $e\n$st');
      return await _localService.getLocalSessions();
    }
  }

  /// Create session (with offline support)
  Future<void> createSession(String userId, Session session) async {
    // Save locally first
    await _localService.saveSessionLocally(session);

    try {
      // Check connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      final isOnline =
          connectivityResult.any((r) => r != ConnectivityResult.none);

      if (isOnline) {
        // Sync to Firestore
        await _firestoreService.createSession(userId, session);
        // Clear sync flag if successful
        await _localService.clearSyncItem(session.id, 'session');
      } else {
        // Mark for sync when online
        await _localService.markForSync(session.id, 'session');
      }
    } catch (e) {
      // Queue for sync on error
      await _localService.markForSync(session.id, 'session');
      rethrow;
    }
  }

  /// Update session
  Future<void> updateSession(String userId, Session session) async {
    await _localService.saveSessionLocally(session);

    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      final isOnline =
          connectivityResult.any((r) => r != ConnectivityResult.none);

      if (isOnline) {
        await _firestoreService.updateSession(userId, session);
        await _localService.clearSyncItem(session.id, 'session');
      } else {
        await _localService.markForSync(session.id, 'session');
      }
    } catch (e) {
      await _localService.markForSync(session.id, 'session');
      rethrow;
    }
  }

  /// Delete session
  Future<void> deleteSession(String userId, String sessionId) async {
    await _localService.deleteLocalSession(sessionId);

    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      final isOnline =
          connectivityResult.any((r) => r != ConnectivityResult.none);

      if (isOnline) {
        await _firestoreService.deleteSession(userId, sessionId);
      }
    } catch (e) {
      print('Error deleting session online: $e');
    }
  }

  /// Sync pending changes (sessions and programs)
  Future<void> syncPendingChanges(String userId) async {
    final connectivityResult = await _connectivity.checkConnectivity();
    final isOnline =
        connectivityResult.any((r) => r != ConnectivityResult.none);

    if (!isOnline) return;

    try {
      final pendingItems = await _localService.getPendingSync();

      for (var item in pendingItems) {
        final itemId = item['id'] as String;
        final itemType = item['type'] as String;

        try {
          if (itemType == 'session') {
            final session = await _localService.getLocalSession(itemId);
            if (session != null) {
              // Check if it exists in Firestore to determine create vs update
              final existing =
                  await _firestoreService.getSessionById(userId, itemId);
              if (existing == null) {
                await _firestoreService.createSession(userId, session);
              } else {
                await _firestoreService.updateSession(userId, session);
              }
              await _localService.clearSyncItem(itemId, 'session');
            }
          } else if (itemType == 'program') {
            final program = await _localService.getLocalProgram(itemId);
            if (program != null) {
              final existing = await _firestoreService.getProgramById(itemId,
                  userId: userId);
              if (existing == null) {
                await _firestoreService.createProgram(userId, program);
              } else {
                await _firestoreService.updateProgram(userId, program);
              }
              await _localService.clearSyncItem(itemId, 'program');
            }
          }
        } catch (e) {
          // Continue with other items even if one fails
          // The item will remain in sync queue for next attempt
        }
      }
    } catch (e) {
      // Log error but don't throw - sync can retry later
    }
  }

  // ===== EXERCISES (CACHE-FIRST) =====

  /// Returns Hive cache immediately when available; may refresh from Firestore
  /// in the background (throttled, only when the catalog actually changed).
  Future<List<Exercise>> getExercises({void Function()? onCacheUpdated}) async {
    final List<Exercise> cached = await _localService.getCachedExercises();
    if (cached.isNotEmpty) {
      unawaited(
        _refreshExercisesFromRemoteIfStale(onCacheUpdated: onCacheUpdated),
      );
      return cached;
    }
    return _fetchExercisesFromRemoteOrCache();
  }

  /// Forces a Firestore fetch and cache refresh (e.g. pull-to-refresh).
  Future<List<Exercise>> refreshExercises() async {
    _lastExerciseBackgroundSyncAt = DateTime.now();
    return _fetchExercisesFromRemoteOrCache();
  }

  Future<List<Exercise>> _fetchExercisesFromRemoteOrCache() async {
    try {
      final List<Exercise> remote = await _firestoreService.getExercises();
      if (remote.isNotEmpty) {
        await _localService.cacheExercises(remote);
        if (kDebugMode) {
          debugPrint(
            '[SyncService] exercises synced from Firestore (${remote.length})',
          );
        }
        return remote;
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[SyncService] Firestore exercises failed: $e\n$st');
      }
    }
    return _localService.getCachedExercises();
  }

  Future<void> _refreshExercisesFromRemoteIfStale({
    void Function()? onCacheUpdated,
  }) async {
    if (_exerciseBackgroundSyncInFlight) return;

    final DateTime now = DateTime.now();
    if (_lastExerciseBackgroundSyncAt != null &&
        now.difference(_lastExerciseBackgroundSyncAt!) <
            _exerciseBackgroundSyncMinInterval) {
      return;
    }

    _exerciseBackgroundSyncInFlight = true;
    try {
      final List<Exercise> cached = await _localService.getCachedExercises();
      final List<Exercise> remote = await _firestoreService.getExercises();
      if (remote.isEmpty) return;

      _lastExerciseBackgroundSyncAt = now;

      if (!_remoteHasExercisesNotInCache(cached, remote)) {
        return;
      }

      final int added = await _localService.mergeCachedExercises(remote);
      if (added == 0) return;

      if (kDebugMode) {
        debugPrint('[SyncService] merged $added new exercise(s) from Firestore');
      }
      onCacheUpdated?.call();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SyncService] background exercise sync failed: $e');
      }
    } finally {
      _exerciseBackgroundSyncInFlight = false;
    }
  }

  static bool _remoteHasExercisesNotInCache(
    List<Exercise> cached,
    List<Exercise> remote,
  ) {
    if (remote.isEmpty) return false;
    final Set<String> cachedIds =
        cached.map((Exercise e) => e.id).toSet();
    return remote.any((Exercise e) => !cachedIds.contains(e.id));
  }

  /// Get exercise by ID
  Future<Exercise?> getExerciseById(
    String id, {
    void Function()? onCacheUpdated,
  }) async {
    try {
      // Try cache first
      final cached = await _localService.getCachedExercise(id);
      if (cached != null) {
        // If missing locally but present remotely, merge in background
        _firestoreService.getExerciseById(id).then((exercise) async {
          if (exercise == null) return;
          final added = await _localService.mergeCachedExercises([exercise]);
          if (added > 0) {
            onCacheUpdated?.call();
          }
        }).catchError((_) {
          // Silent fail for background refresh
        });
        return cached;
      }

      // Not in cache, fetch from Firestore
      final exercise = await _firestoreService.getExerciseById(id);
      if (exercise != null) {
        await _localService.mergeCachedExercises([exercise]);
      }
      return exercise;
    } catch (e) {
      // Fallback to cache
      return await _localService.getCachedExercise(id);
    }
  }

  /// Search exercises
  Future<List<Exercise>> searchExercises(String query) async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      final isOnline =
          connectivityResult.any((r) => r != ConnectivityResult.none);

      if (isOnline) {
        return await _firestoreService.searchExercises(query);
      } else {
        // Search in cache
        final cached = await _localService.getCachedExercises();
        final lowerQuery = query.toLowerCase();
        return cached.where((exercise) {
          return exercise.name.toLowerCase().contains(lowerQuery) ||
              exercise.muscleGroupsDisplay.toLowerCase().contains(lowerQuery);
        }).toList();
      }
    } catch (e) {
      // Fallback to cache search
      final cached = await _localService.getCachedExercises();
      final lowerQuery = query.toLowerCase();
      return cached.where((exercise) {
        return exercise.name.toLowerCase().contains(lowerQuery) ||
            exercise.muscleGroupsDisplay.toLowerCase().contains(lowerQuery);
      }).toList();
    }
  }

  // ===== PROGRAMS =====

  /// Get preset sessions used by curated programs.
  Future<List<Session>> getPresetSessions() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      final isOnline =
          connectivityResult.any((r) => r != ConnectivityResult.none);

      if (isOnline) {
        final remote = await _firestoreService.getPresetSessions();
        if (remote.isNotEmpty) {
          return remote;
        }
      }
    } catch (_) {
      // Fall back to local curated catalog below.
    }

    return PresetProgramCatalog.buildSessions();
  }

  /// Get programs (preset + user's custom)
  Future<List<Program>> getPrograms({String? userId}) async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      final isOnline =
          connectivityResult.any((r) => r != ConnectivityResult.none);

      if (isOnline) {
        // Preset programs may be restricted by Firestore rules — treat as optional
        List<Program> presetPrograms = [];
        try {
          presetPrograms = await _firestoreService.getPrograms();
        } catch (_) {
          // No preset programs available (permission or network) — continue
        }
        if (presetPrograms.isEmpty) {
          presetPrograms = PresetProgramCatalog.buildPrograms();
        }

        List<Program> userPrograms = [];
        if (userId != null) {
          userPrograms = await _firestoreService.getUserPrograms(userId);
        }

        // Cache all programs
        await _localService.cachePrograms([...presetPrograms, ...userPrograms]);

        return [...presetPrograms, ...userPrograms];
      } else {
        // Return cached, or bundled presets if cache is empty.
        final cached = await _localService.getLocalPrograms();
        if (cached.isNotEmpty) {
          return cached;
        }
        return PresetProgramCatalog.buildPrograms();
      }
    } catch (e, st) {
      debugPrint('[SyncService.getPrograms] ERROR: $e\n$st');
      final cached = await _localService.getLocalPrograms();
      if (cached.isNotEmpty) {
        return cached;
      }
      return PresetProgramCatalog.buildPrograms();
    }
  }

  /// Get program by ID
  Future<Program?> getProgramById(String programId, {String? userId}) async {
    try {
      // Try cache first
      final cached = await _localService.getLocalProgram(programId);
      if (cached != null) {
        // Refresh in background
        _firestoreService
            .getProgramById(programId, userId: userId)
            .then((program) {
          if (program != null) {
            _localService.saveProgramLocally(program);
          }
        }).catchError((_) {
          // Silent fail
        });
        return cached;
      }

      // Not in cache, fetch from Firestore
      final program =
          await _firestoreService.getProgramById(programId, userId: userId);
      if (program != null) {
        await _localService.saveProgramLocally(program);
        return program;
      }
      return _bundledProgramById(programId);
    } catch (e) {
      // Fallback to cache
      final Program? cached = await _localService.getLocalProgram(programId);
      if (cached != null) {
        return cached;
      }
      return _bundledProgramById(programId);
    }
  }

  /// Create program (with offline support)
  Future<void> createProgram(String userId, Program program) async {
    // Save locally first
    await _localService.saveProgramLocally(program);

    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      final isOnline =
          connectivityResult.any((r) => r != ConnectivityResult.none);

      if (isOnline) {
        await _firestoreService.createProgram(userId, program);
        await _localService.clearSyncItem(program.id, 'program');
      } else {
        await _localService.markForSync(program.id, 'program');
      }
    } catch (e) {
      await _localService.markForSync(program.id, 'program');
      rethrow;
    }
  }

  /// Update program
  Future<void> updateProgram(String userId, Program program) async {
    await _localService.saveProgramLocally(program);

    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      final isOnline =
          connectivityResult.any((r) => r != ConnectivityResult.none);

      if (isOnline) {
        await _firestoreService.updateProgram(userId, program);
        await _localService.clearSyncItem(program.id, 'program');
      } else {
        await _localService.markForSync(program.id, 'program');
      }
    } catch (e) {
      await _localService.markForSync(program.id, 'program');
      rethrow;
    }
  }

  /// Delete program
  Future<void> deleteProgram(String userId, String programId) async {
    await _localService.deleteLocalProgram(programId);

    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      final isOnline =
          connectivityResult.any((r) => r != ConnectivityResult.none);

      if (isOnline) {
        await _firestoreService.deleteProgram(userId, programId);
      }
    } catch (e) {
      // Log error but don't throw - deletion is local
    }
  }

  Program? _bundledProgramById(String programId) {
    for (final Program program in PresetProgramCatalog.buildPrograms()) {
      if (program.id == programId) {
        return program;
      }
    }
    return null;
  }
}
