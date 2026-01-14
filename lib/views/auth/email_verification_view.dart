import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/core/errors/auth_exception.dart';
import 'package:workin_fit/providers/auth_provider.dart';
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
      if (user?.emailVerified ?? false) {
        // Email is verified, navigation will be handled by auth state listener
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Email verified successfully!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Email not verified yet. Please check your inbox.'),
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

      AppDialog.show(
        context: context,
        title: 'Verification Email Sent',
        content:
            'A new verification email has been sent to $_userEmail. Please check your inbox.',
        icon: Icons.email_outlined,
        primaryButtonLabel: 'OK',
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

  Future<void> _signOut() async {
    try {
      await ref.read(authActionsProvider).signOut();
    } catch (e) {
      if (mounted) {
        final errorMessage = e is AuthException
            ? e.message
            : e.toString().replaceAll('Exception: ', '');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $errorMessage'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
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
                const SizedBox(height: 24),
                const Text(
                  'Verify Your Email',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'We\'ve sent a verification email to:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
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
                const SizedBox(height: 24),
                Text(
                  'Please check your inbox and click the verification link to activate your account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: _isChecking ? 'Checking...' : 'I\'ve Verified My Email',
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
                      : const Text(
                          'Resend Verification Email',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                const SizedBox(height: 32),
                TextButton(
                  onPressed: _signOut,
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
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
