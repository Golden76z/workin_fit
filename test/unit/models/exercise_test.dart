import 'package:flutter_test/flutter_test.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/enums.dart';

Exercise _makeExercise({
  String id = 'ex1',
  List<MuscleGroup> muscleGroups = const [MuscleGroup.chest, MuscleGroup.triceps],
  List<String> equipment = const [],
}) {
  return Exercise(
    id: id,
    name: 'Push Up',
    description: 'A classic push up',
    imageMuscleUrl: 'https://example.com/muscle.png',
    imageTutorialUrl: 'https://example.com/tutorial.gif',
    muscleGroups: muscleGroups,
    difficulty: DifficultyLevel.beginner,
    equipment: equipment,
  );
}

void main() {
  group('Exercise.isBodyweight', () {
    test('returns true when equipment is empty', () {
      expect(_makeExercise(equipment: []).isBodyweight, isTrue);
    });

    test('returns false when equipment is present', () {
      expect(
          _makeExercise(equipment: ['barbell']).isBodyweight, isFalse);
    });
  });

  group('Exercise.muscleGroupsDisplay', () {
    test('joins muscle group names with comma', () {
      final exercise = _makeExercise(
          muscleGroups: [MuscleGroup.chest, MuscleGroup.triceps]);
      expect(exercise.muscleGroupsDisplay, 'chest, triceps');
    });

    test('single muscle group has no comma', () {
      final exercise =
          _makeExercise(muscleGroups: [MuscleGroup.abs]);
      expect(exercise.muscleGroupsDisplay, 'abs');
    });
  });

  group('Exercise JSON serialization', () {
    test('toJson / fromJson roundtrip preserves all fields', () {
      final original = _makeExercise(
        id: 'ex_pushup',
        muscleGroups: [MuscleGroup.chest, MuscleGroup.shoulders],
        equipment: ['mat'],
      );

      final json = original.toJson();
      final restored = Exercise.fromJson(json);

      expect(restored.id, 'ex_pushup');
      expect(restored.name, 'Push Up');
      expect(restored.muscleGroups, [MuscleGroup.chest, MuscleGroup.shoulders]);
      expect(restored.difficulty, DifficultyLevel.beginner);
      expect(restored.equipment, ['mat']);
    });

    test('fromJson handles missing optional beginnerTips', () {
      final json = {
        'id': 'ex1',
        'name': 'Test',
        'description': 'desc',
        'imageMuscleUrl': '',
        'imageTutorialUrl': '',
        'muscleGroups': ['chest'],
        'difficulty': 'beginner',
        'equipment': <dynamic>[],
      };
      final exercise = Exercise.fromJson(json);
      expect(exercise.beginnerTips, isNull);
    });

    test('fromJson uses fallback for unknown muscle group', () {
      final json = {
        'id': 'ex1',
        'name': 'Test',
        'description': 'desc',
        'imageMuscleUrl': '',
        'imageTutorialUrl': '',
        'muscleGroups': ['unknownMuscle'],
        'difficulty': 'beginner',
        'equipment': <dynamic>[],
      };
      final exercise = Exercise.fromJson(json);
      expect(exercise.muscleGroups, [MuscleGroup.abs]);
    });

    test('fromJson without muscleActivation defaults groups to level 3', () {
      final exercise = Exercise.fromJson({
        'id': 'ex1',
        'name': 'Test',
        'description': 'desc',
        'imageMuscleUrl': '',
        'imageTutorialUrl': '',
        'muscleGroups': ['chest', 'triceps'],
        'difficulty': 'beginner',
        'equipment': <dynamic>[],
      });
      expect(exercise.resolvedMuscleActivation, {
        MuscleGroup.chest: 3,
        MuscleGroup.triceps: 3,
      });
    });

    test('fromJson uses fallback for unknown difficulty', () {
      final json = {
        'id': 'ex1',
        'name': 'Test',
        'description': 'desc',
        'imageMuscleUrl': '',
        'imageTutorialUrl': '',
        'muscleGroups': ['chest'],
        'difficulty': 'unknown',
        'equipment': <dynamic>[],
      };
      final exercise = Exercise.fromJson(json);
      expect(exercise.difficulty, DifficultyLevel.beginner);
    });
  });
}
