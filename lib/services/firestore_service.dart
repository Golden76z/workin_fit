import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workin_fit/core/constants/app_constants.dart';
import 'package:workin_fit/models/active_program_state.dart';
import 'package:workin_fit/models/session.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/program.dart';

/// Custom exception for Firestore operations
class FirestoreException implements Exception {
  final String message;
  final String? code;

  FirestoreException(this.message, {this.code});

  @override
  String toString() =>
      'FirestoreException: $message${code != null ? ' (code: $code)' : ''}';
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
          .set(
        {
          'username': username,
          'usernameSearch': username.toLowerCase(),
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      throw FirestoreException(
        'Unexpected error creating/updating user profile: $e',
      );
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
      // Keep profile loading resilient in UI if profile doc is missing/unreachable.
      return null;
    }
  }

  /// Stream currently subscribed program state from the user profile.
  Stream<ActiveProgramState?> activeProgramStateStream(String userId) {
    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) => ActiveProgramState.fromUserProfile(doc.data()))
        .handleError((error) {
      throw FirestoreException(
        'Error streaming active program state: $error',
      );
    });
  }

  /// Read currently subscribed program state from the user profile.
  Future<ActiveProgramState?> getActiveProgramState(String userId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .get();
      return ActiveProgramState.fromUserProfile(doc.data());
    } on FirebaseException catch (e) {
      throw FirestoreException(
        'Failed to fetch active program state: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw FirestoreException(
        'Unexpected error fetching active program state: $e',
      );
    }
  }

  /// Subscribe user to a program and set the start date.
  Future<void> subscribeUserToProgram({
    required String userId,
    required String programId,
    required DateTime startDate,
  }) async {
    final DateTime startDateOnly = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );

    try {
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .set(
        <String, dynamic>{
          'activeProgramId': programId,
          'activeProgramStartDate': Timestamp.fromDate(startDateOnly),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } on FirebaseException catch (e) {
      throw FirestoreException(
        'Failed to subscribe to program: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw FirestoreException('Unexpected error subscribing to program: $e');
    }
  }

  /// Clear user's active program subscription.
  Future<void> unsubscribeUserFromProgram(String userId) async {
    try {
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .set(
        <String, dynamic>{
          'activeProgramId': null,
          'activeProgramStartDate': null,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } on FirebaseException catch (e) {
      throw FirestoreException(
        'Failed to unsubscribe from program: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw FirestoreException(
        'Unexpected error unsubscribing from program: $e',
      );
    }
  }

  // ===== EXERCISES (READ-ONLY FOR USERS) =====

  /// Get all exercises
  Future<List<Exercise>> getExercises() async {
    try {
      // Fetch without orderBy so documents missing a `name` field are not excluded.
      final snapshot = await _firestore
          .collection(FirebaseConstants.exercisesCollection)
          .get();

      final List<Exercise> exercises = <Exercise>[];
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in snapshot.docs) {
        try {
          final Map<String, dynamic> data = doc.data();
          data['id'] = doc.id;
          exercises.add(Exercise.fromJson(data));
        } on Object {
          // Skip malformed documents instead of failing the whole fetch.
        }
      }
      exercises.sort(
        (Exercise a, Exercise b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
      return exercises;
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
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
          final List<Exercise> exercises = <Exercise>[];
          for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
              in snapshot.docs) {
            try {
              final Map<String, dynamic> data = doc.data();
              data['id'] = doc.id;
              exercises.add(Exercise.fromJson(data));
            } on Object {
              // Skip malformed documents.
            }
          }
          exercises.sort(
            (Exercise a, Exercise b) =>
                a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
          return exercises;
        })
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

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Session.fromFirestore(data);
      }).toList();
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

  /// Fetch a session owned by any user (used for "Start This Workout" on shared workouts).
  /// Requires Firestore security rules to allow the current user to read another
  /// user's sessions subcollection, or the session to be public/shared.
  Future<Session?> getSessionByOwner(
      String ownerId, String sessionId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(ownerId)
          .collection(FirebaseConstants.sessionsCollection)
          .doc(sessionId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      data['id'] = doc.id;
      return Session.fromFirestore(data);
    } on FirebaseException catch (e) {
      throw FirestoreException(
        'Failed to fetch shared session: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw FirestoreException('Unexpected error fetching shared session: $e');
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
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Session.fromFirestore(data);
          }).toList(),
        )
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

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Session.fromFirestore(data);
      }).toList();
    } catch (e) {
      throw FirestoreException('Unexpected error fetching preset sessions: $e');
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

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Program.fromFirestore(data);
      }).toList();
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

      // Listen to both streams and forward whichever has data.
      return Stream<Program?>.multi((controller) {
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

        controller.onCancel = () async {
          await presetSub?.cancel();
          await userSub?.cancel();
        };
      }).handleError((error) {
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

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Program.fromFirestore(data);
      }).toList();
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

  /// Get user's completed workout history (most recent first)
  Future<List<Map<String, dynamic>>> getWorkoutHistory({
    required String userId,
    int limit = 180,
  }) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .collection(FirebaseConstants.workoutHistoryCollection)
          .orderBy('completedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        'Failed to fetch workout history: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw FirestoreException(
        'Unexpected error fetching workout history: $e',
      );
    }
  }

  /// Get monthly aggregate counters for all exercises
  Future<List<Map<String, dynamic>>> getMonthlyExerciseAggregates({
    required String userId,
    required String monthKey,
    int limit = 2000,
  }) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .collection(FirebaseConstants.exerciseMonthlyCollection)
          .doc(monthKey)
          .collection(FirebaseConstants.exercisesCollection)
          .orderBy('doneReps', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        'Failed to fetch monthly exercise aggregates: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw FirestoreException(
        'Unexpected error fetching monthly exercise aggregates: $e',
      );
    }
  }

  /// Get month-level aggregate summary.
  Future<Map<String, dynamic>?> getMonthlyWorkoutSummary({
    required String userId,
    required String monthKey,
  }) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .collection(FirebaseConstants.exerciseMonthlyCollection)
          .doc(monthKey)
          .get();

      if (!doc.exists) {
        return null;
      }
      final Map<String, dynamic> data = doc.data()!;
      data['id'] = doc.id;
      return data;
    } on FirebaseException catch (e) {
      throw FirestoreException(
        'Failed to fetch monthly workout summary: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw FirestoreException(
        'Unexpected error fetching monthly workout summary: $e',
      );
    }
  }

  /// Save completed workout. Returns the Firestore document ID of the history entry.
  Future<String> saveWorkoutHistory({
    required String userId,
    required String sessionId,
    required DateTime completedAt,
    required int duration,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final Map<String, dynamic> safeMetadata = metadata ?? <String, dynamic>{};
      final DateTime completedAtUtc = completedAt.toUtc();
      final String completedAtIso = completedAtUtc.toIso8601String();
      final String monthKey = _resolveMonthKey(
        completedAt: completedAt,
        metadata: safeMetadata,
      );
      final DateTime monthDate = _parseMonthKey(monthKey);

      final DocumentReference<Map<String, dynamic>> userDocRef =
          _firestore.collection(FirebaseConstants.usersCollection).doc(userId);
      final DocumentReference<Map<String, dynamic>> historyDocRef = userDocRef
          .collection(FirebaseConstants.workoutHistoryCollection)
          .doc();
      final DocumentReference<Map<String, dynamic>> monthDocRef = userDocRef
          .collection(FirebaseConstants.exerciseMonthlyCollection)
          .doc(monthKey);

      final WriteBatch batch = _firestore.batch();

      batch.set(historyDocRef, <String, dynamic>{
        'sessionId': sessionId,
        'completedAt': completedAtIso,
        'completedAtEpochMs': completedAtUtc.millisecondsSinceEpoch,
        'duration': duration,
        'metadata': safeMetadata,
        'monthKey': monthKey,
        'createdAt': FieldValue.serverTimestamp(),
      });

      batch.set(
        monthDocRef,
        <String, dynamic>{
          'monthKey': monthKey,
          'year': monthDate.year,
          'month': monthDate.month,
          'totalWorkouts': FieldValue.increment(1),
          'totalDurationSeconds': FieldValue.increment(duration),
          'totalPlannedReps': FieldValue.increment(
            _asInt(safeMetadata['totalPlannedReps']),
          ),
          'totalDoneReps': FieldValue.increment(
            _asInt(safeMetadata['totalDoneReps']),
          ),
          'totalPlannedWorkSeconds': FieldValue.increment(
            _asInt(safeMetadata['plannedWorkSeconds']),
          ),
          'totalDoneWorkSeconds': FieldValue.increment(
            _asInt(safeMetadata['totalDoneWorkSeconds']),
          ),
          'lastWorkoutAt': completedAtIso,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      final List<Map<String, dynamic>> exerciseSummaries = _toMapList(
        safeMetadata['exerciseSummaries'],
      );
      for (final Map<String, dynamic> exerciseSummary in exerciseSummaries) {
        final String exerciseId =
            (exerciseSummary['exerciseId'] as String? ?? '').trim();
        if (exerciseId.isEmpty) {
          continue;
        }

        final DocumentReference<Map<String, dynamic>> exerciseDocRef =
            monthDocRef
                .collection(FirebaseConstants.exercisesCollection)
                .doc(exerciseId);

        batch.set(
          exerciseDocRef,
          <String, dynamic>{
            'exerciseId': exerciseId,
            'monthKey': monthKey,
            'workoutCount': FieldValue.increment(
              _asInt(exerciseSummary['workoutCount']),
            ),
            'plannedDurationSeconds': FieldValue.increment(
              _asInt(exerciseSummary['plannedDurationSeconds']),
            ),
            'plannedWorkSeconds': FieldValue.increment(
              _asInt(exerciseSummary['plannedWorkSeconds']),
            ),
            'plannedSets': FieldValue.increment(
              _asInt(exerciseSummary['plannedSets']),
            ),
            'plannedReps': FieldValue.increment(
              _asInt(exerciseSummary['plannedReps']),
            ),
            'plannedRounds': FieldValue.increment(
              _asInt(exerciseSummary['plannedRounds']),
            ),
            'plannedTimedSeconds': FieldValue.increment(
              _asInt(exerciseSummary['plannedTimedSeconds']),
            ),
            'doneDurationSeconds': FieldValue.increment(
              _asInt(exerciseSummary['doneDurationSeconds']),
            ),
            'doneWorkSeconds': FieldValue.increment(
              _asInt(exerciseSummary['doneWorkSeconds']),
            ),
            'doneSets': FieldValue.increment(
              _asInt(exerciseSummary['doneSets']),
            ),
            'doneReps': FieldValue.increment(
              _asInt(exerciseSummary['doneReps']),
            ),
            'doneRounds': FieldValue.increment(
              _asInt(exerciseSummary['doneRounds']),
            ),
            'doneTimedSeconds': FieldValue.increment(
              _asInt(exerciseSummary['doneTimedSeconds']),
            ),
            'lastWorkoutAt': completedAtIso,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      await batch.commit();
      return historyDocRef.id;
    } catch (e) {
      throw FirestoreException('Unexpected error saving workout history: $e');
    }
  }

  // ===== STREAK =====

  /// Compute streak data from the user's workout history.
  ///
  /// Returns a map with:
  ///   - `currentStreak` (int)  – consecutive days ending today or yesterday
  ///   - `bestStreak`    (int)  – longest streak found in history
  ///   - `lastSevenDays` (List<bool>) – whether the user worked out each of the
  ///                                     last 7 days (index 0 = 6 days ago, 6 = today)
  Future<Map<String, dynamic>> getStreakData({required String userId}) async {
    final List<Map<String, dynamic>> history = await getWorkoutHistory(
      userId: userId,
      limit: 365,
    );

    // Collect unique local calendar days that had at least one workout.
    final Set<String> workoutDays = <String>{};
    for (final Map<String, dynamic> entry in history) {
      final String? raw = entry['completedAt'] as String?;
      if (raw == null) continue;
      final DateTime? dt = DateTime.tryParse(raw)?.toLocal();
      if (dt == null) continue;
      workoutDays.add(_toDateKey(dt));
    }

    final DateTime today = DateTime.now();

    // ── Current streak ────────────────────────────────────────────────────────
    // Walk backwards from today (or yesterday if the user hasn't worked out yet
    // today) and count consecutive days.
    int currentStreak = 0;
    DateTime check = workoutDays.contains(_toDateKey(today))
        ? today
        : today.subtract(const Duration(days: 1));
    while (workoutDays.contains(_toDateKey(check))) {
      currentStreak++;
      check = check.subtract(const Duration(days: 1));
    }

    // ── Best streak ───────────────────────────────────────────────────────────
    int bestStreak = currentStreak;
    if (workoutDays.length > 1) {
      final List<String> sorted = workoutDays.toList()..sort();
      int run = 1;
      for (int i = 1; i < sorted.length; i++) {
        final DateTime prev = DateTime.parse(sorted[i - 1]);
        final DateTime curr = DateTime.parse(sorted[i]);
        if (curr.difference(prev).inDays == 1) {
          run++;
          if (run > bestStreak) bestStreak = run;
        } else {
          run = 1;
        }
      }
    }

    // ── Last 7 days ───────────────────────────────────────────────────────────
    final List<bool> lastSevenDays = List<bool>.generate(7, (int i) {
      final DateTime day = today.subtract(Duration(days: 6 - i));
      return workoutDays.contains(_toDateKey(day));
    });

    return <String, dynamic>{
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'lastSevenDays': lastSevenDays,
    };
  }

  String _toDateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  // ===== ACHIEVEMENTS =====

  /// Returns all unlocked achievement IDs for a user.
  Future<Set<String>> getUnlockedAchievementIds(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .collection(FirebaseConstants.achievementsCollection)
          .get();
      return snapshot.docs.map((d) => d.id).toSet();
    } catch (_) {
      return {};
    }
  }

  /// Unlocks a single achievement and records the timestamp.
  Future<void> unlockAchievement({
    required String userId,
    required String achievementId,
    required DateTime unlockedAt,
  }) async {
    try {
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .collection(FirebaseConstants.achievementsCollection)
          .doc(achievementId)
          .set({
        'achievementId': achievementId,
        'unlockedAt': Timestamp.fromDate(unlockedAt),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirestoreException('Failed to unlock achievement: $e');
    }
  }

  /// Returns the sum of `totalDoneReps` across all exercise_monthly month docs.
  Future<int> getTotalDoneReps(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .collection(FirebaseConstants.exerciseMonthlyCollection)
          .get();
      int total = 0;
      for (final doc in snapshot.docs) {
        total += (doc.data()['totalDoneReps'] as num?)?.toInt() ?? 0;
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  /// Returns the total workout count by summing `totalWorkouts` across month docs.
  Future<int> getTotalWorkoutCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .collection(FirebaseConstants.exerciseMonthlyCollection)
          .get();
      int total = 0;
      for (final doc in snapshot.docs) {
        total += (doc.data()['totalWorkouts'] as num?)?.toInt() ?? 0;
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  /// Returns the `programsCompleted` counter from the user profile doc.
  Future<int> getProgramsCompleted(String userId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .get();
      return (doc.data()?['programsCompleted'] as num?)?.toInt() ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Increments the `programsCompleted` counter in the user profile.
  Future<void> incrementProgramsCompleted(String userId) async {
    try {
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .update({'programsCompleted': FieldValue.increment(1)});
    } catch (_) {}
  }

  String _resolveMonthKey({
    required DateTime completedAt,
    required Map<String, dynamic> metadata,
  }) {
    final dynamic rawMonthKey = metadata['monthKey'];
    if (rawMonthKey is String &&
        RegExp(r'^\d{4}-(0[1-9]|1[0-2])$').hasMatch(rawMonthKey)) {
      return rawMonthKey;
    }
    final DateTime localDate = completedAt.toLocal();
    final String month = localDate.month.toString().padLeft(2, '0');
    return '${localDate.year}-$month';
  }

  DateTime _parseMonthKey(String monthKey) {
    final List<String> parts = monthKey.split('-');
    if (parts.length != 2) {
      final DateTime now = DateTime.now();
      return DateTime(now.year, now.month);
    }
    final int? year = int.tryParse(parts[0]);
    final int? month = int.tryParse(parts[1]);
    if (year == null || month == null || month < 1 || month > 12) {
      final DateTime now = DateTime.now();
      return DateTime(now.year, now.month);
    }
    return DateTime(year, month);
  }

  int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.round();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  // ── Daily Challenge Completion ─────────────────────────────────────────

  String _completionDocId(String challengeId, DateTime date) {
    final DateTime d = date.toLocal();
    final String y = d.year.toString().padLeft(4, '0');
    final String m = d.month.toString().padLeft(2, '0');
    final String day = d.day.toString().padLeft(2, '0');
    return '$y-$m-${day}_$challengeId';
  }

  Future<bool> getChallengeCompletion({
    required String userId,
    required String challengeId,
    required DateTime date,
  }) async {
    final String docId = _completionDocId(challengeId, date);
    final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(userId)
        .collection(FirebaseConstants.challengeCompletionsCollection)
        .doc(docId)
        .get();
    return doc.exists && (doc.data()?['completed'] == true);
  }

  Future<void> setChallengeCompleted({
    required String userId,
    required String challengeId,
    required DateTime date,
    required bool completed,
  }) async {
    final String docId = _completionDocId(challengeId, date);
    await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(userId)
        .collection(FirebaseConstants.challengeCompletionsCollection)
        .doc(docId)
        .set(
          <String, dynamic>{
            'challengeId': challengeId,
            'completed': completed,
            'date': Timestamp.fromDate(date),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
  }

  List<Map<String, dynamic>> _toMapList(dynamic rawValue) {
    if (rawValue is! List<dynamic>) {
      return <Map<String, dynamic>>[];
    }

    return rawValue
        .whereType<Map<dynamic, dynamic>>()
        .map((Map<dynamic, dynamic> rawMap) {
      return rawMap.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }).toList();
  }
}
