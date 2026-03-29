import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/features/auth/domain/auth_provider.dart';
import 'package:workin_fit/views/auth/authentication_view.dart';
import 'package:workin_fit/views/auth/email_verification_view.dart';
import 'package:workin_fit/views/home/home_page.dart';

/// Top-level auth guard widget that routes users based on Firebase auth state.
///
/// - Unauthenticated: `WelcomePage`
/// - Authenticated but email not verified: `EmailVerificationView`
/// - Fully authenticated: `HomePage`
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const AuthenticationView();
        }

        if (!user.emailVerified) {
          return const EmailVerificationView();
        }

        return const HomePage();
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => const AuthenticationView(),
    );
  }
}

