import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sport_app/services/auth/bloc/auth_bloc.dart';
import 'package:sport_app/services/auth/bloc/auth_event.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
          child: Text(
            'Email Verification',
            style: theme.textTheme.displaySmall?.copyWith(
              color: colors.onPrimary,
            ),
          ),
        ),
        backgroundColor: colors.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.onPrimary),
          onPressed: () {
            context.read<AuthBloc>().add(const AuthEventLogOut());
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            Text(
              "Hi there,",
              style: theme.textTheme.displaySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "We've sent a verification email to your inbox. Please check your email to complete the process.",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "If you didn't receive the email, click the button below to resend it.",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(
                  const AuthEventSendEmailVerification()
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Verification email sent!',
                      style: TextStyle(color: colors.onPrimary),
                    ),
                    backgroundColor: colors.primary,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Resend Verification Email',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colors.onPrimary,
                ),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                context.read<AuthBloc>().add(const AuthEventLogOut());
              },
              child: Text(
                'Go Back to Login',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}