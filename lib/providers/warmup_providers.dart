import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/data/warmup_routines.dart';
import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/warmup_routine.dart';
import 'package:workin_fit/providers/workout_providers.dart';

/// Selected warmup category (defaults to fullBody)
final warmupCategoryProvider = StateProvider<WarmupCategory>(
  (ref) => WarmupCategory.fullBody,
);

/// Selected warmup duration in minutes (defaults to 5)
final warmupDurationProvider = StateProvider<int>((ref) => 5);

/// Admin-authored warmup routines from Firestore, keyed by [WarmupRoutine.docKey]
/// (`<category>_<minutes>`), real-time. Empty/loading falls back to [WarmupData].
final firestoreWarmupsProvider =
    StreamProvider<Map<String, WarmupRoutine>>((ref) {
  return ref.watch(firestoreServiceProvider).warmupsStream().map(
    (List<WarmupRoutine> routines) => <String, WarmupRoutine>{
      for (final WarmupRoutine r in routines) r.docKey: r,
    },
  );
});

/// Current warmup routine for the selected category+duration. Prefers an
/// admin-authored routine from Firestore, falling back to the built-in
/// [WarmupData] routine. Stays synchronous via [AsyncValue.valueOrNull].
final warmupRoutineProvider = Provider<WarmupRoutine>((ref) {
  final category = ref.watch(warmupCategoryProvider);
  final duration = ref.watch(warmupDurationProvider);
  final overrides = ref.watch(firestoreWarmupsProvider).valueOrNull;
  final authored = overrides?['${category.name}_$duration'];
  return authored ?? WarmupData.getRoutine(category, duration);
});

/// Exercises for the current warmup routine (already embedded in WarmupRoutine)
final warmupExercisesProvider = Provider<List<Exercise>>((ref) {
  final routine = ref.watch(warmupRoutineProvider);
  return routine.exercises;
});
