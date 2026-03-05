import 'package:flutter/material.dart';
import 'package:workin_fit/l10n/app_localizations.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/exercise_localization_helper.dart';

/// Extension to get localized strings for exercises
///
/// **Note**: For best results, access ARB getters directly:
/// ```dart
/// final localizations = AppLocalizations.of(context)!;
/// Text(localizations.exercise_push_001_name)
/// ```
///
/// This extension provides fallback methods that return stored English text.
/// For proper localization, use the ARB getters directly.
extension ExerciseLocalization on Exercise {
  /// Get localized name
  ///
  /// Uses ARB localization first, then falls back to stored English text.
  String getLocalizedName(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return name;

    return ExerciseLocalizationHelper.getName(localizations, id) ?? name;
  }

  /// Get localized description
  ///
  /// Uses ARB localization first, then falls back to stored English text.
  String getLocalizedDescription(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return description;

    return ExerciseLocalizationHelper.getDescription(localizations, id) ??
        description;
  }

  /// Get localized beginner tips
  ///
  /// Uses ARB localization first, then falls back to stored English tips.
  String? getLocalizedBeginnerTips(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return beginnerTips;

    return ExerciseLocalizationHelper.getBeginnerTips(localizations, id) ??
        beginnerTips;
  }

  /// Get the localization key for the exercise name
  String get nameKey => 'exercise_${id}_name';

  /// Get the localization key for the exercise description
  String get descriptionKey => 'exercise_${id}_description';

  /// Get the localization key for beginner tips (if tips exist)
  String? get beginnerTipsKey =>
      beginnerTips != null ? 'exercise_${id}_beginner_tips' : null;
}
