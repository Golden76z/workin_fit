// Script to upload exercises from JSON files to Firestore
// Run with: dart run data/exercises/upload_exercises.dart

import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:workin_fit/core/constants/app_constants.dart';

// You'll need to initialize Firebase before running this
// Make sure to have your firebase_options.dart configured

Future<void> main() async {
  // Initialize Firebase
  await Firebase.initializeApp();

  final firestore = FirebaseFirestore.instance;
  final exercisesCollection = firestore.collection(
    FirebaseConstants.exercisesCollection,
  );

  // Read all.json file
  final file = File('data/exercises/all.json');
  if (!await file.exists()) {
    print('❌ Error: data/exercises/all.json not found');
    exit(1);
  }

  final content = await file.readAsString();
  final exercises = json.decode(content) as List<dynamic>;

  print('📤 Uploading ${exercises.length} exercises to Firestore...\n');

  int successCount = 0;
  int errorCount = 0;

  for (var exercise in exercises) {
    try {
      final exerciseMap = Map<String, dynamic>.from(exercise);
      final id = exerciseMap['id'] as String;

      // Use the exercise ID as the document ID
      await exercisesCollection.doc(id).set(exerciseMap);

      final label = exerciseMap['name'] ?? exerciseMap['nameKey'] ?? id;
      print('✅ Uploaded: $label');
      successCount++;
    } catch (e) {
      final label = exercise['name'] ?? exercise['nameKey'] ?? exercise['id'];
      print('❌ Error uploading $label: $e');
      errorCount++;
    }
  }

  print('\n📊 Summary:');
  print('   ✅ Success: $successCount');
  print('   ❌ Errors: $errorCount');
  print('   📝 Total: ${exercises.length}');
}
