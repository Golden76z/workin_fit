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
    stops: <double>[0.0, 0.5, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: _gradient),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -52,
            top: -28,
            child: IgnorePointer(
              child: _TopBarCircle(
                diameter: 180,
                fillColor: Colors.white.withValues(alpha: 0.045),
              ),
            ),
          ),
          Positioned(
            left: -42,
            top: -58,
            child: IgnorePointer(
              child: _TopBarCircle(
                diameter: 148,
                borderColor: Colors.white.withValues(alpha: 0.055),
                borderWidth: 1.4,
              ),
            ),
          ),
          Positioned(
            right: 30,
            top: 12,
            child: IgnorePointer(
              child: _TopBarCircle(
                diameter: 74,
                fillColor: Colors.white.withValues(alpha: 0.038),
                borderColor: Colors.white.withValues(alpha: 0.06),
                borderWidth: 1.1,
              ),
            ),
          ),
          Positioned(
            left: -48,
            bottom: -18,
            child: IgnorePointer(
              child: _TopBarCircle(
                diameter: 130,
                fillColor: Colors.white.withValues(alpha: 0.024),
              ),
            ),
          ),
          Positioned(
            left: 60,
            bottom: 14,
            child: IgnorePointer(
              child: _TopBarCircle(
                diameter: 38,
                fillColor: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            left: 98,
            bottom: 42,
            child: IgnorePointer(
              child: _TopBarCircle(
                diameter: 18,
                fillColor: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            right: 86,
            bottom: -24,
            child: IgnorePointer(
              child: _TopBarCircle(
                diameter: 96,
                borderColor: Colors.white.withValues(alpha: 0.048),
                borderWidth: 1.5,
              ),
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _TopBarCircle extends StatelessWidget {
  final double diameter;
  final Color? fillColor;
  final Color? borderColor;
  final double borderWidth;

  const _TopBarCircle({
    required this.diameter,
    this.fillColor,
    this.borderColor,
    this.borderWidth = 1,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: diameter,
      height: diameter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fillColor,
          border: borderColor == null
              ? null
              : Border.all(
                  color: borderColor!,
                  width: borderWidth,
                ),
        ),
      ),
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
      child: AppTopBarBackground(
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
      child: const AppTopBarBackground(),
    );
  }
}
