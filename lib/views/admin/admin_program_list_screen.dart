import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/models/program.dart';
import 'package:workin_fit/providers/admin_providers.dart';
import 'package:workin_fit/views/admin/admin_program_editor_screen.dart';
import 'package:workin_fit/views/admin/widgets/admin_guard.dart';
import 'package:workin_fit/widgets/app_dialog.dart';

/// Admin list of all preset programs with create / edit / delete. Reads
/// [adminProgramsProvider] so newly saved content shows up after a write.
class AdminProgramListScreen extends ConsumerWidget {
  const AdminProgramListScreen({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => const AdminProgramListScreen(),
      );

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Program program,
  ) async {
    final bool? confirmed = await AppDialog.showConfirm(
      context: context,
      title: 'Delete program?',
      message: '“${program.name}” will be removed for all users.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      icon: Icons.delete_outline_rounded,
      iconColor: AppColors.error,
      destructive: true,
    );
    if (confirmed != true) return;
    try {
      await ref.read(adminActionsProvider).deletePresetProgram(program.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted “${program.name}”')),
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
    final AsyncValue<List<Program>> programs =
        ref.watch(adminProgramsProvider);

    return AdminGuard(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('Programs'),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add_rounded),
          label: const Text('New'),
          onPressed: () => Navigator.of(context).push(
            AdminProgramEditorScreen.route(),
          ),
        ),
        body: programs.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                'Failed to load programs:\n$e',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
          data: (List<Program> list) {
            if (list.isEmpty) {
              return const Center(
                child: Text(
                  'No programs yet. Tap “New” to add one.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }
            final List<Program> sorted = <Program>[...list]
              ..sort(
                (Program a, Program b) =>
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
                final Program program = sorted[index];
                return _ProgramRow(
                  program: program,
                  onEdit: () => Navigator.of(context).push(
                    AdminProgramEditorScreen.route(existing: program),
                  ),
                  onDelete: () => _confirmDelete(context, ref, program),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ProgramRow extends StatelessWidget {
  const _ProgramRow({
    required this.program,
    required this.onEdit,
    required this.onDelete,
  });

  final Program program;
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
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.sm),
                child: Container(
                  width: 48,
                  height: 48,
                  color: AppColors.surfaceVariant,
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    size: 20,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      program.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${program.difficulty.name} · '
                      '${program.durationWeeks}w · '
                      '${program.daysPerWeek}d/wk · '
                      '${program.totalSessions} sessions',
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
