import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/l10n/app_localizations.dart';
import 'package:workin_fit/providers/auth_provider.dart';
import 'package:workin_fit/views/auth/auth_page_layout.dart';
import 'package:workin_fit/widgets/auth_text_field.dart';
import 'package:workin_fit/widgets/button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
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
          );

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Verify Your Email'),
          content: const Text(
            'A verification email has been sent. Please verify before logging in.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: '',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            AuthTextField(
              controller: _emailController,
              label: AppLocalizations.of(context)!.auth_page_register_username_input,
              icon: Icons.person,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (value.length < 4) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),


            AuthTextField(
              controller: _emailController,
              label: AppLocalizations.of(context)!.auth_page_register_email_input,
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            AuthTextField(
              controller: _passwordController,
              label: AppLocalizations.of(context)!.auth_page_register_password_input,
              icon: Icons.lock,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters';
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

            AuthTextField(
              controller: _confirmPasswordController,
              label: AppLocalizations.of(context)!.auth_page_register_confirm_password_input,
              icon: Icons.lock_outline,
              obscureText: true,
              validator: (value) {
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : AppButton(
                    label: AppLocalizations.of(context)!.auth_page_register_button,
                    onPressed: _register,
                  ),
          ],
        ),
      ),
    );
  }
}