import 'package:flutter/material.dart';

class AppColors {
  // Brand Palette — indigo-blue scale from deep to pale
  static const Color electricSapphire = Color(0xFF5465FF); // deep electric blue
  static const Color cornflowerBlue = Color(0xFF788BFF);   // medium blue-purple
  static const Color babyBlueIce = Color(0xFF9BB1FF);      // soft blue
  static const Color pearlBlue = Color(0xFFBFD7FF);        // pale blue
  static const Color frostedCyan = Color(0xFFE2FDFF);      // near-white ice blue

  // Light Theme Palette
  static const Color lightPrimary = electricSapphire;
  static const Color lightPrimaryDark = Color(0xFF4252E6);
  static const Color lightPrimaryDarker = Color(0xFF3340B8);
  static const Color lightPrimaryDarkest = Color(0xFF252F8A);
  static const Color lightPrimaryAbyss = Color(0xFF171E57);
  static const Color lightPrimaryLight = cornflowerBlue;
  static const Color lightPrimaryPastel = pearlBlue;
  static const Color lightAccent = babyBlueIce;
  static const Color lightAccentLight = pearlBlue;
  static const Color lightBackground = frostedCyan;
  static const Color lightSurface = Color(0xFFFDFEFF);
  static const Color lightSurfaceVariant = Color(0xFFF1FAFF);
  static const Color lightTextPrimary = Color(0xFF1D275E);
  static const Color lightTextSecondary = Color(0xFF4D5FAF);
  static const Color lightTextTertiary = cornflowerBlue;

  // Dark Theme Palette (kept for future theme toggle)
  static const Color darkPrimary = cornflowerBlue;
  static const Color darkPrimaryDark = electricSapphire;
  static const Color darkPrimaryDarker = Color(0xFF4252E6);
  static const Color darkPrimaryDarkest = Color(0xFF3340B8);
  static const Color darkPrimaryAbyss = Color(0xFF151C4F);
  static const Color darkPrimaryLight = babyBlueIce;
  static const Color darkPrimaryPastel = pearlBlue;
  static const Color darkAccent = babyBlueIce;
  static const Color darkAccentLight = pearlBlue;
  static const Color darkBackground = Color(0xFF0D1233);
  static const Color darkSurface = Color(0xFF141B42);
  static const Color darkSurfaceVariant = Color(0xFF1C2557);
  static const Color darkTextPrimary = frostedCyan;
  static const Color darkTextSecondary = pearlBlue;
  static const Color darkTextTertiary = cornflowerBlue;

  // Active Palette (currently light mode)
  static const Color primary = lightPrimary;
  static const Color primaryDark = lightPrimaryDark;
  static const Color primaryDarker = lightPrimaryDarker;
  static const Color primaryDarkest = lightPrimaryDarkest;
  static const Color primaryAbyss = lightPrimaryAbyss;
  static const Color primaryLight = lightPrimaryLight;
  static const Color primaryPastel = lightPrimaryPastel;
  static const Color accent = lightAccent;
  static const Color accentLight = lightAccentLight;
  static const Color background = lightBackground;
  static const Color surface = lightSurface;
  static const Color surfaceVariant = lightSurfaceVariant;
  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color textTertiary = lightTextTertiary;

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successSoft = Color(0xFF81C784); // lighter green
  static const Color error = Color(0xFFF44336);
  static const Color errorSoft = Color(0xFFE57373); // lighter red
  static const Color warning = Color(0xFFFF9800);
  static const Color warningSoft = Color(0xFFFFB74D); // lighter orange
  static const Color info = Color(0xFF2196F3);

  // Navigation surfaces — primary blue at 70 % opacity, matches top chrome tone.
  static const Color navBarSurface = Color(0xB35465FF);
}
