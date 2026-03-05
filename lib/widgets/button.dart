import 'package:flutter/material.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const AppButton({required this.label, this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: AppSizes.buttonMinimum,
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm + 2,
          horizontal: AppSpacing.xl,
        ),
        textStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          fontFamily: 'AppFontMedium',
        ),
        backgroundColor: AppColors.primaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
