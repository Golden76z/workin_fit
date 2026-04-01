// Upload preset program and session catalog to Firestore.
//
// Usage (from a Flutter-enabled environment):
//   flutter pub run data/programs/upload_preset_programs.dart
//   flutter pub run data/programs/upload_preset_programs.dart --dry-run

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:workin_fit/core/constants/app_constants.dart';
import 'package:workin_fit/data/preset_program_catalog.dart';
import 'package:workin_fit/models/program.dart';
import 'package:workin_fit/models/session.dart';

Future<void> main(List<String> args) async {
  final bool dryRun = args.contains('--dry-run');

  await Firebase.initializeApp();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final List<Session> sessions = PresetProgramCatalog.buildSessions();
  final List<Program> programs = PresetProgramCatalog.buildPrograms();

  print(
    'Preparing ${sessions.length} preset sessions and ${programs.length} preset programs.',
  );

  if (dryRun) {
    print('Dry run complete. No Firestore writes were performed.');
    return;
  }

  final WriteBatch batch = firestore.batch();

  for (final session in sessions) {
    final doc = firestore.collection('preset_sessions').doc(session.id);
    batch.set(doc, session.toFirestore(), SetOptions(merge: true));
  }

  for (final program in programs) {
    final doc = firestore
        .collection(FirebaseConstants.programsCollection)
        .doc(program.id);
    batch.set(
      doc,
      PresetProgramCatalog.programToFirestore(program),
      SetOptions(merge: true),
    );
  }

  await batch.commit();

  print('Upload completed successfully.');
}
