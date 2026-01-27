import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:workin_fit/models/exercise_model.dart';
import 'package:workin_fit/models/program_model.dart';
import 'package:workin_fit/models/session_model.dart';

/// Firestore collection converters for JSON-serializable models.
///
/// These helpers wrap the underlying collections with typed converters so that
/// reads and writes use the strongly-typed model classes instead of raw maps.

extension ExerciseModelCollectionsX on FirebaseFirestore {
  /// Typed `exercises` collection using [ExerciseModel].
  CollectionReference<ExerciseModel> exerciseModelsCollection() {
    return collection('exercises').withConverter<ExerciseModel>(
      fromFirestore: (snapshot, _) {
        final data = snapshot.data();
        if (data == null) {
          throw StateError('Exercise document ${snapshot.id} has no data');
        }
        return ExerciseModel.fromFirestore(data, id: snapshot.id);
      },
      toFirestore: (model, _) => model.toFirestore(),
    );
  }
}

extension SessionModelCollectionsX on FirebaseFirestore {
  /// Typed `preset_sessions` collection for admin-created sessions.
  CollectionReference<SessionModel> presetSessionsCollection() {
    return collection('preset_sessions').withConverter<SessionModel>(
      fromFirestore: (snapshot, _) {
        final data = snapshot.data();
        if (data == null) {
          throw StateError('Session document ${snapshot.id} has no data');
        }
        return SessionModel.fromFirestore(data, id: snapshot.id);
      },
      toFirestore: (model, _) => model.toFirestore(),
    );
  }

  /// Typed `users/{userId}/sessions` sub-collection for user-created sessions.
  CollectionReference<SessionModel> userSessionsCollection(String userId) {
    return collection('users')
        .doc(userId)
        .collection('sessions')
        .withConverter<SessionModel>(
      fromFirestore: (snapshot, _) {
        final data = snapshot.data();
        if (data == null) {
          throw StateError('Session document ${snapshot.id} has no data');
        }
        return SessionModel.fromFirestore(data, id: snapshot.id);
      },
      toFirestore: (model, _) => model.toFirestore(),
    );
  }
}

extension ProgramModelCollectionsX on FirebaseFirestore {
  /// Typed `programs` collection for preset programs.
  CollectionReference<ProgramModel> presetProgramsCollection() {
    return collection('programs').withConverter<ProgramModel>(
      fromFirestore: (snapshot, _) {
        final data = snapshot.data();
        if (data == null) {
          throw StateError('Program document ${snapshot.id} has no data');
        }
        return ProgramModel.fromFirestore(data, id: snapshot.id);
      },
      toFirestore: (model, _) => model.toFirestore(),
    );
  }

  /// Typed `users/{userId}/programs` sub-collection for user-created programs.
  CollectionReference<ProgramModel> userProgramsCollection(String userId) {
    return collection('users')
        .doc(userId)
        .collection('programs')
        .withConverter<ProgramModel>(
      fromFirestore: (snapshot, _) {
        final data = snapshot.data();
        if (data == null) {
          throw StateError('Program document ${snapshot.id} has no data');
        }
        return ProgramModel.fromFirestore(data, id: snapshot.id);
      },
      toFirestore: (model, _) => model.toFirestore(),
    );
  }
}

