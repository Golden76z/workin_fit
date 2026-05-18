import 'package:flutter/material.dart';
import 'package:flutter_body_atlas/flutter_body_atlas.dart' as atlas;
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/app_opacity.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/features/workout/data/muscle_atlas_mapper.dart';
import 'package:workin_fit/models/muscle_activation.dart';
import 'package:workin_fit/models/enums.dart';

/// Interactive muscle diagram with activation shading (levels 1–3).
/// Front and back views are shown side by side.
class ExerciseMuscleAtlas extends StatelessWidget {
  final Map<MuscleGroup, int> muscleActivation;
  final bool isFrench;

  const ExerciseMuscleAtlas({
    required this.muscleActivation,
    required this.isFrench,
    super.key,
  });

  Map<atlas.MuscleInfo, Color> _colorMapping() {
    final Map<atlas.MuscleInfo, Color> mapping = <atlas.MuscleInfo, Color>{};
    muscleActivation.forEach((MuscleGroup group, int level) {
      final Color color = MuscleActivationLevel.highlightColor(level);
      for (final atlas.MuscleInfo info
          in MuscleAtlasMapper.musclesForGroup(group)) {
        mapping[info] = color;
      }
    });
    return mapping;
  }

  @override
  Widget build(BuildContext context) {
    final Map<atlas.MuscleInfo, Color> colorMapping = _colorMapping();
    final String frontLabel = isFrench ? 'Face' : 'Front';
    final String backLabel = isFrench ? 'Dos' : 'Back';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: AppSizes.exerciseMuscleAtlasHeight,
          child: Stack(
            children: <Widget>[
              ColoredBox(
                color: AppColors.mediaCanvas,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: _AtlasPanel(
                        label: frontLabel,
                        view: atlas.AtlasAsset.musclesFront,
                        colorMapping: colorMapping,
                      ),
                    ),
                    Container(
                      width: 1,
                      color: Colors.white.withValues(alpha: AppOpacity.faint),
                    ),
                    Expanded(
                      child: _AtlasPanel(
                        label: backLabel,
                        view: atlas.AtlasAsset.musclesBack,
                        colorMapping: colorMapping,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: AppExerciseDetailLayout.cardPadding,
                bottom: AppExerciseDetailLayout.atlasDiagramFeetInset,
                child: _ActivationLegend(isFrench: isFrench),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppExerciseDetailLayout.atlasAttributionPaddingH,
            AppExerciseDetailLayout.atlasAttributionGapTop,
            AppExerciseDetailLayout.atlasAttributionPaddingH,
            AppExerciseDetailLayout.atlasFooterPaddingBottom,
          ),
          child: Text(
            isFrench
                ? 'Schéma musculaire © Ryan Graves (CC BY 4.0)'
                : 'Muscle diagram © Ryan Graves (CC BY 4.0)',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: AppOpacity.moderate),
              fontSize: 10,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _AtlasPanel extends StatelessWidget {
  final String label;
  final atlas.AtlasAsset view;
  final Map<atlas.MuscleInfo, Color> colorMapping;

  const _AtlasPanel({
    required this.label,
    required this.view,
    required this.colorMapping,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xxs,
              right: AppSpacing.xxs,
              bottom: AppExerciseDetailLayout.atlasDiagramFeetInset,
            ),
            child: atlas.BodyAtlasView<atlas.MuscleInfo>(
              view: view,
              resolver: const atlas.MuscleResolver(),
              colorMapping: colorMapping,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivationLegend extends StatelessWidget {
  final bool isFrench;

  const _ActivationLegend({required this.isFrench});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.mediaCanvas.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(AppExerciseDetailLayout.chipRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            isFrench ? 'Intensité' : 'Intensity',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          for (final int level in <int>[3, 2, 1])
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: MuscleActivationLevel.highlightColor(level),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$level',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
