import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:workin_fit/l10n/app_localizations.dart';
// import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/program.dart';
import 'package:workin_fit/models/session.dart';
import 'package:workin_fit/models/workout_config.dart';
import 'package:workin_fit/providers/auth_provider.dart';
import 'package:workin_fit/providers/locale_provider.dart';
import 'package:workin_fit/services/deep_link_service.dart';
import 'package:workin_fit/views/auth/email_verification_view.dart';
import 'package:workin_fit/views/home/home_page.dart';
import 'package:workin_fit/views/welcome/welcome_page.dart';
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

class WorkinFitApp extends ConsumerStatefulWidget {
  const WorkinFitApp({super.key});

  @override
  ConsumerState<WorkinFitApp> createState() => _WorkinFitAppState();
}

class _WorkinFitAppState extends ConsumerState<WorkinFitApp> {
  @override
  void initState() {
    super.initState();
    // Initialize deep link service after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final deepLinkService = ref.read(deepLinkServiceProvider);
      deepLinkService.initialize(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state to determine initial route
    final authState = ref.watch(authStateProvider);
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
      // Redirect based on auth state and email verification
      home: authState.when(
        data: (user) {
          if (user == null) {
            return const WelcomePage();
          }
          // Check if email is verified
          if (!user.emailVerified) {
            return const EmailVerificationView();
          }
          return const HomePage();
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => const WelcomePage(),
      ),
    );
  }
}