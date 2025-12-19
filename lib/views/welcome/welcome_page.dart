import 'package:flutter/material.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/l10n/app_localizations.dart';
import 'package:workin_fit/views/auth/authentication_view.dart';
import 'package:workin_fit/views/welcome/choose_language.dart';
import 'package:workin_fit/widgets/button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.welcome_page_app_title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'AppFont',
                fontSize: 52,
              ),
            ),
            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 120),
              child: Divider(
                thickness: 4,
                height: 20,
                color: AppColors.textPrimary.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 16),

            AppButton(
              label: AppLocalizations.of(context)!.welcome_page_register_button,
              onPressed: () {
                // Navigate to authentication view
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AuthenticationView(),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),
            AppButton(
              label: AppLocalizations.of(context)!.welcome_page_choose_language, 
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LanguageSelectionScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}