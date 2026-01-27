# Global Authentication State with Riverpod – Workin Fit

This document explains **what was implemented**, **how it works**, and **how to extend it** for global authentication state management using **Riverpod** and **Firebase Auth**.

It’s written so you can read through and understand the full flow without needing to reverse–engineer the code.

---

## 1. High‑level overview

**Goal**: Centralize authentication state for the entire app so that:

- Auth state comes from **one source of truth** (Firebase Auth).
- The app **automatically navigates** based on auth status (logged out, logged in, email verified).
- Auth state is **accessible anywhere** via Riverpod providers.
- Logout **clears state** and returns the user to the unauthenticated flow.

To achieve this, the following pieces were put in place:

- A **feature‑based auth provider file** under `lib/features/auth/domain/auth_provider.dart`.
- A **backwards-compatible re‑export** at `lib/providers/auth_provider.dart`.
- A top‑level **auth guard widget (`AuthGate`)** under `lib/features/auth/presentation/auth_gate.dart`.
- `main.dart` updated to use `AuthGate` as the root `home:` widget.

The app already:

- Included `flutter_riverpod` and `riverpod_annotation` as dependencies.
- Wrapped the app in a top-level `ProviderScope`.

---

## 2. Files touched / created

### 2.1 New files

- `lib/features/auth/domain/auth_provider.dart`  
  Defines **all global auth-related providers** and the `AuthActions` class.

- `lib/features/auth/presentation/auth_gate.dart`  
  Defines **`AuthGate`**, a `ConsumerWidget` that reads the auth state from Riverpod and decides which top‑level screen to show.

### 2.2 Updated files

- `lib/providers/auth_provider.dart`  
  Now simply **re‑exports** the new feature-based auth providers so old imports keep working:

  ```dart
  /// Backwards-compatible export for legacy imports.
  ///
  /// New code should import:
  /// `package:workin_fit/features/auth/domain/auth_provider.dart`
  export 'package:workin_fit/features/auth/domain/auth_provider.dart';
  ```

- `lib/main.dart`  
  Replaced manual auth-based `home:` logic with the new `AuthGate` widget.

---

## 3. Global auth providers (domain layer)

**File**: `lib/features/auth/domain/auth_provider.dart`

This file contains 4 groups of providers:

1. **Low-level dependencies**
2. **Auth state providers**
3. **Derived state helpers**
4. **Auth actions**

### 3.1 Low-level dependencies

These connect Riverpod to your existing services:

- `firestoreServiceProvider`  
  Provides a `FirestoreService` instance.

  ```dart
  final firestoreServiceProvider = Provider<FirestoreService>((ref) {
    return FirestoreService();
  });
  ```

- `authRepositoryProvider`  
  Provides your existing `AuthRepository`, which wraps `FirebaseAuth` and social sign-in.

  ```dart
  final authRepositoryProvider = Provider<AuthRepository>((ref) {
    return AuthRepository();
  });
  ```

### 3.2 Auth state provider (Firebase-backed)

- `authStateProvider` (core of global auth):

  ```dart
  final authStateProvider = StreamProvider<User?>((ref) {
    final authRepository = ref.watch(authRepositoryProvider);
    return authRepository.authStateChanges;
  });
  ```

  - Uses `AuthRepository.authStateChanges`, which is just `FirebaseAuth.instance.authStateChanges()`.
  - Emits:
    - `null` → user is logged out.
    - `User` instance → user is logged in (but we still need to check email verification separately).

### 3.3 Derived state helpers

These provide convenient, synchronous access to the auth state:

- `currentUserProvider`:

  ```dart
  final currentUserProvider = Provider<User?>((ref) {
    return ref.watch(authStateProvider).value;
  });
  ```

  - Reads the **current value** of `authStateProvider`’s `AsyncValue<User?>`.
  - Good for widgets that only care about the latest user and can tolerate `null`.

- `isEmailVerifiedProvider`:

  ```dart
  final isEmailVerifiedProvider = Provider<bool>((ref) {
    final user = ref.watch(currentUserProvider);
    return user?.emailVerified ?? false;
  });
  ```

  - Returns `true` only when there is a logged-in user **and** `emailVerified == true`.

### 3.4 Auth actions (imperative API for the UI)

**Provider:**

```dart
final authActionsProvider = Provider<AuthActions>((ref) {
  return AuthActions(ref);
});
```

**Class:**

```dart
class AuthActions {
  final Ref ref;
  AuthActions(this.ref);

  AuthRepository get _authRepo => ref.read(authRepositoryProvider);
  FirestoreService get _firestoreService => ref.read(firestoreServiceProvider);
  ...
}
```

This class provides **methods your UI can call**:

- `registerWithEmailPassword({ email, password, username })`
  - Calls `_authRepo.registerWithEmailPassword`.
  - Then writes a user profile to Firestore using `FirestoreService.createOrUpdateUserProfile`.

- `signInWithEmailPassword({ email, password })`
  - Delegates to `_authRepo.signInWithEmailPassword`.
  - On success, Firebase emits a new `User` on `authStateChanges`, which updates the app.

- `signInWithGoogle()`
  - Uses `_authRepo.signInWithGoogle()`.
  - On success, creates or updates a user profile in Firestore.

- `signInWithApple()`, `signInWithGitHub()`
  - Thin wrappers around the same-named methods in `AuthRepository`.

- `sendPasswordResetEmail(email)`
  - Delegates to `_authRepo.sendPasswordResetEmail`.

- `sendEmailVerification()`
  - Delegates to `_authRepo.sendEmailVerification`.

- `reloadUser()`
  - Forces Firebase to reload the current user, so `emailVerified` status is up to date.

- `signOut()`

  ```dart
  Future<void> signOut() async {
    await _authRepo.signOut();
  }
  ```

  - Calls `AuthRepository.signOut()`, which signs out both Firebase and Google sign-in.
  - After this, `authStateChanges` emits `null`, which `authStateProvider` passes down to the UI.

**Why this shape?**

- All **read-only state** comes from providers (`authStateProvider`, `currentUserProvider`).
- All **side effects / mutations** go through `AuthActions`.
- The UI never directly calls `FirebaseAuth` or `GoogleSignIn`; it only talks to `AuthActions`, which keeps the logic centralized and testable.

---

## 4. Global auth guard: `AuthGate`

**File**: `lib/features/auth/presentation/auth_gate.dart`

This widget is the **router/guard** for the app’s root navigation.

```dart
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const WelcomePage();
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
      error: (_, __) => const WelcomePage(),
    );
  }
}
```

### 4.1 Logic

1. **Loading**  
   While the auth stream is connecting / resolving the current user:

   - Show a full-screen `CircularProgressIndicator`.

2. **Error**  
   If there is an error from the stream:

   - Fallback to `WelcomePage` (you could later add a more explicit error screen).

3. **Data: user is `null`**

   - No authenticated user → show `WelcomePage`, which leads into your `AuthenticationView` (register/login).

4. **Data: user is not `null`, but email is not verified**

   - User is logged in but `emailVerified == false` → show `EmailVerificationView`.
   - This is consistent with your existing email verification flows.

5. **Data: user is not `null` and email is verified**

   - User is fully authenticated → show `HomePage`.

This is effectively your **auth guard**: it protects the authenticated area by gating it behind both **login** and **email verification**.

---

## 5. `main.dart`: wiring the auth gate into the app

**File**: `lib/main.dart`

We leave initialization logic as is (Firebase, Hive) and keep `ProviderScope` at the entry point. The key change is in the `WorkinFitApp`’s `build` method.

### 5.1 Before

Previously, `WorkinFitApp` watched `authStateProvider` directly and manually decided the `home:` widget.

### 5.2 After

Now `WorkinFitApp` delegates that responsibility to `AuthGate`:

```dart
@override
Widget build(BuildContext context) {
  final locale = ref.watch(localeProvider);

  return MaterialApp(
    title: 'Workin Fit',
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF7B68EE),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    ),
    // Redirect based on global auth state and email verification
    home: const AuthGate(),
  );
}
```

This keeps `main.dart` **clean**:

- `main.dart` handles **initialization** and global concerns (Firebase, Hive, locale, theme, deep links).
- `AuthGate` handles **auth-based routing**.

---

## 6. How existing screens use the new setup

All your existing screens that used `auth_provider.dart` continue to work, because the file now re-exports the new feature-based providers.

Examples:

- `LoginView` (`lib/views/auth/login_view.dart`)
- `RegisterScreen` (`lib/views/auth/register_view.dart`)
- `EmailVerificationView` (`lib/views/auth/email_verification_view.dart`)
- `HomePage` (`lib/views/home/home_page.dart`)

They typically do things like:

- Read actions:

  ```dart
  await ref.read(authActionsProvider).signInWithEmailPassword(
    email: ...,
    password: ...,
  );
  ```

- Read current user:

  ```dart
  final user = ref.read(currentUserProvider);
  ```

No changes are required in those screens to benefit from the new global auth flow; they simply **plug into the same providers**, which are now organized under `features/auth/domain`.

---

## 7. How logout and persistence work now

### 7.1 Logout

1. UI triggers:

   ```dart
   await ref.read(authActionsProvider).signOut();
   ```

2. `AuthActions.signOut()` calls `AuthRepository.signOut()`:
   - Signs out from Firebase.
   - Signs out from Google.

3. Firebase emits `null` on `authStateChanges`.

4. `authStateProvider` sees `null` and rebuilds dependents, including `AuthGate`.

5. `AuthGate` receives `user == null` and shows `WelcomePage` again.

So logout is now **fully driven by the auth stream**, and the UI naturally returns to the unauthenticated flow.

### 7.2 Persistence across app restarts

- `FirebaseAuth` automatically restores the user on app startup (if the user had a valid session).
- As soon as Firebase resolves that, it emits on `authStateChanges`.
- `authStateProvider` picks that up and `AuthGate` immediately routes to:
  - `WelcomePage` if the user is `null`, or
  - `EmailVerificationView` / `HomePage` depending on email verification status.

No extra persistence layer is needed—Firebase + the auth stream provide this for free.

---

## 8. How to use this in new code

When writing new features, you can:

- Import directly from the feature-based file:

  ```dart
  import 'package:workin_fit/features/auth/domain/auth_provider.dart';
  ```

- Or, for now, keep using the legacy import:

  ```dart
  import 'package:workin_fit/providers/auth_provider.dart';
  ```

Then:

- **To read the current user:**

  ```dart
  final user = ref.watch(currentUserProvider);
  ```

- **To check if the user is verified:**

  ```dart
  final isVerified = ref.watch(isEmailVerifiedProvider);
  ```

- **To perform auth actions (login/register/logout/etc.):**

  ```dart
  final actions = ref.read(authActionsProvider);

  await actions.signInWithEmailPassword(email: ..., password: ...);
  await actions.signOut();
  ```

If you later introduce route-level guards (for specific screens), you can either:

- Use `AuthGate` as a parent for those routes, or
- Create smaller guard widgets that check `currentUserProvider` / `isEmailVerifiedProvider` and redirect accordingly.

---

## 9. Summary

- **State management** is centralized in `lib/features/auth/domain/auth_provider.dart`.
- **Routing & guards** are handled by `AuthGate` in `lib/features/auth/presentation/auth_gate.dart`.
- `main.dart` is simplified to just use `AuthGate` as the `home` based on Riverpod’s auth state.
- Existing screens continue to work thanks to the re-export in `lib/providers/auth_provider.dart`.
- The implementation meets your acceptance criteria:
  - Global, accessible Riverpod auth state.
  - Automatic navigation based on auth + email verification.
  - Persistence via Firebase’s built-in session handling.
  - Logout that clears state and returns to the unauthenticated flow.

Use this document as your reference when you need to:

- Add new auth-related providers.
- Create new protected screens.
- Debug auth flows or understand why the app navigates a certain way on startup or after logout.

