import 'package:firebase_core/firebase_core.dart';
import 'package:sport_app/firebase_options.dart';
import 'package:sport_app/services/auth/auth_user.dart';
import 'package:sport_app/services/auth/auth_provider.dart';
import 'package:sport_app/services/auth/auth_exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseAuthException;

class FirebaseAuthProvider implements AuthProvider {
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
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      final user = currentUser;
      if (user == null) throw UserNotLoggedInAuthException();
      return user;
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
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      final user = currentUser;
      if (user == null) throw UserNotLoggedInAuthException();
      return user;
    } on FirebaseAuthException catch(e) {
      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          throw WrongCredentialsAuthException();
        case 'user-disabled':
          throw UserDisabledAuthException();
        case 'too-many-requests':
          throw TooManyRequestsAuthException();
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
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw UserNotLoggedInAuthException();
      if (user.emailVerified) throw EmailAlreadyVerifiedAuthException();
      await user.sendEmailVerification();
    } on FirebaseAuthException catch(e) {
      switch (e.code) {
        case 'too-many-requests':
          throw TooManyRequestsAuthException();
        default:
          throw GenericAuthException();
      }
    } catch(_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch(e) {
      switch (e.code) {
        case 'invalid-email':
          throw EmailFormatAuthException();
        case 'user-not-found':
          throw UserNotFoundAuthException();
        case 'too-many-requests':
          throw TooManyRequestsAuthException();
        default:
          throw GenericAuthException();
      }
    } catch(_) {
      throw GenericAuthException();
    }
  }
}