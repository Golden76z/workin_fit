import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/models/warmup_routine.dart';
import 'package:workin_fit/providers/admin_providers.dart';
import 'package:workin_fit/providers/warmup_providers.dart';
import 'package:workin_fit/views/admin/admin_warmup_editor_screen.dart';
import 'package:workin_fit/views/admin/widgets/admin_guard.dart';
import 'package:workin_fit/widgets/app_dialog.dart';

/// Admin list of authored warmup routines (overrides of the built-in ones).
class AdminWarmupListScreen extends ConsumerWidget {
  const AdminWarmupListScreen({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => const AdminWarmupListScreen(),
      );

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    WarmupRoutine routine,
  ) async {
    final bool? confirmed = await AppDialog.showConfirm(
      context: context,
      title: 'Delete warmup override?',
      message:
          'The built-in “${routine.category.name} / ${routine.durationMinutes} min” '
          'routine will be used again.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      icon: Icons.delete_outline_rounded,
      iconColor: AppColors.error,
      destructive: true,
    );
    if (confirmed != true) return;
    try {
      await ref.read(adminActionsProvider).deleteWarmup(routine.docKey);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Warmup override removed')),
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
    final AsyncValue<Map<String, WarmupRoutine>> warmups =
        ref.watch(firestoreWarmupsProvider);

    return AdminGuard(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('Warmups'),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add_rounded),
          label: const Text('New'),
          onPressed: () =>
              Navigator.of(context).push(AdminWarmupEditorScreen.route()),
        ),
        body: warmups.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                'Failed to load warmups:\n$e',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
          data: (Map<String, WarmupRoutine> map) {
            if (map.isEmpty) return const _EmptyHint();
            final List<WarmupRoutine> routines = map.values.toList()
              ..sort(
                (WarmupRoutine a, WarmupRoutine b) =>
                    a.docKey.compareTo(b.docKey),
              );
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xs,
                AppSpacing.xs,
                AppSpacing.xs,
                96,
              ),
              itemCount: routines.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.xxs),
              itemBuilder: (BuildContext context, int index) {
                final WarmupRoutine r = routines[index];
                return _WarmupRow(
                  routine: r,
                  onEdit: () => Navigator.of(context).push(
                    AdminWarmupEditorScreen.route(existing: r),
                  ),
                  onDelete: () => _confirmDelete(context, ref, r),
                );
              },
            );
          },
        ),
      ),
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
