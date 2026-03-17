import 'package:flutter/material.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/l10n/app_localizations.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final formattedDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          localizations.privacy_policy_title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontFamily: 'AppFontMedium',
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Builder(
                builder: (context) {
                  final dateText = localizations.privacy_policy_last_updated(formattedDate);
                  return Text(
                    dateText,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                localizations.privacy_policy_intro,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              _buildSection(
                title: localizations.privacy_policy_section_1_title,
                content: localizations.privacy_policy_section_1_content,
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: localizations.privacy_policy_section_2_title,
                content: localizations.privacy_policy_section_2_content,
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: localizations.privacy_policy_section_3_title,
                content: localizations.privacy_policy_section_3_content,
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: localizations.privacy_policy_section_4_title,
                content: localizations.privacy_policy_section_4_content,
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: localizations.privacy_policy_section_5_title,
                content: localizations.privacy_policy_section_5_content,
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: localizations.privacy_policy_section_6_title,
                content: localizations.privacy_policy_section_6_content,
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: localizations.privacy_policy_section_7_title,
                content: localizations.privacy_policy_section_7_content,
              ),
              const SizedBox(height: 32),
              Text(
                localizations.privacy_policy_contact,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'AppFontMedium',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
