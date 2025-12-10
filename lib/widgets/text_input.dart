import 'package:flutter/material.dart';
import 'package:workin_fit/core/theme/colors.dart';

class AppTextInput extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final int maxLines;

  /// Optional custom margin (defaults to horizontal padding)
  final EdgeInsetsGeometry? margin;

  /// NEW: enable/disable border
  final bool hasBorder;

  const AppTextInput({
    required this.hint, 
    super.key,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.margin,
    // Border disabled by default
    this.hasBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    // choose border style based on hasBorder
    final BorderSide side = hasBorder
        ? const BorderSide(
            color: AppColors.textTertiary,
            width: 1.5,
          )
        : BorderSide.none;

    final BorderSide focusedSide = hasBorder
        ? const BorderSide(
            color: AppColors.primary,
            width: 2,
          )
        : BorderSide.none;

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16),

      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),

        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          filled: true,
          fillColor: AppColors.surfaceVariant,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 20,
          ),

          // default border
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: side,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: side,
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: focusedSide,
          ),
        ),
      ),
    );
  }
}