import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/app_opacity.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/providers/locale_provider.dart';
import 'package:workin_fit/widgets/app_dialog.dart';

class LanguagePickerDialog extends ConsumerWidget {
  const LanguagePickerDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isFrench = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('fr');

    return AppDialog(
      title: isFrench ? 'Langue' : 'Language',
      icon: Icons.language_rounded,
      iconColor: AppColors.primary,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _LanguageOption(
              flag: '🇬🇧',
              label: 'English',
              isSelected: !isFrench,
              onTap: () {
                ref.read(localeProvider.notifier).setLocale('en');
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            _LanguageOption(
              flag: '🇫🇷',
              label: 'Français',
              isSelected: isFrench,
              onTap: () {
                ref.read(localeProvider.notifier).setLocale('fr');
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
      actions: <AppDialogAction<dynamic>>[
        AppDialogAction<bool>(
          label: isFrench ? 'Fermer' : 'Close',
          returnValue: false,
        ),
      ],
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String flag;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.flag,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: AppOpacity.faint)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: AppOpacity.muted)
                : AppColors.babyBlueIce.withValues(alpha: AppOpacity.half),
          ),
        ),
        child: Row(
          children: <Widget>[
            Text(flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
