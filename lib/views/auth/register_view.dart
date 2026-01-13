import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/core/constants/app_constants.dart';
import 'package:workin_fit/core/errors/auth_exception.dart';
import 'package:workin_fit/l10n/app_localizations.dart';
import 'package:workin_fit/providers/auth_provider.dart';
import 'package:workin_fit/widgets/auth_text_field.dart';
import 'package:workin_fit/widgets/button.dart';
import 'package:workin_fit/widgets/app_dialog.dart';

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

      AppDialog.show(
        context: context,
        barrierDismissible: false,
        title: 'Verify Your Email',
        content:
            'A verification email has been sent to your inbox. Please verify your email address before logging in.',
        icon: Icons.email_outlined,
        primaryButtonLabel: 'Got it',
        onPrimaryButtonPressed: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      );
    } catch (e) {
      if (mounted) {
        // Extract user-friendly error message
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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
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
                  const SizedBox(height: 16),

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
                  const SizedBox(height: 16),

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
                  const SizedBox(height: 16),

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
                  const SizedBox(height: 24),

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
                  const SizedBox(height: 24),

                  // Terms and privacy
                  Text(
                    'By creating an account, you agree to our\nTerms of Service and Privacy Policy',
                    style: TextStyle(
                      color: AppColors.textPrimary.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}