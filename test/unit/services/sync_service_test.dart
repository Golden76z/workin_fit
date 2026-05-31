import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/program.dart';
import 'package:workin_fit/models/session.dart';
import 'package:workin_fit/models/workout_config.dart';
import 'package:workin_fit/services/firestore_service.dart';
import 'package:workin_fit/services/local_storage_service.dart';
import 'package:workin_fit/services/sync_service.dart';

import 'sync_service_test.mocks.dart';

@GenerateMocks([FirestoreService, LocalStorageService, Connectivity])
void main() {
  late MockFirestoreService mockFirestore;
  late MockLocalStorageService mockStorage;
  late MockConnectivity mockConnectivity;
  late SyncService syncService;

  Session makeSession(String id) => Session(
        id: id,
        name: 'Session $id',
        workouts: [SetsConfig(exerciseId: 'e1', sets: 3, reps: 10)],
        difficulty: DifficultyLevel.beginner,
      );

  Exercise makeExercise(String id) => Exercise(
        id: id,
        name: 'Exercise $id',
        description: 'desc',
        imageMuscleUrl: '',
        imageTutorialUrl: '',
        muscleGroups: [MuscleGroup.chest],
        difficulty: DifficultyLevel.beginner,
      );

  Program makeProgram(String id) => Program(
        id: id,
        name: 'Program $id',
        description: 'desc',
        sessionIds: ['s1'],
        durationWeeks: 4,
        difficulty: DifficultyLevel.beginner,
        goals: [],
        daysPerWeek: 3,
      );

  setUp(() {
    mockFirestore = MockFirestoreService();
    mockStorage = MockLocalStorageService();
    mockConnectivity = MockConnectivity();

    syncService = SyncService(
      firestoreService: mockFirestore,
      localService: mockStorage,
      connectivity: mockConnectivity,
    );
  });

  // Helper to stub connectivity
  void stubOnline() {
    when(mockConnectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.wifi]);
  }

  void stubOffline() {
    when(mockConnectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.none]);
  }

  group('getSessions', () {
    test('online: fetches from Firestore and caches locally', () async {
      final sessions = [makeSession('s1'), makeSession('s2')];
      stubOnline();
      when(mockFirestore.getSessions('user1'))
          .thenAnswer((_) async => sessions);
      when(mockStorage.saveSessionLocally(any)).thenAnswer((_) async {});

      final result = await syncService.getSessions('user1');

      expect(result.length, 2);
      verify(mockFirestore.getSessions('user1')).called(1);
      verify(mockStorage.saveSessionLocally(sessions[0])).called(1);
      verify(mockStorage.saveSessionLocally(sessions[1])).called(1);
    });

    test('offline: returns cached sessions', () async {
      final cached = [makeSession('s1')];
      stubOffline();
      when(mockStorage.getLocalSessions()).thenAnswer((_) async => cached);

      final result = await syncService.getSessions('user1');

      expect(result.length, 1);
      verifyNever(mockFirestore.getSessions(any));
    });

    test('Firestore error: falls back to cache', () async {
      final cached = [makeSession('s1')];
      stubOnline();
      when(mockFirestore.getSessions('user1'))
          .thenThrow(Exception('network error'));
      when(mockStorage.getLocalSessions()).thenAnswer((_) async => cached);

      final result = await syncService.getSessions('user1');

      expect(result.length, 1);
      verify(mockStorage.getLocalSessions()).called(1);
    });
  });

  group('createSession', () {
    test('online: saves locally first, then syncs to Firestore', () async {
      final session = makeSession('s1');
      stubOnline();
      when(mockStorage.saveSessionLocally(session)).thenAnswer((_) async {});
      when(mockFirestore.createSession('user1', session))
          .thenAnswer((_) async {});
      when(mockStorage.clearSyncItem('s1', 'session')).thenAnswer((_) async {});

      await syncService.createSession('user1', session);

      verify(mockStorage.saveSessionLocally(session)).called(1);
      verify(mockFirestore.createSession('user1', session)).called(1);
      verify(mockStorage.clearSyncItem('s1', 'session')).called(1);
    });

    test('offline: saves locally and marks for sync', () async {
      final session = makeSession('s1');
      stubOffline();
      when(mockStorage.saveSessionLocally(session)).thenAnswer((_) async {});
      when(mockStorage.markForSync('s1', 'session')).thenAnswer((_) async {});

      await syncService.createSession('user1', session);

      verify(mockStorage.saveSessionLocally(session)).called(1);
      verify(mockStorage.markForSync('s1', 'session')).called(1);
      verifyNever(mockFirestore.createSession(any, any));
    });

    test('Firestore error: marks for sync and rethrows', () async {
      final session = makeSession('s1');
      stubOnline();
      when(mockStorage.saveSessionLocally(session)).thenAnswer((_) async {});
      when(mockFirestore.createSession('user1', session))
          .thenThrow(Exception('write failed'));
      when(mockStorage.markForSync('s1', 'session')).thenAnswer((_) async {});

      expect(
        () => syncService.createSession('user1', session),
        throwsA(isA<Exception>()),
      );
      // Allow futures to settle
      await Future.delayed(Duration.zero);
      verify(mockStorage.markForSync('s1', 'session')).called(1);
    });
  });

  group('updateSession', () {
    test('online: saves locally and syncs to Firestore', () async {
      final session = makeSession('s1');
      stubOnline();
      when(mockStorage.saveSessionLocally(session)).thenAnswer((_) async {});
      when(mockFirestore.updateSession('user1', session))
          .thenAnswer((_) async {});
      when(mockStorage.clearSyncItem('s1', 'session')).thenAnswer((_) async {});

      await syncService.updateSession('user1', session);

      verify(mockStorage.saveSessionLocally(session)).called(1);
      verify(mockFirestore.updateSession('user1', session)).called(1);
    });

    test('offline: saves locally and marks for sync', () async {
      final session = makeSession('s1');
      stubOffline();
      when(mockStorage.saveSessionLocally(session)).thenAnswer((_) async {});
      when(mockStorage.markForSync('s1', 'session')).thenAnswer((_) async {});

      await syncService.updateSession('user1', session);

      verify(mockStorage.markForSync('s1', 'session')).called(1);
      verifyNever(mockFirestore.updateSession(any, any));
    });
  });

  group('deleteSession', () {
    test('online: deletes locally and from Firestore', () async {
      stubOnline();
      when(mockStorage.deleteLocalSession('s1')).thenAnswer((_) async {});
      when(mockFirestore.deleteSession('user1', 's1')).thenAnswer((_) async {});

      await syncService.deleteSession('user1', 's1');

      verify(mockStorage.deleteLocalSession('s1')).called(1);
      verify(mockFirestore.deleteSession('user1', 's1')).called(1);
    });

    test('offline: only deletes locally, no exception', () async {
      stubOffline();
      when(mockStorage.deleteLocalSession('s1')).thenAnswer((_) async {});

      await syncService.deleteSession('user1', 's1');

      verify(mockStorage.deleteLocalSession('s1')).called(1);
      verifyNever(mockFirestore.deleteSession(any, any));
    });
  });

  group('getExercises', () {
    test('returns cache immediately; background merge only adds new ids',
        () async {
      final cached = [makeExercise('e1')];
      final remote = [makeExercise('e1'), makeExercise('e2')];
      when(mockStorage.getCachedExercises()).thenAnswer((_) async => cached);
      when(mockFirestore.getExercises()).thenAnswer((_) async => remote);
      when(mockStorage.mergeCachedExercises(remote)).thenAnswer((_) async => 1);

      final result = await syncService.getExercises();
      expect(result, cached);

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      verify(mockFirestore.getExercises()).called(1);
      verify(mockStorage.mergeCachedExercises(remote)).called(1);
      verifyNever(mockStorage.cacheExercises(any));

      // Second call within throttle window should not hit Firestore again.
      when(mockStorage.getCachedExercises()).thenAnswer((_) async => remote);
      await syncService.getExercises();
      await Future<void>.delayed(Duration.zero);
      verifyNoMoreInteractions(mockFirestore);
    });

    test('background sync does not shrink cache when Firestore has fewer docs',
        () async {
      final cached = [
        makeExercise('e1'),
        makeExercise('e2'),
        makeExercise('e3'),
      ];
      final remote = [makeExercise('e1')];
      when(mockStorage.getCachedExercises()).thenAnswer((_) async => cached);
      when(mockFirestore.getExercises()).thenAnswer((_) async => remote);

      await syncService.getExercises();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      verify(mockFirestore.getExercises()).called(1);
      verifyNever(mockStorage.cacheExercises(any));
      verifyNever(mockStorage.mergeCachedExercises(any));
    });

    test('empty cache: fetches Firestore before returning', () async {
      final remote = [makeExercise('e1'), makeExercise('e2')];
      when(mockStorage.getCachedExercises()).thenAnswer((_) async => []);
      when(mockFirestore.getExercises()).thenAnswer((_) async => remote);
      when(mockStorage.cacheExercises(remote)).thenAnswer((_) async {});

      final result = await syncService.getExercises();

      expect(result, remote);
      verify(mockStorage.cacheExercises(remote)).called(1);
    });

    test('returns cache when Firestore fails and cache exists', () async {
      final cached = [makeExercise('e1')];
      when(mockStorage.getCachedExercises()).thenAnswer((_) async => cached);
      when(mockFirestore.getExercises()).thenThrow(Exception('network'));

      final result = await syncService.getExercises();

      expect(result, cached);
    });
  });

  group('syncPendingChanges', () {
    test('offline: returns early without processing', () async {
      stubOffline();

      await syncService.syncPendingChanges('user1');

      verifyNever(mockStorage.getPendingSync());
    });

    test('online with empty queue: does not call Firestore', () async {
      stubOnline();
      when(mockStorage.getPendingSync()).thenAnswer((_) async => []);

      await syncService.syncPendingChanges('user1');

      verifyNever(mockFirestore.createSession(any, any));
      verifyNever(mockFirestore.updateSession(any, any));
    });

    test('online: creates session when not in Firestore', () async {
      final session = makeSession('s1');
      stubOnline();
      when(mockStorage.getPendingSync()).thenAnswer((_) async => [
            {'id': 's1', 'type': 'session'}
          ]);
      when(mockStorage.getLocalSession('s1')).thenAnswer((_) async => session);
      when(mockFirestore.getSessionById('user1', 's1'))
          .thenAnswer((_) async => null);
      when(mockFirestore.createSession('user1', session))
          .thenAnswer((_) async {});
      when(mockStorage.clearSyncItem('s1', 'session')).thenAnswer((_) async {});

      await syncService.syncPendingChanges('user1');

      verify(mockFirestore.createSession('user1', session)).called(1);
      verify(mockStorage.clearSyncItem('s1', 'session')).called(1);
    });

    test('online: updates session when already in Firestore', () async {
      final session = makeSession('s1');
      final existingSession = makeSession('s1');
      stubOnline();
      when(mockStorage.getPendingSync()).thenAnswer((_) async => [
            {'id': 's1', 'type': 'session'}
          ]);
      when(mockStorage.getLocalSession('s1')).thenAnswer((_) async => session);
      when(mockFirestore.getSessionById('user1', 's1'))
          .thenAnswer((_) async => existingSession);
      when(mockFirestore.updateSession('user1', session))
          .thenAnswer((_) async {});
      when(mockStorage.clearSyncItem('s1', 'session')).thenAnswer((_) async {});

      await syncService.syncPendingChanges('user1');

      verify(mockFirestore.updateSession('user1', session)).called(1);
      verifyNever(mockFirestore.createSession(any, any));
    });

    test('online: processes program sync item', () async {
      final program = makeProgram('p1');
      stubOnline();
      when(mockStorage.getPendingSync()).thenAnswer((_) async => [
            {'id': 'p1', 'type': 'program'}
          ]);
      when(mockStorage.getLocalProgram('p1')).thenAnswer((_) async => program);
      when(mockFirestore.getProgramById('p1', userId: 'user1'))
          .thenAnswer((_) async => null);
      when(mockFirestore.createProgram('user1', program))
          .thenAnswer((_) async {});
      when(mockStorage.clearSyncItem('p1', 'program')).thenAnswer((_) async {});

      await syncService.syncPendingChanges('user1');

      verify(mockFirestore.createProgram('user1', program)).called(1);
    });
  });
}
