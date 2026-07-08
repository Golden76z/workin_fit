import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/program.dart';
import 'package:workin_fit/models/session.dart';
import 'package:workin_fit/models/workout_config.dart';
import 'package:workin_fit/providers/workout_providers.dart';
import 'package:workin_fit/services/sync_service.dart';
import 'package:workin_fit/features/auth/domain/auth_provider.dart';

import 'workout_providers_test.mocks.dart';

@GenerateMocks([SyncService])
void main() {
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

  group('exercisesProvider', () {
    test('returns exercises from sync service', () async {
      final mockSync = MockSyncService();
      final exercises = [_makeExercise('e1'), _makeExercise('e2')];
      when(mockSync.getExercises(onCacheUpdated: anyNamed('onCacheUpdated')))
          .thenAnswer((_) async => exercises);

      final container = ProviderContainer(overrides: [
        syncServiceProvider.overrideWithValue(mockSync),
        currentUserProvider.overrideWithValue(null),
      ]);
      addTearDown(container.dispose);

      final result = await container.read(exercisesProvider.future);
      expect(result.length, 2);
    });

    test('exerciseByIdProvider returns specific exercise', () async {
      final mockSync = MockSyncService();
      final exercise = _makeExercise('e1');
      when(mockSync.getExerciseById('e1')).thenAnswer((_) async => exercise);

      final container = ProviderContainer(overrides: [
        syncServiceProvider.overrideWithValue(mockSync),
        currentUserProvider.overrideWithValue(null),
      ]);
      addTearDown(container.dispose);

      final result = await container.read(exerciseByIdProvider('e1').future);
      expect(result, isNotNull);
      expect(result!.id, 'e1');
    });

    test('exerciseByIdProvider returns null for missing exercise', () async {
      final mockSync = MockSyncService();
      when(mockSync.getExerciseById('unknown')).thenAnswer((_) async => null);

      final container = ProviderContainer(overrides: [
        syncServiceProvider.overrideWithValue(mockSync),
        currentUserProvider.overrideWithValue(null),
      ]);
      addTearDown(container.dispose);

      final result =
          await container.read(exerciseByIdProvider('unknown').future);
      expect(result, isNull);
    });
  });

  group('userSessionsProvider', () {
    test('returns empty list when userId is null', () async {
      final mockSync = MockSyncService();

      final container = ProviderContainer(overrides: [
        syncServiceProvider.overrideWithValue(mockSync),
        currentUserProvider.overrideWithValue(null),
      ]);
      addTearDown(container.dispose);

      final result = await container.read(userSessionsProvider.future);
      expect(result, isEmpty);
      verifyNever(mockSync.getSessions(any));
    });

    test('returns sessions when userId is set', () async {
      final mockSync = MockSyncService();
      final sessions = [_makeSession('s1')];
      when(mockSync.getSessions('user_1')).thenAnswer((_) async => sessions);

      final container = ProviderContainer(overrides: [
        syncServiceProvider.overrideWithValue(mockSync),
        currentUserIdProvider.overrideWithValue('user_1'),
      ]);
      addTearDown(container.dispose);

      final result = await container.read(userSessionsProvider.future);
      expect(result.length, 1);
      verify(mockSync.getSessions('user_1')).called(1);
    });
  });

  group('SessionActions', () {
    test('createSession calls sync service', () async {
      final mockSync = MockSyncService();
      final session = _makeSession('s1');
      when(mockSync.createSession('user_1', session)).thenAnswer((_) async {});

      final container = ProviderContainer(overrides: [
        syncServiceProvider.overrideWithValue(mockSync),
        currentUserIdProvider.overrideWithValue('user_1'),
      ]);
      addTearDown(container.dispose);

      await container.read(sessionActionsProvider).createSession(session);

      verify(mockSync.createSession('user_1', session)).called(1);
    });

    test('updateSession calls sync service', () async {
      final mockSync = MockSyncService();
      final session = _makeSession('s1');
      when(mockSync.updateSession('user_1', session)).thenAnswer((_) async {});

      final container = ProviderContainer(overrides: [
        syncServiceProvider.overrideWithValue(mockSync),
        currentUserIdProvider.overrideWithValue('user_1'),
      ]);
      addTearDown(container.dispose);

      await container.read(sessionActionsProvider).updateSession(session);

      verify(mockSync.updateSession('user_1', session)).called(1);
    });

    test('deleteSession calls sync service', () async {
      final mockSync = MockSyncService();
      when(mockSync.deleteSession('user_1', 's1')).thenAnswer((_) async {});

      final container = ProviderContainer(overrides: [
        syncServiceProvider.overrideWithValue(mockSync),
        currentUserIdProvider.overrideWithValue('user_1'),
      ]);
      addTearDown(container.dispose);

      await container.read(sessionActionsProvider).deleteSession('s1');

      verify(mockSync.deleteSession('user_1', 's1')).called(1);
    });
  });

  group('ProgramActions', () {
    test('createProgram calls sync service', () async {
      final mockSync = MockSyncService();
      final program = _makeProgram('p1');
      when(mockSync.createProgram('user_1', program)).thenAnswer((_) async {});

      final container = ProviderContainer(overrides: [
        syncServiceProvider.overrideWithValue(mockSync),
        currentUserIdProvider.overrideWithValue('user_1'),
      ]);
      addTearDown(container.dispose);

      await container.read(programActionsProvider).createProgram(program);

      verify(mockSync.createProgram('user_1', program)).called(1);
    });

    test('deleteProgram calls sync service', () async {
      final mockSync = MockSyncService();
      when(mockSync.deleteProgram('user_1', 'p1')).thenAnswer((_) async {});

      final container = ProviderContainer(overrides: [
        syncServiceProvider.overrideWithValue(mockSync),
        currentUserIdProvider.overrideWithValue('user_1'),
      ]);
      addTearDown(container.dispose);

      await container.read(programActionsProvider).deleteProgram('p1');

      verify(mockSync.deleteProgram('user_1', 'p1')).called(1);
    });
  });
}
