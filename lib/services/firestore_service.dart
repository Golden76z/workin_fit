import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workin_fit/models/session.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/program.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===== EXERCISES (READ-ONLY FOR USERS) =====
  
  /// Get all exercises
  Future<List<Exercise>> getAllExercises() async {
    try {
      final snapshot = await _firestore
          .collection('exercises')
          .orderBy('name')
          .get();
      
      return snapshot.docs
          .map((doc) => Exercise.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching exercises: $e');
      rethrow;
    }
  }

  /// Get exercise by ID
  Future<Exercise?> getExerciseById(String id) async {
    try {
      final doc = await _firestore.collection('exercises').doc(id).get();
      
      if (!doc.exists) return null;
      
      return Exercise.fromJson(doc.data()!);
    } catch (e) {
      print('Error fetching exercise: $e');
      return null;
    }
  }

  /// Search exercises by name or muscle group
  Future<List<Exercise>> searchExercises(String query) async {
    try {
      // Note: This is a simple client-side search
      // For production, consider using Algolia or similar
      final allExercises = await getAllExercises();
      
      final lowerQuery = query.toLowerCase();
      return allExercises.where((exercise) {
        return exercise.name.toLowerCase().contains(lowerQuery) ||
               exercise.muscleGroupsDisplay.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      print('Error searching exercises: $e');
      return [];
    }
  }

  /// Stream exercises (real-time updates)
  Stream<List<Exercise>> exercisesStream() {
    return _firestore
        .collection('exercises')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Exercise.fromJson(doc.data()))
            .toList());
  }

  // ===== USER SESSIONS (CRUD) =====
  
  /// Get user's custom sessions
  Future<List<Session>> getUserSessions(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('sessions')
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => Session.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching user sessions: $e');
      rethrow;
    }
  }

  /// Create custom session
  Future<void> createSession(String userId, Session session) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('sessions')
          .doc(session.id)
          .set(session.toFirestore());
    } catch (e) {
      print('Error creating session: $e');
      rethrow;
    }
  }

  /// Update session
  Future<void> updateSession(String userId, Session session) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('sessions')
          .doc(session.id)
          .update(session.toFirestore());
    } catch (e) {
      print('Error updating session: $e');
      rethrow;
    }
  }

  /// Delete session
  Future<void> deleteSession(String userId, String sessionId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('sessions')
          .doc(sessionId)
          .delete();
    } catch (e) {
      print('Error deleting session: $e');
      rethrow;
    }
  }

  /// Stream user sessions (real-time)
  Stream<List<Session>> userSessionsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('sessions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Session.fromFirestore(doc.data()))
            .toList());
  }

  // ===== PRESET SESSIONS (READ-ONLY) =====
  
  /// Get preset sessions (created by admin)
  Future<List<Session>> getPresetSessions() async {
    try {
      final snapshot = await _firestore
          .collection('preset_sessions')
          .orderBy('difficulty')
          .get();
      
      return snapshot.docs
          .map((doc) => Session.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching preset sessions: $e');
      rethrow;
    }
  }

  // ===== PROGRAMS =====
  
  /// Get all preset programs
  Future<List<Program>> getPresetPrograms() async {
    try {
      final snapshot = await _firestore
          .collection('programs')
          .orderBy('difficulty')
          .get();
      
      return snapshot.docs
          .map((doc) => Program.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching programs: $e');
      rethrow;
    }
  }

  /// Get user's custom programs
  Future<List<Program>> getUserPrograms(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('programs')
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => Program.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching user programs: $e');
      rethrow;
    }
  }

  /// Create custom program
  Future<void> createProgram(String userId, Program program) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('programs')
          .doc(program.id)
          .set(program.toFirestore());
    } catch (e) {
      print('Error creating program: $e');
      rethrow;
    }
  }

  // ===== WORKOUT HISTORY =====
  
  /// Save completed workout
  Future<void> saveWorkoutHistory({
    required String userId,
    required String sessionId,
    required DateTime completedAt,
    required int duration,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('workout_history')
          .add({
        'sessionId': sessionId,
        'completedAt': completedAt.toIso8601String(),
        'duration': duration,
        'metadata': metadata ?? {},
      });
    } catch (e) {
      print('Error saving workout history: $e');
      rethrow;
    }
  }
}