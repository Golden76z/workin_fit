import 'package:flutter_test/flutter_test.dart';
import 'package:workin_fit/models/muscle_activation.dart';
import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/models/exercise.dart';

void main() {
  group('MuscleActivationLevel.resolve', () {
    test('defaults all muscle groups to level 3 when no stored map', () {
      final Map<MuscleGroup, int> resolved = MuscleActivationLevel.resolve(
        muscleGroups: const [MuscleGroup.chest, MuscleGroup.triceps],
        storedLevels: null,
      );
      expect(resolved, {
        MuscleGroup.chest: 3,
        MuscleGroup.triceps: 3,
      });
    });

    test('uses stored levels when present', () {
      final Map<MuscleGroup, int> resolved = MuscleActivationLevel.resolve(
        muscleGroups: const [MuscleGroup.chest, MuscleGroup.triceps],
        storedLevels: const {'chest': 3, 'triceps': 1},
      );
      expect(resolved[MuscleGroup.chest], 3);
      expect(resolved[MuscleGroup.triceps], 1);
    });
  });

  group('Exercise muscleActivation JSON', () {
    test('fromJson parses muscleActivation map', () {
      final Exercise exercise = Exercise.fromJson({
        'id': 'ex1',
        'name': 'Push Up',
        'description': 'desc',
        'imageMuscleUrl': '',
        'imageTutorialUrl': '',
        'muscleGroups': ['chest', 'triceps', 'shoulders'],
        'muscleActivation': {'chest': 3, 'triceps': 2, 'shoulders': 1},
        'difficulty': 'beginner',
        'equipment': <dynamic>[],
      });

      expect(exercise.resolvedMuscleActivation[MuscleGroup.chest], 3);
      expect(exercise.resolvedMuscleActivation[MuscleGroup.triceps], 2);
      expect(exercise.resolvedMuscleActivation[MuscleGroup.shoulders], 1);
    });

    test('toJson includes muscleActivation when set', () {
      final Exercise exercise = Exercise(
        id: 'ex1',
        name: 'Row',
        description: 'desc',
        imageMuscleUrl: '',
        imageTutorialUrl: '',
        muscleGroups: const [MuscleGroup.back],
        muscleActivationLevels: const {'back': 3},
        difficulty: DifficultyLevel.beginner,
      );

      expect(exercise.toJson()['muscleActivation'], {'back': 3});
    });
  });
}
