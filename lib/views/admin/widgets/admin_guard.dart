import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/providers/admin_providers.dart';

/// Wraps any admin screen and only renders [child] when the current user is an
/// admin. This is defence-in-depth: even if an admin route is reached directly,
/// non-admins see an access-denied screen rather than admin tooling. Real
/// enforcement of writes lives in Firestore security rules.
class AdminGuard extends ConsumerWidget {
  const AdminGuard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isAdmin = ref.watch(isAdminProvider);
    if (isAdmin) return child;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Admin'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.lock_outline_rounded,
                size: 48,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Admin access required',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Your account does not have permission to view this area.',
                textAlign: TextAlign.center,
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
