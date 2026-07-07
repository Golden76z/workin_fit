import 'package:flutter/material.dart';
import 'package:workin_fit/views/admin/widgets/admin_placeholder.dart';

/// Placeholder for warmup authoring. Warmup routines are currently defined
/// statically in `lib/data/warmup_routines.dart` and read locally; wiring an
/// admin editor requires moving that read path to Firestore first. The write
/// path already exists via `AdminContentService.upsertContentDocument`.
class AdminWarmupEditorScreen extends StatelessWidget {
  const AdminWarmupEditorScreen({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => const AdminWarmupEditorScreen(),
      );

  @override
  Widget build(BuildContext context) {
    return const AdminPlaceholderScreen(
      title: 'Warmups',
      icon: Icons.self_improvement_rounded,
      message: 'Warmup routines are defined locally today. Firestore-backed '
          'authoring is planned — the exercise editor is the reference flow.',
    );
  }
}
