import 'package:flutter_test/flutter_test.dart';
import 'package:workin_fit/core/constants/exercise_assets.dart';

void main() {
  tearDown(ExerciseAssets.clearMovementAssetIndexCache);

  test('bundledMovementPath uses manifest index when present', () {
    ExerciseAssets.setMovementAssetIndexForTests(<String, String>{
      'core_007': 'assets/exercises/movements/core_007/tutorial.webp',
    });

    expect(
      ExerciseAssets.bundledMovementPath('core_007'),
      'assets/exercises/movements/core_007/tutorial.webp',
    );
  });

  test('bundledMovementPath falls back to tutorial.png when not indexed', () {
    ExerciseAssets.setMovementAssetIndexForTests(<String, String>{});

    expect(
      ExerciseAssets.bundledMovementPath('core_007'),
      'assets/exercises/movements/core_007/tutorial.png',
    );
  });

  test('movementFileNameFromPath accepts known extensions', () {
    expect(
      ExerciseAssets.movementPath('core_007'),
      'assets/exercises/movements/core_007/tutorial.png',
    );
    expect(ExerciseAssets.movementPaths('core_007').length, 5);
  });
}
