import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/program.dart';
import 'package:workin_fit/models/user_profile.dart';
import 'package:workin_fit/providers/workout_providers.dart';
import 'package:workin_fit/services/admin_content_service.dart';
import 'package:workin_fit/services/storage_service.dart';

// ===== SERVICE PROVIDERS =====

final adminContentServiceProvider =
    Provider<AdminContentService>((ref) => AdminContentService());

final storageServiceProvider =
    Provider<StorageService>((ref) => StorageService());

// ===== CURRENT USER PROFILE / ROLE =====

/// Streams the signed-in user's Firestore profile (including `role`).
///
/// Resolves to `null` when signed out. While loading or when the document is
/// missing it yields a non-admin [UserProfile] default, so gating fails closed.
final currentUserProfileProvider = StreamProvider<UserProfile?>((ref) {
  final String? userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream<UserProfile?>.value(null);
  return ref
      .watch(adminContentServiceProvider)
      .userProfileStream(userId)
      .map<UserProfile?>((UserProfile profile) => profile);
});

/// Whether the current user is an admin. Fails closed: any loading/error/absent
/// state resolves to `false`.
final isAdminProvider = Provider<bool>((ref) {
  final AsyncValue<UserProfile?> profile =
      ref.watch(currentUserProfileProvider);
  return profile.maybeWhen(
    data: (UserProfile? p) => p?.isAdmin ?? false,
    orElse: () => false,
  );
});

// ===== ADMIN CONTENT ACTIONS =====

final adminActionsProvider = Provider<AdminActions>((ref) => AdminActions(ref));

/// High-level admin operations that wrap the content service and keep the
/// user-facing providers fresh after a write.
class AdminActions {
  AdminActions(this.ref);
  final Ref ref;

  AdminContentService get _content => ref.read(adminContentServiceProvider);
  StorageService get _storage => ref.read(storageServiceProvider);

  String? get _uid => ref.read(currentUserIdProvider);

  void _refreshExercises() {
    ref.invalidate(exercisesProvider);
    ref.invalidate(exercisesStreamProvider);
  }

  /// Upload an exercise image to Storage, returning its download URL.
  Future<String> uploadExerciseImage({
    required File file,
    required String exerciseId,
    required String kind,
  }) {
    return _storage.uploadExerciseImage(
      file: file,
      exerciseId: exerciseId,
      kind: kind,
    );
  }

  Future<void> saveExercise(Exercise exercise) async {
    await _content.upsertExercise(exercise, updatedBy: _uid);
    _refreshExercises();
  }

  Future<void> deleteExercise(String exerciseId) async {
    await _content.deleteExercise(exerciseId);
    _refreshExercises();
  }

  Future<void> savePresetProgram(Program program) async {
    await _content.upsertPresetProgram(program, updatedBy: _uid);
    ref.invalidate(programsProvider);
    ref.invalidate(homePresetProgramsProvider);
  }
}
