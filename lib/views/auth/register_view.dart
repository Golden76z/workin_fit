import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/core/constants/app_constants.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/errors/auth_exception.dart';
import 'package:workin_fit/core/errors/auth_error_mapper.dart';
import 'package:workin_fit/l10n/app_localizations.dart';
import 'package:workin_fit/providers/auth_provider.dart';
import 'package:workin_fit/views/auth/email_verification_view.dart';
import 'package:workin_fit/views/home/home_page.dart';
import 'package:workin_fit/views/legal/privacy_policy_page.dart';
import 'package:workin_fit/views/legal/terms_of_service_page.dart';
import 'package:workin_fit/widgets/auth_text_field.dart';
import 'package:workin_fit/widgets/button.dart';
import 'package:workin_fit/core/theme/app_opacity.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: AppColors.textPrimary.withValues(alpha: 0.9),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.errorSoft,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        duration: AppDurations.snackBar,
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authActionsProvider).registerWithEmailPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            username: _usernameController.text.trim(),
          );

      if (!mounted) return;

      // Navigate to email verification screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const EmailVerificationView(),
        ),
      );
    } catch (e) {
      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        final errorMessage = e is AuthException
            ? mapAuthErrorToMessage(context, e)
            : localizations.error_auth_generic;

        _showErrorSnackBar(errorMessage);
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

      // Google sign-in automatically creates account and verifies email
      // Navigate to home page
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
        (route) => false,
      );
    } catch (e) {
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

        _showErrorSnackBar(errorMessage);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                      localizations.auth_page_register_description,
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

                  // Username field
                  AuthTextField(
                    controller: _usernameController,
                    label: localizations.auth_page_register_username_input,
                    hint: localizations.auth_register_username_hint,
                    icon: Icons.person_outline,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations
                            .auth_register_validation_username_required;
                      }
                      if (value.length < AppConstants.minUsernameLength) {
                        return localizations
                            .auth_register_validation_username_min(
                          AppConstants.minUsernameLength,
                        );
                      }
                      if (value.length > AppConstants.maxUsernameLength) {
                        return localizations
                            .auth_register_validation_username_max(
                          AppConstants.maxUsernameLength,
                        );
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Email field
                  AuthTextField(
                    controller: _emailController,
                    label: localizations.auth_page_register_email_input,
                    hint: localizations.auth_register_email_hint,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations
                            .auth_register_validation_email_required;
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return localizations
                            .auth_register_validation_email_invalid;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Password field
                  AuthTextField(
                    controller: _passwordController,
                    label: localizations.auth_page_register_password_input,
                    hint: localizations.auth_register_password_hint,
                    icon: Icons.lock_outline,
                    obscureText: true,
                    showVisibilityToggle: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations
                            .auth_register_validation_password_required;
                      }
                      if (value.length < AppConstants.minPasswordLength) {
                        return localizations
                            .auth_register_validation_password_min(
                          AppConstants.minPasswordLength,
                        );
                      }
                      if (!value.contains(RegExp(r'[A-Z]'))) {
                        return localizations
                            .auth_register_validation_password_uppercase;
                      }
                      if (!value.contains(RegExp(r'[0-9]'))) {
                        return localizations
                            .auth_register_validation_password_number;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Confirm password field
                  AuthTextField(
                    controller: _confirmPasswordController,
                    label:
                        localizations.auth_page_register_confirm_password_input,
                    hint: localizations.auth_register_confirm_password_hint,
                    icon: Icons.lock_outline,
                    obscureText: true,
                    showVisibilityToggle: true,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return localizations
                            .auth_register_validation_password_match;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Register button
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.accent,
                          ),
                        )
                      : AppButton(
                          label: localizations.auth_page_register_button,
                          onPressed: _register,
                        ),
                  const SizedBox(height: AppSpacing.md),

                  // Terms and privacy
                  _buildTermsText(context),
                  const SizedBox(height: AppSpacing.md),

                  // Social login divider
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: AppColors.textPrimary.withValues(alpha: AppOpacity.soft),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: Text(
                          localizations.auth_page_register_or_text
                              .toUpperCase(),
                          style: TextStyle(
                            color: AppColors.textPrimary.withValues(alpha: AppOpacity.half),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: AppColors.textPrimary.withValues(alpha: AppOpacity.soft),
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

  Widget _buildTermsText(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          color: AppColors.textPrimary.withValues(alpha: AppOpacity.visible),
          fontSize: 12,
        ),
        children: [
          TextSpan(text: localizations.auth_register_terms_prefix),
          TextSpan(
            text: localizations.terms_of_service_title,
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 12,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TermsOfServicePage(),
                  ),
                );
              },
          ),
          TextSpan(text: localizations.auth_register_terms_and),
          TextSpan(
            text: localizations.privacy_policy_title,
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 12,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyPage(),
                  ),
                );
              },
          ),
        ],
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
          color: AppColors.textPrimary.withValues(alpha: AppOpacity.soft),
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
