import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:workin_fit/core/constants/app_constants.dart';
import 'package:workin_fit/core/theme/app_chrome.dart';
import 'package:workin_fit/core/theme/app_theme.dart';
import 'package:workin_fit/l10n/app_localizations.dart';
import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/program.dart';
import 'package:workin_fit/models/session.dart';
import 'package:workin_fit/models/workout_config.dart';
import 'package:workin_fit/providers/locale_provider.dart';
import 'package:workin_fit/services/deep_link_service.dart';
import 'package:workin_fit/features/auth/presentation/auth_gate.dart';
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(AppChrome.globalOverlay);

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
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: AppConstants.appName,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      builder: (BuildContext context, Widget? child) {
        return AppSystemOverlayRegion(
          style: AppChrome.globalOverlay,
          child: child ?? const SizedBox.shrink(),
        );
      },
      // Redirect based on global auth state and email verification
      home: const AuthGate(),
    );
  }
}
