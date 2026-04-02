import 'package:flutter_test/flutter_test.dart';
import 'package:workin_fit/models/exercise_model.dart';
import 'package:workin_fit/models/session_model.dart';
import 'package:workin_fit/models/workout_set_model.dart';
import 'package:workin_fit/models/tabata_config_model.dart';

void main() {
  group('ExerciseModel', () {
    test('fromJson / toJson roundtrip', () {
      final json = {
        'id': 'ex1',
        'name': 'Push Up',
        'description': 'Classic push up',
        'muscleGroups': ['chest', 'triceps'],
        'imageUrl': 'https://example.com/img.gif',
        'difficulty': 'beginner',
      };

      final model = ExerciseModel.fromJson(json);
      expect(model.id, 'ex1');
      expect(model.name, 'Push Up');
      expect(model.muscleGroups, ['chest', 'triceps']);
      expect(model.difficulty, 'beginner');
      expect(model.tips, isNull);

      final roundTrip = ExerciseModel.fromJson(model.toJson());
      expect(roundTrip.id, model.id);
      expect(roundTrip.name, model.name);
    });

    test('fromFirestore uses provided id override', () {
      final data = {
        'id': 'old_id',
        'name': 'Squat',
        'description': 'Squat exercise',
        'muscleGroups': ['quads'],
        'imageUrl': '',
        'difficulty': 'intermediate',
      };
      final model = ExerciseModel.fromFirestore(data, id: 'doc_id');
      expect(model.id, 'doc_id');
    });

    test('copyWith updates only specified fields', () {
      const original = ExerciseModel(
        id: 'ex1',
        name: 'Original',
        description: 'desc',
        muscleGroups: ['chest'],
        imageUrl: '',
        difficulty: 'beginner',
      );
      final updated = original.copyWith(name: 'Updated');
      expect(updated.name, 'Updated');
      expect(updated.id, 'ex1');
    });

    test('optional tips field preserved in roundtrip', () {
      final json = {
        'id': 'ex1',
        'name': 'Plank',
        'description': 'Core exercise',
        'muscleGroups': ['abs'],
        'imageUrl': '',
        'difficulty': 'beginner',
        'tips': 'Keep back flat',
      };
      final model = ExerciseModel.fromJson(json);
      expect(model.tips, 'Keep back flat');
      expect(ExerciseModel.fromJson(model.toJson()).tips, 'Keep back flat');
    });
  });

  group('WorkoutSetModel', () {
    test('fromJson / toJson roundtrip', () {
      final json = {
        'exerciseId': 'ex1',
        'sets': 3,
        'reps': 10,
        'restTime': 60,
      };
      final model = WorkoutSetModel.fromJson(json);
      expect(model.exerciseId, 'ex1');
      expect(model.sets, 3);
      expect(model.reps, 10);
      expect(model.restTime, 60);

      final restored = WorkoutSetModel.fromJson(model.toJson());
      expect(restored.sets, 3);
    });

    test('copyWith updates only specified fields', () {
      const original = WorkoutSetModel(
          exerciseId: 'ex1', sets: 3, reps: 10, restTime: 60);
      final updated = original.copyWith(sets: 5);
      expect(updated.sets, 5);
      expect(updated.reps, 10);
    });

    test('fromFirestore works same as fromJson', () {
      final data = {
        'exerciseId': 'ex1',
        'sets': 4,
        'reps': 8,
        'restTime': 90,
      };
      final model = WorkoutSetModel.fromFirestore(data);
      expect(model.sets, 4);
    });
  });

  group('TabataConfigModel', () {
    test('fromJson / toJson roundtrip', () {
      final json = {
        'exerciseId': 'ex1',
        'workTime': 20,
        'restTime': 10,
        'rounds': 8,
      };
      final model = TabataConfigModel.fromJson(json);
      expect(model.workTime, 20);
      expect(model.restTime, 10);
      expect(model.rounds, 8);

      final restored = TabataConfigModel.fromJson(model.toJson());
      expect(restored.workTime, 20);
    });

    test('copyWith updates only specified fields', () {
      const original = TabataConfigModel(
          exerciseId: 'ex1', workTime: 20, restTime: 10, rounds: 8);
      final updated = original.copyWith(rounds: 10);
      expect(updated.rounds, 10);
      expect(updated.workTime, 20);
    });
  });

  group('SessionModel', () {
    final exerciseJson = {
      'exerciseId': 'ex1',
      'sets': 3,
      'reps': 10,
      'restTime': 60,
    };

    test('fromJson / toJson roundtrip', () {
      final json = {
        'id': 'sess1',
        'name': 'Morning Workout',
        'exercises': [exerciseJson],
        'duration': 1800,
        'difficulty': 'beginner',
      };
      final model = SessionModel.fromJson(json);
      expect(model.id, 'sess1');
      expect(model.exercises.length, 1);
      expect(model.duration, 1800);

      final restored = SessionModel.fromJson(model.toJson());
      expect(restored.name, 'Morning Workout');
    });

    test('optional description is null by default', () {
      final json = {
        'id': 'sess1',
        'name': 'Test',
        'exercises': <dynamic>[],
        'duration': 600,
        'difficulty': 'beginner',
      };
      final model = SessionModel.fromJson(json);
      expect(model.description, isNull);
    });

    test('fromFirestore uses provided id override', () {
      final data = {
        'id': 'old',
        'name': 'Test',
        'exercises': <dynamic>[],
        'duration': 600,
        'difficulty': 'beginner',
      };
      final model = SessionModel.fromFirestore(data, id: 'doc_id');
      expect(model.id, 'doc_id');
    });

    test('asWorkoutSet parses exercise at index', () {
      final json = {
        'id': 's1',
        'name': 'Test',
        'exercises': [exerciseJson],
        'duration': 600,
        'difficulty': 'beginner',
      };
      final model = SessionModel.fromJson(json);
      final workoutSet = model.asWorkoutSet(0);
      expect(workoutSet.exerciseId, 'ex1');
      expect(workoutSet.sets, 3);
    });

    test('copyWith updates only specified fields', () {
      final original = SessionModel(
        id: 's1',
        name: 'Original',
        exercises: [],
        duration: 600,
        difficulty: 'beginner',
      );
      final updated = original.copyWith(name: 'Updated');
      expect(updated.name, 'Updated');
      expect(updated.id, 's1');
    });
  });
}
