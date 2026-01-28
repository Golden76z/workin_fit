import 'package:hive_flutter/hive_flutter.dart';
import 'package:workin_fit/models/session.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/program.dart';

class LocalStorageService {
  static const String exercisesBox = 'exercises';
  static const String sessionsBox = 'sessions';
  static const String programsBox = 'programs';
  static const String syncQueueBox = 'sync_queue';

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

  /// Get single local session
  Future<Session?> getLocalSession(String sessionId) async {
    final box = await Hive.openBox<Session>(sessionsBox);
    return box.get(sessionId);
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

  // ===== PROGRAMS (OFFLINE SUPPORT) =====
  
  /// Save program locally
  Future<void> saveProgramLocally(Program program) async {
    final box = await Hive.openBox<Program>(programsBox);
    await box.put(program.id, program);
  }

  /// Get all local programs
  Future<List<Program>> getLocalPrograms() async {
    final box = await Hive.openBox<Program>(programsBox);
    return box.values.toList();
  }

  /// Get single local program
  Future<Program?> getLocalProgram(String programId) async {
    final box = await Hive.openBox<Program>(programsBox);
    return box.get(programId);
  }

  /// Cache multiple programs
  Future<void> cachePrograms(List<Program> programs) async {
    final box = await Hive.openBox<Program>(programsBox);
    for (var program in programs) {
      await box.put(program.id, program);
    }
  }

  /// Delete local program
  Future<void> deleteLocalProgram(String programId) async {
    final box = await Hive.openBox<Program>(programsBox);
    await box.delete(programId);
  }

  /// Clear all local programs
  Future<void> clearLocalPrograms() async {
    final box = await Hive.openBox<Program>(programsBox);
    await box.clear();
  }

  // ===== SYNC STATUS TRACKING =====
  
  /// Mark item as needing sync
  Future<void> markForSync(String itemId, String type) async {
    final box = await Hive.openBox(syncQueueBox);
    await box.put(itemId, {
      'id': itemId,
      'timestamp': DateTime.now().toIso8601String(),
      'type': type, // 'session' or 'program'
    });
  }

  /// Get items needing sync
  Future<List<Map<String, dynamic>>> getPendingSync() async {
    final box = await Hive.openBox(syncQueueBox);
    return box.values.cast<Map<String, dynamic>>().toList();
  }

  /// Clear sync queue item
  Future<void> clearSyncItem(String id, String type) async {
    final box = await Hive.openBox(syncQueueBox);
    await box.delete(id);
  }

  /// Clear all sync queue items
  Future<void> clearSyncQueue() async {
    final box = await Hive.openBox(syncQueueBox);
    await box.clear();
  }
}