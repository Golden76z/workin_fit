import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/app_opacity.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/features/auth/domain/auth_provider.dart';
import 'package:workin_fit/models/chat_message.dart';
import 'package:workin_fit/models/friend.dart';
import 'package:workin_fit/providers/chat_providers.dart';
import 'package:workin_fit/providers/friend_providers.dart';
import 'package:workin_fit/widgets/workout_summary_card.dart';

class ShareWorkoutSheet extends ConsumerStatefulWidget {
  const ShareWorkoutSheet({super.key, required this.shareData});
  final WorkoutShareData shareData;

  @override
  ConsumerState<ShareWorkoutSheet> createState() => _ShareWorkoutSheetState();
}

class _ShareWorkoutSheetState extends ConsumerState<ShareWorkoutSheet> {
  final TextEditingController _commentController = TextEditingController();
  Friend? _selectedFriend;
  bool _sending = false;
  String? _cachedUsername;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final profile = await ref
        .read(firestoreServiceProvider)
        .getUserProfile(user.uid);
    if (mounted) {
      setState(() {
        _cachedUsername =
            profile?['username'] as String? ?? user.displayName ?? 'User';
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final friend = _selectedFriend;
    if (friend == null) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _sending = true);
    try {
      final senderUsername = _cachedUsername ?? user.displayName ?? 'User';

      await ref.read(chatServiceProvider).sendWorkoutShare(
            fromUserId: user.uid,
            fromUsername: senderUsername,
            fromPhotoUrl: user.photoURL,
            toUserId: friend.userId,
            toUsername: friend.username,
            toPhotoUrl: friend.photoUrl,
            shareData: widget.shareData,
            comment: _commentController.text.trim(),
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e, st) {
      debugPrint('ShareWorkoutSheet: sendWorkoutShare failed — $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to share. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final friendsAsync = ref.watch(friendsStreamProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadii.xl)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Share Workout',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'AppFontMedium',
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  // Preview card (no button — sender view)
                  WorkoutSummaryCard(
                    shareData: widget.shareData,
                    comment: '',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Comment field
                  TextField(
                    controller: _commentController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Add a comment... (optional)',
                      hintStyle: TextStyle(
                          color: AppColors.textSecondary
                              .withValues(alpha: AppOpacity.visible)),
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadii.md),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Send to',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  friendsAsync.when(
                    data: (friends) {
                      if (friends.isEmpty) {
                        return const Text(
                          'Add friends to share workouts!',
                          style: TextStyle(color: AppColors.textSecondary),
                        );
                      }
                      return Column(
                        children: friends
                            .map(
                              (f) => RadioListTile<Friend>(
                                value: f,
                                groupValue: _selectedFriend,
                                onChanged: (v) =>
                                    setState(() => _selectedFriend = v),
                                title: Text(
                                  f.username,
                                  style: const TextStyle(
                                      color: AppColors.textPrimary),
                                ),
                                activeColor: AppColors.primary,
                                contentPadding: EdgeInsets.zero,
                              ),
                            )
                            .toList(),
                      );
                    },
                    loading: () =>
                        const LinearProgressIndicator(),
                    error: (_, __) => const Text(
                      'Could not load friends.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                      (_selectedFriend == null || _sending) ? null : _send,
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary),
                  child: _sending
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Send'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
