# Contributing to Workin Fit

## Development Setup

### Prerequisites
- Flutter SDK (latest stable - 3.16+)
- Dart SDK
- Android Studio / Xcode
- Firebase CLI
- Git
- VS Code (recommended) with Flutter extensions

### Installation
```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/workin-fit.git
cd workin-fit

# Install dependencies
flutter pub get

# Run code generation (for Riverpod & JSON serialization)
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Firebase Setup
1. Create a Firebase project at https://console.firebase.google.com
2. Install FlutterFire CLI: `dart pub global activate flutterfire_cli`
3. Run: `flutterfire configure` (automatically creates config files)
4. Enable Authentication providers (Email, Google, Apple, GitHub)
5. Create Firestore database
6. Set up Firebase Storage

### Branch Strategy
- `main` - Production-ready code (protected)
- `develop` - Integration branch (protected)
- `feature/*` - New features (merge to develop)
- `bugfix/*` - Bug fixes (merge to develop)
- `hotfix/*` - Urgent production fixes (merge to main)

### Commit Convention
Follow [Conventional Commits](https://www.conventionalcommits.org/):
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting)
- `refactor:` Code refactoring
- `test:` Test additions/changes
- `chore:` Build/config changes

Examples:
- `feat(auth): add Google sign-in`
- `fix(workout): timer not pausing on app minimize`
- `docs: update setup instructions`

### Pull Request Process
1. Create feature branch from `develop`: `git checkout -b feature/exercise-timer`
2. Make changes and commit with conventional commit messages
3. Write/update tests for new functionality
4. Run `flutter test` and ensure all tests pass
5. Run `flutter analyze` and fix any issues
6. Update documentation if needed
7. Push branch and create PR to `develop`
8. Address review comments
9. Squash and merge after approval

### Code Style
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use trailing commas for better git diffs
- Prefer `const` constructors when possible
- Keep functions small and focused
- Write self-documenting code with clear variable names
- Add comments for complex logic only

### Testing Guidelines
- Write unit tests for business logic
- Write widget tests for UI components
- Aim for 70%+ code coverage
- Test error cases and edge cases
- Mock Firebase services in tests

### File Naming
- **Dart files:** `lowercase_with_underscores.dart`
- **Widgets:** `my_custom_widget.dart`
- **Models:** `user_model.dart`
- **Services:** `auth_service.dart`
- **Providers:** `workout_provider.dart`

### Folder Structure
```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── firebase_constants.dart
│   │   └── route_constants.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── colors.dart
│   │   └── text_styles.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   └── helpers.dart
│   └── errors/
│       └── exceptions.dart
├── features/
│   ├── auth/
│   │   ├── data/          # Firebase calls, local storage
│   │   ├── domain/        # Business logic, models
│   │   └── presentation/  # UI, widgets, providers
│   ├── workout/
│   ├── profile/
│   └── social/
├── models/
│   ├── exercise_model.dart
│   ├── session_model.dart
│   └── program_model.dart
├── services/
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── storage_service.dart
├── widgets/
│   ├── buttons/
│   ├── cards/
│   └── inputs/
└── main.dart
```

### Admin Features
- Admin users can create preset exercises, programs, and warmups directly in the app
- Admin role is managed via Firebase Auth custom claims
- Content moderation includes banned word filtering

### Need Help?
- Check existing issues and discussions
- Join our Discord [Link TBD]
- Review the resources guide in the repo
