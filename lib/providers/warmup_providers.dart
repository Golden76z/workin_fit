import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/data/warmup_routines.dart';
import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/warmup_routine.dart';

/// Selected warmup category (defaults to fullBody)
final warmupCategoryProvider = StateProvider<WarmupCategory>(
  (ref) => WarmupCategory.fullBody,
);

/// Selected warmup duration in minutes (defaults to 5)
final warmupDurationProvider = StateProvider<int>((ref) => 5);

/// Current warmup routine derived from selected category and duration
final warmupRoutineProvider = Provider<WarmupRoutine>((ref) {
  final category = ref.watch(warmupCategoryProvider);
  final duration = ref.watch(warmupDurationProvider);
  return WarmupData.getRoutine(category, duration);
});

/// Exercises for the current warmup routine (already embedded in WarmupRoutine)
final warmupExercisesProvider = Provider<List<Exercise>>((ref) {
  final routine = ref.watch(warmupRoutineProvider);
  return routine.exercises;
});
