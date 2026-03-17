import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/core/errors/auth_exception.dart';
import 'package:workin_fit/core/errors/auth_error_mapper.dart';
import 'package:workin_fit/l10n/app_localizations.dart';
import 'package:workin_fit/providers/auth_provider.dart';
import 'package:workin_fit/views/home/home_page.dart';
import 'package:workin_fit/widgets/auth_text_field.dart';
import 'package:workin_fit/widgets/app_dialog.dart';
import 'package:workin_fit/widgets/button.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar({
    required String message,
    required Color backgroundColor,
    FontWeight? fontWeight,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: AppColors.textPrimary.withValues(alpha: 0.9),
            fontWeight: fontWeight,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        duration: AppDurations.snackBar,
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authActionsProvider).signInWithEmailPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (!mounted) return;

      // Check if email is verified, if not, navigation will be handled by auth state listener
      final user = ref.read(currentUserProvider);
      if (user?.emailVerified ?? false) {
        // Navigate to home page
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
          (route) => false,
        );
      }
      // If not verified, the auth state listener will redirect to email verification
    } catch (e) {
      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        final errorMessage = e is AuthException
            ? mapAuthErrorToMessage(context, e)
            : localizations.error_auth_generic;

        _showSnackBar(
          message: errorMessage,
          backgroundColor: AppColors.errorSoft,
          fontWeight: FontWeight.w600,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(authActionsProvider).signInWithGoogle();

      if (!mounted) return;

      // Check if email is verified (Google accounts are auto-verified)
      final user = ref.read(currentUserProvider);
      if (user != null) {
        // Navigate to home page
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      // Log error for debugging
      debugPrint('Google Sign-In Error in UI: $e');
      if (e is AuthException && e.originalException != null) {
        debugPrint('Original exception: ${e.originalException}');
      }

      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        final errorMessage = e is AuthException
            ? mapAuthErrorToMessage(context, e)
            : localizations.error_auth_generic;

        // Don't show error if user cancelled
        if (e is AuthException && e.code == 'cancelled') {
          // User cancelled, no need to show error
          return;
        }

        _showSnackBar(
          message: errorMessage,
          backgroundColor: AppColors.errorSoft,
          fontWeight: FontWeight.w600,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final localizations = AppLocalizations.of(context)!;

    if (_emailController.text.trim().isEmpty) {
      _showSnackBar(
        message: localizations.auth_login_forgot_dialog_email_required,
        backgroundColor: AppColors.warningSoft,
      );
      return;
    }

    final email = _emailController.text.trim();

    final confirmed = await AppDialog.showConfirm(
      context: context,
      title: localizations.auth_login_forgot_dialog_title,
      confirmLabel: localizations.auth_login_forgot_dialog_send,
      cancelLabel: localizations.auth_login_forgot_dialog_cancel,
      message: localizations.auth_login_forgot_dialog_content(email),
      icon: Icons.lock_reset_rounded,
      iconColor: AppColors.primary,
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(authActionsProvider).sendPasswordResetEmail(email);
      if (mounted) {
        _showSnackBar(
          message: localizations.auth_login_forgot_dialog_success,
          backgroundColor: AppColors.successSoft,
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e is AuthException
            ? mapAuthErrorToMessage(context, e)
            : localizations.error_auth_generic;
        _showSnackBar(
          message: errorMessage,
          backgroundColor: AppColors.errorSoft,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xxl,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      localizations.auth_page_login_description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontFamily: 'AppFontMedium',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Email field
                  AuthTextField(
                    controller: _emailController,
                    label: localizations.auth_login_email_label,
                    hint: localizations.auth_login_email_hint,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations
                            .auth_login_validation_email_required;
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return localizations
                            .auth_login_validation_email_invalid;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Password field
                  AuthTextField(
                    controller: _passwordController,
                    label: localizations.auth_login_password_label,
                    hint: localizations.auth_login_password_hint,
                    icon: Icons.lock_outline,
                    obscureText: true,
                    showVisibilityToggle: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations
                            .auth_login_validation_password_required;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _forgotPassword,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: AppSpacing.xxs,
                        ),
                      ),
                      child: Text(
                        localizations.auth_login_forgot_password,
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Login button
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.accent,
                          ),
                        )
                      : AppButton(
                          label: localizations.auth_page_login_button,
                          onPressed: _login,
                        ),
                  const SizedBox(height: AppSpacing.lg),

                  // Social login divider
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: AppColors.textPrimary.withValues(alpha: 0.2),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: Text(
                          localizations.auth_login_or_text,
                          style: TextStyle(
                            color: AppColors.textPrimary.withValues(alpha: 0.5),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: AppColors.textPrimary.withValues(alpha: 0.2),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Social login buttons
                  _buildSocialButton(
                    label: localizations.auth_login_social_google,
                    icon: Icons.g_mobiledata,
                    onPressed: _isLoading ? null : _signInWithGoogle,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildSocialButton(
                    label: localizations.auth_login_social_apple,
                    icon: Icons.apple,
                    onPressed: () {
                      // Add Apple sign-in logic
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: BorderSide(
          color: AppColors.textPrimary.withValues(alpha: 0.2),
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm + 2,
          horizontal: AppSpacing.xl,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: AppColors.textPrimary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
