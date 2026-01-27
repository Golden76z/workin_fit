import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/l10n/app_localizations.dart';
import 'package:workin_fit/providers/auth_provider.dart';
import 'package:workin_fit/views/auth/authentication_view.dart';
import 'package:workin_fit/widgets/button.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final userEmail = user?.email ?? 'User';
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          localizations.welcome_page_app_title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontFamily: 'AppFont',
            fontSize: 28,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              // Welcome message
              Text(
                localizations.home_welcome_title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'AppFontMedium',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                userEmail,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 48),
              
              // Placeholder content
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 80,
                        color: AppColors.accent.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        localizations.home_placeholder_title,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        localizations.home_placeholder_subtitle,
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Logout button
              AppButton(
                label: localizations.home_logout,
                onPressed: () async {
                  try {
                    // Sign out and navigate immediately
                    // We navigate before signOut completes to avoid auth state listener interference
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const AuthenticationView(
                            initialTabIndex: 1, // Login tab
                          ),
                        ),
                        (route) => false,
                      );
                    }
                    // Sign out after navigation
                    await ref.read(authActionsProvider).signOut();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            localizations.email_verification_error_signout(
                              e.toString(),
                            ),
                          ),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
