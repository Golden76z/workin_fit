import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'data/exercises_data.dart';
// import 'data/programs_data.dart';
// import 'data/badges_data.dart';

void main() async {
  // Initialize Firebase
  await Firebase.initializeApp();

  print('🌱 Starting database seeding...');

  try {
    await seedExercises();
    // await seedPrograms();
    // await seedBadges();
    // await seedStretchingRoutines();

    print('✅ Database seeding completed!');
  } catch (e) {
    print('❌ Error seeding database: $e');
  }
}

Future<void> seedExercises() async {
  final batch = FirebaseFirestore.instance.batch();

  // for (var exercise in EXERCISES_DATA) {
  //   final docRef = FirebaseFirestore.instance.collection('exercises').doc();
  //   batch.set(docRef, exercise);
  // }

  await batch.commit();
  print('✅ Exercises seeded');
}
