import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/views/admin/widgets/admin_guard.dart';
import 'package:workin_fit/widgets/app_dialog.dart';

/// Shared scaffold for the admin content-list screens (exercises, programs,
/// daily challenges, warmups). Each of those screens is otherwise identical:
/// [AdminGuard] → [Scaffold] with an AppBar + a "New" FAB → an async body that
/// shows a spinner / error / empty-state / separated list, plus a
/// confirm-then-delete flow with success + failure snackbars.
///
/// Callers supply an already-normalized (filtered/sorted) `AsyncValue<List<T>>`
/// so per-screen differences in provider shape and sort order stay out of here,
/// and a [rowBuilder] that renders one item with ready-made edit/delete
/// callbacks — the only part that genuinely differs per content type.
class AdminListScaffold<T> extends ConsumerWidget {
  const AdminListScaffold({
    required this.title,
    required this.errorNoun,
    required this.items,
    required this.emptyState,
    required this.onNew,
    required this.onEditItem,
    required this.rowBuilder,
    required this.deleteTitle,
    required this.deleteMessage,
    required this.deletedMessage,
    required this.onDelete,
    super.key,
  });

  /// AppBar title, e.g. `'Exercises'`.
  final String title;

  /// Lower-case plural used in the load-error message, e.g. `'exercises'`.
  final String errorNoun;

  /// Already-normalized items (sorting/filtering done by the caller).
  final AsyncValue<List<T>> items;

  /// Shown when the loaded list is empty.
  final Widget emptyState;

  /// Opens the editor to create a new item.
  final VoidCallback onNew;

  /// Opens the editor for [item].
  final void Function(BuildContext context, T item) onEditItem;

  /// Renders a single row given prepared edit/delete callbacks.
  final Widget Function(T item, VoidCallback onEdit, VoidCallback onDelete)
      rowBuilder;

  /// Confirmation-dialog title, e.g. `'Delete exercise?'`.
  final String deleteTitle;

  /// Confirmation-dialog body for [item].
  final String Function(T item) deleteMessage;

  /// Success-snackbar text after [item] is deleted.
  final String Function(T item) deletedMessage;

  /// Performs the actual delete (wired to the relevant admin action).
  final Future<void> Function(WidgetRef ref, T item) onDelete;

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    T item,
  ) async {
    final bool? confirmed = await AppDialog.showConfirm(
      context: context,
      title: deleteTitle,
      message: deleteMessage(item),
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      icon: Icons.delete_outline_rounded,
      iconColor: AppColors.error,
      destructive: true,
    );
    if (confirmed != true) return;
    try {
      await onDelete(ref, item);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(deletedMessage(item))),
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
    return AdminGuard(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: Text(title),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add_rounded),
          label: const Text('New'),
          onPressed: onNew,
        ),
        body: items.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                'Failed to load $errorNoun:\n$e',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
          data: (List<T> list) {
            if (list.isEmpty) return emptyState;
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xs,
                AppSpacing.xs,
                AppSpacing.xs,
                96, // clear the FAB
              ),
              itemCount: list.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.xxs),
              itemBuilder: (BuildContext context, int index) {
                final T item = list[index];
                return rowBuilder(
                  item,
                  () => onEditItem(context, item),
                  () => _confirmDelete(context, ref, item),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
