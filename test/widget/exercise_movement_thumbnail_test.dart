import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workin_fit/core/constants/exercise_assets.dart';
import 'package:workin_fit/features/workout/presentation/widgets/exercise_movement_thumbnail.dart';

void main() {
  tearDown(ExerciseAssets.clearMovementAssetIndexCache);

  testWidgets('loads bundled tutorial when imageUrl is empty', (tester) async {
    ExerciseAssets.setMovementAssetIndexForTests(<String, String>{
      'core_007': 'assets/exercises/movements/core_007/tutorial.png',
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 200,
            child: ExerciseMovementThumbnail(
              exerciseId: 'core_007',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('ignores non-http imageUrl and uses bundled asset', (tester) async {
    ExerciseAssets.setMovementAssetIndexForTests(<String, String>{
      'core_007': 'assets/exercises/movements/core_007/tutorial.png',
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ExerciseMovementThumbnail(
            exerciseId: 'core_007',
            imageUrl: 'broken-relative-path.png',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
  });
}
