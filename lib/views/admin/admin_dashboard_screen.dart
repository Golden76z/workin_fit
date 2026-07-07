import 'package:flutter/material.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/views/admin/admin_daily_challenge_list_screen.dart';
import 'package:workin_fit/views/admin/admin_exercise_list_screen.dart';
import 'package:workin_fit/views/admin/admin_program_editor_screen.dart';
import 'package:workin_fit/views/admin/admin_warmup_editor_screen.dart';
import 'package:workin_fit/views/admin/widgets/admin_guard.dart';

/// Entry point for the in-app admin content tools. Guarded by [AdminGuard] so
/// only admins can see the management sections.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => const AdminDashboardScreen(),
      );

  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('Admin'),
        ),
        body: SafeArea(
          child: GridView.count(
            padding: const EdgeInsets.all(AppSpacing.md),
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.05,
            children: <Widget>[
              _AdminCard(
                icon: Icons.fitness_center_rounded,
                label: 'Exercises',
                subtitle: 'Add, edit & remove',
                onTap: () => Navigator.of(context)
                    .push(AdminExerciseListScreen.route()),
              ),
              _AdminCard(
                icon: Icons.calendar_month_rounded,
                label: 'Programs',
                subtitle: 'Preset programs',
                onTap: () => Navigator.of(context)
                    .push(AdminProgramEditorScreen.route()),
              ),
              _AdminCard(
                icon: Icons.self_improvement_rounded,
                label: 'Warmups',
                subtitle: 'Warmup routines',
                onTap: () => Navigator.of(context)
                    .push(AdminWarmupEditorScreen.route()),
              ),
              _AdminCard(
                icon: Icons.emoji_events_rounded,
                label: 'Daily Challenges',
                subtitle: 'Manage challenges',
                onTap: () => Navigator.of(context)
                    .push(AdminDailyChallengeListScreen.route()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  const _AdminCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, size: 32, color: AppColors.primary),
              const Spacer(),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
