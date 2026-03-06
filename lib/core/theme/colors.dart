import 'package:flutter/material.dart';

class AppColors {
  // Brand Palette
  static const Color crushedBerry = Color(0xFF5465FF); // Electric Sapphire
  static const Color raspberry = Color(0xFF788BFF); // Cornflower Blue
  static const Color bubblegumPink = Color(0xFF9BB1FF); // Baby Blue Ice
  static const Color pinkMist = Color(0xFFBFD7FF); // Periwinkle
  static const Color lightCyan = Color(0xFFE2FDFF); // Light Cyan

  // Light Theme Palette
  static const Color lightPrimary = crushedBerry;
  static const Color lightPrimaryDark = Color(0xFF4252E6);
  static const Color lightPrimaryDarker = Color(0xFF3340B8);
  static const Color lightPrimaryDarkest = Color(0xFF252F8A);
  static const Color lightPrimaryAbyss = Color(0xFF171E57);
  static const Color lightPrimaryLight = raspberry;
  static const Color lightPrimaryPastel = pinkMist;
  static const Color lightAccent = bubblegumPink;
  static const Color lightAccentLight = pinkMist;
  static const Color lightBackground = lightCyan;
  static const Color lightSurface = Color(0xFFFDFEFF);
  static const Color lightSurfaceVariant = Color(0xFFF1FAFF);
  static const Color lightTextPrimary = Color(0xFF1D275E);
  static const Color lightTextSecondary = Color(0xFF4D5FAF);
  static const Color lightTextTertiary = raspberry;

  // Dark Theme Palette (kept for future theme toggle)
  static const Color darkPrimary = raspberry;
  static const Color darkPrimaryDark = crushedBerry;
  static const Color darkPrimaryDarker = Color(0xFF4252E6);
  static const Color darkPrimaryDarkest = Color(0xFF3340B8);
  static const Color darkPrimaryAbyss = Color(0xFF151C4F);
  static const Color darkPrimaryLight = bubblegumPink;
  static const Color darkPrimaryPastel = pinkMist;
  static const Color darkAccent = bubblegumPink;
  static const Color darkAccentLight = pinkMist;
  static const Color darkBackground = Color(0xFF0D1233);
  static const Color darkSurface = Color(0xFF141B42);
  static const Color darkSurfaceVariant = Color(0xFF1C2557);
  static const Color darkTextPrimary = lightCyan;
  static const Color darkTextSecondary = pinkMist;
  static const Color darkTextTertiary = raspberry;

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

  // Navigation surfaces
  static const Color navigationBarBackground = Color(0x99171E57);
}
