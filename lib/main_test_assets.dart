import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/features/workout/presentation/widgets/exercise_movement_thumbnail.dart';
import 'package:workin_fit/core/constants/exercise_assets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ExerciseAssets.warmMovementAssetIndex();

  runApp(
    const ProviderScope(
      child: TestAssetsApp(),
    ),
  );
}

class TestAssetsApp extends StatelessWidget {
  const TestAssetsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.mediaCanvas,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Test Exercise Assets - Batch 2'),
          backgroundColor: Colors.black,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildExerciseRow('cardio_004', 'Burpees'),
              const SizedBox(height: 24),
              _buildExerciseRow('cardio_005', 'Skater Jumps'),
              const SizedBox(height: 24),
              _buildExerciseRow('cardio_006', 'Star Jumps'),
              const SizedBox(height: 24),
              _buildExerciseRow('cardio_007', 'Tuck Jumps'),
              const SizedBox(height: 24),
              _buildExerciseRow('cardio_008', 'Inchworms'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseRow(String id, String label) {
    return Card(
      color: Colors.grey[900],
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            height: 200,
            width: double.infinity,
            child: ExerciseMovementThumbnail(
              exerciseId: id,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Text(
                  'List View:  ',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(
                  height: 84,
                  width: 150,
                  child: ExerciseMovementThumbnail(
                    exerciseId: id,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
