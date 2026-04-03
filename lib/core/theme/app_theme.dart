import 'package:flutter/material.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    // Light theme is currently unused (app runs ThemeMode.dark),
    // but kept consistent so a future toggle works correctly.
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.brand200,
        onPrimary: AppColors.neutral600,
        primaryContainer: AppColors.brand500,
        onPrimaryContainer: AppColors.brand50,
        secondary: AppColors.brand300,
        onSecondary: AppColors.neutral600,
        secondaryContainer: AppColors.brand400,
        onSecondaryContainer: AppColors.brand50,
        tertiary: AppColors.brand100,
        onTertiary: AppColors.neutral0,
        surface: AppColors.neutral100,
        onSurface: AppColors.neutral600,
        surfaceContainerHighest: AppColors.neutral300,
        surfaceContainerHigh: AppColors.neutral200,
        surfaceContainer: AppColors.neutral200,
        surfaceContainerLow: AppColors.neutral100,
        surfaceContainerLowest: AppColors.neutral0,
        outline: AppColors.neutral400,
        outlineVariant: AppColors.neutral300,
        error: AppColors.error,
        onError: Colors.white,
        shadow: Colors.black,
        scrim: Colors.black,
        inversePrimary: AppColors.neutral0,
        inverseSurface: AppColors.neutral600,
        onInverseSurface: AppColors.neutral0,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.neutral0,
        foregroundColor: AppColors.neutral600,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.neutral300,
        contentTextStyle: const TextStyle(color: AppColors.neutral600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.brand200,
        onPrimary: AppColors.neutral600,
        primaryContainer: AppColors.brand500,
        onPrimaryContainer: AppColors.brand50,
        secondary: AppColors.brand300,
        onSecondary: AppColors.neutral600,
        secondaryContainer: AppColors.brand400,
        onSecondaryContainer: AppColors.brand50,
        tertiary: AppColors.brand100,
        onTertiary: AppColors.neutral0,
        surface: AppColors.neutral100,
        onSurface: AppColors.neutral600,
        surfaceContainerHighest: AppColors.neutral300,
        surfaceContainerHigh: AppColors.neutral200,
        surfaceContainer: AppColors.neutral200,
        surfaceContainerLow: AppColors.neutral100,
        surfaceContainerLowest: AppColors.neutral0,
        outline: AppColors.neutral400,
        outlineVariant: AppColors.neutral300,
        error: AppColors.error,
        onError: Colors.white,
        shadow: Colors.black,
        scrim: Colors.black,
        inversePrimary: AppColors.neutral0,
        inverseSurface: AppColors.neutral600,
        onInverseSurface: AppColors.neutral0,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.neutral0,
        foregroundColor: AppColors.neutral600,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.neutral300,
        contentTextStyle: const TextStyle(color: AppColors.neutral600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
      ),
    );
  }
}
