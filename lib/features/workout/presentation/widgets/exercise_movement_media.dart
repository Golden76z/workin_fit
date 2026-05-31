import 'package:flutter/material.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/features/workout/presentation/widgets/exercise_movement_thumbnail.dart';

/// Full-size movement media for exercise detail (no memory cache downscale).
class ExerciseMovementMedia extends StatelessWidget {
  final String exerciseId;
  final BoxFit fit;

  const ExerciseMovementMedia({
    super.key,
    required this.exerciseId,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return ExerciseMovementThumbnail(
      exerciseId: exerciseId,
      fit: fit,
      placeholder: const _DetailPlaceholder(),
    );
  }
}

class _DetailPlaceholder extends StatelessWidget {
  const _DetailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.mediaCanvas,
      child: Center(
        child: Icon(
          Icons.fitness_center_rounded,
          color: AppColors.frostedCyan,
          size: 56,
        ),
      ),
    );
  }
}
