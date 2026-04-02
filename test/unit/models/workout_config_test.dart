import 'package:flutter_test/flutter_test.dart';
import 'package:workin_fit/models/workout_config.dart';
import 'package:workin_fit/models/enums.dart';

void main() {
  group('SetsConfig', () {
    test('totalReps is sets * reps', () {
      final config = SetsConfig(exerciseId: 'e1', sets: 3, reps: 10);
      expect(config.totalReps, 30);
    });

    test('estimatedWorkDuration is totalReps * 3 seconds', () {
      final config = SetsConfig(exerciseId: 'e1', sets: 3, reps: 10);
      expect(config.estimatedWorkDuration, 90);
    });

    test('totalRestTime is (sets - 1) * restBetweenSets', () {
      final config =
          SetsConfig(exerciseId: 'e1', sets: 3, reps: 10, restBetweenSets: 60);
      expect(config.totalRestTime, 120);
    });

    test('estimatedTotalTime sums work and rest', () {
      final config =
          SetsConfig(exerciseId: 'e1', sets: 3, reps: 10, restBetweenSets: 60);
      expect(config.estimatedTotalTime, 210); // 90 work + 120 rest
    });

    test('single set has zero rest time', () {
      final config =
          SetsConfig(exerciseId: 'e1', sets: 1, reps: 5, restBetweenSets: 60);
      expect(config.totalRestTime, 0);
      expect(config.estimatedTotalTime, 15); // 5 * 3
    });

    test('type is WorkoutType.sets', () {
      final config = SetsConfig(exerciseId: 'e1', sets: 3, reps: 10);
      expect(config.type, WorkoutType.sets);
    });

    test('toJson includes type field', () {
      final config = SetsConfig(exerciseId: 'e1', sets: 3, reps: 10);
      final json = config.toJson();
      expect(json['type'], 'sets');
      expect(json['sets'], 3);
      expect(json['reps'], 10);
    });

    test('fromJson roundtrip preserves values', () {
      final original =
          SetsConfig(exerciseId: 'e1', sets: 3, reps: 10, restBetweenSets: 90);
      final json = original.toJson();
      final restored = WorkoutConfig.fromJson(json) as SetsConfig;
      expect(restored.sets, 3);
      expect(restored.reps, 10);
      expect(restored.restBetweenSets, 90);
      expect(restored.exerciseId, 'e1');
    });

    test('weight fields are optional', () {
      final config = SetsConfig(
        exerciseId: 'e1',
        sets: 3,
        reps: 10,
        weight: 50.0,
        weightUnit: 'kg',
      );
      expect(config.weight, 50.0);
      expect(config.weightUnit, 'kg');

      final noWeight = SetsConfig(exerciseId: 'e1', sets: 3, reps: 10);
      expect(noWeight.weight, isNull);
    });
  });

  group('TabataConfig', () {
    test('totalWorkTime is workTime * rounds', () {
      final config = TabataConfig(
          exerciseId: 'e1', workTime: 20, restTime: 10, rounds: 8);
      expect(config.totalWorkTime, 160);
    });

    test('totalRestTime is restTime * rounds', () {
      final config = TabataConfig(
          exerciseId: 'e1', workTime: 20, restTime: 10, rounds: 8);
      expect(config.totalRestTime, 80);
    });

    test('singleSetDuration is totalWork + totalRest', () {
      final config = TabataConfig(
          exerciseId: 'e1', workTime: 20, restTime: 10, rounds: 8);
      expect(config.singleSetDuration, 240);
    });

    test('totalDuration with single set equals singleSetDuration', () {
      final config = TabataConfig(
          exerciseId: 'e1', workTime: 20, restTime: 10, rounds: 8, sets: 1);
      expect(config.totalDuration, 240);
    });

    test('totalDuration with multiple sets includes inter-set rest', () {
      final config = TabataConfig(
        exerciseId: 'e1',
        workTime: 20,
        restTime: 10,
        rounds: 8,
        sets: 2,
        restBetweenSets: 60,
      );
      // (240 * 2) + (1 * 60) = 540
      expect(config.totalDuration, 540);
    });

    test('type is WorkoutType.tabata', () {
      final config = TabataConfig(
          exerciseId: 'e1', workTime: 20, restTime: 10, rounds: 8);
      expect(config.type, WorkoutType.tabata);
    });

    test('toJson includes type field', () {
      final config = TabataConfig(
          exerciseId: 'e1', workTime: 20, restTime: 10, rounds: 8);
      final json = config.toJson();
      expect(json['type'], 'tabata');
      expect(json['workTime'], 20);
      expect(json['restTime'], 10);
      expect(json['rounds'], 8);
    });

    test('fromJson roundtrip preserves values', () {
      final original = TabataConfig(
          exerciseId: 'e1', workTime: 20, restTime: 10, rounds: 8, sets: 2);
      final json = original.toJson();
      final restored = WorkoutConfig.fromJson(json) as TabataConfig;
      expect(restored.workTime, 20);
      expect(restored.restTime, 10);
      expect(restored.rounds, 8);
      expect(restored.sets, 2);
    });
  });

  group('TimedConfig', () {
    test('totalDuration equals duration field', () {
      final config = TimedConfig(exerciseId: 'e1', duration: 60);
      expect(config.totalDuration, 60);
    });

    test('type is WorkoutType.timed', () {
      final config = TimedConfig(exerciseId: 'e1', duration: 60);
      expect(config.type, WorkoutType.timed);
    });

    test('toJson includes type field', () {
      final config = TimedConfig(exerciseId: 'e1', duration: 60);
      final json = config.toJson();
      expect(json['type'], 'timed');
      expect(json['duration'], 60);
    });

    test('fromJson roundtrip preserves values', () {
      final original = TimedConfig(exerciseId: 'e1', duration: 45);
      final json = original.toJson();
      final restored = WorkoutConfig.fromJson(json) as TimedConfig;
      expect(restored.duration, 45);
      expect(restored.exerciseId, 'e1');
    });
  });

  group('CircuitConfig', () {
    test('totalDuration with single round and single exercise', () {
      final circuit = CircuitConfig(
        name: 'Test',
        exercises: [TimedConfig(exerciseId: 'e1', duration: 30)],
        rounds: 1,
        restBetweenExercises: 0,
        restBetweenRounds: 60,
      );
      expect(circuit.totalDuration, 30);
    });

    test('totalDuration removes trailing restBetweenExercises', () {
      final circuit = CircuitConfig(
        name: 'Test',
        exercises: [
          TimedConfig(exerciseId: 'e1', duration: 30),
          TimedConfig(exerciseId: 'e2', duration: 20),
        ],
        rounds: 1,
        restBetweenExercises: 10,
        restBetweenRounds: 60,
      );
      // perRound = 30 + 10 + 20 + 10 - 10 (trailing) = 60
      // total = 60 * 1 + 0 inter-round = 60
      expect(circuit.totalDuration, 60);
    });

    test('totalDuration with multiple rounds includes inter-round rest', () {
      final circuit = CircuitConfig(
        name: 'Test',
        exercises: [
          TimedConfig(exerciseId: 'e1', duration: 30),
          TimedConfig(exerciseId: 'e2', duration: 20),
        ],
        rounds: 3,
        restBetweenExercises: 10,
        restBetweenRounds: 60,
      );
      // perRound = 30 + 10 + 20 = 60 (trailing rest removed)
      // total = 60 * 3 + 2 * 60 = 300
      expect(circuit.totalDuration, 300);
    });

    test('totalDuration with SetsConfig exercises', () {
      final circuit = CircuitConfig(
        name: 'Test',
        exercises: [
          SetsConfig(
              exerciseId: 'e1', sets: 3, reps: 10, restBetweenSets: 60),
        ],
        rounds: 2,
        restBetweenExercises: 0,
        restBetweenRounds: 90,
      );
      // SetsConfig.estimatedTotalTime = 90 + 120 = 210
      // perRound = 210, total = 210 * 2 + 1 * 90 = 510
      expect(circuit.totalDuration, 510);
    });

    test('totalDuration with TabataConfig exercise', () {
      final circuit = CircuitConfig(
        name: 'Test',
        exercises: [
          TabataConfig(
              exerciseId: 'e1', workTime: 20, restTime: 10, rounds: 8),
        ],
        rounds: 1,
        restBetweenExercises: 0,
        restBetweenRounds: 60,
      );
      // TabataConfig.totalDuration = 240
      expect(circuit.totalDuration, 240);
    });

    test('type is WorkoutType.circuit', () {
      final circuit = CircuitConfig(
        name: 'Test',
        exercises: [],
        rounds: 3,
      );
      expect(circuit.type, WorkoutType.circuit);
    });

    test('exerciseId is empty string', () {
      final circuit = CircuitConfig(name: 'Test', exercises: [], rounds: 1);
      expect(circuit.exerciseId, '');
    });

    test('toJson / fromJson roundtrip', () {
      final original = CircuitConfig(
        name: 'Cardio Blast',
        exercises: [
          TimedConfig(exerciseId: 'e1', duration: 30),
          SetsConfig(exerciseId: 'e2', sets: 2, reps: 5),
        ],
        rounds: 3,
        restBetweenExercises: 15,
        restBetweenRounds: 60,
      );
      final json = original.toJson();
      final restored = WorkoutConfig.fromJson(json) as CircuitConfig;
      expect(restored.name, 'Cardio Blast');
      expect(restored.rounds, 3);
      expect(restored.exercises.length, 2);
      expect(restored.restBetweenExercises, 15);
      expect(restored.restBetweenRounds, 60);
    });
  });

  group('WorkoutConfig.fromJson type inference (no type field)', () {
    test('infers tabata from workTime field', () {
      final json = {
        'exerciseId': 'e1',
        'workTime': 20,
        'restTime': 10,
        'rounds': 8,
      };
      final config = WorkoutConfig.fromJson(json);
      expect(config.type, WorkoutType.tabata);
    });

    test('infers tabata from rounds field', () {
      final json = {
        'exerciseId': 'e1',
        'rounds': 8,
        'workTime': 20,
        'restTime': 10,
      };
      final config = WorkoutConfig.fromJson(json);
      expect(config.type, WorkoutType.tabata);
    });

    test('infers circuit from exercises field', () {
      final json = {
        'name': 'Test Circuit',
        'exercises': <dynamic>[],
        'rounds': 3,
      };
      final config = WorkoutConfig.fromJson(json);
      expect(config.type, WorkoutType.circuit);
    });

    test('infers timed from duration without reps', () {
      final json = {
        'exerciseId': 'e1',
        'duration': 60,
      };
      final config = WorkoutConfig.fromJson(json);
      expect(config.type, WorkoutType.timed);
    });

    test('defaults to sets when no type-specific fields present', () {
      final json = {
        'exerciseId': 'e1',
        'sets': 3,
        'reps': 10,
      };
      final config = WorkoutConfig.fromJson(json);
      expect(config.type, WorkoutType.sets);
    });

    test('explicit type field takes precedence', () {
      final json = {
        'exerciseId': 'e1',
        'type': 'tabata',
        'workTime': 20,
        'restTime': 10,
        'rounds': 8,
      };
      final config = WorkoutConfig.fromJson(json);
      expect(config.type, WorkoutType.tabata);
    });
  });
}
