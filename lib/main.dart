import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/program.dart';
import 'package:workin_fit/models/session.dart';
import 'package:workin_fit/models/workout_config.dart';
import 'package:workin_fit/views/auth/authentication_view.dart';
// import 'package:workin_fit/views/test/test_page_001.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    return MaterialApp(
      title: 'Workin Fit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
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
    return const AuthenticationView();   
    }
}
