import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/models/program.dart';
import 'package:workin_fit/providers/admin_providers.dart';
import 'package:workin_fit/views/admin/admin_program_editor_screen.dart';
import 'package:workin_fit/views/admin/widgets/admin_list_scaffold.dart';

/// Admin list of all preset programs with create / edit / delete. Reads
/// [adminProgramsProvider] so newly saved content shows up after a write.
class AdminProgramListScreen extends ConsumerWidget {
  const AdminProgramListScreen({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => const AdminProgramListScreen(),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Program>> programs =
        ref.watch(adminProgramsProvider).whenData(
              (List<Program> list) => <Program>[...list]..sort(
                  (Program a, Program b) =>
                      a.name.toLowerCase().compareTo(b.name.toLowerCase()),
                ),
            );

    return AdminListScaffold<Program>(
      title: 'Programs',
      errorNoun: 'programs',
      items: programs,
      emptyState: const Center(
        child: Text(
          'No programs yet. Tap “New” to add one.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
      onNew: () => Navigator.of(context).push(AdminProgramEditorScreen.route()),
      onEditItem: (BuildContext context, Program program) =>
          Navigator.of(context).push(
        AdminProgramEditorScreen.route(existing: program),
      ),
      rowBuilder:
          (Program program, VoidCallback onEdit, VoidCallback onDelete) =>
              _ProgramRow(program: program, onEdit: onEdit, onDelete: onDelete),
      deleteTitle: 'Delete program?',
      deleteMessage: (Program p) => '“${p.name}” will be removed for all users.',
      deletedMessage: (Program p) => 'Deleted “${p.name}”',
      onDelete: (WidgetRef ref, Program p) =>
          ref.read(adminActionsProvider).deletePresetProgram(p.id),
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
