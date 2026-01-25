import 'package:flutter/material.dart';
import 'package:workin_fit/core/theme/colors.dart';

/// A reusable dialog widget that follows the app's color constants and theme
class AppDialog extends StatelessWidget {
  final String title;
  final String? content;
  final Widget? contentWidget;
  final IconData? icon;
  final Color? iconColor;
  final String? primaryButtonLabel;
  final VoidCallback? onPrimaryButtonPressed;
  final String? secondaryButtonLabel;
  final VoidCallback? onSecondaryButtonPressed;
  final bool barrierDismissible;
  final Color? backgroundColor;
  final double? borderRadius;

  const AppDialog({
    super.key,
    required this.title,
    this.content,
    this.contentWidget,
    this.icon,
    this.iconColor,
    this.primaryButtonLabel,
    this.onPrimaryButtonPressed,
    this.secondaryButtonLabel,
    this.onSecondaryButtonPressed,
    this.barrierDismissible = true,
    this.backgroundColor,
    this.borderRadius,
  }) : assert(
          content != null || contentWidget != null,
          'Either content or contentWidget must be provided',
        );

  /// Show the dialog
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? content,
    Widget? contentWidget,
    IconData? icon,
    Color? iconColor,
    String? primaryButtonLabel,
    VoidCallback? onPrimaryButtonPressed,
    String? secondaryButtonLabel,
    VoidCallback? onSecondaryButtonPressed,
    bool barrierDismissible = true,
    Color? backgroundColor,
    double? borderRadius,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => AppDialog(
        title: title,
        content: content,
        contentWidget: contentWidget,
        icon: icon,
        iconColor: iconColor,
        primaryButtonLabel: primaryButtonLabel,
        onPrimaryButtonPressed: onPrimaryButtonPressed,
        secondaryButtonLabel: secondaryButtonLabel,
        onSecondaryButtonPressed: onSecondaryButtonPressed,
        barrierDismissible: barrierDismissible,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: backgroundColor ?? AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
      ),
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: iconColor ?? AppColors.accent,
              size: 28,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: contentWidget ??
          (content != null
              ? Text(
                  content!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                  ),
                )
              : null),
      actions: [
        if (secondaryButtonLabel != null)
          TextButton(
            onPressed: onSecondaryButtonPressed ?? () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(secondaryButtonLabel!),
          ),
        if (primaryButtonLabel != null)
          TextButton(
            onPressed: onPrimaryButtonPressed ?? () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              primaryButtonLabel!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }
}
