#!/bin/bash

# Workin Fit - Quick Start Script
# This script helps you get started quickly after running the GitHub setup

set -e

echo "🏋️ Workin Fit - Quick Start Setup"
echo "=================================="
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Please install Flutter first:"
    echo "   https://docs.flutter.dev/get-started/install"
    exit 1
fi

echo "✅ Flutter detected: $(flutter --version | head -1)"
echo ""

# Check Flutter doctor
echo "🔍 Running Flutter Doctor..."
flutter doctor
echo ""

# Create Flutter project
echo "📱 Creating Flutter project..."
read -p "Enter project name (default: workin_fit): " PROJECT_NAME
PROJECT_NAME=${PROJECT_NAME:-workin_fit}

if [ -d "$PROJECT_NAME" ]; then
    echo "⚠️  Directory $PROJECT_NAME already exists!"
    read -p "Do you want to continue? This will modify existing files. (y/N): " CONTINUE
    if [[ ! $CONTINUE =~ ^[Yy]$ ]]; then
        echo "Exiting..."
        exit 0
    fi
else
    flutter create --org com.workinfit "$PROJECT_NAME"
fi

cd "$PROJECT_NAME"

echo ""
echo "📦 Setting up project structure..."

# Create directory structure
mkdir -p lib/core/{constants,theme,utils,errors}
mkdir -p lib/features/{auth,home,workout,profile,social}/{data,domain,presentation}
mkdir -p lib/models
mkdir -p lib/services
mkdir -p lib/widgets
mkdir -p test/{unit,widget,integration}
mkdir -p assets/{images,icons,animations}

echo "✅ Directory structure created"

# Create pubspec.yaml with dependencies
cat > pubspec.yaml << 'EOF'
name: workin_fit
description: A comprehensive Flutter fitness app
publish_to: 'none'
version: 0.1.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.13.3
  firebase_storage: ^11.5.3
  
  # Social Auth
  google_sign_in: ^6.1.6
  sign_in_with_apple: ^5.0.0
  
  # State Management (Riverpod)
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  
  # UI & Design
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  lucide_icons: ^0.1.0
  flutter_animate: ^4.3.0
  lottie: ^2.7.0
  fl_chart: ^0.65.0
  percent_indicator: ^4.2.3
  
  # Workout Specific
  circular_countdown_timer: ^0.2.3
  stop_watch_timer: ^3.0.1
  wakelock: ^0.6.2
  vibration: ^1.8.3
  audioplayers: ^5.2.1
  
  # Data & Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  json_annotation: ^4.8.1
  
  # Utilities
  dio: ^5.4.0
  connectivity_plus: ^5.0.2
  intl: ^0.19.0
  timeago: ^3.6.0
  uuid: ^4.2.2
  share_plus: ^7.2.1
  url_launcher: ^6.2.2
  image_picker: ^1.0.5
  permission_handler: ^11.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  
  # Build
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
  hive_generator: ^2.0.1
  riverpod_generator: ^2.3.9
  
  # Testing
  mockito: ^5.4.4
  fake_cloud_firestore: ^2.4.8
  firebase_auth_mocks: ^0.13.0
  
  # Tools
  flutter_launcher_icons: ^0.13.1
  flutter_native_splash: ^2.3.7

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
    - assets/animations/

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icons/app_icon.png"
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/icons/app_icon.png"

flutter_native_splash:
  color: "#FFFFFF"
  image: assets/images/splash_logo.png
  android: true
  ios: true
EOF

echo "✅ pubspec.yaml created"

# Create analysis_options.yaml
cat > analysis_options.yaml << 'EOF'
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    # Error rules
    always_use_package_imports: true
    avoid_dynamic_calls: true
    avoid_empty_else: true
    avoid_print: true
    avoid_relative_lib_imports: true
    avoid_slow_async_io: true
    avoid_types_as_parameter_names: true
    cancel_subscriptions: true
    close_sinks: true
    empty_statements: true
    hash_and_equals: true
    no_duplicate_case_values: true
    valid_regexps: true
    
    # Style rules
    always_declare_return_types: true
    always_put_required_named_parameters_first: true
    avoid_bool_literals_in_conditional_expressions: true
    avoid_catches_without_on_clauses: false
    avoid_catching_errors: true
    avoid_private_typedef_functions: true
    avoid_returning_null_for_void: true
    avoid_shadowing_type_parameters: true
    avoid_unnecessary_containers: true
    avoid_void_async: true
    camel_case_extensions: true
    camel_case_types: true
    curly_braces_in_flow_control_structures: true
    file_names: true
    prefer_const_constructors: true
    prefer_const_declarations: true
    prefer_final_fields: true
    prefer_final_locals: true
    prefer_single_quotes: true
    require_trailing_commas: true
    sort_child_properties_last: true
    use_key_in_widget_constructors: true
    use_super_parameters: true

analyzer:
  errors:
    missing_required_param: error
    missing_return: error
    must_be_immutable: error
    invalid_annotation_target: ignore
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
EOF

echo "✅ analysis_options.yaml created"

# Create main.dart
cat > lib/main.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: WorkinFitApp(),
    ),
  );
}

class WorkinFitApp extends StatelessWidget {
  const WorkinFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workin Fit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workin Fit'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '💪 Workin Fit',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your fitness journey starts here',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to login
              },
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
EOF

echo "✅ main.dart created"

# Create constants file
cat > lib/core/constants/app_constants.dart << 'EOF'
class AppConstants {
  // App Info
  static const String appName = 'Workin Fit';
  static const String appVersion = '1.0.0';
  
  // Timing (from requirements)
  static const int defaultSetRestTime = 60; // 60s between sets
  static const int defaultExerciseRestTime = 120; // 120s between exercises
  static const int defaultTabataWorkTime = 20; // 20s work
  static const int defaultTabataRestTime = 10; // 10s rest
  static const int transitionTime = 5; // 5s to get ready
  
  // Warmup Durations (in seconds)
  static const int warmup2Min = 120;
  static const int warmup5Min = 300;
  static const int warmup10Min = 600;
  
  // Limits (free tier)
  static const int maxCustomSessions = 20;
  static const int maxCustomPrograms = 5;
  
  // Pagination
  static const int pageSize = 20;
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxUsernameLength = 20;
  static const int minUsernameLength = 3;
  
  // Content
  static const int totalExercisesTarget = 100;
}

class FirebaseConstants {
  // Collections
  static const String usersCollection = 'users';
  static const String exercisesCollection = 'exercises';
  static const String sessionsCollection = 'sessions';
  static const String programsCollection = 'programs';
  static const String warmupsCollection = 'warmups';
  static const String workoutHistoryCollection = 'workout_history';
  static const String dailyChallengesCollection = 'daily_challenges';
  static const String friendsCollection = 'friends';
  static const String friendRequestsCollection = 'friend_requests';
  static const String chatsCollection = 'chats';
  static const String achievementsCollection = 'achievements';
  static const String streaksCollection = 'streaks';
  
  // Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String exerciseImagesPath = 'exercise_images';
}

class RouteConstants {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String workout = '/workout';
  static const String workoutExecution = '/workout/execution';
  static const String exerciseDetail = '/exercise/detail';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String friends = '/friends';
  static const String chat = '/chat';
  static const String leaderboard = '/leaderboard';
  static const String achievements = '/achievements';
  static const String settings = '/settings';
  static const String programDetail = '/program/detail';
  static const String sessionDetail = '/session/detail';
  static const String sessionBuilder = '/session/builder';
  static const String programBuilder = '/program/builder';
}

// Workout Types
enum WorkoutType {
  sets,
  tabata,
}

// Difficulty Levels
enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
}

// Muscle Groups
enum MuscleGroup {
  chest,
  shoulders,
  triceps,
  biceps,
  back,
  forearms,
  quads,
  hamstrings,
  calves,
  glutes,
  abs,
  obliques,
  lowerBack,
  cardio,
}
EOF

echo "✅ Constants created"

# Create README for next steps
cat > NEXT_STEPS.md << 'EOF'
# 🎯 Next Steps for Workin Fit Development

## Immediate Actions

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Setup Firebase
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project named "Workin Fit"
3. Add iOS app (Bundle ID: com.workinfit.workinFit)
4. Add Android app (Package name: com.workinfit.workin_fit)
5. Download configuration files:
   - iOS: `GoogleService-Info.plist` → place in `ios/Runner/`
   - Android: `google-services.json` → place in `android/app/`

### 3. Configure Firebase in Project
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

### 4. Run the App
```bash
# Check for any issues
flutter doctor

# Run on connected device
flutter run
```

## Development Workflow

### Branch Strategy
- `main` - Production ready
- `develop` - Integration branch
- `feature/[feature-name]` - New features
- `bugfix/[bug-name]` - Bug fixes

### Before Starting a Feature
1. Create a new branch: `git checkout -b feature/auth-screen`
2. Check the corresponding GitHub issue
3. Update issue status to "In Progress"

### Code Standards
- Follow the linting rules in `analysis_options.yaml`
- Write tests for new features
- Use meaningful commit messages (Conventional Commits)
- Request code review before merging to `develop`

## Firebase Security Rules

### Firestore Rules (Initial Setup)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Exercises (read-only for users)
    match /exercises/{exerciseId} {
      allow read: if request.auth != null;
      allow write: if false; // Admin only via Cloud Functions
    }
    
    // Add more rules as needed
  }
}
```

### Storage Rules (Initial Setup)
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_images/{userId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId 
                   && request.resource.size < 5 * 1024 * 1024
                   && request.resource.contentType.matches('image/.*');
    }
  }
}
```

## Testing Commands

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Useful Commands

```bash
# Clean build
flutter clean
flutter pub get

# Generate code (after adding json_serializable models)
flutter pub run build_runner build --delete-conflicting-outputs

# Check for outdated packages
flutter pub outdated

# Format code
dart format .

# Analyze code
flutter analyze

# Generate app icons
flutter pub run flutter_launcher_icons

# Generate splash screen
flutter pub run flutter_native_splash:create
```

## Design Phase

1. **Create Figma Design**
   - App icon
   - Splash screen
   - All main screens (login, home, workout, profile)
   - Components (buttons, cards, inputs)
   - Color palette
   - Typography

2. **Export Assets**
   - App icon (1024x1024)
   - Splash logo (512x512)
   - Wave separator SVG
   - Any custom icons

## Recommended First Issues

Start with these issues from GitHub:
1. ✅ Setup Firebase project and configuration
2. ✅ Create design system and theme configuration
3. ✅ Implement email/password authentication
4. ✅ Design and implement exercise data model

## Resources Quick Links

- [Flutter Docs](https://docs.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [GitHub Repository Issues](https://github.com/YOUR_USERNAME/workin-fit/issues)
- [Figma Design File](YOUR_FIGMA_LINK)

## Questions or Issues?

- Check the resources guide in the repository
- Ask in Flutter Discord
- Search Stack Overflow
- Review existing GitHub issues

---

**Happy Coding! 🚀💪**
EOF

echo "✅ NEXT_STEPS.md created"

echo ""
echo "📱 Installing dependencies..."
flutter pub get

echo ""
echo "🎉 Quick start setup complete!"
echo ""
echo "📋 Next steps:"
echo "  1. Read NEXT_STEPS.md for detailed instructions"
echo "  2. Setup Firebase project"
echo "  3. Run: flutterfire configure"
echo "  4. Start coding! Check GitHub issues for tasks"
echo ""
echo "🚀 To run the app:"
echo "   cd $PROJECT_NAME"
echo "   flutter run"
echo ""
