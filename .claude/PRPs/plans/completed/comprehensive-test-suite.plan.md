# Plan: Comprehensive Test Suite

## Summary
Build a comprehensive test suite for the workin_fit Flutter app covering unit tests for all models, auth flows, workout logic (timers/sets/tabata), offline sync, and widget tests for key screens. Starting from near-zero coverage, the goal is 70%+ code coverage with no flaky tests.

## User Story
As a developer, I want comprehensive tests for all critical app paths, so that regressions are caught automatically in CI/CD and the codebase can be evolved safely.

## Problem → Solution
0% test coverage (single placeholder test) → 70%+ coverage with unit, widget, and integration tests for models, auth, workout logic, sync, and providers.

## Metadata
- **Complexity**: Large
- **Source PRD**: N/A
- **PRD Phase**: N/A (issue #32)
- **Estimated Files**: 25–30 test files

---

## UX Design

N/A — internal change. No user-facing UX transformation.

---

## Mandatory Reading

| Priority | File | Lines | Why |
|---|---|---|---|
| P0 | `lib/models/workout_config.dart` | 1–257 | Core duration calc logic to test |
| P0 | `lib/models/session.dart` | 1–130 | Session duration aggregation |
| P0 | `lib/services/sync_service.dart` | 1–426 | Offline-first logic to mock/test |
| P0 | `lib/services/local_storage_service.dart` | 1–137 | Hive operations to test |
| P1 | `lib/features/auth/domain/auth_provider.dart` | 1–143 | Auth providers and AuthActions |
| P1 | `lib/repository/auth_repository.dart` | all | Firebase Auth wrapper |
| P1 | `lib/providers/workout_providers.dart` | 1–441 | Riverpod providers |
| P2 | `lib/models/exercise.dart` | all | Hive model serialization |
| P2 | `lib/models/program.dart` | all | Hive model serialization |
| P2 | `lib/models/enums.dart` | all | Enum types used throughout |
| P2 | `pubspec.yaml` | 64–78 | Test dependencies (mockito, fake_cloud_firestore, firebase_auth_mocks) |

## External Documentation
| Topic | Source | Key Takeaway |
|---|---|---|
| flutter_test | Flutter SDK | Use `WidgetTester`, `testWidgets`, `find` for widget tests |
| mockito | pub.dev/packages/mockito | Use `@GenerateMocks` annotation + `build_runner` to generate mocks |
| fake_cloud_firestore | pub.dev/packages/fake_cloud_firestore | In-memory Firestore, no emulator needed |
| firebase_auth_mocks | pub.dev/packages/firebase_auth_mocks | `MockFirebaseAuth` with `signedIn` flag |
| Riverpod testing | riverpod.dev | Use `ProviderContainer` for unit testing providers |
| Hive testing | hivedb.dev | Use `Hive.init(tempDir)` in setUp, delete after |

---

## Patterns to Mirror

### NAMING_CONVENTION
```dart
// SOURCE: test/widget_test.dart:1
// Test files: {feature}_test.dart
// Test groups: group('ClassName', () { ... })
// Test cases: test('methodName does X when Y', () { ... })
// Widget tests: testWidgets('Widget shows X', (tester) async { ... })
```

### ERROR_HANDLING
```dart
// SOURCE: lib/services/sync_service.dart:39-42
try {
  // operation
} catch (e, st) {
  debugPrint('[SyncService.getSessions] ERROR: $e\n$st');
  return await _localService.getLocalSessions();  // fallback
}
// Tests should verify: (1) happy path, (2) error path returns fallback
```

### MOCK_PATTERN (mockito)
```dart
// Generated mocks via build_runner
@GenerateMocks([FirestoreService, LocalStorageService, Connectivity])
import 'sync_service_test.mocks.dart';

setUp(() {
  mockFirestore = MockFirestoreService();
  mockStorage = MockLocalStorageService();
});

when(mockFirestore.getSessions(any)).thenAnswer((_) async => [session]);
verify(mockFirestore.getSessions('user123')).called(1);
```

### HIVE_TEST_SETUP
```dart
// SOURCE: lib/services/local_storage_service.dart:16
// For Hive tests: init with temp dir, register adapters, tearDown
setUp(() async {
  final dir = await Directory.systemTemp.createTemp();
  Hive.init(dir.path);
  Hive.registerAdapter(SessionAdapter());
  // etc.
});
tearDown(() async {
  await Hive.deleteFromDisk();
});
```

### RIVERPOD_TEST_SETUP
```dart
// SOURCE: lib/providers/workout_providers.dart:11-26
// Use ProviderContainer with overrides for isolated provider tests
final container = ProviderContainer(
  overrides: [
    syncServiceProvider.overrideWithValue(mockSyncService),
    currentUserIdProvider.overrideWithValue('test_user'),
  ],
);
addTearDown(container.dispose);
```

### FIRESTORE_TEST_SETUP
```dart
// SOURCE: lib/services/firestore_service.dart
// Use fake_cloud_firestore for integration-style tests
final fakeFirestore = FakeFirebaseFirestore();
final mockAuth = MockFirebaseAuth(signedIn: true);
```

### DURATION_CALC_TEST
```dart
// SOURCE: lib/models/workout_config.dart:82-92
// SetsConfig: totalReps * 3 + (sets-1) * restBetweenSets
test('SetsConfig estimatedTotalTime', () {
  final config = SetsConfig(exerciseId: 'e1', sets: 3, reps: 10, restBetweenSets: 60);
  expect(config.totalReps, 30);
  expect(config.estimatedWorkDuration, 90);   // 30 * 3
  expect(config.totalRestTime, 120);          // (3-1) * 60
  expect(config.estimatedTotalTime, 210);     // 90 + 120
});
```

---

## Files to Change

| File | Action | Justification |
|---|---|---|
| `test/widget_test.dart` | UPDATE | Replace placeholder with real tests |
| `test/unit/models/workout_config_test.dart` | CREATE | Duration calc unit tests |
| `test/unit/models/session_test.dart` | CREATE | Session duration + serialization |
| `test/unit/models/exercise_test.dart` | CREATE | Exercise model serialization |
| `test/unit/models/program_test.dart` | CREATE | Program model serialization |
| `test/unit/models/session_model_test.dart` | CREATE | API model JSON roundtrip |
| `test/unit/models/workout_set_model_test.dart` | CREATE | Workout set model tests |
| `test/unit/models/tabata_config_model_test.dart` | CREATE | Tabata config model tests |
| `test/unit/models/achievement_test.dart` | CREATE | Achievement model tests |
| `test/unit/services/local_storage_service_test.dart` | CREATE | Hive CRUD + sync queue |
| `test/unit/services/sync_service_test.dart` | CREATE | Offline-first logic with mocks |
| `test/unit/services/auth_repository_test.dart` | CREATE | Auth methods with firebase_auth_mocks |
| `test/unit/providers/auth_provider_test.dart` | CREATE | AuthActions with ProviderContainer |
| `test/unit/providers/workout_providers_test.dart` | CREATE | SessionActions, programActionsProvider |
| `test/widget/screens/workout_execution_screen_test.dart` | CREATE | Timer UI widget test |
| `test/widget/screens/session_detail_screen_test.dart` | CREATE | Session detail widget test |
| `test/widget/screens/auth_screens_test.dart` | CREATE | Login/register form validation |

## NOT Building
- E2E tests requiring a running device/emulator (out of scope for this branch)
- Tests for `workout_execution_screen.dart` internal timer logic (uses `stop_watch_timer` package, keep widget-level only)
- Tests for social features (chat, friends, leaderboard) — lower priority
- Performance benchmarks

---

## Step-by-Step Tasks

### Task 1: Set Up Test Infrastructure
- **ACTION**: Create test directory structure and add any missing test helpers
- **IMPLEMENT**: Create `test/helpers/` directory with `hive_test_helper.dart` and `riverpod_test_helper.dart` containing shared setUp/tearDown logic
- **MIRROR**: HIVE_TEST_SETUP pattern
- **IMPORTS**: `package:hive_flutter/hive_flutter.dart`, `dart:io`
- **GOTCHA**: Must call `Hive.registerAdapter()` for every Hive type used in tests (Exercise, Session, Program, WorkoutConfig subtypes, enums). Check `lib/core/utils/hive_helpers.dart` for the full adapter registration list.
- **VALIDATE**: Run `flutter test test/` — all tests pass

### Task 2: Unit Tests — WorkoutConfig Duration Calculations
- **ACTION**: Create `test/unit/models/workout_config_test.dart`
- **IMPLEMENT**: Test all four WorkoutConfig subtypes:
  - `SetsConfig`: `totalReps`, `estimatedWorkDuration`, `totalRestTime`, `estimatedTotalTime`
  - `TabataConfig`: `totalWorkTime`, `totalRestTime`, `singleSetDuration`, `totalDuration` (single set and multi-set)
  - `TimedConfig`: `totalDuration`
  - `CircuitConfig`: `totalDuration` with mixed exercise types, trailing rest removal, multi-round rest
  - JSON roundtrip for each subtype (serialize → deserialize → equal)
  - `WorkoutConfig.fromJson` type inference: field-based detection (no `type` key, has `exercises`, has `workTime`, has `duration`)
- **MIRROR**: DURATION_CALC_TEST pattern
- **IMPORTS**: `package:flutter_test/flutter_test.dart`, `package:workin_fit/models/workout_config.dart`, `package:workin_fit/models/enums.dart`
- **GOTCHA**: CircuitConfig `totalDuration` removes one trailing `restBetweenExercises` from `perRound` (line 228 of workout_config.dart). Test this edge case explicitly.
- **VALIDATE**: `flutter test test/unit/models/workout_config_test.dart` — 20+ assertions pass

### Task 3: Unit Tests — Session Model
- **ACTION**: Create `test/unit/models/session_test.dart`
- **IMPLEMENT**:
  - `estimatedDuration` with multiple workout types including CircuitConfig
  - `exerciseCount` getter
  - `durationDisplay` human-readable string
  - `hasWorkoutType()` check
  - `exerciseIds` getter (unique IDs from workouts)
  - JSON roundtrip (`toJson` / `fromJson`)
  - `toFirestore` / `fromFirestore` with Timestamp conversion
  - `fromFirestore` handles null `createdAt`, Timestamp object, and String
- **MIRROR**: DURATION_CALC_TEST pattern
- **IMPORTS**: `package:flutter_test/flutter_test.dart`, `package:workin_fit/models/session.dart`
- **GOTCHA**: `estimatedDuration` adds `(exerciseCount - 1) * restBetweenExercises` + `exerciseCount * transitionTime`. With zero workouts, `(0-1)` would be -1 × rest — test empty session edge case.
- **VALIDATE**: `flutter test test/unit/models/session_test.dart`

### Task 4: Unit Tests — Exercise and Program Models
- **ACTION**: Create `test/unit/models/exercise_test.dart` and `test/unit/models/program_test.dart`
- **IMPLEMENT**:
  - Exercise: JSON roundtrip, Hive serialization fields, `muscleGroupsDisplay` getter
  - Program: JSON roundtrip, `sessionCount` getter, difficulty level serialization
- **MIRROR**: NAMING_CONVENTION pattern for test naming
- **IMPORTS**: relevant model packages
- **GOTCHA**: Exercise and Program use `@HiveType` — these tests do NOT need Hive initialized since we're only testing JSON (no box operations). Only test Hive when testing LocalStorageService.
- **VALIDATE**: `flutter test test/unit/models/`

### Task 5: Unit Tests — API Models (JSON Only)
- **ACTION**: Create `test/unit/models/session_model_test.dart`, `workout_set_model_test.dart`, `tabata_config_model_test.dart`
- **IMPLEMENT**: For each API model:
  - `fromJson` with valid data
  - `toJson` roundtrip
  - `fromJson` with missing optional fields (null safety)
  - `fromJson` with wrong types (graceful handling)
- **MIRROR**: NAMING_CONVENTION pattern
- **IMPORTS**: model files from `lib/models/`
- **GOTCHA**: API models (`*_model.dart`) are separate from Hive models. No adapter registration needed.
- **VALIDATE**: `flutter test test/unit/models/`

### Task 6: Unit Tests — LocalStorageService (Hive)
- **ACTION**: Create `test/unit/services/local_storage_service_test.dart`
- **IMPLEMENT**:
  - Exercise cache: `cacheExercises`, `getCachedExercises`, `getCachedExercise` (hit and miss)
  - Session CRUD: `saveSessionLocally`, `getLocalSessions`, `getLocalSession`, `deleteLocalSession`, `clearLocalSessions`
  - Program CRUD: `saveProgramLocally`, `getLocalPrograms`, `getLocalProgram`, `deleteLocalProgram`, `cachePrograms`
  - Sync queue: `markForSync`, `getPendingSync`, `clearSyncItem`, `clearSyncQueue`
- **MIRROR**: HIVE_TEST_SETUP pattern
- **IMPORTS**: `package:hive_flutter/hive_flutter.dart`, `dart:io`, `package:flutter_test/flutter_test.dart`
- **GOTCHA**: Must use `Hive.init(tempDir.path)` with a real temp directory — `path_provider` is not available in tests. Register all adapters needed for Session (which contains WorkoutConfig). Teardown with `await Hive.deleteFromDisk()`.
- **VALIDATE**: `flutter test test/unit/services/local_storage_service_test.dart`

### Task 7: Unit Tests — SyncService (Mocked Dependencies)
- **ACTION**: Create `test/unit/services/sync_service_test.dart`
- **IMPLEMENT**: Use `@GenerateMocks([FirestoreService, LocalStorageService, Connectivity])` then run `flutter pub run build_runner build`.
  - `getSessions` online: calls Firestore, caches locally, returns sessions
  - `getSessions` offline: returns cached data
  - `getSessions` Firestore error: falls back to cache
  - `createSession` online: saves locally first, then syncs to Firestore, clears sync flag
  - `createSession` offline: saves locally, marks for sync
  - `createSession` Firestore error: marks for sync, rethrows
  - `updateSession` same three cases as create
  - `deleteSession` online: deletes locally + Firestore
  - `deleteSession` offline: deletes locally only, no throw
  - `syncPendingChanges` offline: returns early
  - `syncPendingChanges` online: processes session and program queue items, upsert logic
- **MIRROR**: MOCK_PATTERN
- **IMPORTS**: `package:mockito/mockito.dart`, `package:mockito/annotations.dart`, `package:connectivity_plus/connectivity_plus.dart`
- **GOTCHA**: `SyncService` instantiates `FirestoreService`, `LocalStorageService`, and `Connectivity` directly in its constructor (lines 11-13). To inject mocks, you need to either (a) add constructor injection to `SyncService`, or (b) use a subclass/factory. **Preferred approach**: add optional constructor params to `SyncService` for testing:
  ```dart
  SyncService({
    FirestoreService? firestoreService,
    LocalStorageService? localService,
    Connectivity? connectivity,
  }) : _firestoreService = firestoreService ?? FirestoreService(),
       _localService = localService ?? LocalStorageService(),
       _connectivity = connectivity ?? Connectivity();
  ```
  This is a minimal, non-breaking change.
- **VALIDATE**: `flutter test test/unit/services/sync_service_test.dart`

### Task 8: Unit Tests — Auth Repository
- **ACTION**: Create `test/unit/services/auth_repository_test.dart`
- **IMPLEMENT**: Use `firebase_auth_mocks` package:
  - `registerWithEmailPassword`: creates user, returns UserCredential
  - `signInWithEmailPassword`: signs in successfully
  - `signInWithEmailPassword` with unverified email: throws AuthException with appropriate message
  - `sendPasswordResetEmail`: calls FirebaseAuth method
  - `signOut`: clears auth state
  - `authStateChanges`: emits null when signed out, User when signed in
  - Error mapping: FirebaseAuthException codes map to user-friendly AuthException messages (check `auth_error_mapper.dart`)
- **MIRROR**: FIRESTORE_TEST_SETUP pattern (use `MockFirebaseAuth`)
- **IMPORTS**: `package:firebase_auth_mocks/firebase_auth_mocks.dart`
- **GOTCHA**: `AuthRepository` uses `FirebaseAuth.instance` singleton. To inject the mock, add optional constructor param: `AuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;`. Check `lib/repository/auth_repository.dart` for exact field name.
- **VALIDATE**: `flutter test test/unit/services/auth_repository_test.dart`

### Task 9: Unit Tests — Auth Providers (Riverpod)
- **ACTION**: Create `test/unit/providers/auth_provider_test.dart`
- **IMPLEMENT**: Use `ProviderContainer` with overrides:
  - `authStateProvider` returns signed-in user
  - `currentUserProvider` derives from `authStateProvider`
  - `isEmailVerifiedProvider`: true when user.emailVerified = true
  - `AuthActions.registerWithEmailPassword`: calls repo + creates Firestore profile
  - `AuthActions.signInWithGoogle`: calls repo + creates/updates Firestore profile with display name fallback logic
  - `AuthActions.signOut`: calls repo signOut
- **MIRROR**: RIVERPOD_TEST_SETUP pattern
- **IMPORTS**: `package:flutter_riverpod/flutter_riverpod.dart`, `package:mockito/mockito.dart`
- **GOTCHA**: `AuthActions` takes a `Ref` and reads providers lazily. In tests, override `authRepositoryProvider` and `firestoreServiceProvider` with mocks so `AuthActions` gets the mocked dependencies.
- **VALIDATE**: `flutter test test/unit/providers/auth_provider_test.dart`

### Task 10: Unit Tests — Workout Providers (Riverpod)
- **ACTION**: Create `test/unit/providers/workout_providers_test.dart`
- **IMPLEMENT**:
  - `exercisesProvider`: returns mocked exercises from SyncService
  - `exerciseByIdProvider`: returns specific exercise for given ID
  - `searchExercisesProvider`: returns filtered results
  - `userSessionsProvider`: returns user sessions when userId is set
  - `userSessionsProvider`: returns empty list when userId is null
  - `SessionActions.createSession`: calls syncService + invalidates provider
  - `SessionActions.updateSession`: calls syncService + invalidates provider
  - `SessionActions.deleteSession`: calls syncService + invalidates provider
  - `programActionsProvider` CRUD operations
- **MIRROR**: RIVERPOD_TEST_SETUP pattern
- **IMPORTS**: `package:flutter_riverpod/flutter_riverpod.dart`, `package:mockito/mockito.dart`
- **GOTCHA**: `SessionActions` calls `ref.invalidateSelf()` and `ref.invalidate(sessionByIdProvider(id))`. In container tests these invalidations are safe but don't trigger rebuilds — test that the mock service method was called instead.
- **VALIDATE**: `flutter test test/unit/providers/workout_providers_test.dart`

### Task 11: Widget Tests — Auth Screens
- **ACTION**: Create `test/widget/screens/auth_screens_test.dart`
- **IMPLEMENT**:
  - Login screen: email/password fields render
  - Login screen: empty form shows validation errors on submit
  - Login screen: valid input calls `signInWithEmailPassword`
  - Register screen: weak password shows error
  - Register screen: password mismatch shows error
  - Register screen: valid input calls `registerWithEmailPassword`
- **MIRROR**: flutter_test `testWidgets` + `find.byType`, `find.text`, `tester.tap`
- **IMPORTS**: `package:flutter_test/flutter_test.dart`, `package:flutter_riverpod/flutter_riverpod.dart`
- **GOTCHA**: Wrap widget under test with `ProviderScope(overrides: [...])` to inject mock auth. Use `MockAuthActions` or override `authActionsProvider`.
- **VALIDATE**: `flutter test test/widget/screens/auth_screens_test.dart`

### Task 12: Widget Tests — Session Detail Screen
- **ACTION**: Create `test/widget/screens/session_detail_screen_test.dart`
- **IMPLEMENT**:
  - Screen renders session name, exercise count, duration display
  - Exercise list items visible
  - Start workout button present
  - Empty session: shows empty state message
- **MIRROR**: RIVERPOD_TEST_SETUP + testWidgets
- **IMPORTS**: `package:flutter_test/flutter_test.dart`, `package:flutter_riverpod/flutter_riverpod.dart`
- **GOTCHA**: Session detail screen likely uses `sessionByIdProvider`. Override it with a fixed `AsyncValue.data(session)` in the `ProviderScope` overrides.
- **VALIDATE**: `flutter test test/widget/screens/session_detail_screen_test.dart`

### Task 13: Widget Tests — Workout Execution Screen (Basic)
- **ACTION**: Create `test/widget/screens/workout_execution_screen_test.dart`
- **IMPLEMENT**:
  - Screen renders with session loaded
  - Exercise name is displayed
  - Pause/resume button present
  - Progress indicator visible
  - Skip button (if present) is tappable
- **MIRROR**: testWidgets pattern
- **GOTCHA**: This screen uses `stop_watch_timer` — do NOT test timer accuracy. Only test that the widget renders and basic controls are present. The screen likely requires a `Session` argument; pass a minimal test session.
- **VALIDATE**: `flutter test test/widget/screens/workout_execution_screen_test.dart`

### Task 14: Fix Failing Tests and Validate Coverage
- **ACTION**: Run full test suite, fix any compilation errors, verify coverage
- **IMPLEMENT**:
  ```bash
  # Generate mocks
  flutter pub run build_runner build --delete-conflicting-outputs

  # Run all tests
  flutter test --coverage

  # Generate coverage report
  genhtml coverage/lcov.info -o coverage/html
  ```
- **MIRROR**: N/A — validation only
- **GOTCHA**: If coverage is below 70%, identify the largest uncovered files using `lcov --list coverage/lcov.info` and add targeted tests. Common gaps: enum serialization, error mappers, Hive adapter generated code.
- **VALIDATE**: `flutter test` exits 0; coverage report shows ≥70% line coverage

---

## Testing Strategy

### Unit Tests

| Test | Input | Expected Output | Edge Case? |
|---|---|---|---|
| `SetsConfig.estimatedTotalTime` | sets=3, reps=10, rest=60 | 210 | No |
| `SetsConfig.estimatedTotalTime` single set | sets=1, reps=5, rest=60 | 15 | Yes — no rest |
| `TabataConfig.totalDuration` single set | work=20, rest=10, rounds=8, sets=1 | 240 | No |
| `TabataConfig.totalDuration` multi-set | work=20, rest=10, rounds=8, sets=2, rest_sets=60 | 540 | Yes |
| `CircuitConfig.totalDuration` trailing rest removal | 2 exercises, rest=30 each | (ex1 + ex2 + 30) * rounds, no trailing 30 | Yes |
| `Session.estimatedDuration` empty | 0 workouts | transitionTime * 0 + 0 rest | Yes — avoid negative |
| `WorkoutConfig.fromJson` type inference | JSON with no `type` key, has `workTime` | TabataConfig | Yes |
| `SyncService.getSessions` offline | connectivity=none | cached sessions | Yes |
| `SyncService.createSession` Firestore error | exception thrown | marks for sync, rethrows | Yes |
| `LocalStorageService` empty box | getLocalSessions on empty | empty list | Yes |

### Edge Cases Checklist
- [ ] SetsConfig with 1 set (no inter-set rest)
- [ ] TabataConfig with 1 set (no inter-set rest)
- [ ] CircuitConfig with 1 exercise (no inter-exercise rest)
- [ ] CircuitConfig with 0 rounds (edge case)
- [ ] Session with 0 workouts (estimatedDuration = 0)
- [ ] Session with 1 workout (no inter-exercise rest = 0)
- [ ] WorkoutConfig.fromJson with all type inference paths
- [ ] Session.fromFirestore with null createdAt
- [ ] Session.fromFirestore with Timestamp object (dynamic.toDate())
- [ ] SyncService falling back to cache when Firestore throws
- [ ] Auth error codes mapped to user-friendly messages

---

## Validation Commands

### Generate Mocks
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
EXPECT: `*.mocks.dart` files generated in test directories

### Unit Tests Only
```bash
flutter test test/unit/
```
EXPECT: All unit tests pass

### Widget Tests
```bash
flutter test test/widget/
```
EXPECT: All widget tests pass

### Full Test Suite with Coverage
```bash
flutter test --coverage
```
EXPECT: All tests pass, `coverage/lcov.info` generated

### Coverage Report
```bash
genhtml coverage/lcov.info -o coverage/html && open coverage/html/index.html
```
EXPECT: ≥70% line coverage

### Static Analysis
```bash
flutter analyze
```
EXPECT: Zero errors

---

## Acceptance Criteria
- [ ] All tasks completed
- [ ] `flutter test` exits 0 with no failures
- [ ] Coverage ≥70% (`flutter test --coverage`)
- [ ] `flutter analyze` exits 0
- [ ] No flaky tests (run suite 3 times, all pass)
- [ ] SyncService injectable for testing (constructor injection added)
- [ ] AuthRepository injectable for testing (constructor injection added)

## Completion Checklist
- [ ] Mocks generated via build_runner
- [ ] Hive test setup/teardown uses temp directory
- [ ] All Hive adapters registered in tests that need them
- [ ] ProviderContainer disposed in addTearDown
- [ ] Widget tests wrap screens in ProviderScope with overrides
- [ ] No hardcoded Firebase project IDs or credentials
- [ ] No flaky async timing issues (use `pump`, `pumpAndSettle`)
- [ ] Duration calculations tested with boundary values (1 set, 1 round, etc.)

## Risks
| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Hive adapter registration complexity | High | Medium | Create centralized `registerAllAdapters()` helper in test/helpers/ |
| SyncService hard-codes dependencies | High | High | Add constructor injection (minimal change) as described in Task 7 |
| WorkoutConfig Hive adapters generated | Medium | Medium | Run `build_runner build` before writing tests; test generated code exists |
| Widget tests need full Firebase initialization | Medium | High | Mock all Firebase providers via ProviderScope overrides; never call Firebase.initializeApp in tests |
| Coverage gaps in generated code | Low | Low | Exclude `*.g.dart` files from coverage with `--exclude` flag |

## Notes
- **Constructor injection for SyncService and AuthRepository**: These two classes instantiate dependencies directly. Adding optional constructor params (with defaults) is the minimal, non-breaking change needed for testability. This is the only production code modification required.
- **Hive adapter registration**: Check `lib/core/utils/hive_helpers.dart` for the canonical list of adapters. WorkoutConfig subtypes (SetsConfig, TabataConfig, TimedConfig, CircuitConfig) each have their own typeId and adapter.
- **Coverage exclusions**: Add `--exclude "**/*.g.dart,**/*.freezed.dart"` to coverage commands to avoid inflating/deflating metrics from generated files.
- **Test file location convention**: All tests mirror the `lib/` directory structure under `test/unit/`, `test/widget/`, matching Flutter community conventions.
