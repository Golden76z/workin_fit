import 'package:hive_flutter/hive_flutter.dart';
import 'package:workin_fit/models/session.dart';
import 'package:workin_fit/models/exercise.dart';

class LocalStorageService {
  static const String exercisesBox = 'exercises';
  static const String sessionsBox = 'sessions';
  static const String programsBox = 'programs';

  // ===== EXERCISES (CACHE) =====
  
  /// Cache exercises locally
  Future<void> cacheExercises(List<Exercise> exercises) async {
    final box = await Hive.openBox<Exercise>(exercisesBox);
    
    await box.clear();
    for (var exercise in exercises) {
      await box.put(exercise.id, exercise);
    }
  }

  /// Get cached exercises
  Future<List<Exercise>> getCachedExercises() async {
    final box = await Hive.openBox<Exercise>(exercisesBox);
    return box.values.toList();
  }

  /// Get single cached exercise
  Future<Exercise?> getCachedExercise(String id) async {
    final box = await Hive.openBox<Exercise>(exercisesBox);
    return box.get(id);
  }

  // ===== USER SESSIONS (OFFLINE SUPPORT) =====
  
  /// Save session locally
  Future<void> saveSessionLocally(Session session) async {
    final box = await Hive.openBox<Session>(sessionsBox);
    await box.put(session.id, session);
  }

  /// Get all local sessions
  Future<List<Session>> getLocalSessions() async {
    final box = await Hive.openBox<Session>(sessionsBox);
    return box.values.toList();
  }

  /// Delete local session
  Future<void> deleteLocalSession(String sessionId) async {
    final box = await Hive.openBox<Session>(sessionsBox);
    await box.delete(sessionId);
  }

  /// Clear all local sessions
  Future<void> clearLocalSessions() async {
    final box = await Hive.openBox<Session>(sessionsBox);
    await box.clear();
  }

  // ===== SYNC STATUS TRACKING =====
  
  /// Mark session as needing sync
  Future<void> markForSync(String sessionId) async {
    final box = await Hive.openBox('sync_queue');
    await box.put(sessionId, {
      'id': sessionId,
      'timestamp': DateTime.now().toIso8601String(),
      'type': 'session',
    });
  }

  /// Get items needing sync
  Future<List<Map<String, dynamic>>> getPendingSync() async {
    final box = await Hive.openBox('sync_queue');
    return box.values.cast<Map<String, dynamic>>().toList();
  }

  /// Clear sync queue item
  Future<void> clearSyncItem(String id) async {
    final box = await Hive.openBox('sync_queue');
    await box.delete(id);
  }
}