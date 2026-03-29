import 'package:flutter/material.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/core/theme/app_opacity.dart';

// ---------------------------------------------------------------------------
// Action type
// ---------------------------------------------------------------------------

enum AppDialogActionStyle {
  /// Ghost / outlined — used for cancel
  cancel,

  /// Filled blue — primary confirm
  primary,

  /// Filled red tint — destructive confirm
  destructive,

  /// Outlined blue — secondary positive option
  outlined,
}

/// Descriptor for a single action button inside an [AppDialog].
class AppDialogAction<T> {
  final String label;
  final T returnValue;
  final AppDialogActionStyle style;

  const AppDialogAction({
    required this.label,
    required this.returnValue,
    this.style = AppDialogActionStyle.cancel,
  });
}

// ---------------------------------------------------------------------------
// AppDialog
// ---------------------------------------------------------------------------

/// A polished, app-themed dialog.
///
/// Supports 1–3 actions. When there are ≤ 2 actions they are placed in a row;
/// with 3 or more they stack vertically (full-width).
class AppDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? body;
  final IconData? icon;
  final Color? iconColor;

  /// Action buttons. Supply 2 (row) or 3 (column) actions.
  final List<AppDialogAction<dynamic>> actions;

  const AppDialog({
    required this.title,
    this.message,
    this.body,
    this.icon,
    this.iconColor,
    this.actions = const [],
    super.key,
  });

  // ---------------------------------------------------------------------------
  // Static helpers
  // ---------------------------------------------------------------------------

  /// Show a two-button confirm dialog. Returns `true` if confirmed, else
  /// `false` / `null`.
  static Future<bool?> showConfirm({
    required BuildContext context,
    required String title,
    required String confirmLabel,
    required String cancelLabel,
    String? message,
    Widget? body,
    IconData? icon,
    Color? iconColor,
    bool destructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AppDialog(
        title: title,
        message: message,
        body: body,
        icon: icon,
        iconColor: iconColor,
        actions: [
          AppDialogAction<bool>(
            label: cancelLabel,
            returnValue: false,
          ),
          AppDialogAction<bool>(
            label: confirmLabel,
            returnValue: true,
            style: destructive
                ? AppDialogActionStyle.destructive
                : AppDialogActionStyle.primary,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final hasIcon = icon != null;
    final stackVertically = actions.length > 2;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primaryPastel.withValues(alpha: AppOpacity.dim),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: AppOpacity.whisper),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: AppOpacity.trace),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Optional icon circle
            if (hasIcon) ...[
              const SizedBox(height: 26),
              Center(
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppColors.primary)
                        .withValues(alpha: AppOpacity.whisper),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: (iconColor ?? AppColors.primary)
                          .withValues(alpha: 0.22),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? AppColors.primary,
                    size: 28,
                  ),
                ),
              ),
            ],

            // Title
            Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                hasIcon ? 14 : 24,
                24,
                4,
              ),
              child: Text(
                title,
                textAlign: hasIcon ? TextAlign.center : TextAlign.start,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'AppFontMedium',
                ),
              ),
            ),

            // Message or body
            if (body != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
                child: body!,
              )
            else if (message != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 2, 24, 0),
                child: Text(
                  message!,
                  textAlign: hasIcon ? TextAlign.center : TextAlign.start,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),

            // Action buttons
            if (actions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: stackVertically
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (int i = 0; i < actions.length; i++) ...[
                            if (i > 0) const SizedBox(height: 8),
                            _ActionButton(action: actions[i]),
                          ],
                        ],
                      )
                    : Row(
                        children: [
                          for (int i = 0; i < actions.length; i++) ...[
                            if (i > 0) const SizedBox(width: 10),
                            Expanded(child: _ActionButton(action: actions[i])),
                          ],
                        ],
                      ),
              )
            else
              const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action button renderer
// ---------------------------------------------------------------------------

class _ActionButton extends StatelessWidget {
  final AppDialogAction<dynamic> action;

  const _ActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    switch (action.style) {
      case AppDialogActionStyle.primary:
        return FilledButton(
          onPressed: () => Navigator.of(context).pop(action.returnValue),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
          ),
          child: Text(
            action.label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        );

      case AppDialogActionStyle.destructive:
        return FilledButton(
          onPressed: () => Navigator.of(context).pop(action.returnValue),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error.withValues(alpha: AppOpacity.whisper),
            foregroundColor: AppColors.error,
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
          ),
          child: Text(
            action.label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        );

      case AppDialogActionStyle.outlined:
        return OutlinedButton(
          onPressed: () => Navigator.of(context).pop(action.returnValue),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(
              color: AppColors.primary.withValues(alpha: AppOpacity.dim),
            ),
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
          ),
          child: Text(
            action.label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        );

      case AppDialogActionStyle.cancel:
        return OutlinedButton(
          onPressed: () => Navigator.of(context).pop(action.returnValue),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            side: BorderSide(
              color: AppColors.primaryPastel.withValues(alpha: AppOpacity.over),
            ),
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
          ),
          child: Text(
            action.label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        );
    }
  }
}
