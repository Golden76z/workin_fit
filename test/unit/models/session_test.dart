import 'package:flutter_test/flutter_test.dart';
import 'package:workin_fit/models/session.dart';
import 'package:workin_fit/models/workout_config.dart';
import 'package:workin_fit/models/enums.dart';

Session _makeSession({
  List<WorkoutConfig>? workouts,
  int restBetweenExercises = 120,
  int transitionTime = 5,
}) {
  return Session(
    id: 'test_session',
    name: 'Test Session',
    workouts: workouts ?? [],
    difficulty: DifficultyLevel.beginner,
    restBetweenExercises: restBetweenExercises,
    transitionTime: transitionTime,
  );
}

void main() {
  group('Session.exerciseCount', () {
    test('returns 0 for empty session', () {
      expect(_makeSession().exerciseCount, 0);
    });

    test('returns correct count', () {
      final session = _makeSession(workouts: [
        SetsConfig(exerciseId: 'e1', sets: 3, reps: 10),
        TimedConfig(exerciseId: 'e2', duration: 60),
      ]);
      expect(session.exerciseCount, 2);
    });
  });

  group('Session.estimatedDuration', () {
    test('empty session has zero duration', () {
      final session = _makeSession(workouts: []);
      expect(session.estimatedDuration, 0);
    });

    test('single SetsConfig exercise — no inter-exercise rest', () {
      final session = _makeSession(
        workouts: [SetsConfig(exerciseId: 'e1', sets: 3, reps: 10)],
        restBetweenExercises: 120,
        transitionTime: 5,
      );
      // SetsConfig: 210s, rest = (1-1)*120 = 0, transitions = 1*5 = 5
      expect(session.estimatedDuration, 215);
    });

    test('two exercises include one inter-exercise rest', () {
      final session = _makeSession(
        workouts: [
          SetsConfig(exerciseId: 'e1', sets: 1, reps: 5), // 15s work
          TimedConfig(exerciseId: 'e2', duration: 60),     // 60s work
        ],
        restBetweenExercises: 120,
        transitionTime: 0,
      );
      // work = 15 + 60 = 75, rest = (2-1)*120 = 120, transitions = 0
      expect(session.estimatedDuration, 195);
    });

    test('includes TabataConfig duration', () {
      final session = _makeSession(
        workouts: [
          TabataConfig(
              exerciseId: 'e1', workTime: 20, restTime: 10, rounds: 8),
        ],
        restBetweenExercises: 0,
        transitionTime: 0,
      );
      expect(session.estimatedDuration, 240);
    });

    test('includes CircuitConfig duration', () {
      final session = _makeSession(
        workouts: [
          CircuitConfig(
            name: 'Circuit',
            exercises: [TimedConfig(exerciseId: 'e1', duration: 30)],
            rounds: 2,
            restBetweenExercises: 0,
            restBetweenRounds: 60,
          ),
        ],
        restBetweenExercises: 0,
        transitionTime: 0,
      );
      // CircuitConfig: 30*2 + 1*60 = 120
      expect(session.estimatedDuration, 120);
    });

    test('transition time is added per exercise', () {
      final session = _makeSession(
        workouts: [
          TimedConfig(exerciseId: 'e1', duration: 30),
          TimedConfig(exerciseId: 'e2', duration: 30),
        ],
        restBetweenExercises: 0,
        transitionTime: 10,
      );
      // work = 60, rest = 0, transitions = 2*10 = 20
      expect(session.estimatedDuration, 80);
    });
  });

  group('Session.durationDisplay', () {
    test('rounds up to nearest minute', () {
      final session = _makeSession(
        workouts: [TimedConfig(exerciseId: 'e1', duration: 61)],
        restBetweenExercises: 0,
        transitionTime: 0,
      );
      expect(session.durationDisplay, '2 min');
    });

    test('exact minute', () {
      final session = _makeSession(
        workouts: [TimedConfig(exerciseId: 'e1', duration: 120)],
        restBetweenExercises: 0,
        transitionTime: 0,
      );
      expect(session.durationDisplay, '2 min');
    });
  });

  group('Session.hasWorkoutType', () {
    test('returns true when type present', () {
      final session = _makeSession(workouts: [
        SetsConfig(exerciseId: 'e1', sets: 3, reps: 10),
      ]);
      expect(session.hasWorkoutType(WorkoutType.sets), isTrue);
    });

    test('returns false when type absent', () {
      final session = _makeSession(workouts: [
        SetsConfig(exerciseId: 'e1', sets: 3, reps: 10),
      ]);
      expect(session.hasWorkoutType(WorkoutType.tabata), isFalse);
    });
  });

  group('Session.exerciseIds', () {
    test('returns unique exercise IDs', () {
      final session = _makeSession(workouts: [
        SetsConfig(exerciseId: 'e1', sets: 3, reps: 10),
        TabataConfig(exerciseId: 'e1', workTime: 20, restTime: 10, rounds: 8),
        TimedConfig(exerciseId: 'e2', duration: 60),
      ]);
      expect(session.exerciseIds.toSet(), {'e1', 'e2'});
    });
  });

  group('Session JSON serialization', () {
    test('toJson / fromJson roundtrip', () {
      final original = Session(
        id: 'session_1',
        name: 'Test',
        workouts: [
          SetsConfig(exerciseId: 'e1', sets: 3, reps: 10),
          TimedConfig(exerciseId: 'e2', duration: 60),
        ],
        difficulty: DifficultyLevel.intermediate,
        restBetweenExercises: 90,
        transitionTime: 10,
        isCustom: true,
        userId: 'user_1',
      );

      final json = original.toJson();
      final restored = Session.fromJson(json);

      expect(restored.id, 'session_1');
      expect(restored.name, 'Test');
      expect(restored.workouts.length, 2);
      expect(restored.difficulty, DifficultyLevel.intermediate);
      expect(restored.restBetweenExercises, 90);
      expect(restored.isCustom, isTrue);
    });
  });

  group('Session.fromFirestore', () {
    test('handles null createdAt', () {
      final data = {
        'id': 'session_1',
        'name': 'Test',
        'workouts': <dynamic>[],
        'difficulty': 'beginner',
        'restBetweenExercises': 120,
        'transitionTime': 5,
        'isCustom': false,
      };
      final session = Session.fromFirestore(data);
      expect(session.id, 'session_1');
      expect(session.createdAt, isNotNull);
    });

    test('handles ISO string createdAt', () {
      final now = DateTime(2024, 1, 15);
      final data = {
        'id': 'session_1',
        'name': 'Test',
        'workouts': <dynamic>[],
        'difficulty': 'beginner',
        'restBetweenExercises': 120,
        'transitionTime': 5,
        'isCustom': false,
        'createdAt': now.toIso8601String(),
      };
      final session = Session.fromFirestore(data);
      expect(session.createdAt.year, 2024);
      expect(session.createdAt.month, 1);
      expect(session.createdAt.day, 15);
    });
  });
}
