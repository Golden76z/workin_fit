import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/l10n/app_localizations.dart';
import 'package:workin_fit/providers/locale_provider.dart';
import 'package:workin_fit/widgets/button.dart';

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
      ),
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppButton(
              label: AppLocalizations.of(context)!.welcome_page_language_english,
              onPressed: () {
                ref.read(localeProvider.notifier).setLocale('en');
              },
            ),

            const SizedBox(height: 12),
            AppButton(
              label: AppLocalizations.of(context)!.welcome_page_language_french, 
              onPressed: () {
                ref.read(localeProvider.notifier).setLocale('fr');
              },
            ),
          ],
        ),
      ),
    );
  }
}