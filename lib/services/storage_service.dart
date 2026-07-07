import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:workin_fit/core/constants/app_constants.dart';

/// Wraps Firebase Storage uploads for app content (currently exercise images).
///
/// Mirrors the avatar-upload pattern already used in the profile screen, but
/// centralised so admin editors can reuse it and so paths stay consistent with
/// [FirebaseConstants].
class StorageService {
  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  /// Upload an exercise image and return its public download URL.
  ///
  /// [exerciseId] scopes the file so an exercise's images are grouped and
  /// overwritten in place on re-upload. [kind] distinguishes the muscle diagram
  /// from the movement tutorial (e.g. `'muscle'` / `'tutorial'`).
  Future<String> uploadExerciseImage({
    required File file,
    required String exerciseId,
    required String kind,
  }) async {
    final Reference ref = _storage
        .ref()
        .child(FirebaseConstants.exerciseImagesPath)
        .child(exerciseId)
        .child('$kind.jpg');

    final SettableMetadata metadata =
        SettableMetadata(contentType: 'image/jpeg');

    await ref.putFile(file, metadata);
    return ref.getDownloadURL();
  }
}
