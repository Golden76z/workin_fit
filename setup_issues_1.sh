#!/bin/bash

# Workin Fit - Issues Creation Script (Beginner-Friendly)
# Tailored for solo developer, beginner with Flutter/Firebase
# Run this after setup_github_project.sh
# Usage: ./create_issues.sh

set -e

echo "📝 Creating GitHub issues for Workin Fit..."
echo "Timeline: 16 weeks to March 1, 2025"
echo ""

# Function to create issue
create_issue() {
    local title="$1"
    local body="$2"
    local labels="$3"
    local milestone="$4"
    
    gh issue create \
        --title "$title" \
        --body "$body" \
        --label "$labels" \
        --milestone "$milestone"
}

# ============================================
# WEEK 1-2: Foundation
# ============================================

create_issue \
    "[SETUP] Create Flutter project with proper structure" \
    "## 🎯 Goal
Initialize the Flutter project with clean architecture and proper folder structure.

## 📋 Tasks
- [ ] Run \`flutter create --org com.workinfit workin_fit\`
- [ ] Create folder structure:
  - \`lib/core/\` (constants, theme, utils, errors)
  - \`lib/features/\` (auth, workout, profile, social)
  - \`lib/models/\` (data models)
  - \`lib/services/\` (Firebase services)
  - \`lib/widgets/\` (reusable components)
  - \`test/\` (unit, widget, integration tests)
  - \`assets/\` (images, icons, animations)
- [ ] Setup \`pubspec.yaml\` with initial dependencies (see resources below)
- [ ] Create \`analysis_options.yaml\` with linting rules
- [ ] Test that app builds: \`flutter run\`

## ✅ Acceptance Criteria
- Project builds successfully on iOS and Android emulators
- Folder structure follows clean architecture
- Linting rules are active and enforced

## 📚 Resources
- [Flutter Clean Architecture Example](https://github.com/ResoCoder/flutter-tdd-clean-architecture-course)
- [Effective Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- **Key packages to add:** firebase_core, firebase_auth, cloud_firestore, flutter_riverpod, hive, hive_flutter

## 💡 Beginner Tips
- Use \`flutter doctor\` to check your setup before starting
- The quick_start.sh script in the repo can automate much of this
- Keep your folder structure flat at first - you can always refactor later" \
    "type:chore,area:infrastructure,priority:critical,difficulty:beginner,good-first-issue" \
    "Week 1-2: Foundation"

create_issue \
    "[SETUP] Configure Firebase project and FlutterFire" \
    "## 🎯 Goal
Set up Firebase project and connect it to your Flutter app.

## 📋 Tasks
- [ ] Go to [Firebase Console](https://console.firebase.google.com/)
- [ ] Create new project named \"Workin Fit\"
- [ ] Install Firebase CLI: \`npm install -g firebase-tools\`
- [ ] Install FlutterFire CLI: \`dart pub global activate flutterfire_cli\`
- [ ] Run \`flutterfire configure\` (auto-generates config files)
- [ ] Enable Firebase Authentication
- [ ] Enable Email/Password auth provider
- [ ] Create Cloud Firestore database (start in test mode for now)
- [ ] Create Firebase Storage bucket
- [ ] Add Firebase initialization to \`main.dart\`

## ✅ Acceptance Criteria
- Firebase successfully initializes in app
- Can view Firebase project in console
- \`google-services.json\` (Android) and \`GoogleService-Info.plist\` (iOS) are generated
- App runs without Firebase errors

## 📚 Resources
- [FlutterFire Setup Guide](https://firebase.flutter.dev/docs/overview)
- [Firebase Console](https://console.firebase.google.com/)
- **Video Tutorial:** [Firebase + Flutter Setup (10min)](https://www.youtube.com/watch?v=sz4slPFwEvs)

## 💡 Beginner Tips
- \`flutterfire configure\` handles most of the setup automatically
- Keep Firebase CLI logged in: \`firebase login\`
- Start with test mode security rules - we'll lock them down later
- Save your Firebase project ID somewhere safe

## ⚠️ Common Issues
- If FlutterFire CLI fails, manually download config files from Firebase Console
- Make sure to add config files to .gitignore (security!)" \
    "type:chore,area:infrastructure,area:backend,priority:critical,difficulty:beginner,firebase" \
    "Week 1-2: Foundation"

create_issue \
    "[DESIGN] Create app theme with dark purple/blue color scheme" \
    "## 🎯 Goal
Design and implement the app's visual theme with dark mode and purple/blue colors.

## 📋 Tasks
- [ ] Create \`lib/core/theme/colors.dart\` with color palette
- [ ] Create \`lib/core/theme/text_styles.dart\` for typography
- [ ] Create \`lib/core/theme/app_theme.dart\` for ThemeData
- [ ] Define primary purple color (with blue tint)
- [ ] Define secondary and accent colors
- [ ] Setup Material 3 with dark theme
- [ ] Configure button styles (ElevatedButton, TextButton, etc)
- [ ] Configure input field styles (TextFormField)
- [ ] Test theme on sample screen

## ✅ Acceptance Criteria
- Dark theme with purple/blue color scheme
- All UI components use theme colors (no hardcoded colors)
- Text is readable with good contrast
- Theme feels modern and cohesive

## 🎨 Color Suggestions
\`\`\`dart
// Purple with blue tint
Primary: #7B68EE (Medium Slate Blue)
Secondary: #6A5ACD (Slate Blue)
Accent: #4169E1 (Royal Blue)
Background: #121212 (Dark)
Surface: #1E1E1E (Slightly lighter)
\`\`\`

## 📚 Resources
- [Material 3 Color System](https://m3.material.io/styles/color/overview)
- [Coolors.co](https://coolors.co/) - Color palette generator
- [Flutter ThemeData Class](https://api.flutter.dev/flutter/material/ThemeData-class.html)

## 💡 Beginner Tips
- Use Material 3: \`useMaterial3: true\` in ThemeData
- Test your colors on both light text and dark text
- Keep accessibility in mind - use enough contrast
- You can always adjust colors later!" \
    "type:feature,area:ui,priority:high,difficulty:beginner,good-first-issue" \
    "Week 1-2: Foundation"

create_issue \
    "[SETUP] Setup Hive for offline storage" \
    "## 🎯 Goal
Configure Hive for local caching of sessions, programs, and offline support.

## 📋 Tasks
- [ ] Add dependencies: \`hive\`, \`hive_flutter\`, \`hive_generator\` (dev)
- [ ] Initialize Hive in \`main.dart\`: \`await Hive.initFlutter()\`
- [ ] Create \`lib/services/local_storage_service.dart\`
- [ ] Create boxes for:
  - User sessions (custom created)
  - User programs (custom created)
  - Cached exercises
  - User preferences
- [ ] Implement basic CRUD operations (Create, Read, Update, Delete)
- [ ] Test by saving and retrieving data

## ✅ Acceptance Criteria
- Hive successfully initializes
- Can save and retrieve data locally
- Data persists after app restart
- No errors or warnings

## 📚 Resources
- [Hive Documentation](https://docs.hivedb.dev/)
- [Hive Tutorial Video](https://www.youtube.com/watch?v=w8cZKm9s228)
- [Hive vs SQLite](https://docs.hivedb.dev/#/README?id=hive-vs-sqflite) - Why we chose Hive

## 💡 Beginner Tips
- Hive is much simpler than SQLite for beginners
- Think of boxes like separate databases for different data types
- Use TypeAdapters for custom objects (we'll add these later)
- Test with simple data (strings/ints) first before complex models" \
    "type:feature,area:infrastructure,priority:high,difficulty:beginner,offline-support" \
    "Week 1-2: Foundation"

# ============================================
# WEEK 3-4: Authentication
# ============================================

create_issue \
    "[AUTH] Implement email/password registration with verification" \
    "## 🎯 Goal
Create registration screen where users sign up with email/password and must verify email before accessing the app.

## 📋 Tasks
- [ ] Create \`lib/features/auth/presentation/screens/register_screen.dart\`
- [ ] Create form with fields: email, password, confirm password
- [ ] Add form validation (email format, password strength, matching passwords)
- [ ] Create \`lib/features/auth/data/auth_repository.dart\`
- [ ] Implement \`registerWithEmailPassword()\` using Firebase Auth
- [ ] Send email verification after registration
- [ ] Show dialog instructing user to check email
- [ ] Block app access until email is verified
- [ ] Add loading states and error handling
- [ ] Style forms according to app theme

## ✅ Acceptance Criteria
- Users can register with valid email/password
- Email verification is sent automatically
- Users cannot access app without verifying email
- Clear error messages for invalid inputs
- Password requirements: min 8 characters, 1 uppercase, 1 number

## 📚 Resources
- [Firebase Email/Password Auth](https://firebase.flutter.dev/docs/auth/usage)
- [Form Validation in Flutter](https://docs.flutter.dev/cookbook/forms/validation)
- **Code Example:** [Email Verification Flow](https://github.com/FirebaseExtended/flutterfire/blob/master/packages/firebase_auth/firebase_auth/example/lib/auth.dart)

## 💡 Beginner Tips
- Use \`Form\` widget with \`GlobalKey<FormState>\` for validation
- Create a separate \`validators.dart\` file for reusable validation functions
- Test with a real email you control to see verification emails
- Firebase sends verification emails automatically - no backend code needed!

## ⚠️ Common Issues
- Email verification link expires in 3 days
- Check spam folder for verification emails during testing
- Use \`user.reload()\` to check if email is verified" \
    "type:feature,area:auth,priority:critical,difficulty:intermediate,firebase" \
    "Week 3-4: Authentication"

create_issue \
    "[AUTH] Implement login screen with email/password" \
    "## 🎯 Goal
Create login screen for users to sign in with verified email/password.

## 📋 Tasks
- [ ] Create \`lib/features/auth/presentation/screens/login_screen.dart\`
- [ ] Create form with email and password fields
- [ ] Implement login logic using Firebase Auth
- [ ] Check if email is verified before allowing access
- [ ] Add \"Forgot Password?\" button
- [ ] Implement password reset flow (send reset email)
- [ ] Add \"Don't have an account? Sign up\" navigation
- [ ] Add loading states and error handling
- [ ] Remember me functionality (optional for MVP)

## ✅ Acceptance Criteria
- Users can login with verified email/password
- Unverified users are redirected to verification screen
- Password reset emails are sent successfully
- Clear error messages for wrong credentials
- Smooth navigation between login/register screens

## 📚 Resources
- [Firebase Auth Sign In](https://firebase.flutter.dev/docs/auth/usage#signing-in)
- [Password Reset](https://firebase.flutter.dev/docs/auth/usage#password-reset)

## 💡 Beginner Tips
- Reuse validation logic from registration screen
- Use \`try-catch\` to handle Firebase exceptions (wrong password, user not found, etc)
- Show user-friendly error messages, not Firebase error codes
- Test with both verified and unverified accounts" \
    "type:feature,area:auth,priority:critical,difficulty:beginner" \
    "Week 3-4: Authentication"

create_issue \
    "[AUTH] Add Google Sign-In" \
    "## 🎯 Goal
Allow users to sign in with their Google account.

## 📋 Tasks
- [ ] Add \`google_sign_in\` package to pubspec.yaml
- [ ] Enable Google provider in Firebase Console
- [ ] Configure OAuth consent screen
- [ ] Add SHA-1 fingerprint for Android (debug & release)
- [ ] Configure iOS URL schemes in Xcode
- [ ] Create Google sign-in button on login screen
- [ ] Implement sign-in flow: \`GoogleSignIn → Firebase Auth\`
- [ ] Handle account linking (if email already exists)
- [ ] Test on both Android and iOS

## ✅ Acceptance Criteria
- Users can sign in with Google
- Google account is linked to Firebase Auth
- Works on both platforms
- Handles errors gracefully (canceled sign-in, network errors)

## 📚 Resources
- [Google Sign-In Package](https://pub.dev/packages/google_sign_in)
- [Firebase Google Auth Guide](https://firebase.flutter.dev/docs/auth/social#google)
- [SHA-1 Setup (Android)](https://stackoverflow.com/questions/51845559/how-to-generate-sha-1-for-flutter-react-native-android-native-app)

## 💡 Beginner Tips
- Debug and release SHA-1 are different - add both
- Use \`keytool\` to get SHA-1: \`keytool -list -v -keystore ~/.android/debug.keystore\`
- iOS setup is simpler than Android
- Test with a real device if emulator doesn't have Google Play Services

## ⚠️ Common Issues
- Android: PlatformException(sign_in_failed) → Missing SHA-1
- iOS: Invalid client ID → Check URL schemes in Xcode" \
    "type:feature,area:auth,priority:high,difficulty:intermediate,firebase" \
    "Week 3-4: Authentication"

create_issue \
    "[AUTH] Add Apple Sign-In (iOS required)" \
    "## 🎯 Goal
Implement Apple Sign-In (required for iOS App Store submission).

## 📋 Tasks
- [ ] Add \`sign_in_with_apple\` package
- [ ] Enable Apple provider in Firebase Console
- [ ] Setup Apple Sign-In in Apple Developer account
- [ ] Add Sign In with Apple capability in Xcode
- [ ] Create Apple sign-in button (iOS only)
- [ ] Implement sign-in flow
- [ ] Handle account linking
- [ ] Test on iOS device (doesn't work on simulator)

## ✅ Acceptance Criteria
- Users can sign in with Apple on iOS
- Button only shows on iOS (hide on Android)
- Account linking works
- Passes App Store requirements

## 📚 Resources
- [Sign in with Apple Package](https://pub.dev/packages/sign_in_with_apple)
- [Firebase Apple Auth](https://firebase.flutter.dev/docs/auth/social#apple)
- [Apple Developer Setup](https://firebase.google.com/docs/auth/ios/apple)

## 💡 Beginner Tips
- You need an Apple Developer account ($99/year) for this
- Apple sign-in only works on iOS 13+ and real devices
- Users can choose to hide their email - handle this gracefully
- Required for App Store but not critical for development/testing" \
    "type:feature,area:auth,priority:medium,difficulty:intermediate" \
    "Week 3-4: Authentication"

create_issue \
    "[AUTH] Add GitHub Sign-In" \
    "## 🎯 Goal
Add GitHub as an authentication provider.

## 📋 Tasks
- [ ] Create OAuth App in GitHub Developer Settings
- [ ] Enable GitHub provider in Firebase Console
- [ ] Add Client ID and Client Secret to Firebase
- [ ] Create GitHub sign-in button
- [ ] Implement OAuth flow using Firebase Auth
- [ ] Handle account linking
- [ ] Test sign-in flow

## ✅ Acceptance Criteria
- Users can sign in with GitHub account
- OAuth redirects work properly
- Account linking is handled

## 📚 Resources
- [Firebase GitHub Auth](https://firebase.flutter.dev/docs/auth/social#github)
- [GitHub OAuth Apps](https://github.com/settings/developers)

## 💡 Beginner Tips
- GitHub sign-in uses OAuth redirect flow
- No additional packages needed - Firebase Auth handles it
- Easier to implement than Google/Apple
- Good for developer-focused audience" \
    "type:feature,area:auth,priority:medium,difficulty:beginner" \
    "Week 3-4: Authentication"

create_issue \
    "[AUTH] Setup Riverpod for auth state management" \
    "## 🎯 Goal
Implement global authentication state management using Riverpod.

## 📋 Tasks
- [ ] Add \`flutter_riverpod\` and \`riverpod_annotation\` packages
- [ ] Wrap app with \`ProviderScope\` in \`main.dart\`
- [ ] Create \`lib/features/auth/domain/auth_provider.dart\`
- [ ] Create auth state provider that listens to Firebase auth changes
- [ ] Create auth repository provider
- [ ] Implement auth guards for route protection
- [ ] Create loading, authenticated, and unauthenticated states
- [ ] Navigate to appropriate screens based on auth state
- [ ] Implement logout functionality

## ✅ Acceptance Criteria
- Auth state is accessible throughout app via Riverpod
- App automatically navigates based on auth status
- Auth state persists across app restarts
- Logout works and clears state

## 📚 Resources
- [Riverpod Documentation](https://riverpod.dev/docs/introduction/getting_started)
- [Riverpod Authentication Example](https://codewithandrea.com/articles/flutter-firebase-auth-riverpod/)
- **Video:** [Riverpod in 100 Seconds](https://www.youtube.com/watch?v=zjIR8X0EkNU)

## 💡 Beginner Tips
- Riverpod is Flutter's most modern state management solution
- Use \`StreamProvider\` for Firebase auth state stream
- Riverpod providers are global - no context needed!
- Start simple - you can refactor to code generation later

## ⚠️ Important
- Don't use Provider (older) - use Riverpod (newer)
- Riverpod 2.0+ has breaking changes - follow latest docs" \
    "type:feature,area:auth,area:infrastructure,priority:critical,difficulty:intermediate" \
    "Week 3-4: Authentication"

# ============================================
# WEEK 5-6: Exercise System & Models
# ============================================

create_issue \
    "[DATA] Design and implement data models" \
    "## 🎯 Goal
Create all data models for exercises, sessions, programs with JSON serialization.

## 📋 Tasks
- [ ] Add \`json_annotation\` and \`json_serializable\` packages
- [ ] Create \`lib/models/exercise_model.dart\`:
  - id, name, description, muscleGroups, imageUrl, difficulty, tips
- [ ] Create \`lib/models/workout_set_model.dart\`:
  - exerciseId, sets, reps, restTime
- [ ] Create \`lib/models/tabata_config_model.dart\`:
  - exerciseId, workTime, restTime, rounds
- [ ] Create \`lib/models/session_model.dart\`:
  - id, name, description, exercises (mixed sets/tabata), duration, difficulty
- [ ] Create \`lib/models/program_model.dart\`:
  - id, name, description, sessionIds, durationWeeks, difficulty, goals
- [ ] Add JSON serialization annotations
- [ ] Run \`flutter pub run build_runner build\`
- [ ] Add Firestore converters for each model

## ✅ Acceptance Criteria
- All models compile without errors
- JSON serialization works (to/from JSON)
- Models support Firebase Firestore
- Clear documentation for each field

## 📚 Resources
- [json_serializable Guide](https://pub.dev/packages/json_serializable)
- [Firestore Data Modeling](https://firebase.google.com/docs/firestore/manage-data/structure-data)

## 💡 Beginner Tips
- Use \`@JsonSerializable()\` annotation for auto-generation
- Run build_runner in watch mode: \`flutter pub run build_runner watch\`
- Keep models immutable (use \`final\` fields)
- Add \`copyWith\` methods for easy updates

## 📊 Example Model Structure
\`\`\`dart
@JsonSerializable()
class ExerciseModel {
  final String id;
  final String name;
  final String description;
  final List<String> muscleGroups;
  final String imageUrl;
  final String difficulty; // 'beginner', 'intermediate', 'advanced'
  final String? tips;
}
\`\`\`" \
    "type:feature,area:workout,area:backend,priority:critical,difficulty:intermediate" \
    "Week 5-6: Exercise System & Models"

create_issue \
    "[BACKEND] Create Firestore service for data operations" \
    "## 🎯 Goal
Build a service layer to interact with Firestore for CRUD operations.

## 📋 Tasks
- [ ] Create \`lib/services/firestore_service.dart\`
- [ ] Implement methods for exercises:
  - \`getExercises()\`, \`getExerciseById(id)\`, \`searchExercises(query)\`
- [ ] Implement methods for sessions:
  - \`getSessions()\`, \`getSessionById(id)\`, \`createSession()\`, \`updateSession()\`, \`deleteSession()\`
- [ ] Implement methods for programs:
  - \`getPrograms()\`, \`getProgramById(id)\`, \`subscribeToProgram()\`
- [ ] Add offline caching with Hive
- [ ] Implement data sync logic (Hive ↔ Firestore)
- [ ] Add error handling and loading states
- [ ] Create Riverpod providers for each service method

## ✅ Acceptance Criteria
- Can fetch data from Firestore
- Can create/update/delete user data
- Offline caching works (data persists locally)
- Data syncs when connection is restored
- Error handling for network failures

## 📚 Resources
- [Cloud Firestore CRUD](https://firebase.flutter.dev/docs/firestore/usage)
- [Offline Data](https://firebase.google.com/docs/firestore/manage-data/enable-offline)

## 💡 Beginner Tips
- Use subcollections for user data: \`users/{uid}/sessions/{sessionId}\`
- Enable Firestore offline persistence (enabled by default in Flutter)
- Cache frequently accessed data in Hive to reduce reads
- Use Riverpod's \`FutureProvider\` for async data fetching" \
    "type:feature,area:backend,priority:critical,difficulty:intermediate,firebase,offline-support" \
    "Week 5-6: Exercise System & Models"
