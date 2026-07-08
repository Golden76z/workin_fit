import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workin_fit/core/constants/app_constants.dart';
import 'package:workin_fit/models/daily_challenge.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/program.dart';
import 'package:workin_fit/models/session.dart';
import 'package:workin_fit/models/user_profile.dart';
import 'package:workin_fit/models/warmup_routine.dart';

/// Write access to the app's shared content collections.
///
/// These writes target the top-level `exercises` / `programs` / `warmups` /
/// `daily_challenges` collections that every user reads from, so they must only
/// be reachable by admins. Enforcement is twofold:
///   1. The UI is gated behind [UserProfile.isAdmin] (see `admin_providers`).
///   2. Firestore security rules reject non-admin writes (see `firestore.rules`).
///
/// This service assumes it is called from an already-gated context.
class AdminContentService {
  AdminContentService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Stream the current user's profile document, mapped to [UserProfile].
  /// Emits a non-admin default while the document is missing/loading.
  Stream<UserProfile> userProfileStream(String userId) {
    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(userId)
        .snapshots()
        .map(
          (DocumentSnapshot<Map<String, dynamic>> doc) =>
              UserProfile.fromMap(userId, doc.data()),
        );
  }

  // ===== EXERCISES =====

  /// Create or update an exercise. Uses the exercise id as the document id so
  /// re-saving edits the same document. [updatedBy] records the acting admin.
  Future<void> upsertExercise(Exercise exercise, {String? updatedBy}) async {
    final Map<String, dynamic> data = exercise.toJson()
      ..remove('id') // id is the document id, not a field
      ..['updatedAt'] = FieldValue.serverTimestamp();
    if (updatedBy != null) data['updatedBy'] = updatedBy;

    await _firestore
        .collection(FirebaseConstants.exercisesCollection)
        .doc(exercise.id)
        .set(data, SetOptions(merge: true));
  }

  Future<void> deleteExercise(String exerciseId) async {
    await _firestore
        .collection(FirebaseConstants.exercisesCollection)
        .doc(exerciseId)
        .delete();
  }

  // ===== PROGRAMS (preset / top-level) =====

  Future<void> upsertPresetProgram(Program program, {String? updatedBy}) async {
    final Map<String, dynamic> data = program.toFirestore()
      ..remove('id')
      ..['updatedAt'] = FieldValue.serverTimestamp();
    if (updatedBy != null) data['updatedBy'] = updatedBy;

    await _firestore
        .collection(FirebaseConstants.programsCollection)
        .doc(program.id)
        .set(data, SetOptions(merge: true));
  }

  Future<void> deletePresetProgram(String programId) async {
    await _firestore
        .collection(FirebaseConstants.programsCollection)
        .doc(programId)
        .delete();
  }

  // ===== PRESET SESSIONS (curated, referenced by programs) =====

  Future<void> upsertPresetSession(Session session, {String? updatedBy}) async {
    final Map<String, dynamic> data = session.toFirestore()
      ..remove('id')
      ..['updatedAt'] = FieldValue.serverTimestamp();
    if (updatedBy != null) data['updatedBy'] = updatedBy;

    await _firestore
        .collection(FirebaseConstants.presetSessionsCollection)
        .doc(session.id)
        .set(data, SetOptions(merge: true));
  }

  Future<void> deletePresetSession(String sessionId) async {
    await _firestore
        .collection(FirebaseConstants.presetSessionsCollection)
        .doc(sessionId)
        .delete();
  }

  // ===== DAILY CHALLENGES =====

  Future<void> upsertDailyChallenge(
    DailyChallenge challenge, {
    String? updatedBy,
  }) async {
    final Map<String, dynamic> data = challenge.toFirestore()
      ..['updatedAt'] = FieldValue.serverTimestamp();
    if (updatedBy != null) data['updatedBy'] = updatedBy;

    await _firestore
        .collection(FirebaseConstants.dailyChallengesCollection)
        .doc(challenge.id)
        .set(data, SetOptions(merge: true));
  }

  Future<void> deleteDailyChallenge(String challengeId) async {
    await _firestore
        .collection(FirebaseConstants.dailyChallengesCollection)
        .doc(challengeId)
        .delete();
  }

  // ===== WARMUPS =====

  Future<void> upsertWarmup(WarmupRoutine routine, {String? updatedBy}) async {
    final Map<String, dynamic> data = routine.toFirestore()
      ..['updatedAt'] = FieldValue.serverTimestamp();
    if (updatedBy != null) data['updatedBy'] = updatedBy;

    await _firestore
        .collection(FirebaseConstants.warmupsCollection)
        .doc(routine.docKey)
        .set(data, SetOptions(merge: true));
  }

  Future<void> deleteWarmup(String docKey) async {
    await _firestore
        .collection(FirebaseConstants.warmupsCollection)
        .doc(docKey)
        .delete();
  }

  // ===== GENERIC MAP-BASED CONTENT =====

  /// Generic upsert for content collections whose in-app model is currently
  /// static/local (warmups, daily challenges). The stub editors write raw maps
  /// here; when the read paths are wired to Firestore these documents will be
  /// picked up automatically.
  Future<void> upsertContentDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
    String? updatedBy,
  }) async {
    final Map<String, dynamic> payload = Map<String, dynamic>.from(data)
      ..['updatedAt'] = FieldValue.serverTimestamp();
    if (updatedBy != null) payload['updatedBy'] = updatedBy;

    await _firestore
        .collection(collection)
        .doc(docId)
        .set(payload, SetOptions(merge: true));
  }

  Future<void> deleteContentDocument({
    required String collection,
    required String docId,
  }) async {
    await _firestore.collection(collection).doc(docId).delete();
  }
}
