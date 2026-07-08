import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/models/warmup_routine.dart';
import 'package:workin_fit/providers/admin_providers.dart';
import 'package:workin_fit/providers/warmup_providers.dart';
import 'package:workin_fit/views/admin/admin_warmup_editor_screen.dart';
import 'package:workin_fit/views/admin/widgets/admin_list_scaffold.dart';

/// Admin list of authored warmup routines (overrides of the built-in ones).
class AdminWarmupListScreen extends ConsumerWidget {
  const AdminWarmupListScreen({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => const AdminWarmupListScreen(),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<WarmupRoutine>> warmups =
        ref.watch(firestoreWarmupsProvider).whenData(
              (Map<String, WarmupRoutine> map) => map.values.toList()
                ..sort(
                  (WarmupRoutine a, WarmupRoutine b) =>
                      a.docKey.compareTo(b.docKey),
                ),
            );

    return AdminListScaffold<WarmupRoutine>(
      title: 'Warmups',
      errorNoun: 'warmups',
      items: warmups,
      emptyState: const _EmptyHint(),
      onNew: () => Navigator.of(context).push(AdminWarmupEditorScreen.route()),
      onEditItem: (BuildContext context, WarmupRoutine routine) =>
          Navigator.of(context).push(
        AdminWarmupEditorScreen.route(existing: routine),
      ),
      rowBuilder: (WarmupRoutine routine, VoidCallback onEdit,
              VoidCallback onDelete) =>
          _WarmupRow(routine: routine, onEdit: onEdit, onDelete: onDelete),
      deleteTitle: 'Delete warmup override?',
      deleteMessage: (WarmupRoutine r) =>
          'The built-in “${r.category.name} / ${r.durationMinutes} min” '
          'routine will be used again.',
      deletedMessage: (WarmupRoutine r) => 'Warmup override removed',
      onDelete: (WidgetRef ref, WarmupRoutine r) =>
          ref.read(adminActionsProvider).deleteWarmup(r.docKey),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.self_improvement_outlined,
              size: 44,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No authored warmups yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'The 15 built-in routines (5 categories × 2/5/10 min) are active. '
              'Add one here to override a specific category + duration for '
              'everyone.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _WarmupRow extends StatelessWidget {
  const _WarmupRow({
    required this.routine,
    required this.onEdit,
    required this.onDelete,
  });

  final WarmupRoutine routine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${routine.category.name} · ${routine.durationMinutes} min',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${routine.workoutConfigs.length} steps',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
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
