# Firestore Service Layer Architecture

This document explains the complete service layer architecture for interacting with Firestore, including CRUD operations, offline caching, data synchronization, and Riverpod providers.

## 📋 Table of Contents

1. [Overview](#overview)
2. [Architecture Layers](#architecture-layers)
3. [Firestore Service](#firestore-service)
4. [Local Storage Service](#local-storage-service)
5. [Sync Service](#sync-service)
6. [Riverpod Providers](#riverpod-providers)
7. [Offline Support](#offline-support)
8. [Error Handling](#error-handling)
9. [Usage Examples](#usage-examples)
10. [Best Practices](#best-practices)

## 🎯 Overview

The service layer is built with three main components:

1. **FirestoreService** - Direct Firestore operations
2. **LocalStorageService** - Hive-based local caching
3. **SyncService** - Orchestrates offline-first data synchronization

All services are exposed through **Riverpod providers** for reactive state management.

## 🏗️ Architecture Layers

```
┌─────────────────────────────────────────┐
│         UI Layer (Widgets)              │
│  Uses Riverpod Providers                │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│      Riverpod Providers Layer           │
│  - exercisesProvider                    │
│  - sessionsProvider                     │
│  - programsProvider                     │
│  - CRUD Actions                          │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         Sync Service Layer               │
│  - Offline-first logic                  │
│  - Connectivity checks                  │
│  - Sync queue management                │
└──────────────┬──────────────────────────┘
               │
       ┌───────┴───────┐
       │               │
┌──────▼──────┐  ┌─────▼──────────────┐
│ Firestore   │  │ Local Storage      │
│ Service     │  │ Service (Hive)      │
│             │  │                    │
│ - CRUD ops  │  │ - Cache management │
│ - Streams   │  │ - Sync queue       │
└─────────────┘  └────────────────────┘
```

## 🔥 Firestore Service

**Location:** `lib/services/firestore_service.dart`

### Purpose

Direct interface to Cloud Firestore. Handles all CRUD operations with proper error handling.

### Key Features

- ✅ Typed exceptions (`FirestoreException`)
- ✅ Automatic offline persistence (enabled by default)
- ✅ Real-time streams for reactive updates
- ✅ Proper error handling with error codes

### Methods

#### Exercises

```dart
// Get all exercises
Future<List<Exercise>> getExercises()

// Get exercise by ID
Future<Exercise?> getExerciseById(String id)

// Search exercises
Future<List<Exercise>> searchExercises(String query)

// Stream exercises (real-time)
Stream<List<Exercise>> exercisesStream()
```

#### Sessions

```dart
// Get user sessions
Future<List<Session>> getSessions(String userId)

// Get session by ID
Future<Session?> getSessionById(String userId, String sessionId)

// Create session
Future<void> createSession(String userId, Session session)

// Update session
Future<void> updateSession(String userId, Session session)

// Delete session
Future<void> deleteSession(String userId, String sessionId)

// Stream user sessions (real-time)
Stream<List<Session>> userSessionsStream(String userId)
```

#### Programs

```dart
// Get all programs (preset)
Future<List<Program>> getPrograms()

// Get program by ID (checks preset + user programs)
Future<Program?> getProgramById(String programId, {String? userId})

// Subscribe to program updates (real-time)
Stream<Program?> subscribeToProgram(String programId, {String? userId})

// Get user's custom programs
Future<List<Program>> getUserPrograms(String userId)

// Create program
Future<void> createProgram(String userId, Program program)

// Update program
Future<void> updateProgram(String userId, Program program)

// Delete program
Future<void> deleteProgram(String userId, String programId)
```

### Error Handling

All methods throw `FirestoreException` with:
- Descriptive error messages
- Firebase error codes (when available)
- Proper exception chaining

Example:
```dart
try {
  final sessions = await firestoreService.getSessions(userId);
} on FirestoreException catch (e) {
  print('Error: ${e.message}');
  print('Code: ${e.code}');
}
```

## 💾 Local Storage Service

**Location:** `lib/services/local_storage_service.dart`

### Purpose

Manages local caching using Hive. Provides offline data persistence and sync queue management.

### Key Features

- ✅ Hive-based storage (fast, type-safe)
- ✅ Automatic serialization/deserialization
- ✅ Sync queue for pending operations
- ✅ Separate boxes for exercises, sessions, programs

### Storage Structure

```
Hive Boxes:
├── exercises    (Exercise objects)
├── sessions     (Session objects)
├── programs     (Program objects)
└── sync_queue   (Pending sync operations)
```

### Methods

#### Exercises

```dart
// Cache exercises
Future<void> cacheExercises(List<Exercise> exercises)

// Get cached exercises
Future<List<Exercise>> getCachedExercises()

// Get single cached exercise
Future<Exercise?> getCachedExercise(String id)
```

#### Sessions

```dart
// Save session locally
Future<void> saveSessionLocally(Session session)

// Get all local sessions
Future<List<Session>> getLocalSessions()

// Get single local session
Future<Session?> getLocalSession(String sessionId)

// Delete local session
Future<void> deleteLocalSession(String sessionId)
```

#### Programs

```dart
// Save program locally
Future<void> saveProgramLocally(Program program)

// Get all local programs
Future<List<Program>> getLocalPrograms()

// Get single local program
Future<Program?> getLocalProgram(String programId)

// Cache multiple programs
Future<void> cachePrograms(List<Program> programs)

// Delete local program
Future<void> deleteLocalProgram(String programId)
```

#### Sync Queue

```dart
// Mark item for sync
Future<void> markForSync(String itemId, String type) // type: 'session' or 'program'

// Get pending sync items
Future<List<Map<String, dynamic>>> getPendingSync()

// Clear sync item
Future<void> clearSyncItem(String id, String type)

// Clear all sync queue
Future<void> clearSyncQueue()
```

## 🔄 Sync Service

**Location:** `lib/services/sync_service.dart`

### Purpose

Orchestrates data synchronization between Firestore and local storage. Implements offline-first strategies.

### Key Features

- ✅ Offline-first data fetching
- ✅ Automatic sync queue management
- ✅ Connectivity-aware operations
- ✅ Background refresh for cached data

### Sync Strategies

#### 1. Exercises (Cache-First)

```
1. Check local cache
2. If cache exists → return immediately, refresh in background
3. If no cache → fetch from Firestore, cache locally
4. On error → return cached data
```

#### 2. Sessions (Offline-First)

```
Create/Update:
1. Save locally first (always)
2. If online → sync to Firestore immediately
3. If offline → mark for sync queue
4. On error → mark for sync queue

Read:
1. If online → fetch from Firestore, cache locally
2. If offline → return cached data
3. On error → return cached data
```

#### 3. Programs (Offline-First)

Same strategy as sessions.

### Methods

#### Exercises

```dart
Future<List<Exercise>> getExercises()
Future<Exercise?> getExerciseById(String id)
Future<List<Exercise>> searchExercises(String query)
```

#### Sessions

```dart
Future<List<Session>> getSessions(String userId)
Future<void> createSession(String userId, Session session)
Future<void> updateSession(String userId, Session session)
Future<void> deleteSession(String userId, String sessionId)
```

#### Programs

```dart
Future<List<Program>> getPrograms({String? userId})
Future<Program?> getProgramById(String programId, {String? userId})
Future<void> createProgram(String userId, Program program)
Future<void> updateProgram(String userId, Program program)
Future<void> deleteProgram(String userId, String programId)
```

#### Sync Operations

```dart
// Sync all pending changes
Future<void> syncPendingChanges(String userId)
```

This method:
1. Checks connectivity
2. Retrieves pending items from sync queue
3. Determines create vs update based on Firestore state
4. Syncs each item
5. Clears sync queue on success

## 🎣 Riverpod Providers

**Location:** `lib/providers/workout_providers.dart`

### Purpose

Expose services through reactive providers. Handles loading states, errors, and automatic invalidation.

### Provider Types

#### 1. Service Providers

```dart
final syncServiceProvider = Provider<SyncService>(...)
final firestoreServiceProvider = Provider<FirestoreService>(...)
final localStorageServiceProvider = Provider<LocalStorageService>(...)
```

#### 2. Data Providers (FutureProvider)

```dart
// Exercises
final exercisesProvider = FutureProvider<List<Exercise>>(...)
final exerciseByIdProvider = FutureProvider.family<Exercise?, String>(...)
final searchExercisesProvider = FutureProvider.family<List<Exercise>, String>(...)

// Sessions
final userSessionsProvider = FutureProvider<List<Session>>(...)
final sessionByIdProvider = FutureProvider.family<Session?, String>(...)

// Programs
final programsProvider = FutureProvider<List<Program>>(...)
final programByIdProvider = FutureProvider.family<Program?, String>(...)
```

#### 3. Stream Providers (StreamProvider)

```dart
final exercisesStreamProvider = StreamProvider<List<Exercise>>(...)
final userSessionsStreamProvider = StreamProvider<List<Session>>(...)
final programStreamProvider = StreamProvider.family<Program?, String>(...)
```

#### 4. Action Providers

```dart
final sessionActionsProvider = Provider<SessionActions>(...)
final programActionsProvider = Provider<ProgramActions>(...)
final syncActionsProvider = Provider<SyncActions>(...)
```

### Usage in UI

```dart
// Read data
final exercisesAsync = ref.watch(exercisesProvider);
exercisesAsync.when(
  data: (exercises) => ExerciseList(exercises),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => ErrorWidget(err),
);

// Perform actions
final sessionActions = ref.read(sessionActionsProvider);
await sessionActions.createSession(session);

// Watch streams
final sessionsStream = ref.watch(userSessionsStreamProvider);
sessionsStream.when(
  data: (sessions) => SessionList(sessions),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => ErrorWidget(err),
);
```

## 📱 Offline Support

### How It Works

1. **Firestore Offline Persistence**
   - Enabled by default in Flutter
   - Automatically caches Firestore data locally
   - Syncs when connection is restored

2. **Hive Caching**
   - Additional layer for frequently accessed data
   - Faster than Firestore cache for reads
   - Used for offline-first operations

3. **Sync Queue**
   - Tracks pending create/update operations
   - Automatically syncs when online
   - Can be manually triggered

### Connectivity Detection

Uses `connectivity_plus` package to detect network status:
- Online → Fetch from Firestore, cache locally
- Offline → Return cached data, queue operations

### Sync Flow

```
User Action (Offline)
    ↓
Save to Hive
    ↓
Mark for Sync Queue
    ↓
[Connection Restored]
    ↓
syncPendingChanges()
    ↓
Check Firestore State
    ↓
Create or Update
    ↓
Clear Sync Queue
```

## ⚠️ Error Handling

### Error Types

1. **FirestoreException**
   - Thrown by FirestoreService
   - Contains message and error code
   - Caught and handled by SyncService

2. **Network Errors**
   - Handled gracefully
   - Falls back to cached data
   - Queues operations for later sync

3. **Validation Errors**
   - Should be caught at UI layer
   - Display user-friendly messages

### Error Handling Strategy

```dart
// In SyncService
try {
  if (isOnline) {
    await firestoreService.createSession(userId, session);
  } else {
    await localService.markForSync(session.id, 'session');
  }
} catch (e) {
  // Always queue for sync on error
  await localService.markForSync(session.id, 'session');
  rethrow; // Let UI handle the error
}
```

### Error Recovery

- **Automatic**: Sync queue processes on next connection
- **Manual**: Call `syncActionsProvider.syncNow()`
- **UI Feedback**: Providers expose errors through `AsyncValue`

## 📝 Usage Examples

### Example 1: Fetch Exercises

```dart
class ExerciseListWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercisesAsync = ref.watch(exercisesProvider);
    
    return exercisesAsync.when(
      data: (exercises) => ListView.builder(
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          return ExerciseCard(exercise: exercises[index]);
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => ErrorView(error: error),
    );
  }
}
```

### Example 2: Create Session

```dart
class CreateSessionButton extends ConsumerWidget {
  final Session session;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        final actions = ref.read(sessionActionsProvider);
        try {
          await actions.createSession(session);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Session created!')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      },
      child: Text('Create Session'),
    );
  }
}
```

### Example 3: Search Exercises

```dart
class ExerciseSearchWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<ExerciseSearchWidget> createState() => _ExerciseSearchWidgetState();
}

class _ExerciseSearchWidgetState extends ConsumerState<ExerciseSearchWidget> {
  final _searchController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    final searchQuery = _searchController.text;
    final searchResults = ref.watch(
      searchExercisesProvider(searchQuery),
    );
    
    return Column(
      children: [
        TextField(controller: _searchController),
        searchResults.when(
          data: (exercises) => ExerciseList(exercises: exercises),
          loading: () => CircularProgressIndicator(),
          error: (err, stack) => ErrorView(error: err),
        ),
      ],
    );
  }
}
```

### Example 4: Real-time Updates

```dart
class SessionsStreamWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsStream = ref.watch(userSessionsStreamProvider);
    
    return sessionsStream.when(
      data: (sessions) => SessionList(sessions: sessions),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => ErrorView(error: err),
    );
  }
}
```

### Example 5: Manual Sync

```dart
class SyncButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncActions = ref.read(syncActionsProvider);
    
    return ElevatedButton(
      onPressed: () async {
        try {
          await syncActions.syncNow();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sync completed!')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sync failed: $e')),
          );
        }
      },
      child: Text('Sync Now'),
    );
  }
}
```

## ✅ Best Practices

### 1. Always Use Providers

Don't instantiate services directly in widgets. Use providers:

```dart
// ❌ Bad
final service = SyncService();
await service.getSessions(userId);

// ✅ Good
final sessions = ref.watch(userSessionsProvider);
```

### 2. Handle Loading States

Always handle `AsyncValue` states:

```dart
data.when(
  data: (data) => YourWidget(data),
  loading: () => LoadingWidget(),
  error: (err, stack) => ErrorWidget(err),
);
```

### 3. Use Actions for Mutations

Use action providers for create/update/delete:

```dart
// ❌ Bad
await syncService.createSession(userId, session);

// ✅ Good
await ref.read(sessionActionsProvider).createSession(session);
```

### 4. Invalidate After Mutations

Action providers automatically invalidate related providers. Don't manually invalidate unless necessary.

### 5. Handle Errors Gracefully

```dart
try {
  await actions.createSession(session);
} catch (e) {
  // Show user-friendly error
  showErrorDialog(context, e);
}
```

### 6. Use Streams for Real-time Data

For data that changes frequently, use stream providers:

```dart
// Real-time updates
final sessionsStream = ref.watch(userSessionsStreamProvider);
```

### 7. Cache-First for Read-Heavy Data

Exercises use cache-first strategy since they change infrequently:

```dart
// Returns cached data immediately, refreshes in background
final exercises = ref.watch(exercisesProvider);
```

### 8. Offline-First for User Data

Sessions and programs use offline-first strategy:

```dart
// Always saves locally first, syncs when online
await actions.createSession(session);
```

## 🔍 Troubleshooting

### Issue: Data not syncing

**Solution**: Check sync queue and manually trigger sync:
```dart
await ref.read(syncActionsProvider).syncNow();
```

### Issue: Stale cached data

**Solution**: Invalidate the provider:
```dart
ref.invalidate(exercisesProvider);
```

### Issue: Offline operations failing

**Solution**: Ensure Hive is initialized and adapters are registered in `main.dart`.

### Issue: Stream not updating

**Solution**: Check Firestore security rules and network connectivity.

## 📚 Additional Resources

- [Cloud Firestore Documentation](https://firebase.flutter.dev/docs/firestore/usage)
- [Firestore Offline Data](https://firebase.google.com/docs/firestore/manage-data/enable-offline)
- [Riverpod Documentation](https://riverpod.dev/)
- [Hive Documentation](https://docs.hivedb.dev/)

## 🎯 Acceptance Criteria Status

✅ **Can fetch data from Firestore** - All CRUD methods implemented  
✅ **Can create/update/delete user data** - Full CRUD for sessions and programs  
✅ **Offline caching works** - Hive-based caching with persistence  
✅ **Data syncs when connection is restored** - Automatic sync queue processing  
✅ **Error handling for network failures** - Comprehensive error handling throughout  

---

**Last Updated**: 2024  
**Maintained By**: Workin Fit Development Team
