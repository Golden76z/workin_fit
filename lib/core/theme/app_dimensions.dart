import 'package:flutter/material.dart';

class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

class AppRadii {
  static const double sm = 8;
  static const double md = 10;
  static const double lg = 12;
  static const double xl = 16;
}

class AppSizes {
  static const Size buttonMinimum = Size(250, 0);

  // Workout execution layout
  static const double workoutTimerDiameter = 220;
  static const double workoutTimerStroke = 14;
  static const double workoutCurrentImageHeight = 190;
  static const double workoutNextImageSize = 66;
  static const double workoutBottomBarHeight = 72;
  static const double workoutControlButtonHeight = 50;

  // Exercise detail — on-screen slots (logical pixels)
  static const double exerciseMovementMediaHeight = 200;
  static const double exerciseMuscleAtlasHeight = 320;

  /// Recommended movement GIF export size (16:9, ~3× phone width).
  static const int exerciseMovementAssetWidth = 1080;
  static const int exerciseMovementAssetHeight = 608;

  /// Recommended muscle atlas panel export (one half of the row).
  static const int exerciseMuscleAtlasPanelWidth = 540;
  static const int exerciseMuscleAtlasPanelHeight = 780;
}

class AppLayout {
  /// Consistent horizontal margin applied to all list / content views.
  static const double pageMargin = AppSpacing.xs;
}

/// Tighter spacing and radii for [ExerciseDetailScreen].
abstract final class AppExerciseDetailLayout {
  static const double screenPadding = AppSpacing.sm;
  static const double screenPaddingBottom = AppSpacing.lg;
  static const double sectionGap = AppSpacing.sm;
  static const double cardRadius = AppRadii.sm;
  static const double cardPadding = AppSpacing.sm;
  static const double cardHeaderPaddingH = AppSpacing.sm;
  static const double cardHeaderPaddingV = AppSpacing.xs;
  static const double chipRadius = AppRadii.sm;
  static const double mediaLabelRadius = AppRadii.sm;
  static const double tipsRadius = AppRadii.sm;
  static const double atlasAttributionPaddingH = AppSpacing.xs;
  /// Inset so feet do not sit on the bottom edge of the diagram canvas.
  static const double atlasDiagramFeetInset = AppSpacing.md;
  /// Gap between the black diagram canvas and the copyright line.
  static const double atlasAttributionGapTop = AppSpacing.sm;
  static const double atlasFooterPaddingBottom = AppSpacing.md;
}

class AppDurations {
  static const Duration snackBar = Duration(seconds: 4);
}
