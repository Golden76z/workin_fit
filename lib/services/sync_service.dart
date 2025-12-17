import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/session.dart';
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
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (isOnline) {
        // Fetch from Firestore
        final sessions = await _firestoreService.getUserSessions(userId);
        
        // Cache locally
        for (var session in sessions) {
          await _localService.saveSessionLocally(session);
        }
        
        return sessions;
      } else {
        // Return cached data
        return await _localService.getLocalSessions();
      }
    } catch (e) {
      print('Error getting sessions, falling back to cache: $e');
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
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (isOnline) {
        // Sync to Firestore
        await _firestoreService.createSession(userId, session);
      } else {
        // Mark for sync when online
        await _localService.markForSync(session.id);
      }
    } catch (e) {
      print('Error creating session online, queued for sync: $e');
      await _localService.markForSync(session.id);
    }
  }

  /// Update session
  Future<void> updateSession(String userId, Session session) async {
    await _localService.saveSessionLocally(session);

    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (isOnline) {
        await _firestoreService.updateSession(userId, session);
      } else {
        await _localService.markForSync(session.id);
      }
    } catch (e) {
      print('Error updating session: $e');
      await _localService.markForSync(session.id);
    }
  }

  /// Delete session
  Future<void> deleteSession(String userId, String sessionId) async {
    await _localService.deleteLocalSession(sessionId);

    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (isOnline) {
        await _firestoreService.deleteSession(userId, sessionId);
      }
    } catch (e) {
      print('Error deleting session online: $e');
    }
  }

  /// Sync pending changes
  Future<void> syncPendingChanges(String userId) async {
    final connectivityResult = await _connectivity.checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;

    if (!isOnline) return;

    try {
      final pendingItems = await _localService.getPendingSync();
      
      for (var item in pendingItems) {
        final sessionId = item['id'];
        final session = await _localService.getCachedExercise(sessionId);
        
        if (session != null) {
          // await _firestoreService.createSession(userId, session);
          await _localService.clearSyncItem(sessionId);
        }
      }
    } catch (e) {
      print('Error syncing pending changes: $e');
    }
  }

  // ===== EXERCISES (CACHE-FIRST) =====
  
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
      final exercises = await _firestoreService.getAllExercises();
      await _localService.cacheExercises(exercises);
      return exercises;
    } catch (e) {
      print('Error getting exercises: $e');
      return await _localService.getCachedExercises();
    }
  }

  Future<void> _refreshExercisesInBackground() async {
    try {
      final exercises = await _firestoreService.getAllExercises();
      await _localService.cacheExercises(exercises);
    } catch (e) {
      // Silent fail for background refresh
    }
  }
}