import 'package:flutter/material.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/app_opacity.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/models/chat_message.dart';

class WorkoutSummaryCard extends StatelessWidget {
  const WorkoutSummaryCard({
    super.key,
    required this.shareData,
    required this.comment,
    this.onStartWorkout,
  });

  final WorkoutShareData shareData;
  final String comment;

  /// When non-null, a "Start This Workout" button is shown.
  /// Pass null to hide the button (e.g. on the sender's own card).
  final VoidCallback? onStartWorkout;

  @override
  Widget build(BuildContext context) {
    final minutes = shareData.durationSeconds ~/ 60;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: AppOpacity.moderate),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.fitness_center_rounded,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  shareData.sessionName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'AppFontMedium',
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              _StatChip('$minutes min'),
              _StatChip('${shareData.exerciseCount} exercises'),
              if (shareData.totalReps > 0)
                _StatChip('${shareData.totalReps} reps'),
            ],
          ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              '"$comment"',
              style: TextStyle(
                color: AppColors.textSecondary
                    .withValues(alpha: AppOpacity.bold),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (onStartWorkout != null) ...[
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onStartWorkout,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppRadii.sm),
                  ),
                ),
                child: const Text('Start This Workout'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: AppOpacity.faint),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
