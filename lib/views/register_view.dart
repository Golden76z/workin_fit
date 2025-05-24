import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sport_app/services/auth/auth_exceptions.dart';
import 'package:sport_app/services/auth/bloc/auth_bloc.dart';
import 'package:sport_app/services/auth/bloc/auth_event.dart';
import 'package:sport_app/services/auth/bloc/auth_state.dart';
import 'package:sport_app/utilities/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _username;
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _confirmPassword;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _username = TextEditingController();
    _email = TextEditingController();
    _password = TextEditingController();
    _confirmPassword = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_password.text != _confirmPassword.text) {
        await showErrorDialog(context, "Passwords don't match");
        return;
      }
      context.read<AuthBloc>().add(
            AuthEventRegister(_email.text, _password.text),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthStateRegistering) {
            if (state.exception is WeakPasswordAuthException) {
              await showErrorDialog(context, 'Weak password');
            } else if (state.exception is EmailAlreadyUsedAuthException) {
              await showErrorDialog(context, 'Email already taken');
            } else if (state.exception is EmailFormatAuthException) {
              await showErrorDialog(context, 'Invalid email format');
            } else if (state.exception is GenericAuthException) {
              await showErrorDialog(context, 'Failed to register');
            }
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App Logo/Header Section
                  Container(
                    margin: const EdgeInsets.only(bottom: 48),
                    child: Column(
                      children: [
                        // App Logo
                        // Container(
                        //   width: 80,
                        //   height: 80,
                        //   decoration: BoxDecoration(
                        //     color: colorScheme.primary,
                        //     borderRadius: BorderRadius.circular(20),
                        //     boxShadow: [
                        //       BoxShadow(
                        //         color: colorScheme.primary.withValues(),
                        //         blurRadius: 20,
                        //         offset: const Offset(0, 8),
                        //       ),
                        //     ],
                        //   ),
                        //   child: Icon(
                        //     Icons.sports_tennis,
                        //     size: 40,
                        //     color: colorScheme.onPrimary,
                        //   ),
                        // ),
                        const SizedBox(height: 24),
                        Text(
                          'Create Account',
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start your fitness journey with us',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // Register Form
                  AutofillGroup(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Username
                          TextFormField(
                            controller: _username,
                            autofillHints: const [AutofillHints.username],
                            // keyboardType: TextInputType.username,
                            textInputAction: TextInputAction.next,
                            style: theme.textTheme.bodyLarge,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                              labelText: 'Username',
                              hintText: 'Enter your username',
                              prefixIcon: Icon(
                                Icons.account_circle,
                                color: colorScheme.primary,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Email Field
                          TextFormField(
                            controller: _email,
                            autofillHints: const [AutofillHints.email],
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            style: theme.textTheme.bodyLarge,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                              labelText: 'Email',
                              hintText: 'Enter your email address',
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: colorScheme.primary,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          TextFormField(
                            controller: _password,
                            autofillHints: const [AutofillHints.newPassword],
                            obscureText: true,
                            textInputAction: TextInputAction.next,
                            style: theme.textTheme.bodyLarge,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              prefixIcon: Icon(
                                Icons.lock_outlined,
                                color: colorScheme.primary,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password Field
                          TextFormField(
                            controller: _confirmPassword,
                            autofillHints: const [AutofillHints.newPassword],
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            style: theme.textTheme.bodyLarge,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                              labelText: 'Confirm Password',
                              hintText: 'Confirm your password',
                              prefixIcon: Icon(
                                Icons.lock_outlined,
                                color: colorScheme.primary,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _password.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) => _submit(),
                          ),
                          const SizedBox(height: 32),

                          // Register Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _submit,
                              child: Text(
                                'CREATE ACCOUNT',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Alternative Registration Options
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: colorScheme.outlineVariant,
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'OR',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: colorScheme.outlineVariant,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Social Registration Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    // TODO: Implement Google registration
                                  },
                                  icon: const Icon(Icons.g_mobiledata, size: 24),
                                  label: const Text('Google'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    // TODO: Implement Apple registration
                                  },
                                  icon: const Icon(Icons.apple, size: 20),
                                  label: const Text('Apple'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Sign In Link
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}