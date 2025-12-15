# Workin Fit

A comprehensive Flutter fitness mobile app featuring customizable workouts, social challenges, and progress tracking.

## FLutter ressources

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Running the project:

Start the emulator
```bash
emulator @Pixel_5_API_34
```

Run the project on the emulator
```bash
flutter run
```

## Features
- Multi-provider authentication (Email, Google, Apple, GitHub)
- Customizable workout sessions and programs
- Intelligent exercise timer with transitions
- Achievement system with trophies and streaks
- Social features: friends, challenges, leaderboards
- Progress tracking and statistics
- Daily challenges and warmup routines
- Offline support for created sessions and programs

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

<!-- ## Development Timeline -->
<!-- - **Weeks 1-2:** Foundation & Firebase setup -->
<!-- - **Weeks 3-4:** Authentication -->
<!-- - **Weeks 5-8:** Core workout engine & exercise execution -->
<!-- - **Weeks 9-10:** Home page & content (programs, warmups, challenges) -->
<!-- - **Weeks 11-12:** Profile, progress tracking, achievements -->
<!-- - **Week 13:** Social features (friends, sharing, leaderboards) -->
<!-- - **Week 14:** Testing & bug fixes -->
