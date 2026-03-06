import 'package:flutter/material.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/features/workout/presentation/screens/workout_execution_screen.dart';
import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/exercise_localization.dart';
import 'package:workin_fit/models/session.dart';
import 'package:workin_fit/models/workout_config.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({
    required this.exercise,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final bool isFrench = locale.languageCode.toLowerCase().startsWith('fr');
    final String localizedName = exercise.getLocalizedName(context);
    final String localizedDescription =
        exercise.getLocalizedDescription(context);
    final String? localizedTips = exercise.getLocalizedBeginnerTips(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            expandedHeight: 300,
            backgroundColor: AppColors.primaryDark,
            iconTheme: const IconThemeData(color: AppColors.background),
            title: Text(
              localizedName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.background,
                fontFamily: 'AppFontMedium',
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Hero(
                    tag: 'exercise-image-${exercise.id}',
                    child: _ExerciseMedia(url: exercise.imageTutorialUrl),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Color(0x22000000),
                          Color(0x880C154A),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: AppSpacing.md,
                    right: AppSpacing.md,
                    bottom: AppSpacing.md,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            localizedName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.background,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'AppFontMedium',
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _DifficultyBadge(
                          difficulty: exercise.difficulty,
                          locale: locale,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _InfoCardSection(
                    title: isFrench ? 'Groupes musculaires' : 'Muscle Groups',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (exercise.imageMuscleUrl
                            .trim()
                            .isNotEmpty) ...<Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadii.md),
                            child: SizedBox(
                              height: 170,
                              width: double.infinity,
                              child:
                                  _ExerciseMedia(url: exercise.imageMuscleUrl),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: exercise.muscleGroups
                              .map(
                                (MuscleGroup group) => Chip(
                                  label: Text(_muscleLabel(group, isFrench)),
                                  labelStyle: const TextStyle(
                                    color: AppColors.primaryAbyss,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  side: BorderSide(
                                    color: AppColors.primaryLight
                                        .withValues(alpha: 0.38),
                                  ),
                                  backgroundColor: AppColors.lightCyan,
                                  visualDensity: VisualDensity.compact,
                                ),
                              )
                              .toList(growable: false),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _InfoCardSection(
                    title: isFrench
                        ? 'Description du mouvement'
                        : 'Movement Description',
                    child: Text(
                      localizedDescription,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _InfoCardSection(
                    title: isFrench ? 'Comment effectuer' : 'How to Perform',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildHowToSteps(
                        description: localizedDescription,
                        isFrench: isFrench,
                      )
                          .asMap()
                          .entries
                          .map(
                            (MapEntry<int, String> entry) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: 24,
                                    height: 24,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                    child: Text(
                                      '${entry.key + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Expanded(
                                    child: Text(
                                      entry.value,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _InfoCardSection(
                    title: isFrench ? 'Conseils debutants' : 'Beginner Tips',
                    child: Text(
                      _tipsFallback(tips: localizedTips, isFrench: isFrench),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () => _startExercise(context),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(
                        isFrench ? 'Demarrer l\'exercice' : 'Start Exercise',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'AppFontMedium',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height:
                        MediaQuery.paddingOf(context).bottom + AppSpacing.md,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startExercise(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final bool isFrench = locale.languageCode.toLowerCase().startsWith('fr');
    final String localizedName = exercise.getLocalizedName(context);

    final Session quickSession = Session(
      id: 'quick_${exercise.id}_${DateTime.now().millisecondsSinceEpoch}',
      name: isFrench
          ? 'Demarrage rapide - $localizedName'
          : 'Quick Start - $localizedName',
      workouts: <WorkoutConfig>[
        TimedConfig(
          exerciseId: exercise.id,
          duration: _durationFromDifficulty(exercise.difficulty),
        ),
      ],
      difficulty: exercise.difficulty,
      restBetweenExercises: 10,
      transitionTime: 5,
      isCustom: false,
    );

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WorkoutExecutionScreen(
          session: quickSession,
          seededExercises: <Exercise>[exercise],
        ),
      ),
    );
  }

  int _durationFromDifficulty(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return 35;
      case DifficultyLevel.intermediate:
        return 45;
      case DifficultyLevel.advanced:
        return 60;
    }
  }

  String _tipsFallback({
    required String? tips,
    required bool isFrench,
  }) {
    final String value = tips?.trim() ?? '';
    if (value.isNotEmpty) {
      return value;
    }

    return isFrench
        ? 'Concentre-toi sur un mouvement lent et propre. Garde une respiration reguliere et arrete-toi si tu perds la posture.'
        : 'Move slowly with control, keep breathing regularly, and stop if your form starts to break.';
  }

  List<String> _buildHowToSteps({
    required String description,
    required bool isFrench,
  }) {
    final List<String> extracted = description
        .replaceAll('\n', ' ')
        .split(RegExp(r'[.!?]'))
        .map((String step) => step.trim())
        .where((String step) => step.length > 10)
        .take(4)
        .toList(growable: false);

    if (extracted.isNotEmpty) {
      return extracted;
    }

    if (isFrench) {
      return const <String>[
        'Prends une position de depart stable et aligne ton corps.',
        'Contracte le tronc avant chaque repetition.',
        'Execute le mouvement lentement avec controle.',
        'Reviens a la position initiale puis repete.',
      ];
    }

    return const <String>[
      'Set up a stable starting position with good posture.',
      'Brace your core before each repetition.',
      'Perform the movement slowly and with control.',
      'Return to start position and repeat.',
    ];
  }

  String _muscleLabel(MuscleGroup muscle, bool isFrench) {
    switch (muscle) {
      case MuscleGroup.chest:
        return isFrench ? 'Pectoraux' : 'Chest';
      case MuscleGroup.shoulders:
        return isFrench ? 'Epaules' : 'Shoulders';
      case MuscleGroup.triceps:
        return 'Triceps';
      case MuscleGroup.biceps:
        return 'Biceps';
      case MuscleGroup.back:
        return isFrench ? 'Dos' : 'Back';
      case MuscleGroup.forearms:
        return isFrench ? 'Avant-bras' : 'Forearms';
      case MuscleGroup.quads:
        return isFrench ? 'Quadriceps' : 'Quads';
      case MuscleGroup.hamstrings:
        return isFrench ? 'Ischio-jambiers' : 'Hamstrings';
      case MuscleGroup.calves:
        return isFrench ? 'Mollets' : 'Calves';
      case MuscleGroup.glutes:
        return isFrench ? 'Fessiers' : 'Glutes';
      case MuscleGroup.abs:
        return isFrench ? 'Abdos' : 'Abs';
      case MuscleGroup.obliques:
        return isFrench ? 'Obliques' : 'Obliques';
      case MuscleGroup.lowerBack:
        return isFrench ? 'Bas du dos' : 'Lower back';
      case MuscleGroup.cardio:
        return 'Cardio';
    }
  }
}

class _InfoCardSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCardSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        side: BorderSide(
          color: AppColors.primaryLight.withValues(alpha: 0.2),
        ),
      ),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'AppFontMedium',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            child,
          ],
        ),
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final DifficultyLevel difficulty;
  final Locale locale;

  const _DifficultyBadge({
    required this.difficulty,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFrench = locale.languageCode.toLowerCase().startsWith('fr');
    final ({String label, Color color}) meta = _difficultyMeta(isFrench);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: meta.color,
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      child: Text(
        meta.label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  ({String label, Color color}) _difficultyMeta(bool isFrench) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return (
          label: isFrench ? 'Debutant' : 'Beginner',
          color: AppColors.success,
        );
      case DifficultyLevel.intermediate:
        return (
          label: isFrench ? 'Intermediaire' : 'Intermediate',
          color: AppColors.warning,
        );
      case DifficultyLevel.advanced:
        return (
          label: isFrench ? 'Avance' : 'Advanced',
          color: AppColors.error,
        );
    }
  }
}

class _ExerciseMedia extends StatelessWidget {
  final String url;

  const _ExerciseMedia({required this.url});

  @override
  Widget build(BuildContext context) {
    final String trimmed = url.trim();

    if (trimmed.isEmpty) {
      return const _MissingExerciseMedia();
    }

    if (trimmed.startsWith('assets/')) {
      return Image.asset(
        trimmed,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _MissingExerciseMedia(),
      );
    }

    return Image.network(
      trimmed,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const _MissingExerciseMedia(),
    );
  }
}

class _MissingExerciseMedia extends StatelessWidget {
  const _MissingExerciseMedia();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryAbyss,
      alignment: Alignment.center,
      child: const Icon(
        Icons.fitness_center_rounded,
        color: AppColors.background,
        size: 56,
      ),
    );
  }
}
