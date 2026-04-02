import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:workin_fit/features/auth/domain/auth_provider.dart';
import 'package:workin_fit/repository/auth_repository.dart';
import 'package:workin_fit/services/firestore_service.dart';

import 'auth_provider_test.mocks.dart';

@GenerateMocks([FirestoreService, AuthRepository])
void main() {
  group('currentUserProvider', () {
    test('returns null when not signed in', () async {
      final auth = MockFirebaseAuth(signedIn: false);
      final repo = AuthRepository(firebaseAuth: auth);

      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(repo),
      ]);
      addTearDown(container.dispose);

      // Wait for auth state
      await container.read(authStateProvider.future);
      final user = container.read(currentUserProvider);
      expect(user, isNull);
    });

    test('returns user when signed in', () async {
      final mockUser = MockUser(uid: 'user_1', email: 'test@test.com');
      final auth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
      final repo = AuthRepository(firebaseAuth: auth);

      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(repo),
      ]);
      addTearDown(container.dispose);

      await container.read(authStateProvider.future);
      final user = container.read(currentUserProvider);
      expect(user, isNotNull);
      expect(user!.uid, 'user_1');
    });
  });

  group('isEmailVerifiedProvider', () {
    test('returns false when no user', () async {
      final auth = MockFirebaseAuth(signedIn: false);
      final repo = AuthRepository(firebaseAuth: auth);

      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(repo),
      ]);
      addTearDown(container.dispose);

      await container.read(authStateProvider.future);
      expect(container.read(isEmailVerifiedProvider), isFalse);
    });

    test('returns true when email is verified', () async {
      final mockUser = MockUser(isEmailVerified: true);
      final auth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
      final repo = AuthRepository(firebaseAuth: auth);

      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(repo),
      ]);
      addTearDown(container.dispose);

      await container.read(authStateProvider.future);
      expect(container.read(isEmailVerifiedProvider), isTrue);
    });
  });

  group('AuthActions', () {
    late MockAuthRepository mockRepo;
    late MockFirestoreService mockFirestore;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockAuthRepository();
      mockFirestore = MockFirestoreService();

      container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
        firestoreServiceProvider.overrideWithValue(mockFirestore),
      ]);
    });

    tearDown(() => container.dispose());

    test('signOut calls repo signOut', () async {
      when(mockRepo.signOut()).thenAnswer((_) async {});

      await container.read(authActionsProvider).signOut();

      verify(mockRepo.signOut()).called(1);
    });

    test('sendPasswordResetEmail calls repo', () async {
      when(mockRepo.sendPasswordResetEmail('test@test.com'))
          .thenAnswer((_) async {});

      await container
          .read(authActionsProvider)
          .sendPasswordResetEmail('test@test.com');

      verify(mockRepo.sendPasswordResetEmail('test@test.com')).called(1);
    });

    test('registerWithEmailPassword calls repo and saves profile', () async {
      final mockUser = MockUser(uid: 'user_1', email: 'test@test.com');
      final mockCredential = MockUserCredential(mockUser);
      when(mockRepo.registerWithEmailPassword(
        email: 'test@test.com',
        password: 'password123',
      )).thenAnswer((_) async => mockCredential);
      when(mockFirestore.createOrUpdateUserProfile(
        userId: anyNamed('userId'),
        username: anyNamed('username'),
        email: anyNamed('email'),
      )).thenAnswer((_) async {});

      await container.read(authActionsProvider).registerWithEmailPassword(
            email: 'test@test.com',
            password: 'password123',
            username: 'testuser',
          );

      verify(mockRepo.registerWithEmailPassword(
        email: 'test@test.com',
        password: 'password123',
      )).called(1);
      verify(mockFirestore.createOrUpdateUserProfile(
        userId: 'user_1',
        username: 'testuser',
        email: 'test@test.com',
      )).called(1);
    });

    test('signInWithEmailPassword calls repo', () async {
      final mockUser = MockUser(uid: 'user_1', isEmailVerified: true);
      final mockCredential = MockUserCredential(mockUser);
      when(mockRepo.signInWithEmailPassword(
        email: 'test@test.com',
        password: 'password123',
      )).thenAnswer((_) async => mockCredential);

      await container.read(authActionsProvider).signInWithEmailPassword(
            email: 'test@test.com',
            password: 'password123',
          );

      verify(mockRepo.signInWithEmailPassword(
        email: 'test@test.com',
        password: 'password123',
      )).called(1);
    });
  });
}

class MockUserCredential extends Mock implements UserCredential {
  final MockUser? _mockUser;
  MockUserCredential(this._mockUser);

  @override
  User? get user => _mockUser;
}
