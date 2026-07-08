import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/features/session/presentation/screens/session_builder_screen.dart';
import 'package:workin_fit/models/session.dart';
import 'package:workin_fit/providers/admin_providers.dart';
import 'package:workin_fit/views/admin/widgets/admin_list_scaffold.dart';

/// Admin list of curated preset sessions (the ones programs reference). Reads
/// [adminSessionsProvider]. Create, edit, and delete all reuse the full workout
/// builder in preset mode (edit reverse-populates it from the saved session).
class AdminSessionListScreen extends ConsumerWidget {
  const AdminSessionListScreen({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => const AdminSessionListScreen(),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Session>> sessions =
        ref.watch(adminSessionsProvider).whenData(
              (List<Session> list) => <Session>[...list]..sort(
                  (Session a, Session b) =>
                      a.name.toLowerCase().compareTo(b.name.toLowerCase()),
                ),
            );

    return AdminListScaffold<Session>(
      title: 'Sessions',
      errorNoun: 'sessions',
      items: sessions,
      emptyState: const _EmptyHint(),
      onNew: () =>
          Navigator.of(context).push(SessionBuilderScreen.presetRoute()),
      onEditItem: (BuildContext context, Session session) =>
          Navigator.of(context).push(
        SessionBuilderScreen.presetRoute(existing: session),
      ),
      rowBuilder:
          (Session session, VoidCallback onEdit, VoidCallback onDelete) =>
              _SessionRow(
        session: session,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
      deleteTitle: 'Delete session?',
      deleteMessage: (Session s) =>
          '“${s.name}” will be removed. Programs that reference it will no '
          'longer find this session.',
      deletedMessage: (Session s) => 'Deleted “${s.name}”',
      onDelete: (WidgetRef ref, Session s) =>
          ref.read(adminActionsProvider).deletePresetSession(s.id),
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
              Icons.playlist_add_check_rounded,
              size: 44,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No preset sessions yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Tap “New” to author a curated session with the full workout '
              'builder. Preset sessions are what programs reference by id.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({
    required this.session,
    required this.onEdit,
    required this.onDelete,
  });

  final Session session;
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
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.sm),
                child: Container(
                  width: 48,
                  height: 48,
                  color: AppColors.surfaceVariant,
                  child: const Icon(
                    Icons.fitness_center_rounded,
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
                      session.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${session.difficulty.name} · '
                      '${session.exerciseCount} exercises · '
                      '${session.durationDisplay}',
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
