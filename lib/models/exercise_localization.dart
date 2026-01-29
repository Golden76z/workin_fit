import 'package:flutter/material.dart';
import 'package:workin_fit/l10n/app_localizations.dart';
import 'package:workin_fit/models/exercise.dart';

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
  /// Returns the stored name (English fallback).
  /// For proper localization, use: `AppLocalizations.of(context)!.exercise_{id}_name`
  String getLocalizedName(BuildContext context) {
    // For now, return stored name as fallback
    // TODO: Implement proper ARB lookup when needed
    return name;
  }

  /// Get localized description
  /// 
  /// Returns the stored description (English fallback).
  /// For proper localization, use: `AppLocalizations.of(context)!.exercise_{id}_description`
  String getLocalizedDescription(BuildContext context) {
    return description;
  }

  /// Get localized beginner tips
  /// 
  /// Returns the stored tips (English fallback).
  /// For proper localization, use: `AppLocalizations.of(context)!.exercise_{id}_beginner_tips`
  String? getLocalizedBeginnerTips(BuildContext context) {
    return beginnerTips;
  }

  /// Get the localization key for the exercise name
  String get nameKey => 'exercise_${id}_name';

  /// Get the localization key for the exercise description
  String get descriptionKey => 'exercise_${id}_description';

  /// Get the localization key for beginner tips (if tips exist)
  String? get beginnerTipsKey => beginnerTips != null ? 'exercise_${id}_beginner_tips' : null;
}
