import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/session.dart';
import 'package:workin_fit/models/workout_config.dart';

/// An immutable warmup routine combining a category, duration, exercises, and exercise metadata.
class WarmupRoutine {
  final WarmupCategory category;
  final int durationMinutes;
  /// Timed workout configs (exerciseId matches a WarmupExercise stub)
  final List<TimedConfig> workoutConfigs;
  /// Self-contained exercise stubs (no network dependency)
  final List<Exercise> exercises;

  const WarmupRoutine({
    required this.category,
    required this.durationMinutes,
    required this.workoutConfigs,
    required this.exercises,
  });

  /// Build a Session object suitable for WorkoutExecutionScreen
  Session toSession() {
    return Session(
      id: 'warmup_${category.name}_${durationMinutes}m',
      name: _sessionName(),
      description: _sessionDescription(),
      workouts: workoutConfigs,
      difficulty: DifficultyLevel.beginner,
      restBetweenExercises: 10,
      transitionTime: 3,
    );
  }

  String _sessionName() {
    final categoryName = switch (category) {
      WarmupCategory.fullBody => 'Full Body',
      WarmupCategory.upperBody => 'Upper Body',
      WarmupCategory.lowerBody => 'Lower Body',
      WarmupCategory.core => 'Core',
      WarmupCategory.cardio => 'Cardio',
    };
    return '$durationMinutes min $categoryName Warmup';
  }

  String _sessionDescription() {
    return switch (category) {
      WarmupCategory.fullBody => 'Whole body activation warmup',
      WarmupCategory.upperBody => 'Arms, shoulders & chest warmup',
      WarmupCategory.lowerBody => 'Legs, hips & glutes warmup',
      WarmupCategory.core => 'Abs & lower back warmup',
      WarmupCategory.cardio => 'Cardio warmup to get your heart rate up',
    };
  }
}
