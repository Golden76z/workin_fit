import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workin_fit/core/constants/app_constants.dart';
import 'package:workin_fit/models/session.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/program.dart';

/// Custom exception for Firestore operations
class FirestoreException implements Exception {
  final String message;
  final String? code;

  FirestoreException(this.message, {this.code});

  @override
  String toString() => 'FirestoreException: $message${code != null ? ' (code: $code)' : ''}';
}

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Note: Firestore offline persistence is enabled by default in Flutter.
  /// No additional configuration needed. Firestore automatically caches
  /// data locally and syncs when connection is restored.

  // ===== USER PROFILE =====
  
  /// Create or update user profile
  Future<void> createOrUpdateUserProfile({
    required String userId,
    required String username,
    required String email,
  }) async {
    try {
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .set({
        'username': username,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error creating/updating user profile: $e');
      rethrow;
    }
  }

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .get();
      
      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // ===== EXERCISES (READ-ONLY FOR USERS) =====
  
  /// Get all exercises
  Future<List<Exercise>> getExercises() async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.exercisesCollection)
          .orderBy('name')
          .get();
      
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Ensure ID is set
            return Exercise.fromJson(data);
          })
          .toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        'Failed to fetch exercises: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw FirestoreException('Unexpected error fetching exercises: $e');
    }
  }

  /// Get exercise by ID
  Future<Exercise?> getExerciseById(String id) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.exercisesCollection)
          .doc(id)
          .get();
      
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      data['id'] = doc.id;
      return Exercise.fromJson(data);
    } on FirebaseException catch (e) {
      throw FirestoreException(
        'Failed to fetch exercise: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw FirestoreException('Unexpected error fetching exercise: $e');
    }
  }

  /// Search exercises by name or muscle group
  Future<List<Exercise>> searchExercises(String query) async {
    if (query.trim().isEmpty) {
      return await getExercises();
    }
    
    try {
      // Note: This is a simple client-side search
      // For production, consider using Algolia or similar
      final allExercises = await getExercises();
      
      final lowerQuery = query.toLowerCase();
      return allExercises.where((exercise) {
        return exercise.name.toLowerCase().contains(lowerQuery) ||
               exercise.muscleGroupsDisplay.toLowerCase().contains(lowerQuery);
      }).toList();
    } on FirestoreException {
      rethrow;
    } catch (e) {
      throw FirestoreException('Unexpected error searching exercises: $e');
    }
  }

  /// Stream exercises (real-time updates)
  Stream<List<Exercise>> exercisesStream() {
    return _firestore
        .collection(FirebaseConstants.exercisesCollection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return Exercise.fromJson(data);
            })
            .toList())
        .handleError((error) {
          throw FirestoreException(
            'Error streaming exercises: $error',
          );
        });
  }

  // ===== USER SESSIONS (CRUD) =====
  
  /// Get user's custom sessions
  Future<List<Session>> getSessions(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .collection(FirebaseConstants.sessionsCollection)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Session.fromFirestore(data);
          })
          .toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        'Failed to fetch sessions: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw FirestoreException('Unexpected error fetching sessions: $e');
    }
  }

  /// Get session by ID
  Future<Session?> getSessionById(String userId, String sessionId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .collection(FirebaseConstants.sessionsCollection)
          .doc(sessionId)
          .get();
      
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      data['id'] = doc.id;
      return Session.fromFirestore(data);
    } on FirebaseException catch (e) {
      throw FirestoreException(
        'Failed to fetch session: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw FirestoreException('Unexpected error fetching session: $e');
    }
  }

  /// Create custom session
  Future<void> createSession(String userId, Session session) async {
    try {
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .collection(FirebaseConstants.sessionsCollection)
          .doc(session.id)
          .set(session.toFirestore());
    } on FirebaseException catch (e) {
      throw FirestoreException(
        'Failed to create session: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw FirestoreException('Unexpected error creating session: $e');
    }
  }

  /// Update session
  Future<void> updateSession(String userId, Session session) async {
    try {
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .collection(FirebaseConstants.sessionsCollection)
          .doc(session.id)
          .update(session.toFirestore());
    } on FirebaseException catch (e) {
      throw FirestoreException(
        'Failed to update session: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw FirestoreException('Unexpected error updating session: $e');
    }
  }

  /// Delete session
  Future<void> deleteSession(String userId, String sessionId) async {
    try {
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .collection(FirebaseConstants.sessionsCollection)
          .doc(sessionId)
          .delete();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        'Failed to delete session: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw FirestoreException('Unexpected error deleting session: $e');
    }
  }

  /// Stream user sessions (real-time)
  Stream<List<Session>> userSessionsStream(String userId) {
    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(userId)
        .collection(FirebaseConstants.sessionsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return Session.fromFirestore(data);
            })
            .toList())
        .handleError((error) {
          throw FirestoreException(
            'Error streaming sessions: $error',
          );
        });
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
  Future<List<Program>> getPrograms() async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.programsCollection)
          .orderBy('difficulty')
          .get();
      
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Program.fromFirestore(data);
          })
          .toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        'Failed to fetch programs: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw FirestoreException('Unexpected error fetching programs: $e');
    }
  }

  /// Get program by ID (checks both preset and user programs)
  Future<Program?> getProgramById(String programId, {String? userId}) async {
    try {
      // First check preset programs
      final presetDoc = await _firestore
          .collection(FirebaseConstants.programsCollection)
          .doc(programId)
          .get();
      
      if (presetDoc.exists) {
        final data = presetDoc.data()!;
        data['id'] = presetDoc.id;
        return Program.fromFirestore(data);
      }
      
      // If not found and userId provided, check user programs
      if (userId != null) {
        final userDoc = await _firestore
            .collection(FirebaseConstants.usersCollection)
            .doc(userId)
            .collection(FirebaseConstants.programsCollection)
            .doc(programId)
            .get();
        
        if (userDoc.exists) {
          final data = userDoc.data()!;
          data['id'] = userDoc.id;
          return Program.fromFirestore(data);
        }
      }
      
      return null;
    } on FirebaseException catch (e) {
      throw FirestoreException(
        'Failed to fetch program: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw FirestoreException('Unexpected error fetching program: $e');
    }
  }

  /// Subscribe to program updates (real-time stream)
  /// Checks preset programs first, then user programs if userId is provided
  Stream<Program?> subscribeToProgram(String programId, {String? userId}) {
    // Try preset programs first
    final presetStream = _firestore
        .collection(FirebaseConstants.programsCollection)
        .doc(programId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          final data = doc.data()!;
          data['id'] = doc.id;
          return Program.fromFirestore(data);
        });
    
    // If userId provided, also listen to user programs
    if (userId != null) {
      final userStream = _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .collection(FirebaseConstants.programsCollection)
          .doc(programId)
          .snapshots()
          .map((doc) {
            if (!doc.exists) return null;
            final data = doc.data()!;
            data['id'] = doc.id;
            return Program.fromFirestore(data);
          });
      
      // Listen to both streams and return whichever has data
      // Prefer preset programs, fallback to user programs
      final controller = StreamController<Program?>.broadcast();
      StreamSubscription<Program?>? presetSub;
      StreamSubscription<Program?>? userSub;
      
      presetSub = presetStream.listen(
        (program) {
          if (program != null) {
            controller.add(program);
          }
        },
        onError: controller.addError,
      );
      
      userSub = userStream.listen(
        (program) {
          if (program != null) {
            controller.add(program);
          }
        },
        onError: controller.addError,
      );
      
      controller.onCancel = () {
        presetSub?.cancel();
        userSub?.cancel();
      };
      
      return controller.stream.handleError((error) {
        throw FirestoreException(
          'Error subscribing to program: $error',
        );
      });
    }
    
    return presetStream.handleError((error) {
      throw FirestoreException(
        'Error subscribing to program: $error',
      );
    });
  }

  /// Get user's custom programs
  Future<List<Program>> getUserPrograms(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .collection(FirebaseConstants.programsCollection)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Program.fromFirestore(data);
          })
          .toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        'Failed to fetch user programs: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw FirestoreException('Unexpected error fetching user programs: $e');
    }
  }

  /// Create custom program
  Future<void> createProgram(String userId, Program program) async {
    try {
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .collection(FirebaseConstants.programsCollection)
          .doc(program.id)
          .set(program.toFirestore());
    } on FirebaseException catch (e) {
      throw FirestoreException(
        'Failed to create program: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw FirestoreException('Unexpected error creating program: $e');
    }
  }

  /// Update program
  Future<void> updateProgram(String userId, Program program) async {
    try {
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .collection(FirebaseConstants.programsCollection)
          .doc(program.id)
          .update(program.toFirestore());
    } on FirebaseException catch (e) {
      throw FirestoreException(
        'Failed to update program: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw FirestoreException('Unexpected error updating program: $e');
    }
  }

  /// Delete program
  Future<void> deleteProgram(String userId, String programId) async {
    try {
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .collection(FirebaseConstants.programsCollection)
          .doc(programId)
          .delete();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        'Failed to delete program: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw FirestoreException('Unexpected error deleting program: $e');
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