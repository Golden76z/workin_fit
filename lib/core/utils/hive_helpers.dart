import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/models/workout_config.dart';

String getWorkoutTypeDisplay(WorkoutType type) {
  switch (type) {
    case WorkoutType.sets:
      return 'Sets';
    case WorkoutType.tabata:
      return 'Tabata';
    case WorkoutType.timed:
      return 'Timed';
  }
}

/// Get difficulty color
String getDifficultyColor(DifficultyLevel difficulty) {
  switch (difficulty) {
    case DifficultyLevel.beginner:
      return '#4CAF50'; // Green
    case DifficultyLevel.intermediate:
      return '#FF9800'; // Orange
    case DifficultyLevel.advanced:
      return '#F44336'; // Red
  }
}

/// Format workout config for display
String formatWorkoutConfig(WorkoutConfig config) {
  if (config is SetsConfig) {
    String base = '${config.sets} sets × ${config.reps} reps';
    if (config.weight != null) {
      base += ' @ ${config.weight}${config.weightUnit ?? 'kg'}';
    }
    return base;
  } else if (config is TabataConfig) {
    return '${config.workTime}s work, ${config.restTime}s rest × ${config.rounds} rounds';
  } else if (config is TimedConfig) {
    return '${config.duration}s hold';
  }
  return 'Unknown';
}