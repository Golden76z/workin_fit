import 'package:flutter/material.dart';
import 'package:workin_fit/core/theme/app_chrome.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/app_opacity.dart';
import 'package:workin_fit/core/theme/colors.dart';

class ChatTab extends StatelessWidget {
  const ChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSystemOverlayRegion(
      style: AppChrome.homeOverlay,
      child: Scaffold(
        backgroundColor: AppColors.surfaceVariant,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          systemOverlayStyle: AppChrome.topSurfaceOverlay,
          flexibleSpace: const AppTopBarBackground(),
          elevation: 0,
          title: const Text(
            'Chat',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'AppFontMedium',
            ),
          ),
          actions: [
            const IconButton(
              icon: Icon(Icons.edit_outlined, color: Colors.white),
              onPressed: null, // compose — coming in next feature
              tooltip: 'New conversation',
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color:
                        AppColors.primary.withValues(alpha: AppOpacity.faint),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 42,
                    color: AppColors.primary
                        .withValues(alpha: AppOpacity.moderate),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'No conversations yet',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'AppFontMedium',
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Share your workouts, sessions and achievements with friends — coming soon.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary
                        .withValues(alpha: AppOpacity.bold),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
