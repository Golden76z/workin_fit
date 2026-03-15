import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/core/errors/auth_exception.dart';
import 'package:workin_fit/l10n/app_localizations.dart';
import 'package:workin_fit/providers/auth_provider.dart';
import 'package:workin_fit/views/home/home_page.dart';
import 'package:workin_fit/widgets/app_dialog.dart';
import 'package:workin_fit/widgets/button.dart';

class EmailVerificationView extends ConsumerStatefulWidget {
  const EmailVerificationView({super.key});

  @override
  ConsumerState<EmailVerificationView> createState() =>
      _EmailVerificationViewState();
}

class _EmailVerificationViewState
    extends ConsumerState<EmailVerificationView> {
  bool _isResending = false;
  bool _isChecking = false;

  String? get _userEmail => ref.read(currentUserProvider)?.email;

  Future<void> _checkVerification() async {
    setState(() => _isChecking = true);

    try {
      // Reload user to get latest verification status
      await ref.read(authActionsProvider).reloadUser();

      if (!mounted) return;

      final user = ref.read(currentUserProvider);
      final localizations = AppLocalizations.of(context)!;
      if (user?.emailVerified ?? false) {
        // Email is verified, navigate to home
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.email_verification_success),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
          // Navigate to home page after a short delay to show success message
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ),
                (route) => false,
              );
            }
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.email_verification_not_verified),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e is AuthException
            ? e.message
            : e.toString().replaceAll('Exception: ', '');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() => _isResending = true);

    try {
      await ref.read(authActionsProvider).sendEmailVerification();

      if (!mounted) return;

      final localizations = AppLocalizations.of(context)!;

      AppDialog.show(
        context: context,
        title: localizations.email_verification_resend_title,
        content: localizations.email_verification_resend_content(
          _userEmail ?? '',
        ),
        icon: Icons.email_outlined,
        primaryButtonLabel: localizations.email_verification_resend_button,
      );
    } catch (e) {
      if (mounted) {
        final errorMessage = e is AuthException
            ? e.message
            : e.toString().replaceAll('Exception: ', '');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              // If no route to pop, sign out and go to welcome page
              ref.read(authActionsProvider).signOut();
            }
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: _isChecking
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent,
                      ),
                    )
                  : const Icon(
                      Icons.refresh,
                      color: AppColors.accent,
                    ),
              onPressed: _isChecking ? null : () => _checkVerification(),
              tooltip: AppLocalizations.of(context)!.email_verification_check_tooltip,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.email_outlined,
                  size: 80,
                  color: AppColors.accent,
                ),
                const SizedBox(height: 32),
                Text(
                  AppLocalizations.of(context)!.email_verification_title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'AppFontMedium',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.email_verification_sent_to,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                if (_userEmail != null)
                  Text(
                    _userEmail!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 32),
                Text(
                  AppLocalizations.of(context)!.email_verification_instructions,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 48),
                AppButton(
                  label: _isChecking
                      ? AppLocalizations.of(context)!.email_verification_button_checking
                      : AppLocalizations.of(context)!.email_verification_button_verified,
                  onPressed: _isChecking ? null : () => _checkVerification(),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _isResending ? null : () => _resendVerificationEmail(),
                  child: _isResending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.accent,
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context)!.email_verification_resend,
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
