
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/services/sync_service.dart';
import 'package:workin_fit/models/session.dart';
import 'package:workin_fit/models/exercise.dart';

// Services
final syncServiceProvider = Provider((ref) => SyncService());

// Current user ID (from auth)
final currentUserIdProvider = StateProvider<String?>((ref) => null);

// ===== EXERCISES =====

final exercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final syncService = ref.watch(syncServiceProvider);
  return await syncService.getExercises();
});

// Get single exercise by ID
final exerciseByIdProvider = FutureProvider.family<Exercise?, String>(
  (ref, exerciseId) async {
    final exercises = await ref.watch(exercisesProvider.future);
    return exercises.firstWhere((e) => e.id == exerciseId);
  },
);

// ===== SESSIONS =====

final userSessionsProvider = FutureProvider<List<Session>>((ref) async {
  final syncService = ref.watch(syncServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  
  if (userId == null) return [];
  
  return await syncService.getSessions(userId);
});

// Session CRUD operations
final sessionActionsProvider = Provider((ref) => SessionActions(ref));

class SessionActions {
  final Ref ref;
  SessionActions(this.ref);

  Future<void> createSession(Session session) async {
    final syncService = ref.read(syncServiceProvider);
    final userId = ref.read(currentUserIdProvider);
    
    if (userId == null) throw Exception('User not authenticated');
    
    await syncService.createSession(userId, session);
    ref.invalidate(userSessionsProvider); // Refresh list
  }

  Future<void> updateSession(Session session) async {
    final syncService = ref.read(syncServiceProvider);
    final userId = ref.read(currentUserIdProvider);
    
    if (userId == null) throw Exception('User not authenticated');
    
    await syncService.updateSession(userId, session);
    ref.invalidate(userSessionsProvider);
  }

  Future<void> deleteSession(String sessionId) async {
    final syncService = ref.read(syncServiceProvider);
    final userId = ref.read(currentUserIdProvider);
    
    if (userId == null) throw Exception('User not authenticated');
    
    await syncService.deleteSession(userId, sessionId);
    ref.invalidate(userSessionsProvider);
  }
}