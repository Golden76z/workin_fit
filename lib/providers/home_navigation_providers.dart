import 'package:flutter_riverpod/flutter_riverpod.dart';

/// True while the home [PageView] is mid-swipe (fractional page offset).
///
/// Heavy tabs (e.g. exercise list shaders) should skip expensive effects while
/// this is active so page transitions stay at 60fps.
final homeTabPageTransitionActiveProvider = StateProvider<bool>((ref) => false);
