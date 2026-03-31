/// Shared UI helpers for exercise-related screens.
///
/// Centralises labels, colours, search normalisation, and the difficulty
/// badge widget so [ExerciseListScreen] and [ExercisePickerScreen] don't
/// need to duplicate the same logic.
library;

import 'package:flutter/material.dart';
import 'package:workin_fit/core/theme/app_difficulty.dart';
import 'package:workin_fit/models/enums.dart';

// ── Search normalisation ──────────────────────────────────────────────────────

String exerciseNormalize(String value) {
  String s = value.toLowerCase();
  const Map<String, String> rep = {
    '\u00E0': 'a',
    '\u00E1': 'a',
    '\u00E2': 'a',
    '\u00E4': 'a',
    '\u00E7': 'c',
    '\u00E8': 'e',
    '\u00E9': 'e',
    '\u00EA': 'e',
    '\u00EB': 'e',
    '\u00EE': 'i',
    '\u00EF': 'i',
    '\u00F4': 'o',
    '\u00F6': 'o',
    '\u00F9': 'u',
    '\u00FB': 'u',
    '\u00FC': 'u',
    '\u0153': 'oe',
    "'": ' ',
    '-': ' ',
    '/': ' ',
  };
  rep.forEach((from, to) => s = s.replaceAll(from, to));
  return s.replaceAll(RegExp(r'\s+'), ' ').trim();
}

// ── Muscle helpers ────────────────────────────────────────────────────────────

String muscleGroupLabel(MuscleGroup muscle, bool isFrench) {
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
      return 'Obliques';
    case MuscleGroup.lowerBack:
      return isFrench ? 'Bas du dos' : 'Lower back';
    case MuscleGroup.cardio:
      return 'Cardio';
  }
}

Iterable<String> muscleGroupAliases(MuscleGroup muscle) {
  switch (muscle) {
    case MuscleGroup.chest:
      return const ['pecs', 'pectoraux'];
    case MuscleGroup.shoulders:
      return const ['delts', 'epaules'];
    case MuscleGroup.triceps:
      return const ['triceps'];
    case MuscleGroup.biceps:
      return const ['biceps'];
    case MuscleGroup.back:
      return const ['dorsaux', 'dos'];
    case MuscleGroup.forearms:
      return const ['avant bras', 'forearm'];
    case MuscleGroup.quads:
      return const ['quadriceps', 'cuisses'];
    case MuscleGroup.hamstrings:
      return const ['ischio', 'hamstrings'];
    case MuscleGroup.calves:
      return const ['mollets', 'calves'];
    case MuscleGroup.glutes:
      return const ['fessiers', 'glutes'];
    case MuscleGroup.abs:
      return const ['abdos', 'abdominals'];
    case MuscleGroup.obliques:
      return const ['obliques'];
    case MuscleGroup.lowerBack:
      return const ['lombaires', 'lower back'];
    case MuscleGroup.cardio:
      return const ['cardio'];
  }
}

// ── Difficulty helpers ────────────────────────────────────────────────────────

String difficultyLabel(DifficultyLevel d, bool isFrench) {
  return AppDifficultyTheme.label(d, isFrench: isFrench);
}

/// Shared purple tone for each difficulty level.
Color difficultyColor(DifficultyLevel d) {
  return AppDifficultyTheme.paletteFor(d).accentColor;
}

int difficultyRank(DifficultyLevel d) {
  switch (d) {
    case DifficultyLevel.beginner:
      return 0;
    case DifficultyLevel.intermediate:
      return 1;
    case DifficultyLevel.advanced:
      return 2;
  }
}

// ── Shared widget ─────────────────────────────────────────────────────────────

class ExerciseDifficultyBadge extends StatelessWidget {
  final DifficultyLevel difficulty;
  final bool isFrench;

  const ExerciseDifficultyBadge({
    required this.difficulty,
    required this.isFrench,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppDifficultyBadge(
      difficulty: difficulty,
      isFrench: isFrench,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDifficultyTheme.compactHorizontalPadding,
        vertical: AppDifficultyTheme.compactVerticalPadding,
      ),
      borderRadius: const BorderRadius.all(
        Radius.circular(AppDifficultyTheme.regularRadius),
      ),
      fontSize: AppDifficultyTheme.compactFontSize,
    );
  }
}
