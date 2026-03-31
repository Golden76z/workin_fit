import 'package:flutter/material.dart';

class AppColors {
  // ── Brand scale — light → deep (no color-name labels) ────────────────────
  static const Color brand50 = Color(0xFFEDE8FF); // lightest tint
  static const Color brand100 = Color(0xFFCFC6FF); // light
  static const Color brand200 = Color(0xFFAF99FF); // main accent
  static const Color brand300 = Color(0xFF9178F8); // secondary
  static const Color brand400 = Color(0xFF7355EE); // deeper
  static const Color brand500 = Color(0xFF5535D4); // deep
  static const Color brand600 = Color(0xFF3A1EAA); // darkest

  // ── Neutral scale — near-black → near-white (no color-name labels) ────────
  static const Color neutral0 = Color(0xFF111111); // page background
  static const Color neutral100 = Color(0xFF1C1C1C); // card surface
  static const Color neutral200 = Color(0xFF242424); // surface variant
  static const Color neutral300 = Color(0xFF2E2E2E); // elevated / borders
  static const Color neutral400 = Color(0xFF5A5A5A); // tertiary / disabled
  static const Color neutral500 = Color(0xFFAAAAAA); // secondary text
  static const Color neutral600 = Color(0xFFF0F0F0); // primary text

  // ── Backward-compatible brand aliases ─────────────────────────────────────
  // Old blue-scale names repointed to equivalent visual roles in the new
  // palette. All existing call sites compile without changes.
  static const Color electricSapphire = brand200;
  static const Color cornflowerBlue = brand300;
  static const Color babyBlueIce = neutral300;
  static const Color pearlBlue = neutral200;
  static const Color frostedCyan = neutral600;

  // ── Light Theme Palette ───────────────────────────────────────────────────
  static const Color lightPrimary = brand200;
  static const Color lightPrimaryDark = brand300;
  static const Color lightPrimaryDarker = brand400;
  static const Color lightPrimaryDarkest = brand500;
  static const Color lightPrimaryAbyss = brand600;
  static const Color lightPrimaryLight = brand100;
  static const Color lightPrimaryPastel = brand50;
  static const Color lightAccent = brand300;
  static const Color lightAccentLight = Color(0xFFFFCC80);
  static const Color lightBackground = neutral0;
  static const Color lightSurface = neutral100;
  static const Color lightSurfaceVariant = neutral200;
  static const Color lightTextPrimary = neutral600;
  static const Color lightTextSecondary = neutral500;
  static const Color lightTextTertiary = neutral400;

  // ── Dark Theme Palette ────────────────────────────────────────────────────
  static const Color darkPrimary = brand200;
  static const Color darkPrimaryDark = brand300;
  static const Color darkPrimaryDarker = brand400;
  static const Color darkPrimaryDarkest = brand500;
  static const Color darkPrimaryAbyss = brand600;
  static const Color darkPrimaryLight = brand100;
  static const Color darkPrimaryPastel = brand50;
  static const Color darkAccent = brand300;
  static const Color darkAccentLight = Color(0xFFFFCC80);
  static const Color darkBackground = neutral0;
  static const Color darkSurface = neutral100;
  static const Color darkSurfaceVariant = neutral200;
  static const Color darkTextPrimary = neutral600;
  static const Color darkTextSecondary = neutral500;
  static const Color darkTextTertiary = neutral400;

  // ── Active Palette ────────────────────────────────────────────────────────
  static const Color primary = brand200;
  static const Color primaryDark = brand300;
  static const Color primaryDarker = brand400;
  static const Color primaryDarkest = brand500;
  static const Color primaryAbyss = brand600;
  static const Color primaryLight = brand100;
  static const Color primaryPastel = brand50;
  static const Color accent = brand300;
  static const Color accentLight = Color(0xFFFFCC80);
  static const Color background = neutral0;
  static const Color surface = neutral100;
  static const Color surfaceVariant = neutral200;
  static const Color textPrimary = neutral600;
  static const Color textSecondary = neutral500;
  static const Color textTertiary = neutral400;

  // ── Semantic Colors ───────────────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color successSoft = Color(0xFF81C784);
  static const Color error = Color(0xFFF44336);
  static const Color errorSoft = Color(0xFFE57373);
  // Warning uses amber — independent of the brand so it stays legible
  // regardless of the brand hue.
  static const Color warning = Color(0xFFFF9800);
  static const Color warningSoft = Color(0xFFFFB74D);
  static const Color info = Color(0xFF29B6F6);

  // ── Award / medal colors ─────────────────────────────────────────────────
  static const Color gold = Color(0xFFFFD700); // gold trophies / medals
  static const Color goldDeep = Color(0xFFFFB300); // gradient deep end
  static const Color goldText = Color(0xFF5C3D00); // text on gold backgrounds
  static const Color silver = Color(0xFFA8A9AD); // silver medals
  static const Color bronze = Color(0xFFCD7F32); // bronze medals

  // ── Navigation surface ────────────────────────────────────────────────────
  // neutral100 at ~91 % opacity so page content subtly bleeds on scroll.
  static const Color navBarSurface = Color(0xE81C1C1C);
  static const Color navCenterButtonSelected = primaryLight;
  static const Color navCenterButtonUnselected = primary;
  static const Color navCenterButtonBorder = textPrimary;
  static const Color navCenterButtonIcon = textPrimary;
  static const Color navCenterButtonShadow = primaryLight;

  // Keep old non-brand colour names referenced in a couple of places
  static const Color nearBlack = neutral0;
  static const Color steelGray = neutral300;
  static const Color snowWhite = neutral600;
}
