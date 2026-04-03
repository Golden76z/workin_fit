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
    case WorkoutType.circuit:
      return 'Circuit';
  }
}

/// Get difficulty color
String getDifficultyColor(DifficultyLevel difficulty) {
  switch (difficulty) {
    case DifficultyLevel.beginner:
      return '#D8C9FF'; // Brand light
    case DifficultyLevel.intermediate:
      return '#5E2BFF'; // Brand primary
    case DifficultyLevel.advanced:
      return '#331886'; // Brand deep
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
