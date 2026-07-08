import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/app_opacity.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/features/auth/domain/auth_provider.dart';

class EditProfileSheet extends ConsumerStatefulWidget {
  final String currentUsername;
  final String userId;
  final String? email;

  const EditProfileSheet({
    required this.currentUsername,
    required this.userId,
    this.email,
    super.key,
  });

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  late final TextEditingController _controller;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentUsername);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final String newName = _controller.text.trim();
    if (newName.isEmpty || newName == widget.currentUsername) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(firestoreServiceProvider).createOrUpdateUserProfile(
        userId: widget.userId,
        username: newName,
        email: widget.email ?? '',
      );
      final user = ref.read(currentUserProvider);
      await user?.updateDisplayName(newName);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isFrench = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('fr');
    final double bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg + bottomPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color:
                    AppColors.textTertiary.withValues(alpha: AppOpacity.half),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            isFrench ? 'Modifier le profil' : 'Edit Profile',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontFamily: 'AppFontMedium',
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            isFrench ? 'Nom d\'utilisateur' : 'Username',
            style: TextStyle(
              color: AppColors.textSecondary
                  .withValues(alpha: AppOpacity.prominent),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surfaceVariant,
              hintText: isFrench ? 'Votre nom' : 'Your name',
              hintStyle: TextStyle(
                color:
                    AppColors.textSecondary.withValues(alpha: AppOpacity.half),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
                borderSide: BorderSide(
                  color: AppColors.primary.withValues(alpha: AppOpacity.muted),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
                borderSide: BorderSide(
                  color:
                      AppColors.babyBlueIce.withValues(alpha: AppOpacity.half),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: _saving ? null : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: BorderSide(
                      color: AppColors.babyBlueIce
                          .withValues(alpha: AppOpacity.half),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm + 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                  ),
                  child: Text(isFrench ? 'Annuler' : 'Cancel'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm + 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isFrench ? 'Sauvegarder' : 'Save',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
