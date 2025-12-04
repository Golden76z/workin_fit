cat > README.md << 'EOF'
# Workin Fit 💪

A comprehensive Flutter fitness mobile app featuring customizable workouts, social challenges, and progress tracking.

## Features
- 🔐 Multi-provider authentication (Email, Google, Apple, GitHub)
- 🏋️ Customizable workout sessions and programs
- ⏱️ Intelligent exercise timer with transitions
- 🏆 Achievement system with trophies and streaks
- 👥 Social features: friends, challenges, leaderboards
- 📊 Progress tracking and statistics
- 🔥 Daily challenges and warmup routines
- 💾 Offline support for created sessions and programs

## Tech Stack
- **Framework:** Flutter/Dart
- **Backend:** Firebase (Auth, Firestore, Storage, Cloud Functions)
- **State Management:** Riverpod
- **Local Storage:** Hive for offline support
- **Theme:** Dark mode with purple/blue color scheme

## Target Launch
March 1, 2025

## Getting Started
See [CONTRIBUTING.md](CONTRIBUTING.md) for setup instructions.

## Project Structure
```
lib/
├── core/           # Core utilities, constants, themes
├── features/       # Feature modules (auth, workout, profile, social)
├── models/         # Data models
├── services/       # Business logic and API services
└── widgets/        # Reusable UI components
```

## Development Timeline
- **Weeks 1-2:** Foundation & Firebase setup
- **Weeks 3-4:** Authentication
- **Weeks 5-8:** Core workout engine & exercise execution
- **Weeks 9-10:** Home page & content (programs, warmups, challenges)
- **Weeks 11-12:** Profile, progress tracking, achievements
- **Week 13:** Social features (friends, sharing, leaderboards)
- **Week 14:** Testing & bug fixes
- **Week 15:** Polish & optimization
- **Week 16:** Final testing & launch prep

## License
[License TBD]
EOF

# Create CONTRIBUTING.md
cat > CONTRIBUTING.md << 'EOF'
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
EOF

# Create initial .gitignore
cat > .gitignore << 'EOF'
# Flutter/Dart
.dart_tool/
.packages
build/
.flutter-plugins
.flutter-plugins-dependencies
*.lock

# Firebase
google-services.json
GoogleService-Info.plist
firebase-debug.log
.firebase/
firebase.json
.firebaserc

# IDE
.idea/
.vscode/
*.iml
*.ipr
*.iws

# Environment
.env
.env.local
*.env

# Generated files
*.g.dart
*.freezed.dart

# OS
.DS_Store
Thumbs.db

# Coverage
coverage/
*.lcov

# Hive
*.hive
*.lock
EOF

git add .
git commit -m "chore: initial project setup with README and CONTRIBUTING"
git push -u origin main

# Create develop branch
git checkout -b develop
git push -u origin develop

# Set main as default branch
git checkout main

echo "✅ Repository created and initialized"

# Create milestones - Adjusted for beginner-friendly 16-week timeline
echo "📅 Creating milestones..."

gh api repos/:owner/:repo/milestones -f title="Week 1-2: Foundation" -f description="Project setup, Firebase configuration, theme, and project structure" -f due_on="2024-12-17T00:00:00Z" -f state="open"

gh api repos/:owner/:repo/milestones -f title="Week 3-4: Authentication" -f description="Complete authentication with email, Google, Apple, GitHub. Email verification required." -f due_on="2024-12-31T00:00:00Z" -f state="open"

gh api repos/:owner/:repo/milestones -f title="Week 5-6: Exercise System & Models" -f description="Exercise database, data models, Firebase integration, offline caching" -f due_on="2025-01-14T00:00:00Z" -f state="open"

gh api repos/:owner/:repo/milestones -f title="Week 7-8: Workout Execution" -f description="Exercise execution screen, timer system, sets/tabata logic, pause/resume" -f due_on="2025-01-28T00:00:00Z" -f state="open"

gh api repos/:owner/:repo/milestones -f title="Week 9-10: Home & Content" -f description="Home page, preset programs/sessions, warmups, daily challenges, session builder" -f due_on="2025-02-11T00:00:00Z" -f state="open"

gh api repos/:owner/:repo/milestones -f title="Week 11-12: Profile & Progress" -f description="Profile page, streak tracking, achievements, statistics, privacy settings" -f due_on="2025-02-18T00:00:00Z" -f state="open"

gh api repos/:owner/:repo/milestones -f title="Week 13: Social Features" -f description="Friend system, workout sharing, leaderboards, basic chat" -f due_on="2025-02-25T00:00:00Z" -f state="open"

gh api repos/:owner/:repo/milestones -f title="Week 14: Testing & Fixes" -f description="Comprehensive testing, bug fixes, error handling" -f due_on="2025-02-25T00:00:00Z" -f state="open"

gh api repos/:owner/:repo/milestones -f title="Week 15: Polish" -f description="UI polish, animations, performance optimization, final UX improvements" -f due_on="2025-02-28T00:00:00Z" -f state="open"

gh api repos/:owner/:repo/milestones -f title="Week 16: Launch Prep" -f description="App store preparation, final testing, documentation, launch!" -f due_on="2025-03-01T00:00:00Z" -f state="open"

gh api repos/:owner/:repo/milestones -f title="Future: v1.1 Group Chat" -f description="Group chat functionality for friend groups" -f state="open"

echo "✅ Milestones created"

# Create labels
echo "🏷️  Creating labels..."

# Priority labels
gh label create "priority:critical" --color "d73a4a" --description "Must be done ASAP - blocks other work" --force
gh label create "priority:high" --color "ff9800" --description "Important - should be done soon" --force
gh label create "priority:medium" --color "fbca04" --description "Normal priority" --force
gh label create "priority:low" --color "0e8a16" --description "Nice to have" --force

# Type labels
gh label create "type:feature" --color "a2eeef" --description "New feature implementation" --force
gh label create "type:bug" --color "d73a4a" --description "Bug fix" --force
gh label create "type:enhancement" --color "84b6eb" --description "Enhancement to existing feature" --force
gh label create "type:refactor" --color "5319e7" --description "Code refactoring" --force
gh label create "type:docs" --color "0075ca" --description "Documentation" --force
gh label create "type:test" --color "bfd4f2" --description "Testing" --force
gh label create "type:chore" --color "fef2c0" --description "Build/config/maintenance" --force

# Area labels
gh label create "area:auth" --color "c5def5" --description "Authentication & Authorization" --force
gh label create "area:workout" --color "c5def5" --description "Workout & Exercise execution" --force
gh label create "area:social" --color "c5def5" --description "Social features (friends, sharing)" --force
gh label create "area:profile" --color "c5def5" --description "User profile & progress" --force
gh label create "area:ui" --color "c5def5" --description "UI/UX" --force
gh label create "area:backend" --color "c5def5" --description "Backend/Firebase/Cloud Functions" --force
gh label create "area:infrastructure" --color "c5def5" --description "Infrastructure, DevOps, CI/CD" --force
gh label create "area:admin" --color "c5def5" --description "Admin features" --force

# Status labels
gh label create "status:blocked" --color "b60205" --description "Blocked by dependency" --force
gh label create "status:in-progress" --color "0052cc" --description "Work in progress" --force
gh label create "status:review" --color "fbca04" --description "In code review" --force
gh label create "status:needs-testing" --color "d4c5f9" --description "Needs manual testing" --force

# Difficulty labels (for solo beginner developer)
gh label create "difficulty:beginner" --color "7057ff" --description "Good for learning - straightforward" --force
gh label create "difficulty:intermediate" --color "d876e3" --description "Requires some research" --force
gh label create "difficulty:advanced" --color "e99695" --description "Complex - may need external help" --force

# Special labels
gh label create "good-first-issue" --color "7057ff" --description "Good for getting started with the codebase" --force
gh label create "help-wanted" --color "008672" --description "May need external help or guidance" --force
gh label create "breaking-change" --color "d93f0b" --description "Breaking change" --force
gh label create "firebase" --color "ffa000" --description "Firebase related" --force
gh label create "offline-support" --color "006b75" --description "Offline functionality" --force

echo "✅ Labels created"

echo ""
echo "🎉 GitHub repository setup complete!"
echo ""
echo "📊 Project Summary:"
echo "  ✓ Repository: $REPO_NAME"
echo "  ✓ Branches: main (protected), develop"
echo "  ✓ Milestones: 11 milestones (16-week timeline + future)"
echo "  ✓ Labels: Priority, Type, Area, Status, Difficulty"
echo ""
echo "Next steps:"
echo "  1. Run: cd $REPO_NAME"
echo "  2. Run: ../create_issues.sh"
echo "  3. Review issues on GitHub and start with 'good-first-issue' labels"
echo "  4. Run: ../quick_start.sh (to initialize Flutter project)"
echo ""
