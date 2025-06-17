import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  print('🌱 Starting database seeding...');

  try {
    await seedBasicExercises();
    print('✅ Database seeding completed!');
  } catch (e) {
    print('❌ Error seeding database: $e');
  }
}

Future<void> seedBasicExercises() async {
  final exercises = [
    {
      'name': 'Push-ups',
      'description': 'Classic upper body exercise',
      'bodyArea': 'chest',
      'difficulty': 'beginner',
      'equipment': 'bodyweight',
      'xpReward': 10,
      'instructions': [
        {
          'step': 1,
          'text': 'Start in plank position with hands shoulder-width apart',
          'duration': null
        },
        {
          'step': 2,
          'text': 'Lower your body until chest nearly touches floor',
          'duration': 2
        },
        {'step': 3, 'text': 'Push back up to starting position', 'duration': 1}
      ],
      'tips': [
        'Keep your core tight throughout the movement',
        'Don\'t let your hips sag'
      ],
      'media': {
        'thumbnail': null, // Add later when you upload images
        'images': {},
        'videos': {},
        'gifs': {}
      },
      'createdAt': FieldValue.serverTimestamp(),
    },
    // Add more exercises...
  ];

  final batch = FirebaseFirestore.instance.batch();

  for (var exercise in exercises) {
    final docRef = FirebaseFirestore.instance.collection('exercises').doc();
    batch.set(docRef, exercise);
  }

  await batch.commit();
  print('✅ ${exercises.length} exercises seeded');
}
