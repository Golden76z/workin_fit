import 'package:flutter/material.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/features/workout/presentation/screens/workout_execution_screen.dart';
import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/session.dart';
import 'package:workin_fit/models/workout_config.dart';
import 'package:workin_fit/views/auth/authentication_view.dart';
import 'package:workin_fit/views/legal/privacy_policy_page.dart';
import 'package:workin_fit/views/legal/terms_of_service_page.dart';
import 'package:workin_fit/views/test/test_page_001.dart';
import 'package:workin_fit/views/test/test_page_002.dart';
import 'package:workin_fit/views/welcome/choose_language.dart';
import 'package:workin_fit/views/welcome/welcome_page.dart';

class RenderTestHubPage extends StatelessWidget {
  const RenderTestHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title: const Text('Render Test Hub'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const Text(
            'Open each page on your phone and quickly validate spacing, fonts,'
            ' and layout behavior.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _PreviewButton(
            label: 'Welcome page',
            onTap: () => _pushPage(
              context,
              const WelcomePage(),
            ),
          ),
          _PreviewButton(
            label: 'Choose language',
            onTap: () => _pushPage(
              context,
              const LanguageSelectionScreen(),
            ),
          ),
          _PreviewButton(
            label: 'Auth (Register tab)',
            onTap: () => _pushPage(
              context,
              const AuthenticationView(initialTabIndex: 0),
            ),
          ),
          _PreviewButton(
            label: 'Auth (Login tab)',
            onTap: () => _pushPage(
              context,
              const AuthenticationView(initialTabIndex: 1),
            ),
          ),
          _PreviewButton(
            label: 'Terms of service',
            onTap: () => _pushPage(
              context,
              const TermsOfServicePage(),
            ),
          ),
          _PreviewButton(
            label: 'Privacy policy',
            onTap: () => _pushPage(
              context,
              const PrivacyPolicyPage(),
            ),
          ),
          _PreviewButton(
            label: 'Test page 001',
            onTap: () => _pushPage(
              context,
              const AuthPage(),
            ),
          ),
          _PreviewButton(
            label: 'Create session page',
            onTap: () => _pushPage(
              context,
              const CreateSessionScreen(),
            ),
          ),
          _PreviewButton(
            label: 'Sessions list page',
            onTap: () => _pushPage(
              context,
              const SessionsListScreen(),
            ),
          ),
          _PreviewButton(
            label: 'Workout execution (seeded demo)',
            onTap: () => _pushPage(
              context,
              WorkoutExecutionScreen(
                session: _seededWorkoutSession(),
                seededExercises: _seededExercises(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _pushPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => page,
      ),
    );
  }
}

Session _seededWorkoutSession() {
  return Session(
    id: 'seed-workout-session',
    name: 'Seeded Workout Preview',
    workouts: [
      TimedConfig(
        exerciseId: 'seed_push_ups',
        duration: 30,
      ),
      TabataConfig(
        exerciseId: 'seed_plank',
        workTime: 20,
        restTime: 10,
        rounds: 3,
      ),
      SetsConfig(
        exerciseId: 'seed_squat',
        sets: 3,
        reps: 12,
        restBetweenSets: 30,
      ),
    ],
    difficulty: DifficultyLevel.beginner,
    transitionTime: 5,
    restBetweenExercises: 30,
  );
}

List<Exercise> _seededExercises() {
  return [
    Exercise(
      id: 'seed_push_ups',
      name: 'Push-ups',
      description: 'Classic upper-body bodyweight movement.',
      imageMuscleUrl: 'assets/images/test.png',
      imageTutorialUrl: 'assets/images/test.png',
      muscleGroups: const [MuscleGroup.chest, MuscleGroup.triceps],
      difficulty: DifficultyLevel.beginner,
      beginnerTips: 'Keep your body in a straight line.',
      equipment: const [],
    ),
    Exercise(
      id: 'seed_plank',
      name: 'Plank',
      description: 'Core stability hold with neutral spine.',
      imageMuscleUrl: 'assets/images/test.png',
      imageTutorialUrl: 'assets/images/test.png',
      muscleGroups: const [MuscleGroup.abs, MuscleGroup.lowerBack],
      difficulty: DifficultyLevel.beginner,
      beginnerTips: 'Brace core and keep hips aligned.',
      equipment: const [],
    ),
    Exercise(
      id: 'seed_squat',
      name: 'Bodyweight Squat',
      description: 'Lower-body movement focusing on quads and glutes.',
      imageMuscleUrl: 'assets/images/test.png',
      imageTutorialUrl: 'assets/images/test.png',
      muscleGroups: const [MuscleGroup.quads, MuscleGroup.glutes],
      difficulty: DifficultyLevel.beginner,
      beginnerTips: 'Track knees over toes and keep chest up.',
      equipment: const [],
    ),
  ];
}

class _PreviewButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PreviewButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: AppColors.primaryDark,
          alignment: Alignment.centerLeft,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'AppFontMedium',
          ),
        ),
      ),
    );
  }
}
