import 'package:flutter/material.dart';
import 'package:sport_app/core/theme/app_theme.dart';

typedef DialogOptionBuilder<T> = Map<String, T?> Function();

Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptionBuilder optionsBuilder,
  ButtonStyle? buttonStyle,
  TextStyle? titleStyle,
  TextStyle? contentStyle,
  Color? backgroundColor,
  double? elevation,
  ShapeBorder? shape,
  EdgeInsetsGeometry? titlePadding,
  EdgeInsetsGeometry? contentPadding,
  AlignmentGeometry? alignment,
  bool? scrollable,
}) {
  final options = optionsBuilder();
  final theme = Theme.of(context);
  final isDarkMode = theme.brightness == Brightness.dark;

  return showDialog<T?>(
    context: context,
    barrierColor: Colors.black54, // Consistent with your theme's scrim color
    builder: (context) {
      return AlertDialog(
        backgroundColor: backgroundColor ?? theme.colorScheme.surface,
        elevation: elevation ?? 8,
        shadowColor: theme.colorScheme.shadow,
        surfaceTintColor: Colors.transparent,
        shape: shape ??
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
        alignment: alignment,
        scrollable: scrollable ?? false,
        titlePadding: titlePadding ?? const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding:
            contentPadding ?? const EdgeInsets.fromLTRB(24, 8, 24, 24),
        title: Text(
          title,
          style: titleStyle ??
              theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
        ),
        content: Text(
          content,
          style: contentStyle ??
              theme.textTheme.bodyLarge?.copyWith(
                color: isDarkMode
                    ? theme.colorScheme.onSurface
                    : AthleticEnergyTheme.darkCharcoal,
              ),
        ),
        actions: options.keys.map((optionTitle) {
          final T? value = options[optionTitle];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextButton(
              style: buttonStyle ??
                  TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              onPressed: () {
                if (value != null) {
                  Navigator.of(context).pop(value);
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: Text(optionTitle),
            ),
          );
        }).toList(),
        actionsPadding: const EdgeInsets.only(bottom: 8, right: 8),
      );
    },
  );
}
