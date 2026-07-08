import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/providers/admin_providers.dart';
import 'package:workin_fit/providers/workout_providers.dart';
import 'package:workin_fit/views/admin/admin_exercise_editor_screen.dart';
import 'package:workin_fit/views/admin/widgets/admin_list_scaffold.dart';

/// Admin list of all exercises with create / edit / delete. Reads the live
/// [exercisesStreamProvider] so newly saved content shows up immediately.
class AdminExerciseListScreen extends ConsumerWidget {
  const AdminExerciseListScreen({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => const AdminExerciseListScreen(),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Exercise>> exercises =
        ref.watch(exercisesStreamProvider).whenData(
              (List<Exercise> list) => <Exercise>[...list]..sort(
                  (Exercise a, Exercise b) =>
                      a.name.toLowerCase().compareTo(b.name.toLowerCase()),
                ),
            );

    return AdminListScaffold<Exercise>(
      title: 'Exercises',
      errorNoun: 'exercises',
      items: exercises,
      emptyState: const Center(
        child: Text(
          'No exercises yet. Tap “New” to add one.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
      onNew: () =>
          Navigator.of(context).push(AdminExerciseEditorScreen.route()),
      onEditItem: (BuildContext context, Exercise exercise) =>
          Navigator.of(context).push(
        AdminExerciseEditorScreen.route(existing: exercise),
      ),
      rowBuilder: (Exercise exercise, VoidCallback onEdit,
              VoidCallback onDelete) =>
          _ExerciseRow(exercise: exercise, onEdit: onEdit, onDelete: onDelete),
      deleteTitle: 'Delete exercise?',
      deleteMessage: (Exercise e) => '“${e.name}” will be removed for all users.',
      deletedMessage: (Exercise e) => 'Deleted “${e.name}”',
      onDelete: (WidgetRef ref, Exercise e) =>
          ref.read(adminActionsProvider).deleteExercise(e.id),
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
