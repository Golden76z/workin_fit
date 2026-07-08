import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/providers/admin_providers.dart';
import 'package:workin_fit/providers/workout_providers.dart';
import 'package:workin_fit/views/admin/admin_exercise_editor_screen.dart';
import 'package:workin_fit/views/admin/widgets/admin_guard.dart';
import 'package:workin_fit/widgets/app_dialog.dart';

/// Admin list of all exercises with create / edit / delete. Reads the live
/// [exercisesStreamProvider] so newly saved content shows up immediately.
class AdminExerciseListScreen extends ConsumerWidget {
  const AdminExerciseListScreen({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => const AdminExerciseListScreen(),
      );

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Exercise exercise,
  ) async {
    final bool? confirmed = await AppDialog.showConfirm(
      context: context,
      title: 'Delete exercise?',
      message: '“${exercise.name}” will be removed for all users.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      icon: Icons.delete_outline_rounded,
      iconColor: AppColors.error,
      destructive: true,
    );
    if (confirmed != true) return;
    try {
      await ref.read(adminActionsProvider).deleteExercise(exercise.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted “${exercise.name}”')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Exercise>> exercises =
        ref.watch(exercisesStreamProvider);

    return AdminGuard(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('Exercises'),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add_rounded),
          label: const Text('New'),
          onPressed: () => Navigator.of(context).push(
            AdminExerciseEditorScreen.route(),
          ),
        ),
        body: exercises.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                'Failed to load exercises:\n$e',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
          data: (List<Exercise> list) {
            if (list.isEmpty) {
              return const Center(
                child: Text(
                  'No exercises yet. Tap “New” to add one.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }
            final List<Exercise> sorted = <Exercise>[...list]
              ..sort(
                (Exercise a, Exercise b) =>
                    a.name.toLowerCase().compareTo(b.name.toLowerCase()),
              );
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xs,
                AppSpacing.xs,
                AppSpacing.xs,
                96, // clear the FAB
              ),
              itemCount: sorted.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.xxs),
              itemBuilder: (BuildContext context, int index) {
                final Exercise exercise = sorted[index];
                return _ExerciseRow(
                  exercise: exercise,
                  onEdit: () => Navigator.of(context).push(
                    AdminExerciseEditorScreen.route(existing: exercise),
                  ),
                  onDelete: () => _confirmDelete(context, ref, exercise),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({
    required this.exercise,
    required this.onEdit,
    required this.onDelete,
  });

  final Exercise exercise;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final String imageUrl = exercise.imageTutorialUrl.isNotEmpty
        ? exercise.imageTutorialUrl
        : exercise.imageMuscleUrl;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.sm),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => const _ImageFallback(),
                        )
                      : const _ImageFallback(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      exercise.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${exercise.difficulty.name} · '
                      '${exercise.muscleGroupsDisplay}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                color: AppColors.textSecondary,
                onPressed: onEdit,
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                color: AppColors.error,
                onPressed: onDelete,
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceVariant,
      child: const Icon(
        Icons.fitness_center_rounded,
        size: 20,
        color: AppColors.textTertiary,
      ),
    );
  }
}
