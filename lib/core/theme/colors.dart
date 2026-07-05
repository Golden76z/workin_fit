import 'package:flutter/material.dart';

class AppColors {
  // ── Brand scale — light → deep (no color-name labels) ────────────────────
  static const Color brand50 = Color(0xFFF1EAFF); // lightest tint
  static const Color brand100 = Color(0xFFD8C9FF); // light
  static const Color brand200 = Color(0xFF5E2BFF); // main accent
  static const Color brand300 = Color(0xFF4E25D9); // secondary
  static const Color brand400 = Color(0xFF401EAE); // deeper
  static const Color brand500 = Color(0xFF331886); // deep
  static const Color brand600 = Color(0xFF260F63); // darkest

  // ── Neutral scale — near-black → near-white (no color-name labels) ────────
  static const Color neutral0 = Color(0xFF0A0914); // page background
  static const Color neutral100 = Color(0xFF161426); // card surface
  static const Color neutral200 = Color(0xFF0F0E1A); // surface variant
  static const Color neutral300 = Color(0xFF262438); // elevated / borders
  static const Color neutral400 = Color(0xFF535170); // tertiary / disabled
  static const Color neutral500 = Color(0xFF8F8DA8); // secondary text
  static const Color neutral600 = Color(0xFFECEBFA); // primary text

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
  static const Color lightPrimaryLight = Color(0xFF7C67D8);
  static const Color lightPrimaryPastel = Color(0xFF2E2A3A);
  static const Color lightAccent = brand300;
  static const Color lightAccentLight = Color(0xFF6659A8);
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
  static const Color darkPrimaryLight = Color(0xFF7C67D8);
  static const Color darkPrimaryPastel = Color(0xFF2E2A3A);
  static const Color darkAccent = brand300;
  static const Color darkAccentLight = Color(0xFF6659A8);
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
  static const Color primaryLight = Color(0xFF7C67D8);
  static const Color primaryPastel = Color(0xFF2E2A3A);
  static const Color accent = brand300;
  static const Color accentLight = Color(0xFF6659A8);
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
  static const Color navCenterButtonSelected = primary;
  static const Color navCenterButtonUnselected = primaryDark;
  static const Color navCenterButtonBorder = textPrimary;
  static const Color navCenterButtonIcon = textPrimary;
  static const Color navCenterButtonShadow = primaryDark;

  // Keep old non-brand colour names referenced in a couple of places
  static const Color nearBlack = neutral0;
  static const Color steelGray = neutral300;
  static const Color snowWhite = neutral600;

  /// Near-black canvas behind exercise media (movement GIF, muscle atlas).
  static const Color mediaCanvas = neutral0;
}
