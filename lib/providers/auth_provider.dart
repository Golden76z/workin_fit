import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workin_fit/repository/auth_repository.dart';

// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Auth State Provider (Stream)
final authStateProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

// Current User Provider
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

// Email Verified Provider
final isEmailVerifiedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.emailVerified ?? false;
});

// Auth Actions Provider (for UI to call methods)
final authActionsProvider = Provider<AuthActions>((ref) {
  return AuthActions(ref);
});

// Auth Actions Class
class AuthActions {
  final Ref ref;
  AuthActions(this.ref);

  AuthRepository get _authRepo => ref.read(authRepositoryProvider);

  // Register
  Future<void> registerWithEmailPassword({
    required String email,
    required String password,
  }) async {
    await _authRepo.registerWithEmailPassword(
      email: email,
      password: password,
    );
  }

  // Sign in
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    await _authRepo.signInWithEmailPassword(
      email: email,
      password: password,
    );
  }

  // Google sign-in
  Future<void> signInWithGoogle() async {
    await _authRepo.signInWithGoogle();
  }

  // Apple sign-in
  Future<void> signInWithApple() async {
    await _authRepo.signInWithApple();
  }

  // GitHub sign-in
  Future<void> signInWithGitHub() async {
    await _authRepo.signInWithGitHub();
  }

  // Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    await _authRepo.sendPasswordResetEmail(email);
  }

  // Email verification
  Future<void> sendEmailVerification() async {
    await _authRepo.sendEmailVerification();
  }

  Future<void> reloadUser() async {
    await _authRepo.reloadUser();
  }

  // Sign out
  Future<void> signOut() async {
    await _authRepo.signOut();
  }
}