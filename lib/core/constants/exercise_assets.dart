import 'dart:convert';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';

/// Paths for user-provided exercise movement media under [kExerciseMovementsRoot].
abstract final class ExerciseAssets {
  static const String kExerciseMovementsRoot = 'assets/exercises/movements';

  /// Preferred movement filenames, tried in order.
  static const List<String> movementFileNames = <String>[
    'tutorial.png',
    'tutorial.jpg',
    'tutorial.jpeg',
    'tutorial.webp',
    'tutorial.gif',
  ];

  static Map<String, String>? _movementPathByExerciseId;

  /// e.g. `assets/exercises/movements/core_007/tutorial.png`
  static String movementPath(
    String exerciseId, {
    String fileName = 'tutorial.png',
  }) {
    return '$kExerciseMovementsRoot/$exerciseId/$fileName';
  }

  static List<String> movementPaths(String exerciseId) {
    return movementFileNames
        .map((String name) => movementPath(exerciseId, fileName: name))
        .toList(growable: false);
  }

  /// Resolved bundled path for [exerciseId] from the manifest index, if any.
  static String? movementAssetPathFor(String exerciseId) {
    return _movementPathByExerciseId?[exerciseId];
  }

  /// Manifest path when indexed, otherwise the canonical `tutorial.png` path.
  static String bundledMovementPath(String exerciseId) {
    return movementAssetPathFor(exerciseId) ?? movementPath(exerciseId);
  }

  /// Scans the asset manifest once at startup and caches id → path.
  static Future<void> warmMovementAssetIndex() async {
    final Set<String> assetPaths = await _loadAllAssetPaths();
    final Map<String, String> resolved = <String, String>{};

    for (final String assetPath in assetPaths) {
      if (!assetPath.startsWith('$kExerciseMovementsRoot/')) continue;

      final String? fileName = _movementFileNameFromPath(assetPath);
      if (fileName == null) continue;

      final List<String> segments = assetPath.split('/');
      if (segments.length < 2) continue;
      final String exerciseId = segments[segments.length - 2];

      resolved.putIfAbsent(exerciseId, () => assetPath);
    }

    _movementPathByExerciseId = resolved;
  }

  static void clearMovementAssetIndexCache() {
    _movementPathByExerciseId = null;
  }

  @visibleForTesting
  static void setMovementAssetIndexForTests(Map<String, String> paths) {
    _movementPathByExerciseId = paths;
  }

  static String? _movementFileNameFromPath(String assetPath) {
    for (final String name in movementFileNames) {
      if (assetPath.endsWith('/$name')) return name;
    }
    return null;
  }

  static Future<Set<String>> _loadAllAssetPaths() async {
    final Set<String> paths = <String>{};

    try {
      final AssetManifest manifest =
          await AssetManifest.loadFromAssetBundle(rootBundle);
      paths.addAll(manifest.listAssets());
    } catch (_) {
      // Fall through to legacy manifest.
    }

    if (paths.isNotEmpty) return paths;

    try {
      final String json =
          await rootBundle.loadString('AssetManifest.json');
      final Object? decoded = jsonDecode(json);
      if (decoded is Map<String, dynamic>) {
        paths.addAll(decoded.keys);
      } else if (decoded is Map) {
        paths.addAll(decoded.keys.cast<String>());
      }
    } catch (_) {
      // No manifest available (tests / misconfigured assets).
    }

    return paths;
  }
}
