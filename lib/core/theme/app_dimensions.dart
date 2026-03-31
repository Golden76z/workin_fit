import 'package:flutter/material.dart';

class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

class AppRadii {
  static const double sm = 8;
  static const double md = 10;
  static const double lg = 12;
  static const double xl = 16;
}

class AppSizes {
  static const Size buttonMinimum = Size(250, 0);

  // Workout execution layout
  static const double workoutTimerDiameter = 220;
  static const double workoutTimerStroke = 14;
  static const double workoutCurrentImageHeight = 190;
  static const double workoutNextImageSize = 66;
  static const double workoutBottomBarHeight = 72;
  static const double workoutControlButtonHeight = 50;
}

class AppLayout {
  /// Consistent horizontal margin applied to all list / content views.
  static const double pageMargin = AppSpacing.xs;
}

class AppDurations {
  static const Duration snackBar = Duration(seconds: 4);
}
