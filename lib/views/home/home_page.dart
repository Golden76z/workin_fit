import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
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
    final localizations = AppLocalizations.of(context)!;
    final userEmail = user?.email ?? localizations.home_user_fallback;

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
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xxl),
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
              const SizedBox(height: AppSpacing.xs),
              Text(
                userEmail,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              // Test labels with AppFont
              Text(
                localizations.home_preview_front,
                style: const TextStyle(
                  fontFamily: 'AppFont',
                  fontSize: 24,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                localizations.home_preview_back,
                style: const TextStyle(
                  fontFamily: 'AppFont',
                  fontSize: 24,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Test image with horizontal margin (for render preview)
              Padding(
                padding: EdgeInsets.zero,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  child: Image.asset(
                    'assets/images/test.png',
                    fit: BoxFit.contain,
                    width: double.infinity,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
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
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        localizations.home_placeholder_title,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        localizations.home_placeholder_subtitle,
                        style: const TextStyle(
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
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
