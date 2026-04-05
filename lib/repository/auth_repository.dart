import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:workin_fit/core/errors/auth_exception.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: ['email', 'profile'],
            );

  // ===== AUTH STATE STREAM =====

  /// Stream of auth state changes (logged in/out)
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // ===== EMAIL/PASSWORD AUTH =====

  /// Register with email and password
  Future<UserCredential> registerWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send standard Firebase verification email (browser-based).
      // The user clicks the link in the email, then taps refresh in-app.
      await userCredential.user?.sendEmailVerification();

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        AuthErrorHandler.handleFirebaseAuthException(
          e.code,
          message: e.message,
        ),
        code: e.code,
        originalException: e,
      );
    }
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if email is verified
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        throw AuthException(
          'Email not verified. Please check your inbox.',
          code: 'email-not-verified',
        );
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        AuthErrorHandler.handleFirebaseAuthException(
          e.code,
          message: e.message,
        ),
        code: e.code,
        originalException: e,
      );
    }
  }

  // ===== GOOGLE SIGN-IN =====

  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger Google sign-in flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw AuthException(
          'Google sign-in was cancelled.',
          code: 'cancelled',
        );
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      // Firebase Auth will automatically handle account linking if the email matches
      // If account exists with different credential, it will throw 'account-exists-with-different-credential'
      return await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      // Log the actual error for debugging
      // print('FirebaseAuthException: ${e.code} - ${e.message}');
      throw AuthException(
        AuthErrorHandler.handleFirebaseAuthException(
          e.code,
          message: e.message,
        ),
        code: e.code,
        originalException: e,
      );
    } catch (e, _) {
      if (e is AuthException) rethrow;

      // Log the actual error for debugging
      // print('Google Sign-In Error: $e');
      // print('Stack trace: $stackTrace');

      // Handle PlatformException (common on Android for SHA-1 issues)
      if (e.toString().contains('PlatformException')) {
        if (e.toString().contains('sign_in_failed') ||
            e.toString().contains('SIGN_IN_FAILED')) {
          throw AuthException(
            'Google Sign-In failed. Please check:\n'
            '1. SHA-1 fingerprint is added to Firebase Console\n'
            '2. Google provider is enabled in Firebase\n'
            '3. google-services.json is up to date',
            code: 'sign_in_failed',
            originalException: e,
          );
        }
      }

      throw AuthException(
        AuthErrorHandler.handleGoogleSignInException(e),
        originalException: e,
      );
    }
  }

  // ===== APPLE SIGN-IN =====

  /// Sign in with Apple
  Future<UserCredential> signInWithApple() async {
    try {
      // Request Apple ID credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create OAuth credential
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase
      return await _firebaseAuth.signInWithCredential(oauthCredential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        AuthErrorHandler.handleFirebaseAuthException(
          e.code,
          message: e.message,
        ),
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw AuthException(
        'Apple Sign-In failed. Please try again.',
        originalException: e,
      );
    }
  }

  // ===== GITHUB SIGN-IN =====

  /// Sign in with GitHub
  Future<UserCredential> signInWithGitHub() async {
    try {
      final GithubAuthProvider githubProvider = GithubAuthProvider();

      // Sign in with popup (web) or redirect (mobile)
      return await _firebaseAuth.signInWithProvider(githubProvider);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        AuthErrorHandler.handleFirebaseAuthException(
          e.code,
          message: e.message,
        ),
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw AuthException(
        'GitHub Sign-In failed. Please try again.',
        originalException: e,
      );
    }
  }

  // ===== PASSWORD RESET =====

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        AuthErrorHandler.handleFirebaseAuthException(
          e.code,
          message: e.message,
        ),
        code: e.code,
        originalException: e,
      );
    }
  }

  // ===== EMAIL VERIFICATION =====

  Future<void> sendEmailVerification() async {
    try {
      await _firebaseAuth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        AuthErrorHandler.handleFirebaseAuthException(
          e.code,
          message: e.message,
        ),
        code: e.code,
        originalException: e,
      );
    }
  }

  Future<void> reloadUser() async {
    await _firebaseAuth.currentUser?.reload();
  }

  bool get isEmailVerified => _firebaseAuth.currentUser?.emailVerified ?? false;

  // ===== SIGN OUT =====

  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // ===== ERROR HANDLING =====
  // Error handling is now centralized in core/errors/auth_exception.dart
}
