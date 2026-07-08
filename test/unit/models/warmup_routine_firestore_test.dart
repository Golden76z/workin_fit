import 'package:flutter_test/flutter_test.dart';
import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/warmup_routine.dart';
import 'package:workin_fit/models/workout_config.dart';

void main() {
  group('WarmupRoutine Firestore serialization', () {
    final WarmupRoutine routine = WarmupRoutine(
      category: WarmupCategory.upperBody,
      durationMinutes: 5,
      workoutConfigs: <TimedConfig>[
        TimedConfig(exerciseId: 'warmup_arm_circles', duration: 45),
        TimedConfig(exerciseId: 'warmup_shoulder_rolls', duration: 30),
      ],
      exercises: <Exercise>[
        Exercise(
          id: 'warmup_arm_circles',
          name: 'Arm Circles',
          description: 'Circle the arms.',
          imageMuscleUrl: '',
          imageTutorialUrl: '',
          muscleGroups: const <MuscleGroup>[MuscleGroup.shoulders],
          difficulty: DifficultyLevel.beginner,
        ),
        Exercise(
          id: 'warmup_shoulder_rolls',
          name: 'Shoulder Rolls',
          description: 'Roll the shoulders.',
          imageMuscleUrl: '',
          imageTutorialUrl: '',
          muscleGroups: const <MuscleGroup>[MuscleGroup.shoulders],
          difficulty: DifficultyLevel.beginner,
        ),
      ],
    );

    test('docKey combines category and duration', () {
      expect(routine.docKey, 'upperBody_5');
    });

    test('round-trips through Firestore map', () {
      final WarmupRoutine restored =
          WarmupRoutine.fromFirestore(routine.toFirestore());

      expect(restored.category, WarmupCategory.upperBody);
      expect(restored.durationMinutes, 5);
      expect(restored.workoutConfigs.length, 2);
      expect(restored.workoutConfigs.first.exerciseId, 'warmup_arm_circles');
      expect(restored.workoutConfigs.first.duration, 45);
      expect(restored.exercises.length, 2);
      expect(restored.exercises.first.name, 'Arm Circles');
      expect(
        restored.exercises.first.muscleGroups,
        contains(MuscleGroup.shoulders),
      );
      // A rebuilt routine is still convertible to a runnable session.
      expect(restored.toSession().workouts.length, 2);
    });

    test('skips malformed steps and defaults unknown enums', () {
      final WarmupRoutine r = WarmupRoutine.fromFirestore(<String, dynamic>{
        'category': 'nope',
        'durationMinutes': 2,
        'steps': <dynamic>[
          'garbage',
          <String, dynamic>{'exerciseId': '', 'duration': 10},
          <String, dynamic>{'exerciseId': 'warmup_x', 'duration': 20},
        ],
      });
      expect(r.category, WarmupCategory.fullBody); // default fallback
      expect(r.durationMinutes, 2);
      expect(r.workoutConfigs.length, 1); // only the valid step survives
      expect(r.workoutConfigs.first.exerciseId, 'warmup_x');
    });
  });
}
