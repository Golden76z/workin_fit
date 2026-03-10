import 'package:flutter/material.dart';
import 'package:workin_fit/core/theme/app_chrome.dart';
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

  static Route<void> route({required Exercise exercise}) {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) =>
          ExerciseDetailScreen(exercise: exercise),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideCurve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        final fadeCurve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutQuart,
          reverseCurve: Curves.easeInQuart,
        );
        return FadeTransition(
          opacity: fadeCurve,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(slideCurve),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final bool isFrench = locale.languageCode.toLowerCase().startsWith('fr');
    final String localizedName = exercise.getLocalizedName(context);
    final String localizedDescription =
        exercise.getLocalizedDescription(context);
    final String? localizedTips = exercise.getLocalizedBeginnerTips(context);

    return AppSystemOverlayRegion(
      style: AppChrome.topAndBottomOverlay,
      child: Scaffold(
        backgroundColor: AppColors.surfaceVariant,
        extendBody: true,
        bottomNavigationBar: const _NavBarFill(),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              backgroundColor: AppChrome.topSurface,
              surfaceTintColor: Colors.transparent,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text(
                localizedName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'AppFontMedium',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: Center(
                    child: _DifficultyBadge(
                      difficulty: exercise.difficulty,
                      locale: locale,
                    ),
                  ),
                ),
              ],
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
                    // 1. Groupes musculaires + muscle image
                    _SectionCard(
                      icon: Icons.sports_gymnastics_rounded,
                      title: isFrench
                          ? 'Groupes musculaires'
                          : 'Muscle Groups',
                      fullWidthBottom: _SectionImage(
                        imageUrl: exercise.imageMuscleUrl,
                        label: isFrench ? 'Muscles ciblés' : 'Targeted Muscles',
                      ),
                      child: Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        alignment: WrapAlignment.center,
                        children: exercise.muscleGroups
                            .map(
                              (MuscleGroup g) =>
                                  _MuscleChip(label: _muscleLabel(g, isFrench)),
                            )
                            .toList(growable: false),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // 2. Description du mouvement + tutorial image
                    _SectionCard(
                      icon: Icons.menu_book_rounded,
                      title: isFrench
                          ? 'Description du mouvement'
                          : 'Movement Description',
                      fullWidthBottom: _SectionImage(
                        imageUrl: exercise.imageTutorialUrl,
                        label: isFrench ? 'Mouvement' : 'Movement',
                      ),
                      child: Text(
                        localizedDescription,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                          height: 1.55,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // 5. Comment effectuer
                    _SectionCard(
                      icon: Icons.checklist_rounded,
                      title:
                          isFrench ? 'Comment effectuer' : 'How to Perform',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildHowToSteps(
                          description: localizedDescription,
                          isFrench: isFrench,
                        )
                            .asMap()
                            .entries
                            .map(
                              (MapEntry<int, String> e) =>
                                  _StepRow(number: e.key + 1, text: e.value),
                            )
                            .toList(growable: false),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // 6. Conseils débutant
                    _TipsCallout(
                      title: isFrench ? 'Conseils débutant' : 'Beginner Tips',
                      text: _tipsFallback(
                        tips: localizedTips,
                        isFrench: isFrench,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Start button
                    SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () => _startExercise(context),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text(
                          isFrench
                              ? "Démarrer l'exercice"
                              : 'Start Exercise',
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
                            borderRadius:
                                BorderRadius.circular(AppRadii.lg),
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
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void _startExercise(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final bool isFrench = locale.languageCode.toLowerCase().startsWith('fr');
    final String localizedName = exercise.getLocalizedName(context);

    final Session quickSession = Session(
      id: 'quick_${exercise.id}_${DateTime.now().millisecondsSinceEpoch}',
      name: isFrench
          ? 'Démarrage rapide - $localizedName'
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

  String _tipsFallback({required String? tips, required bool isFrench}) {
    final String value = tips?.trim() ?? '';
    if (value.isNotEmpty) return value;
    return isFrench
        ? 'Concentre-toi sur un mouvement lent et propre. Garde une respiration régulière et arrête-toi si tu perds la posture.'
        : 'Move slowly with control, keep breathing regularly, and stop if your form starts to break.';
  }

  List<String> _buildHowToSteps({
    required String description,
    required bool isFrench,
  }) {
    final List<String> extracted = description
        .replaceAll('\n', ' ')
        .split(RegExp(r'[.!?]'))
        .map((String s) => s.trim())
        .where((String s) => s.length > 10)
        .take(4)
        .toList(growable: false);

    if (extracted.isNotEmpty) return extracted;

    if (isFrench) {
      return const <String>[
        'Prends une position de départ stable et aligne ton corps.',
        'Contracte le tronc avant chaque répétition.',
        'Exécute le mouvement lentement avec contrôle.',
        'Reviens à la position initiale puis répète.',
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
        return isFrench ? 'Épaules' : 'Shoulders';
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
        return 'Obliques';
      case MuscleGroup.lowerBack:
        return isFrench ? 'Bas du dos' : 'Lower Back';
      case MuscleGroup.cardio:
        return 'Cardio';
    }
  }
}

// ─── Section card ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final Widget? fullWidthBottom;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
    this.fullWidthBottom,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 2,
      shadowColor: AppColors.primary.withValues(alpha: 0.10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Primary-blue header band matching the appbar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            color: AppChrome.topSurface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, size: 17, color: Colors.white),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'AppFontMedium',
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: child,
          ),
          if (fullWidthBottom != null) fullWidthBottom!,
        ],
      ),
    );
  }
}

// ─── Section image ────────────────────────────────────────────────────────────

class _SectionImage extends StatelessWidget {
  final String imageUrl;
  final String label;

  const _SectionImage({required this.imageUrl, required this.label});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SizedBox(
          height: 200,
          width: double.infinity,
          child: _ExerciseMedia(url: imageUrl),
        ),
          Positioned(
            left: AppSpacing.sm,
            bottom: AppSpacing.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryAbyss.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Step row ─────────────────────────────────────────────────────────────────

class _StepRow extends StatelessWidget {
  final int number;
  final String text;

  const _StepRow({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[AppColors.primary, AppColors.cornflowerBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tips callout ─────────────────────────────────────────────────────────────

class _TipsCallout extends StatelessWidget {
  final String title;
  final String text;

  const _TipsCallout({required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.frostedCyan,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.pearlBlue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.lightbulb_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'AppFontMedium',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Muscle chip ──────────────────────────────────────────────────────────────

class _MuscleChip extends StatelessWidget {
  final String label;

  const _MuscleChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Difficulty badge ─────────────────────────────────────────────────────────

class _DifficultyBadge extends StatelessWidget {
  final DifficultyLevel difficulty;
  final Locale locale;

  const _DifficultyBadge({
    required this.difficulty,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFrench =
        locale.languageCode.toLowerCase().startsWith('fr');
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
          label: isFrench ? 'Débutant' : 'Beginner',
          color: AppColors.success,
        );
      case DifficultyLevel.intermediate:
        return (
          label: isFrench ? 'Intermédiaire' : 'Intermediate',
          color: AppColors.warning,
        );
      case DifficultyLevel.advanced:
        return (
          label: isFrench ? 'Avancé' : 'Advanced',
          color: AppColors.error,
        );
    }
  }
}

// ─── Exercise media ───────────────────────────────────────────────────────────

class _ExerciseMedia extends StatelessWidget {
  final String url;

  const _ExerciseMedia({required this.url});

  @override
  Widget build(BuildContext context) {
    final String trimmed = url.trim();

    if (trimmed.isEmpty) return const _MissingExerciseMedia();

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
        color: AppColors.frostedCyan,
        size: 56,
      ),
    );
  }
}

// ─── Nav bar fill ─────────────────────────────────────────────────────────────

// Physically paints the same 70 % primary-blue tone as the SliverAppBar into
// the system nav-bar inset area, so top and bottom chrome match exactly.
class _NavBarFill extends StatelessWidget {
  const _NavBarFill();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.viewPaddingOf(context).bottom,
      child: const ColoredBox(color: AppChrome.topSurface),
    );
  }
}
