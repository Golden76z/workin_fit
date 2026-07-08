import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/models/daily_challenge.dart';
import 'package:workin_fit/providers/admin_providers.dart';
import 'package:workin_fit/providers/challenge_providers.dart';
import 'package:workin_fit/views/admin/admin_daily_challenge_editor_screen.dart';
import 'package:workin_fit/views/admin/widgets/admin_list_scaffold.dart';

/// Admin list of authored daily challenges. When empty, the app falls back to
/// the built-in catalog — surfaced as a hint here.
class AdminDailyChallengeListScreen extends ConsumerWidget {
  const AdminDailyChallengeListScreen({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => const AdminDailyChallengeListScreen(),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<DailyChallenge>> challenges =
        ref.watch(allDailyChallengesProvider);

    return AdminListScaffold<DailyChallenge>(
      title: 'Daily Challenges',
      errorNoun: 'challenges',
      items: challenges,
      emptyState: const _EmptyHint(),
      onNew: () =>
          Navigator.of(context).push(AdminDailyChallengeEditorScreen.route()),
      onEditItem: (BuildContext context, DailyChallenge challenge) =>
          Navigator.of(context).push(
        AdminDailyChallengeEditorScreen.route(existing: challenge),
      ),
      rowBuilder: (DailyChallenge challenge, VoidCallback onEdit,
              VoidCallback onDelete) =>
          _ChallengeRow(
        challenge: challenge,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
      deleteTitle: 'Delete challenge?',
      deleteMessage: (DailyChallenge c) => '“${c.title}” will be removed.',
      deletedMessage: (DailyChallenge c) => 'Deleted “${c.title}”',
      onDelete: (WidgetRef ref, DailyChallenge c) =>
          ref.read(adminActionsProvider).deleteDailyChallenge(c.id),
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
              Icons.emoji_events_outlined,
              size: 44,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No authored challenges yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'The built-in challenge catalog is active. Add one here to '
              'override it — authored challenges take over the daily rotation '
              'for everyone.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChallengeRow extends StatelessWidget {
  const _ChallengeRow({
    required this.challenge,
    required this.onEdit,
    required this.onDelete,
  });

  final DailyChallenge challenge;
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
                      challenge.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${challenge.difficulty.name} · ${challenge.type.name} · '
                      '${challenge.target} ${challenge.unit}',
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
