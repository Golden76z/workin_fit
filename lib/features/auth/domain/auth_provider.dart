import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workin_fit/repository/auth_repository.dart';
import 'package:workin_fit/services/firestore_service.dart';

/// Firestore Service Provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Auth State Provider (Stream) that listens to Firebase auth changes
final authStateProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

/// Current User Provider
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

/// Email Verified Provider
final isEmailVerifiedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.emailVerified ?? false;
});

/// Auth Actions Provider (for UI to call methods)
final authActionsProvider = Provider<AuthActions>((ref) {
  return AuthActions(ref);
});

/// Auth Actions Class
class AuthActions {
  final Ref ref;
  AuthActions(this.ref);

  AuthRepository get _authRepo => ref.read(authRepositoryProvider);
  FirestoreService get _firestoreService => ref.read(firestoreServiceProvider);

  // Register
  Future<void> registerWithEmailPassword({
    required String email,
    required String password,
    required String username,
  }) async {
    final userCredential = await _authRepo.registerWithEmailPassword(
      email: email,
      password: password,
    );

    // Save user profile to Firestore
    if (userCredential.user != null) {
      try {
        await _firestoreService.createOrUpdateUserProfile(
          userId: userCredential.user!.uid,
          username: username,
          email: email,
        );
      } catch (e) {
        // If Firestore save fails, still allow registration but log the error
        // The user can update their profile later
        // ignore: avoid_print
        print('Error saving user profile to Firestore: $e');
      }
    }
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
    final userCredential = await _authRepo.signInWithGoogle();

    // Save/update user profile to Firestore
    if (userCredential.user != null) {
      try {
        final user = userCredential.user!;
        final email = user.email ?? '';
        // Use display name as username, or email prefix if display name is null
        final username = user.displayName ??
            (email.isNotEmpty
                ? email.split('@')[0]
                : 'user_${user.uid.substring(0, 8)}');

        await _firestoreService.createOrUpdateUserProfile(
          userId: user.uid,
          username: username,
          email: email,
        );
      } catch (e) {
        // If Firestore save fails, still allow sign-in but log the error
        // The user can update their profile later
        // ignore: avoid_print
        print('Error saving user profile to Firestore: $e');
      }
    }
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

