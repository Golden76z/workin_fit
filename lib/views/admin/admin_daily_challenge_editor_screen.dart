import 'package:flutter/material.dart';
import 'package:workin_fit/views/admin/widgets/admin_placeholder.dart';

/// Placeholder for daily-challenge authoring. Challenges are currently derived
/// from `DailyChallengesCatalog` in code (only completion state is persisted).
/// The write path exists via `AdminContentService.upsertContentDocument`
/// targeting the `daily_challenges` collection; the catalog/read path needs to
/// consume Firestore before this editor is wired up.
class AdminDailyChallengeEditorScreen extends StatelessWidget {
  const AdminDailyChallengeEditorScreen({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => const AdminDailyChallengeEditorScreen(),
      );

  @override
  Widget build(BuildContext context) {
    return const AdminPlaceholderScreen(
      title: 'Daily Challenges',
      icon: Icons.emoji_events_rounded,
      message: 'Daily challenges come from a static catalog today. '
          'Firestore-backed authoring is planned — the exercise editor is the '
          'reference flow.',
    );
  }
}
