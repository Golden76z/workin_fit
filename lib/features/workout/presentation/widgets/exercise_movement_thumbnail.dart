import 'package:flutter/material.dart';
import 'package:workin_fit/core/constants/exercise_assets.dart';
import 'package:workin_fit/core/theme/colors.dart';

/// Thumbnail for exercise movement media (network URL, explicit asset, or bundled tutorial).
class ExerciseMovementThumbnail extends StatelessWidget {
  final String exerciseId;
  final String imageUrl;
  final BoxFit fit;
  final int? cacheHeight;
  final Widget? placeholder;

  const ExerciseMovementThumbnail({
    super.key,
    required this.exerciseId,
    this.imageUrl = '',
    this.fit = BoxFit.cover,
    this.cacheHeight,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final String trimmed = imageUrl.trim();
    if (_isRemoteOrAssetUrl(trimmed)) {
      if (trimmed.startsWith('assets/')) {
        return Image.asset(
          trimmed,
          fit: fit,
          cacheHeight: cacheHeight,
          errorBuilder: (_, Object __, StackTrace? ___) =>
              _buildBundledOrPlaceholder(),
        );
      }
      return Image.network(
        trimmed,
        fit: fit,
        cacheHeight: cacheHeight,
        errorBuilder: (_, Object __, StackTrace? ___) =>
            _buildBundledOrPlaceholder(),
      );
    }
    return _buildBundledOrPlaceholder();
  }

  static bool _isRemoteOrAssetUrl(String url) {
    if (url.isEmpty) return false;
    if (url.startsWith('assets/')) return true;
    return url.startsWith('http://') || url.startsWith('https://');
  }

  Widget _buildBundledOrPlaceholder() {
    if (exerciseId.isEmpty) {
      return placeholder ?? const _DefaultPlaceholder();
    }

    return Image.asset(
      ExerciseAssets.bundledMovementPath(exerciseId),
      fit: fit,
      cacheHeight: cacheHeight,
      errorBuilder: (_, Object __, StackTrace? ___) =>
          placeholder ?? const _DefaultPlaceholder(),
    );
  }
}

class _DefaultPlaceholder extends StatelessWidget {
  const _DefaultPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.mediaCanvas,
      child: Center(
        child: Icon(
          Icons.fitness_center_rounded,
          color: AppColors.frostedCyan,
          size: 40,
        ),
      ),
    );
  }
}
