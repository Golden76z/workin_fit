import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workin_fit/core/theme/colors.dart';

/// Shared system and surface styles for app chrome:
/// - Android top status bar
/// - Android bottom system bar
/// - App top bars
/// - App bottom navigation surfaces
class AppChrome {
  const AppChrome._();

  // Top app/status bar surface — near-black to match the dark theme.
  // Kept as a const hex literal because withValues() is not a const expression.
  static const Color topSurface = Color(0xFF111111);

  // Bottom app navigation surface.
  static const Color bottomSurface = AppColors.navBarSurface;

  // App-level default overlay.
  static const SystemUiOverlayStyle globalOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemStatusBarContrastEnforced: false,
    systemNavigationBarColor: AppColors.nearBlack,
    systemNavigationBarDividerColor: AppColors.nearBlack,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarContrastEnforced: false,
  );

  // Home shell overlay keeps the Android bottom bar transparent so custom
  // bottom bar surface controls the visible tone.
  static const SystemUiOverlayStyle homeOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemStatusBarContrastEnforced: false,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarContrastEnforced: false,
  );

  // Top status bar style — transparent so the appbar colour shows through
  // without double-tinting in edge-to-edge mode.
  static const SystemUiOverlayStyle topSurfaceOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemStatusBarContrastEnforced: false,
  );

  // Shared overlay used on pages with a top bar surface and no in-app
  // bottom navigation. Nav bar is transparent so a Flutter-drawn surface
  // (e.g. _NavBarFill) controls the visible tone, matching the top chrome.
  static const SystemUiOverlayStyle topAndBottomOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemStatusBarContrastEnforced: false,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarContrastEnforced: false,
  );
}

/// Reusable AnnotatedRegion wrapper for consistent system UI overlay handling.
class AppSystemOverlayRegion extends StatelessWidget {
  final SystemUiOverlayStyle style;
  final Widget child;

  const AppSystemOverlayRegion({
    required this.style,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: style,
      child: child,
    );
  }
}

/// Reusable bottom bar surface container.
class AppBottomBarSurface extends StatelessWidget {
  final double height;
  final EdgeInsetsGeometry padding;
  final Border? border;
  final Widget child;

  const AppBottomBarSurface({
    required this.height,
    required this.padding,
    required this.child,
    super.key,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: AppChrome.bottomSurface,
        border: border,
      ),
      child: child,
    );
  }
}
