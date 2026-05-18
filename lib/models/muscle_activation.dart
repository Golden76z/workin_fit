import 'package:flutter/material.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/models/enums.dart';

/// Engagement level for a [MuscleGroup] on an exercise (1 = light … 3 = primary).
class MuscleActivationLevel {
  MuscleActivationLevel._();

  static const int min = 1;
  static const int max = 3;

  static int clampLevel(int level) => level.clamp(min, max);

  static double opacityFor(int level) {
    return switch (clampLevel(level)) {
      1 => 0.38,
      2 => 0.68,
      _ => 1.0,
    };
  }

  static Color highlightColor(int level, {Color base = AppColors.primary}) {
    return base.withValues(alpha: opacityFor(level));
  }

  /// Resolves per-group levels from stored map or defaults all [muscleGroups] to 3.
  static Map<MuscleGroup, int> resolve({
    required List<MuscleGroup> muscleGroups,
    Map<String, int>? storedLevels,
  }) {
    if (storedLevels != null && storedLevels.isNotEmpty) {
      final Map<MuscleGroup, int> resolved = <MuscleGroup, int>{};
      for (final MapEntry<String, int> entry in storedLevels.entries) {
        final MuscleGroup? group = _groupFromName(entry.key);
        if (group == null) continue;
        resolved[group] = clampLevel(entry.value);
      }
      if (resolved.isNotEmpty) return resolved;
    }
    return <MuscleGroup, int>{
      for (final MuscleGroup group in muscleGroups) group: max,
    };
  }

  static MuscleGroup? _groupFromName(String name) {
    for (final MuscleGroup group in MuscleGroup.values) {
      if (group.name == name) return group;
    }
    return null;
  }

  static Map<String, int> toStoredMap(Map<MuscleGroup, int>? levels) {
    if (levels == null || levels.isEmpty) return <String, int>{};
    return <String, int>{
      for (final MapEntry<MuscleGroup, int> entry in levels.entries)
        entry.key.name: clampLevel(entry.value),
    };
  }
}
