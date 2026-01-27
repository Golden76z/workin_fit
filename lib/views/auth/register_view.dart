import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/core/constants/app_constants.dart';
import 'package:workin_fit/core/errors/auth_exception.dart';
import 'package:workin_fit/l10n/app_localizations.dart';
import 'package:workin_fit/providers/auth_provider.dart';
import 'package:workin_fit/views/auth/email_verification_view.dart';
import 'package:workin_fit/views/home/home_page.dart';
import 'package:workin_fit/views/legal/privacy_policy_page.dart';
import 'package:workin_fit/views/legal/terms_of_service_page.dart';
import 'package:workin_fit/widgets/auth_text_field.dart';
import 'package:workin_fit/widgets/button.dart';

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
        // Extract user-friendly error message
        final errorMessage = e is AuthException
            ? e.message
            : e.toString().replaceAll('Exception: ', '');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppColors.error.withValues(alpha: 0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 4),
          ),
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
        // Extract user-friendly error message
        final errorMessage = e is AuthException
            ? e.message
            : e.toString().replaceAll('Exception: ', '');
        
        // Don't show error if user cancelled
        if (e is AuthException && e.code == 'cancelled') {
          // User cancelled, no need to show error
          return;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppColors.error.withValues(alpha: 0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      AppLocalizations.of(context)!.auth_page_register_description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontFamily: 'AppFontMedium',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Username field
                  AuthTextField(
                    controller: _usernameController,
                    label: AppLocalizations.of(context)!.auth_page_register_username_input,
                    hint: 'Choose a username',
                    icon: Icons.person_outline,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username';
                      }
                      if (value.length < AppConstants.minUsernameLength) {
                        return 'Username must be at least ${AppConstants.minUsernameLength} characters';
                      }
                      if (value.length > AppConstants.maxUsernameLength) {
                        return 'Username must be at most ${AppConstants.maxUsernameLength} characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Email field
                  AuthTextField(
                    controller: _emailController,
                    label: AppLocalizations.of(context)!.auth_page_register_email_input,
                    hint: 'Enter your email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Password field
                  AuthTextField(
                    controller: _passwordController,
                    label: AppLocalizations.of(context)!.auth_page_register_password_input,
                    hint: 'Create a strong password',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    showVisibilityToggle: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < AppConstants.minPasswordLength) {
                        return 'Password must be at least ${AppConstants.minPasswordLength} characters';
                      }
                      if (!value.contains(RegExp(r'[A-Z]'))) {
                        return 'Must contain an uppercase letter';
                      }
                      if (!value.contains(RegExp(r'[0-9]'))) {
                        return 'Must contain a number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Confirm password field
                  AuthTextField(
                    controller: _confirmPasswordController,
                    label: AppLocalizations.of(context)!.auth_page_register_confirm_password_input,
                    hint: 'Confirm your password',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    showVisibilityToggle: true,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Register button
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.accent,
                          ),
                        )
                      : AppButton(
                          label: AppLocalizations.of(context)!.auth_page_register_button,
                          onPressed: _register,
                        ),
                  const SizedBox(height: 16),

                  // Terms and privacy
                  _buildTermsText(context),
                  const SizedBox(height: 16),

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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          AppLocalizations.of(context)!.auth_page_register_or_text.toUpperCase(),
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
                  const SizedBox(height: 20),

                  // Social login buttons
                  _buildSocialButton(
                    label: 'Continue with Google',
                    icon: Icons.g_mobiledata,
                    onPressed: _isLoading ? null : _signInWithGoogle,
                  ),
                  const SizedBox(height: 16),
                  _buildSocialButton(
                    label: 'Continue with Apple',
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
          color: AppColors.textPrimary.withValues(alpha: 0.6),
          fontSize: 12,
        ),
        children: [
          const TextSpan(text: 'By creating an account, you agree to our\n'),
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
          const TextSpan(text: ' and '),
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
          color: AppColors.textPrimary.withValues(alpha: 0.2),
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: AppColors.textPrimary),
          const SizedBox(width: 12),
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