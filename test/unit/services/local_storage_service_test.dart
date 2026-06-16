import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/program.dart';
import 'package:workin_fit/models/session.dart';
import 'package:workin_fit/models/workout_config.dart';
import 'package:workin_fit/services/local_storage_service.dart';

import '../../helpers/hive_test_helper.dart';

Exercise _makeExercise(String id) => Exercise(
      id: id,
      name: 'Exercise $id',
      description: 'desc',
      imageMuscleUrl: '',
      imageTutorialUrl: '',
      muscleGroups: [MuscleGroup.chest],
      difficulty: DifficultyLevel.beginner,
    );

Session _makeSession(String id) => Session(
      id: id,
      name: 'Session $id',
      workouts: [SetsConfig(exerciseId: 'e1', sets: 3, reps: 10)],
      difficulty: DifficultyLevel.beginner,
    );

Program _makeProgram(String id) => Program(
      id: id,
      name: 'Program $id',
      description: 'desc',
      sessionIds: ['s1'],
      durationWeeks: 4,
      difficulty: DifficultyLevel.beginner,
      goals: [],
      daysPerWeek: 3,
    );

void main() {
  late LocalStorageService service;
  late Directory tempDir;

  setUp(() async {
    tempDir = await setUpHive();
    service = LocalStorageService();
  });

  tearDown(() async {
    await tearDownHive(tempDir);
  });

  group('Exercise cache', () {
    test('cacheExercises stores and getCachedExercises retrieves', () async {
      await service.cacheExercises([
        _makeExercise('e1'),
        _makeExercise('e2'),
      ]);
      final cached = await service.getCachedExercises();
      expect(cached.length, 2);
      expect(cached.map((e) => e.id).toSet(), {'e1', 'e2'});
    });

    test('getCachedExercises returns empty list when nothing cached', () async {
      final cached = await service.getCachedExercises();
      expect(cached, isEmpty);
    });

    test('getCachedExercise returns null for unknown id', () async {
      final result = await service.getCachedExercise('unknown');
      expect(result, isNull);
    });

    test('getCachedExercise returns specific exercise', () async {
      await service.cacheExercises([_makeExercise('e1'), _makeExercise('e2')]);
      final result = await service.getCachedExercise('e1');
      expect(result, isNotNull);
      expect(result!.id, 'e1');
    });

    test('cacheExercises clears existing before storing', () async {
      await service.cacheExercises([_makeExercise('e1'), _makeExercise('e2')]);
      await service.cacheExercises([_makeExercise('e3')]);
      final cached = await service.getCachedExercises();
      expect(cached.length, 1);
      expect(cached.first.id, 'e3');
    });

    test('mergeCachedExercises adds only new ids', () async {
      await service.cacheExercises([_makeExercise('e1')]);
      final added = await service.mergeCachedExercises([
        _makeExercise('e1'),
        _makeExercise('e2'),
        _makeExercise('e3'),
      ]);
      expect(added, 2);
      final cached = await service.getCachedExercises();
      expect(cached.map((e) => e.id).toSet(), {'e1', 'e2', 'e3'});
    });

    test('mergeCachedExercises returns 0 when nothing new', () async {
      await service.cacheExercises([_makeExercise('e1')]);
      final added = await service.mergeCachedExercises([_makeExercise('e1')]);
      expect(added, 0);
      expect((await service.getCachedExercises()).length, 1);
    });
  });

  group('Session operations', () {
    test('saveSessionLocally and getLocalSessions', () async {
      await service.saveSessionLocally(_makeSession('s1'));
      await service.saveSessionLocally(_makeSession('s2'));
      final sessions = await service.getLocalSessions();
      expect(sessions.length, 2);
    });

    test('getLocalSessions returns empty list when empty', () async {
      final sessions = await service.getLocalSessions();
      expect(sessions, isEmpty);
    });

    test('getLocalSession returns null for unknown id', () async {
      final result = await service.getLocalSession('unknown');
      expect(result, isNull);
    });

    test('getLocalSession returns specific session', () async {
      await service.saveSessionLocally(_makeSession('s1'));
      final result = await service.getLocalSession('s1');
      expect(result, isNotNull);
      expect(result!.id, 's1');
    });

    test('deleteLocalSession removes session', () async {
      await service.saveSessionLocally(_makeSession('s1'));
      await service.saveSessionLocally(_makeSession('s2'));
      await service.deleteLocalSession('s1');
      final sessions = await service.getLocalSessions();
      expect(sessions.length, 1);
      expect(sessions.first.id, 's2');
    });

    test('clearLocalSessions removes all', () async {
      await service.saveSessionLocally(_makeSession('s1'));
      await service.saveSessionLocally(_makeSession('s2'));
      await service.clearLocalSessions();
      final sessions = await service.getLocalSessions();
      expect(sessions, isEmpty);
    });
  });

  group('Program operations', () {
    test('saveProgramLocally and getLocalPrograms', () async {
      await service.saveProgramLocally(_makeProgram('p1'));
      final programs = await service.getLocalPrograms();
      expect(programs.length, 1);
      expect(programs.first.id, 'p1');
    });

    test('getLocalPrograms returns empty list when empty', () async {
      final programs = await service.getLocalPrograms();
      expect(programs, isEmpty);
    });

    test('getLocalProgram returns null for unknown id', () async {
      final result = await service.getLocalProgram('unknown');
      expect(result, isNull);
    });

    test('cachePrograms stores multiple programs', () async {
      await service.cachePrograms([_makeProgram('p1'), _makeProgram('p2')]);
      final programs = await service.getLocalPrograms();
      expect(programs.length, 2);
    });

    test('deleteLocalProgram removes specific program', () async {
      await service.saveProgramLocally(_makeProgram('p1'));
      await service.saveProgramLocally(_makeProgram('p2'));
      await service.deleteLocalProgram('p1');
      final programs = await service.getLocalPrograms();
      expect(programs.length, 1);
      expect(programs.first.id, 'p2');
    });

    test('clearLocalPrograms removes all', () async {
      await service.cachePrograms([_makeProgram('p1'), _makeProgram('p2')]);
      await service.clearLocalPrograms();
      final programs = await service.getLocalPrograms();
      expect(programs, isEmpty);
    });
  });

  group('Sync queue', () {
    test('markForSync adds item to queue', () async {
      await service.markForSync('session_1', 'session');
      final pending = await service.getPendingSync();
      expect(pending.length, 1);
      expect(pending.first['id'], 'session_1');
      expect(pending.first['type'], 'session');
    });

    test('getPendingSync returns empty when queue empty', () async {
      final pending = await service.getPendingSync();
      expect(pending, isEmpty);
    });

    test('clearSyncItem removes specific item', () async {
      await service.markForSync('s1', 'session');
      await service.markForSync('s2', 'session');
      await service.clearSyncItem('s1', 'session');
      final pending = await service.getPendingSync();
      expect(pending.length, 1);
      expect(pending.first['id'], 's2');
    });

    test('clearSyncQueue removes all items', () async {
      await service.markForSync('s1', 'session');
      await service.markForSync('p1', 'program');
      await service.clearSyncQueue();
      final pending = await service.getPendingSync();
      expect(pending, isEmpty);
    });

    test('markForSync stores type and timestamp', () async {
      await service.markForSync('s1', 'session');
      final pending = await service.getPendingSync();
      expect(pending.first['type'], 'session');
      expect(pending.first['timestamp'], isNotNull);
    });
  });
}
