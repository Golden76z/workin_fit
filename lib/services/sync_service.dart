import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/session.dart';
import 'package:workin_fit/models/program.dart';
import 'package:workin_fit/services/firestore_service.dart';
import 'package:workin_fit/services/local_storage_service.dart';

class SyncService {
  final FirestoreService _firestoreService = FirestoreService();
  final LocalStorageService _localService = LocalStorageService();
  final Connectivity _connectivity = Connectivity();

  // ===== SESSIONS =====
  
  /// Get sessions (offline-first)
  Future<List<Session>> getSessions(String userId) async {
    try {
      // Check connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      final isOnline = connectivityResult.any((r) => r != ConnectivityResult.none);

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
      final isOnline = connectivityResult.any((r) => r != ConnectivityResult.none);

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
      final isOnline = connectivityResult.any((r) => r != ConnectivityResult.none);

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
      final isOnline = connectivityResult.any((r) => r != ConnectivityResult.none);

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
    final isOnline = connectivityResult.any((r) => r != ConnectivityResult.none);

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
              final existing = await _firestoreService.getSessionById(userId, itemId);
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
              final existing = await _firestoreService.getProgramById(itemId, userId: userId);
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
  
  /// Get exercises with cache-first strategy
  Future<List<Exercise>> getExercises() async {
    try {
      // Try local first
      final cached = await _localService.getCachedExercises();
      
      if (cached.isNotEmpty) {
        // Return cached, but fetch fresh in background
        _refreshExercisesInBackground();
        return cached;
      }

      // No cache, fetch from Firestore
      final exercises = await _firestoreService.getExercises();
      await _localService.cacheExercises(exercises);
      return exercises;
    } catch (e) {
      // Fallback to cache on error
      return await _localService.getCachedExercises();
    }
  }

  /// Get exercise by ID
  Future<Exercise?> getExerciseById(String id) async {
    try {
      // Try cache first
      final cached = await _localService.getCachedExercise(id);
      if (cached != null) {
        // Refresh in background
        _firestoreService.getExerciseById(id).then((exercise) {
          if (exercise != null) {
            _localService.cacheExercises([exercise]);
          }
        }).catchError((_) {
          // Silent fail for background refresh
        });
        return cached;
      }

      // Not in cache, fetch from Firestore
      final exercise = await _firestoreService.getExerciseById(id);
      if (exercise != null) {
        await _localService.cacheExercises([exercise]);
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
      final isOnline = connectivityResult.any((r) => r != ConnectivityResult.none);

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

  Future<void> _refreshExercisesInBackground() async {
    try {
      final exercises = await _firestoreService.getExercises();
      await _localService.cacheExercises(exercises);
    } catch (e) {
      // Silent fail for background refresh
    }
  }

  // ===== PROGRAMS =====
  
  /// Get programs (preset + user's custom)
  Future<List<Program>> getPrograms({String? userId}) async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      final isOnline = connectivityResult.any((r) => r != ConnectivityResult.none);

      if (isOnline) {
        // Preset programs may be restricted by Firestore rules — treat as optional
        List<Program> presetPrograms = [];
        try {
          presetPrograms = await _firestoreService.getPrograms();
        } catch (_) {
          // No preset programs available (permission or network) — continue
        }

        List<Program> userPrograms = [];
        if (userId != null) {
          userPrograms = await _firestoreService.getUserPrograms(userId);
        }

        // Cache all programs
        await _localService.cachePrograms([...presetPrograms, ...userPrograms]);

        return [...presetPrograms, ...userPrograms];
      } else {
        // Return cached
        return await _localService.getLocalPrograms();
      }
    } catch (e, st) {
      debugPrint('[SyncService.getPrograms] ERROR: $e\n$st');
      return await _localService.getLocalPrograms();
    }
  }

  /// Get program by ID
  Future<Program?> getProgramById(String programId, {String? userId}) async {
    try {
      // Try cache first
      final cached = await _localService.getLocalProgram(programId);
      if (cached != null) {
        // Refresh in background
        _firestoreService.getProgramById(programId, userId: userId)
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
      final program = await _firestoreService.getProgramById(programId, userId: userId);
      if (program != null) {
        await _localService.saveProgramLocally(program);
      }
      return program;
    } catch (e) {
      // Fallback to cache
      return await _localService.getLocalProgram(programId);
    }
  }

  /// Create program (with offline support)
  Future<void> createProgram(String userId, Program program) async {
    // Save locally first
    await _localService.saveProgramLocally(program);

    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      final isOnline = connectivityResult.any((r) => r != ConnectivityResult.none);

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
      final isOnline = connectivityResult.any((r) => r != ConnectivityResult.none);

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
      final isOnline = connectivityResult.any((r) => r != ConnectivityResult.none);

      if (isOnline) {
        await _firestoreService.deleteProgram(userId, programId);
      }
    } catch (e) {
      // Log error but don't throw - deletion is local
    }
  }
}