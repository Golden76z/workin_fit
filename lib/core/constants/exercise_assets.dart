/// Paths for user-provided exercise movement media under [kExerciseMovementsRoot].
abstract final class ExerciseAssets {
  static const String kExerciseMovementsRoot = 'assets/exercises/movements';

  /// e.g. `assets/exercises/movements/push_001/tutorial.gif`
  static String movementPath(String exerciseId, {String fileName = 'tutorial.gif'}) {
    return '$kExerciseMovementsRoot/$exerciseId/$fileName';
  }
}
