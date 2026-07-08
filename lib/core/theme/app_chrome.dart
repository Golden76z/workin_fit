import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/core/theme/app_opacity.dart';

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

  // Bottom app navigation surface fallback.
  static const Color bottomSurface = AppColors.primaryDark;

  // App-level default overlay.
  static const SystemUiOverlayStyle globalOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemStatusBarContrastEnforced: false,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
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
  // (e.g. AppBottomInsetSurface) controls the visible tone, matching the top
  // chrome.
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

/// Shared rectangular top-bar treatment based on the home banner artwork.
class AppTopBarBackground extends StatelessWidget {
  final Widget? child;

  const AppTopBarBackground({
    this.child,
    super.key,
  });

  static final LinearGradient _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      AppColors.primaryDark.withValues(alpha: 0.84),
      AppColors.primary.withValues(alpha: 0.84),
      AppColors.cornflowerBlue.withValues(alpha: 0.84),
    ],
    stops: <double>[0.0, 0.45, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: _gradient),
        child: Stack(
          fit: StackFit.loose,
          children: <Widget>[
            // Soft radial lighting highlight — top-right
            Positioned(
              right: -50,
              top: -50,
              child: IgnorePointer(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: <Color>[
                        Colors.white.withValues(alpha: AppOpacity.subtle),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Soft radial color highlight — bottom-left
            Positioned(
              left: -30,
              bottom: -30,
              child: IgnorePointer(
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: <Color>[
                        AppColors.primaryLight.withValues(alpha: AppOpacity.muted),
                        AppColors.primaryLight.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Glowing neon bottom border line
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Container(
                  height: 1.5,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        AppColors.primaryLight,
                        AppColors.cornflowerBlue,
                        AppColors.primaryLight,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}

/// Simple clean gradient background for the bottom bar surfaces (no circles, no glows).
class AppBottomBarBackground extends StatelessWidget {
  final Widget? child;

  const AppBottomBarBackground({
    this.child,
    super.key,
  });

  static final LinearGradient _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      AppColors.primaryDark.withValues(alpha: 0.84),
      AppColors.primary.withValues(alpha: 0.84),
      AppColors.cornflowerBlue.withValues(alpha: 0.84),
    ],
    stops: <double>[0.0, 0.45, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: _gradient),
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
    return SizedBox(
      height: height,
      child: AppBottomBarBackground(
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            border: border,
          ),
          child: child,
        ),
      ),
    );
  }
}

class AppBottomInsetSurface extends StatelessWidget {
  const AppBottomInsetSurface({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.viewPaddingOf(context).bottom,
      child: const AppBottomBarBackground(),
    );
  }
}
