import 'package:flutter/material.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/app_opacity.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/models/enums.dart';

class AppDifficultyTheme {
  AppDifficultyTheme._();

  static const AppDifficultyPalette beginner = AppDifficultyPalette(
    accentColor: Color(0xFF10B981), // Emerald Green
    foregroundColor: Color(0xFF10B981),
  );

  static const AppDifficultyPalette intermediate = AppDifficultyPalette(
    accentColor: Color(0xFFFFA000), // Amber
    foregroundColor: Color(0xFFFFA000),
  );

  static const AppDifficultyPalette advanced = AppDifficultyPalette(
    accentColor: Color(0xFFFF2D55), // Red/Pink
    foregroundColor: Color(0xFFFF2D55),
  );

  static const double badgeBackgroundOpacity = AppOpacity.light;
  static const double badgeBorderOpacity = AppOpacity.moderate;
  static const double selectedSurfaceOpacity = AppOpacity.muted;
  static const double compactHorizontalPadding = AppSpacing.xs;
  static const double compactVerticalPadding = AppSpacing.xxs / 2;
  static const double regularHorizontalPadding = AppSpacing.sm;
  static const double regularVerticalPadding = AppSpacing.xs;
  static const double compactFontSize = 10;
  static const double regularFontSize = 12;
  static const double compactRadius = AppSpacing.xxs;
  static const double regularRadius = compactRadius;
  static const double pillRadius = AppRadii.sm;
  static const double selectedBorderWidth = 1.6;
  static const double unselectedBorderWidth = 1.0;

  static AppDifficultyPalette paletteFor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return beginner;
      case DifficultyLevel.intermediate:
        return intermediate;
      case DifficultyLevel.advanced:
        return advanced;
    }
  }

  static String label(
    DifficultyLevel difficulty, {
    required bool isFrench,
  }) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return isFrench ? 'Débutant' : 'Beginner';
      case DifficultyLevel.intermediate:
        return isFrench ? 'Intermédiaire' : 'Intermediate';
      case DifficultyLevel.advanced:
        return isFrench ? 'Avancé' : 'Advanced';
    }
  }
}

class AppDifficultyPalette {
  final Color accentColor;
  final Color foregroundColor;

  const AppDifficultyPalette({
    required this.accentColor,
    required this.foregroundColor,
  });

  Color backgroundColor({
    double alpha = AppDifficultyTheme.badgeBackgroundOpacity,
  }) {
    return accentColor.withValues(alpha: alpha);
  }

  Color borderColor({
    double alpha = AppDifficultyTheme.badgeBorderOpacity,
  }) {
    return accentColor.withValues(alpha: alpha);
  }
}

class AppDifficultyBadge extends StatelessWidget {
  final DifficultyLevel difficulty;
  final bool isFrench;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;
  final double fontSize;
  final FontWeight fontWeight;
  final double backgroundAlpha;
  final double borderAlpha;

  const AppDifficultyBadge({
    required this.difficulty,
    required this.isFrench,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppDifficultyTheme.regularHorizontalPadding,
      vertical: AppDifficultyTheme.regularVerticalPadding,
    ),
    this.borderRadius = const BorderRadius.all(
      Radius.circular(100.0),
    ),
    this.fontSize = AppDifficultyTheme.regularFontSize,
    this.fontWeight = FontWeight.w700,
    this.backgroundAlpha = AppDifficultyTheme.badgeBackgroundOpacity,
    this.borderAlpha = AppDifficultyTheme.badgeBorderOpacity,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final AppDifficultyPalette palette =
        AppDifficultyTheme.paletteFor(difficulty);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: palette.backgroundColor(alpha: backgroundAlpha),
        borderRadius: borderRadius,
        border: Border.all(
          color: palette.borderColor(alpha: borderAlpha),
        ),
      ),
      child: Text(
        AppDifficultyTheme.label(difficulty, isFrench: isFrench),
        style: TextStyle(
          color: palette.foregroundColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}
