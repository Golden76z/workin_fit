import 'package:flutter/material.dart';
import 'package:workin_fit/core/theme/app_chrome.dart';
import 'package:workin_fit/core/theme/app_difficulty.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/features/workout/data/muscle_atlas_mapper.dart';
import 'package:workin_fit/models/muscle_activation.dart';
import 'package:workin_fit/features/workout/presentation/utils/exercise_ui_helpers.dart';
import 'package:workin_fit/features/workout/presentation/widgets/exercise_movement_thumbnail.dart';
import 'package:workin_fit/features/workout/presentation/widgets/exercise_muscle_atlas.dart';
import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/exercise_localization.dart';
import 'package:workin_fit/core/theme/app_opacity.dart';

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
    final Map<MuscleGroup, int> muscleActivation =
        exercise.resolvedMuscleActivation;
    final bool showMuscleAtlas =
        MuscleAtlasMapper.hasDrawableMuscles(exercise.muscleGroups);

    return AppSystemOverlayRegion(
      style: AppChrome.topAndBottomOverlay,
      child: Scaffold(
        backgroundColor: AppColors.surfaceVariant,
        extendBody: true,
        bottomNavigationBar: const AppBottomInsetSurface(),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              systemOverlayStyle: AppChrome.topSurfaceOverlay,
              flexibleSpace: const AppTopBarBackground(),
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
                  padding: const EdgeInsets.only(
                    right: AppExerciseDetailLayout.screenPadding,
                  ),
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
                  AppExerciseDetailLayout.screenPadding,
                  AppExerciseDetailLayout.screenPadding,
                  AppExerciseDetailLayout.screenPadding,
                  AppExerciseDetailLayout.screenPaddingBottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // 1. Groupes musculaires + muscle image
                    _SectionCard(
                      icon: Icons.sports_gymnastics_rounded,
                      title: isFrench ? 'Groupes musculaires' : 'Muscle Groups',
                      fullWidthBottom: showMuscleAtlas
                          ? ExerciseMuscleAtlas(
                              muscleActivation: muscleActivation,
                              isFrench: isFrench,
                            )
                          : _SectionImage(
                              imageUrl: exercise.imageMuscleUrl,
                              label: isFrench
                                  ? 'Muscles ciblés'
                                  : 'Targeted Muscles',
                            ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          alignment: WrapAlignment.center,
                          runAlignment: WrapAlignment.center,
                          children: muscleActivation.entries
                            .map(
                              (MapEntry<MuscleGroup, int> entry) =>
                                  _MuscleChip(
                                label: muscleGroupLabel(entry.key, isFrench),
                                level: entry.value,
                              ),
                            )
                            .toList(growable: false),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppExerciseDetailLayout.sectionGap),

                    // 2. Description du mouvement + tutorial image
                    _SectionCard(
                      icon: Icons.menu_book_rounded,
                      title: isFrench
                          ? 'Description du mouvement'
                          : 'Movement Description',
                      fullWidthBottom: _SectionImage(
                        imageUrl: exercise.imageTutorialUrl,
                        exerciseId: exercise.id,
                        label: isFrench ? 'Mouvement' : 'Movement',
                        heroTag: exercise.imageTutorialUrl.isNotEmpty
                            ? 'exercise-img-${exercise.imageTutorialUrl}'
                            : 'exercise-img-${exercise.id}',
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
                    const SizedBox(height: AppExerciseDetailLayout.sectionGap),

                    // 5. Comment effectuer
                    _SectionCard(
                      icon: Icons.checklist_rounded,
                      title: isFrench ? 'Comment effectuer' : 'How to Perform',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildHowToSteps(isFrench: isFrench)
                            .asMap()
                            .entries
                            .map(
                              (MapEntry<int, String> e) =>
                                  _StepRow(number: e.key + 1, text: e.value),
                            )
                            .toList(growable: false),
                      ),
                    ),
                    const SizedBox(height: AppExerciseDetailLayout.sectionGap),

                    // 6. Conseils débutant
                    _TipsCallout(
                      title: isFrench ? 'Conseils débutant' : 'Beginner Tips',
                      text: _tipsFallback(
                        tips: localizedTips,
                        isFrench: isFrench,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.paddingOf(context).bottom +
                          AppExerciseDetailLayout.screenPadding,
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

  String _tipsFallback({required String? tips, required bool isFrench}) {
    final String value = tips?.trim() ?? '';
    if (value.isNotEmpty) return value;
    return isFrench
        ? 'Concentre-toi sur un mouvement lent et propre. Garde une respiration régulière et arrête-toi si tu perds la posture.'
        : 'Move slowly with control, keep breathing regularly, and stop if your form starts to break.';
  }

  /// Actionable cues only — not parsed from [localizedDescription] (that block is
  /// an overview shown above under Movement Description).
  List<String> _buildHowToSteps({required bool isFrench}) {
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
      color: AppColors.mediaCanvas,
      elevation: 2,
      shadowColor: AppColors.primary.withValues(alpha: AppOpacity.whisper),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppExerciseDetailLayout.cardRadius),
        side: const BorderSide(color: AppColors.neutral300, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppExerciseDetailLayout.cardHeaderPaddingH,
              vertical: AppExerciseDetailLayout.cardHeaderPaddingV,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: AppOpacity.faint),
                  width: 2,
                ),
              ),
            ),
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
            padding: const EdgeInsets.all(AppExerciseDetailLayout.cardPadding),
            child: child,
          ),
          if (fullWidthBottom != null) ...<Widget>[
            Container(
              height: 2,
              color: Colors.white.withValues(alpha: AppOpacity.faint),
            ),
            fullWidthBottom!,
          ],
        ],
      ),
    );
  }
}

// ─── Section image ────────────────────────────────────────────────────────────

class _SectionImage extends StatelessWidget {
  final String imageUrl;
  final String? exerciseId;
  final String label;
  final String? heroTag;

  const _SectionImage({
    required this.imageUrl,
    required this.label,
    this.exerciseId,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final Widget media = SizedBox(
      height: 200,
      width: double.infinity,
      child: _ExerciseMedia(
        imageUrl: imageUrl,
        exerciseId: exerciseId ?? '',
      ),
    );

    return Stack(
      children: <Widget>[
        heroTag != null ? Hero(tag: heroTag!, child: media) : media,
        Positioned(
          left: AppExerciseDetailLayout.cardPadding,
          bottom: AppExerciseDetailLayout.cardPadding,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: AppColors.mediaCanvas.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(
                AppExerciseDetailLayout.mediaLabelRadius,
              ),
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
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
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
              borderRadius: BorderRadius.circular(6),
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
      padding: const EdgeInsets.all(AppExerciseDetailLayout.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppExerciseDetailLayout.tipsRadius),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: AppOpacity.faint),
        ),
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
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'AppFontMedium',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
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
  final int level;

  const _MuscleChip({required this.label, required this.level});

  @override
  Widget build(BuildContext context) {
    final Color accent = MuscleActivationLevel.highlightColor(
      level,
      base: AppColors.primaryLight,
    );
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: AppOpacity.whisper),
        borderRadius: BorderRadius.circular(AppExerciseDetailLayout.chipRadius),
        border: Border.all(
          color: accent.withValues(alpha: AppOpacity.firm),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$level',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
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
    final bool isFrench = locale.languageCode.toLowerCase().startsWith('fr');
    return AppDifficultyBadge(
      difficulty: difficulty,
      isFrench: isFrench,
      borderRadius: const BorderRadius.all(
        Radius.circular(AppDifficultyTheme.pillRadius),
      ),
    );
  }
}

// ─── Exercise media ───────────────────────────────────────────────────────────

class _ExerciseMedia extends StatelessWidget {
  final String imageUrl;
  final String exerciseId;

  const _ExerciseMedia({
    required this.imageUrl,
    required this.exerciseId,
  });

  @override
  Widget build(BuildContext context) {
    return ExerciseMovementThumbnail(
      exerciseId: exerciseId,
      imageUrl: imageUrl,
      placeholder: const ColoredBox(
        color: AppColors.mediaCanvas,
        child: Center(
          child: Icon(
            Icons.fitness_center_rounded,
            color: AppColors.frostedCyan,
            size: 56,
          ),
        ),
      ),
    );
  }
}

// ─── Nav bar fill ─────────────────────────────────────────────────────────────

// Physically paints the same 70 % primary-blue tone as the SliverAppBar into
// the system nav-bar inset area, so top and bottom chrome match exactly.