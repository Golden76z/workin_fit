import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
// import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/program.dart';
import 'package:workin_fit/models/session.dart';
import 'package:workin_fit/models/workout_config.dart';
import 'package:workin_fit/providers/auth_provider.dart';
import 'package:workin_fit/views/auth/authentication_view.dart';
// import 'firebase_options.dart';
// import 'package:workin_fit/views/test/test_page_001.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for authentication and cloud services
  await Firebase.initializeApp();

  // Initialize Hive for offline database
  await Hive.initFlutter();
  Hive.registerAdapter(WorkoutTypeAdapter());
  Hive.registerAdapter(DifficultyLevelAdapter());
  Hive.registerAdapter(MuscleGroupAdapter());
  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(WorkoutConfigAdapter());
  Hive.registerAdapter(SetsConfigAdapter());
  Hive.registerAdapter(TabataConfigAdapter());
  Hive.registerAdapter(TimedConfigAdapter());
  Hive.registerAdapter(SessionAdapter());
  Hive.registerAdapter(ProgramAdapter());

  runApp(
    const ProviderScope(
      child: WorkinFitApp(),
    ),
  );
}

class WorkinFitApp extends ConsumerWidget {
  const WorkinFitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch auth state to determine initial route
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Workin Fit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7B68EE),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      // Redirect based on auth state
      home: authState.when(
        data: (user) => user != null ? const AuthenticationView() : const AuthenticationView(),
        loading: () => const CircularProgressIndicator(),
        error: (_, __) => const AuthenticationView(),
      ),
    );
  }
}