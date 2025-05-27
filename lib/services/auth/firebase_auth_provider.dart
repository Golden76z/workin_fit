import 'package:firebase_core/firebase_core.dart';
import 'package:sport_app/firebase_options.dart';
import 'package:sport_app/services/auth/auth_user.dart';
import 'package:sport_app/services/auth/auth_provider.dart';
import 'package:sport_app/services/auth/auth_exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseAuthException;
import 'package:sport_app/utilities/middlewares/rate_limiter.dart';

class FirebaseAuthProvider implements AuthProvider {
  // Operation keys
  static const _kSignIn = 'signIn';
  static const _kSignUp = 'signUp';
  static const _kPasswordReset = 'passwordReset';
  static const _kEmailVerification = 'emailVerification';

  final RateLimiter _rateLimiter = RateLimiter(
    defaultCooldown: const Duration(minutes: 1),
    operationCooldowns: {
      _kSignIn: const Duration(seconds: 30),
      _kSignUp: const Duration(minutes: 2),
      _kPasswordReset: const Duration(minutes: 1),
      _kEmailVerification: const Duration(minutes: 1),
    },
  );

  @override
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      throw InitializationAuthException();
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    return user != null ? AuthUser.fromFirebase(user) : null;
  }

  @override
  Future<AuthUser> createUser({
    required String email, 
    required String password
  }) async {
    if (_rateLimiter.isRateLimited(_kSignUp)) {
      throw TooManyRequestsAuthException(
        _rateLimiter.timeRemaining(_kSignUp),
        'registration',
      );
    }

    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      _rateLimiter.recordAttempt(_kSignUp);
      
      final user = userCredential.user;
      if (user == null) throw UserNotLoggedInAuthException();
      return AuthUser.fromFirebase(user);
    } on FirebaseAuthException catch(e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw EmailAlreadyUsedAuthException();
        case 'invalid-email':
          throw EmailFormatAuthException();
        case 'weak-password':
          throw WeakPasswordAuthException();
        case 'operation-not-allowed':
          throw OperationNotAllowedAuthException();
        case 'too-many-requests':
          _rateLimiter.recordAttempt(_kSignUp);
          throw TooManyRequestsAuthException(
            _rateLimiter.timeRemaining(_kSignUp), // Fixed: Use rateLimiter instead of _operationLimits
            'registration',
          );
        default:
          throw GenericAuthException();
      }
    } catch(e) {
      throw GenericAuthException();
    }
  }

  @override
  Future<AuthUser> logIn({
    required String email, 
    required String password
  }) async {
    if (_rateLimiter.isRateLimited(_kSignIn)) {
      throw TooManyRequestsAuthException(
        _rateLimiter.timeRemaining(_kSignIn),
        'login',
      );
    }

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      _rateLimiter.recordAttempt(_kSignIn);
      
      final user = userCredential.user;
      if (user == null) throw UserNotLoggedInAuthException();
      return AuthUser.fromFirebase(user);
    } on FirebaseAuthException catch(e) {
      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          throw WrongCredentialsAuthException();
        case 'user-disabled':
          throw UserDisabledAuthException();
        case 'too-many-requests':
          _rateLimiter.recordAttempt(_kSignIn);
          throw TooManyRequestsAuthException(
            _rateLimiter.timeRemaining(_kSignIn),
            'login',
          );
        default:
          throw GenericAuthException();
      }      
    } catch(_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch(e) {
      throw LogOutAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    if (_rateLimiter.isRateLimited(_kEmailVerification)) {
      throw TooManyRequestsAuthException(
        _rateLimiter.timeRemaining(_kEmailVerification),
        'email verification',
      );
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw UserNotLoggedInAuthException();
      if (user.emailVerified) throw EmailAlreadyVerifiedAuthException();
      
      await user.sendEmailVerification();
      _rateLimiter.recordAttempt(_kEmailVerification);
    } on FirebaseAuthException catch(e) {
      switch (e.code) {
        case 'too-many-requests':
          _rateLimiter.recordAttempt(_kEmailVerification);
          throw TooManyRequestsAuthException(
            _rateLimiter.timeRemaining(_kEmailVerification),
            'email verification',
          );
        default:
          throw GenericAuthException();
      }
    } catch(_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    if (_rateLimiter.isRateLimited(_kPasswordReset)) {
      throw TooManyRequestsAuthException(
        _rateLimiter.timeRemaining(_kPasswordReset),
        'password reset',
      );
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _rateLimiter.recordAttempt(_kPasswordReset);
    } on FirebaseAuthException catch(e) {
      switch (e.code) {
        case 'invalid-email':
          throw EmailFormatAuthException();
        case 'user-not-found':
          throw UserNotFoundAuthException();
        case 'too-many-requests':
          _rateLimiter.recordAttempt(_kPasswordReset);
          throw TooManyRequestsAuthException(
            _rateLimiter.timeRemaining(_kPasswordReset),
            'password reset',
          );
        default:
          throw GenericAuthException();
      }
    } catch(_) {
      throw GenericAuthException();
    }
  }

  // Helper method to check rate limiting
  bool _isOperationRateLimited(String operationKey) {
    return _rateLimiter.isRateLimited(operationKey);
  }

  // Helper method to get remaining time
  Duration _getRemainingTime(String operationKey) {
    return _rateLimiter.timeRemaining(operationKey);
  }
}