// scripts/data/exercises_data.dart
import 'package:cloud_firestore/cloud_firestore.dart';

final List<Map<String, dynamic>> exercicesData = [
  {
    'name': 'Push-ups',
    'description':
        'Classic upper body exercise targeting chest, shoulders, and triceps',
    'bodyArea': 'chest',
    'media': {
      'thumbnail': 'gs://your-bucket/exercises/pushups/thumbnail.jpg',
      'images': {
        'step1': 'gs://your-bucket/exercises/pushups/step1_start.jpg',
        'step2': 'gs://your-bucket/exercises/pushups/step2_down.jpg',
        'step3': 'gs://your-bucket/exercises/pushups/step3_up.jpg',
        'form_correct': 'gs://your-bucket/exercises/pushups/form_correct.jpg',
        'form_incorrect':
            'gs://your-bucket/exercises/pushups/form_incorrect.jpg',
      },
      'videos': {
        'demonstration': 'gs://your-bucket/exercises/pushups/demonstration.mp4',
        'slow_motion': 'gs://your-bucket/exercises/pushups/slow_motion.mp4',
        'common_mistakes':
            'gs://your-bucket/exercises/pushups/common_mistakes.mp4',
      },
      'gifs': {
        'quick_demo': 'gs://your-bucket/exercises/pushups/quick_demo.gif',
      }
    },
    'instructions': [
      {
        'step': 1,
        'text': 'Start in a plank position with hands shoulder-width apart',
        'imageRef': 'step1',
        'duration': null
      },
      {
        'step': 2,
        'text': 'Lower your body until chest nearly touches the floor',
        'imageRef': 'step2',
        'duration': 2
      },
      {
        'step': 3,
        'text': 'Push back up to starting position',
        'imageRef': 'step3',
        'duration': 1
      }
    ],
    'tips': [
      'Keep your core tight throughout the movement',
      'Don\'t let your hips sag or pike up',
      'Control the descent - don\'t just drop down'
    ],
    'variations': [
      {
        'name': 'Knee Push-ups',
        'difficulty': 'beginner',
        'description': 'Easier version performed on knees instead of toes',
        'imageUrl': 'gs://your-bucket/exercises/pushups/knee_variation.jpg'
      },
      {
        'name': 'Diamond Push-ups',
        'difficulty': 'advanced',
        'description': 'Hands form diamond shape, targets triceps more',
        'imageUrl': 'gs://your-bucket/exercises/pushups/diamond_variation.jpg'
      }
    ],
    'xpReward': 10,
    'difficulty': 'beginner',
    'equipment': 'bodyweight',
    'createdAt': FieldValue.serverTimestamp(),
  },
];
