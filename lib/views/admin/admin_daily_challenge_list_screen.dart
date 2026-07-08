import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/models/daily_challenge.dart';
import 'package:workin_fit/providers/admin_providers.dart';
import 'package:workin_fit/providers/challenge_providers.dart';
import 'package:workin_fit/views/admin/admin_daily_challenge_editor_screen.dart';
import 'package:workin_fit/views/admin/widgets/admin_guard.dart';
import 'package:workin_fit/widgets/app_dialog.dart';

/// Admin list of authored daily challenges. When empty, the app falls back to
/// the built-in catalog — surfaced as a hint here.
class AdminDailyChallengeListScreen extends ConsumerWidget {
  const AdminDailyChallengeListScreen({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => const AdminDailyChallengeListScreen(),
      );

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    DailyChallenge challenge,
  ) async {
    final bool? confirmed = await AppDialog.showConfirm(
      context: context,
      title: 'Delete challenge?',
      message: '“${challenge.title}” will be removed.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      icon: Icons.delete_outline_rounded,
      iconColor: AppColors.error,
      destructive: true,
    );
    if (confirmed != true) return;
    try {
      await ref.read(adminActionsProvider).deleteDailyChallenge(challenge.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted “${challenge.title}”')),
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
    final AsyncValue<List<DailyChallenge>> challenges =
        ref.watch(allDailyChallengesProvider);

    return AdminGuard(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('Daily Challenges'),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add_rounded),
          label: const Text('New'),
          onPressed: () => Navigator.of(context).push(
            AdminDailyChallengeEditorScreen.route(),
          ),
        ),
        body: challenges.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                'Failed to load challenges:\n$e',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
          data: (List<DailyChallenge> list) {
            if (list.isEmpty) {
              return const _EmptyHint();
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xs,
                AppSpacing.xs,
                AppSpacing.xs,
                96,
              ),
              itemCount: list.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.xxs),
              itemBuilder: (BuildContext context, int index) {
                final DailyChallenge c = list[index];
                return _ChallengeRow(
                  challenge: c,
                  onEdit: () => Navigator.of(context).push(
                    AdminDailyChallengeEditorScreen.route(existing: c),
                  ),
                  onDelete: () => _confirmDelete(context, ref, c),
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
