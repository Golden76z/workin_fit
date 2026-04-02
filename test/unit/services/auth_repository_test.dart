import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:workin_fit/core/errors/auth_exception.dart';
import 'package:workin_fit/repository/auth_repository.dart';

import 'auth_repository_test.mocks.dart';

@GenerateMocks([GoogleSignIn])
void main() {
  group('AuthRepository', () {
    group('authStateChanges', () {
      test('emits null when signed out', () async {
        final auth = MockFirebaseAuth(signedIn: false);
        final repo = AuthRepository(firebaseAuth: auth);

        final states = await repo.authStateChanges.first;
        expect(states, isNull);
      });

      test('emits user when signed in', () async {
        final mockUser = MockUser(uid: 'user_1', email: 'test@example.com');
        final auth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
        final repo = AuthRepository(firebaseAuth: auth);

        final user = await repo.authStateChanges.first;
        expect(user, isNotNull);
        expect(user!.uid, 'user_1');
      });
    });

    group('currentUser', () {
      test('returns null when not signed in', () {
        final auth = MockFirebaseAuth(signedIn: false);
        final repo = AuthRepository(firebaseAuth: auth);
        expect(repo.currentUser, isNull);
      });

      test('returns user when signed in', () {
        final mockUser = MockUser(uid: 'user_1');
        final auth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
        final repo = AuthRepository(firebaseAuth: auth);
        expect(repo.currentUser, isNotNull);
      });
    });

    group('registerWithEmailPassword', () {
      test('returns UserCredential on success', () async {
        final auth = MockFirebaseAuth();
        final repo = AuthRepository(firebaseAuth: auth);

        final credential = await repo.registerWithEmailPassword(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(credential.user, isNotNull);
        expect(credential.user!.email, 'test@example.com');
      });
    });

    group('signInWithEmailPassword', () {
      test('signs in successfully when email is verified', () async {
        final mockUser = MockUser(
          uid: 'user_1',
          email: 'test@example.com',
          isEmailVerified: true,
        );
        final auth = MockFirebaseAuth(mockUser: mockUser);
        final repo = AuthRepository(firebaseAuth: auth);

        // Register first to create the user
        await auth.createUserWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        );

        final credential = await repo.signInWithEmailPassword(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(credential.user, isNotNull);
      });

      test('throws AuthException for unverified email', () async {
        // firebase_auth_mocks: MockUser with isEmailVerified: false
        final mockUser = MockUser(
          uid: 'user_1',
          email: 'test@example.com',
          isEmailVerified: false,
        );
        // signedIn: false but mockUser provided — sign-in call returns mockUser
        final auth = MockFirebaseAuth(signedIn: false, mockUser: mockUser);
        final repo = AuthRepository(firebaseAuth: auth);

        await expectLater(
          repo.signInWithEmailPassword(
            email: 'test@example.com',
            password: 'password123',
          ),
          throwsA(isA<AuthException>().having(
              (e) => e.code, 'code', 'email-not-verified')),
        );
      });
    });

    group('signOut', () {
      test('signs out successfully', () async {
        final mockUser = MockUser(uid: 'user_1');
        final auth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
        final mockGoogleSignIn = MockGoogleSignIn();
        when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);
        final repo = AuthRepository(
          firebaseAuth: auth,
          googleSignIn: mockGoogleSignIn,
        );

        await repo.signOut();

        expect(auth.currentUser, isNull);
      });
    });

    group('isEmailVerified', () {
      test('returns false when no user', () {
        final auth = MockFirebaseAuth(signedIn: false);
        final repo = AuthRepository(firebaseAuth: auth);
        expect(repo.isEmailVerified, isFalse);
      });

      test('returns true when user email is verified', () {
        final mockUser = MockUser(isEmailVerified: true);
        final auth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
        final repo = AuthRepository(firebaseAuth: auth);
        expect(repo.isEmailVerified, isTrue);
      });
    });
  });

  group('AuthErrorHandler', () {
    test('maps user-not-found code', () {
      final msg =
          AuthErrorHandler.handleFirebaseAuthException('user-not-found');
      expect(msg, contains('No user found'));
    });

    test('maps wrong-password code', () {
      final msg =
          AuthErrorHandler.handleFirebaseAuthException('wrong-password');
      expect(msg, contains('Wrong password'));
    });

    test('maps email-already-in-use code', () {
      final msg =
          AuthErrorHandler.handleFirebaseAuthException('email-already-in-use');
      expect(msg, contains('already exists'));
    });

    test('maps weak-password code', () {
      final msg =
          AuthErrorHandler.handleFirebaseAuthException('weak-password');
      expect(msg, contains('too weak'));
    });

    test('maps invalid-email code', () {
      final msg =
          AuthErrorHandler.handleFirebaseAuthException('invalid-email');
      expect(msg, contains('Invalid email'));
    });

    test('returns default message for unknown code', () {
      final msg = AuthErrorHandler.handleFirebaseAuthException('unknown_code');
      expect(msg, contains('Authentication error'));
    });

    test('uses provided message as fallback for unknown code', () {
      final msg = AuthErrorHandler.handleFirebaseAuthException(
        'unknown_code',
        message: 'Custom error',
      );
      expect(msg, 'Custom error');
    });
  });
}
