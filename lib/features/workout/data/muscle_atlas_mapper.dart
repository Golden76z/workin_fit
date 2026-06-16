import 'package:flutter_body_atlas/flutter_body_atlas.dart' as atlas;
import 'package:workin_fit/models/enums.dart';

/// Maps app [MuscleGroup] values to [atlas.MuscleInfo] regions for highlighting.
abstract final class MuscleAtlasMapper {
  static bool prefersBackView(Iterable<MuscleGroup> groups) {
    const Set<MuscleGroup> backHeavy = <MuscleGroup>{
      MuscleGroup.back,
      MuscleGroup.hamstrings,
      MuscleGroup.glutes,
      MuscleGroup.lowerBack,
    };
    const Set<MuscleGroup> frontHeavy = <MuscleGroup>{
      MuscleGroup.chest,
      MuscleGroup.abs,
      MuscleGroup.biceps,
      MuscleGroup.quads,
    };
    int backScore = 0;
    int frontScore = 0;
    for (final MuscleGroup group in groups) {
      if (backHeavy.contains(group)) backScore++;
      if (frontHeavy.contains(group)) frontScore++;
    }
    return backScore >= frontScore;
  }

  static bool hasDrawableMuscles(Iterable<MuscleGroup> groups) {
    return groups.any((MuscleGroup g) => g != MuscleGroup.cardio);
  }

  static Iterable<atlas.MuscleInfo> musclesForGroup(MuscleGroup group) {
    if (group == MuscleGroup.cardio) return const <atlas.MuscleInfo>[];

    bool idHas(atlas.MuscleInfo info, String fragment) =>
        info.id.contains(fragment);

    switch (group) {
      case MuscleGroup.chest:
        return atlas.MuscleCatalog.chest;
      case MuscleGroup.shoulders:
        return atlas.MuscleCatalog.shoulders.where(
          (atlas.MuscleInfo info) =>
              idHas(info, 'deltoid') || idHas(info, 'trapezius'),
        );
      case MuscleGroup.triceps:
        return atlas.MuscleCatalog.arms.where(
          (atlas.MuscleInfo info) => idHas(info, 'triceps'),
        );
      case MuscleGroup.biceps:
        return atlas.MuscleCatalog.arms.where(
          (atlas.MuscleInfo info) => idHas(info, 'biceps'),
        );
      case MuscleGroup.forearms:
        return atlas.MuscleCatalog.arms.where(
          (atlas.MuscleInfo info) =>
              !idHas(info, 'triceps') && !idHas(info, 'biceps'),
        );
      case MuscleGroup.back:
        return <atlas.MuscleInfo>[
          ...atlas.MuscleCatalog.back,
          ...atlas.MuscleCatalog.shoulders.where(
            (atlas.MuscleInfo info) => idHas(info, 'trapezius_middle'),
          ),
        ];
      case MuscleGroup.lowerBack:
        return atlas.MuscleCatalog.shoulders.where(
          (atlas.MuscleInfo info) => idHas(info, 'trapezius_lower'),
        );
      case MuscleGroup.quads:
        return atlas.MuscleCatalog.legs.where(
          (atlas.MuscleInfo info) =>
              idHas(info, 'rectus_femoris') ||
              idHas(info, 'vastus_') ||
              idHas(info, 'sartoris'),
        );
      case MuscleGroup.hamstrings:
        return atlas.MuscleCatalog.hamstrings;
      case MuscleGroup.calves:
        return atlas.MuscleCatalog.legs.where(
          (atlas.MuscleInfo info) =>
              idHas(info, 'gastrocnemius') ||
              idHas(info, 'tibialis') ||
              idHas(info, 'fibularis') ||
              idHas(info, 'extensor_hallucis') ||
              idHas(info, 'extensor_digitorum_longus'),
        );
      case MuscleGroup.glutes:
        return atlas.MuscleCatalog.glutes;
      case MuscleGroup.abs:
        return atlas.MuscleCatalog.core.where(
          (atlas.MuscleInfo info) => idHas(info, 'rectus_abdominis'),
        );
      case MuscleGroup.obliques:
        return atlas.MuscleCatalog.core.where(
          (atlas.MuscleInfo info) => idHas(info, 'external_oblique'),
        );
      case MuscleGroup.cardio:
        return const <atlas.MuscleInfo>[];
    }
  }
}
