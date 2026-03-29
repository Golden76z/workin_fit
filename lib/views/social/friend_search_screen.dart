import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/features/auth/domain/auth_provider.dart';
import 'package:workin_fit/providers/friend_providers.dart';
import 'package:workin_fit/core/theme/app_opacity.dart';

class FriendSearchScreen extends ConsumerStatefulWidget {
  const FriendSearchScreen({super.key});

  @override
  ConsumerState<FriendSearchScreen> createState() => _FriendSearchScreenState();
}

class _FriendSearchScreenState extends ConsumerState<FriendSearchScreen> {
  final _controller = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;
  // Maps targetUserId -> status ('pending_sent', 'friends', 'pending_received', null)
  final Map<String, String?> _statusCache = {};

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _loading = true);
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;
      final service = ref.read(friendServiceProvider);
      final results = await service.searchUsersByUsername(query, user.uid);
      // Load statuses for each result
      for (final r in results) {
        final targetId = r['userId'] as String;
        _statusCache[targetId] ??=
            await service.getFriendStatus(user.uid, targetId);
      }
      if (mounted) setState(() => _results = results);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendRequest(Map<String, dynamic> target) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final targetId = target['userId'] as String;

    // Optimistic update
    setState(() => _statusCache[targetId] = 'pending_sent');

    try {
      final profile = await ref
          .read(firestoreServiceProvider)
          .getUserProfile(user.uid);
      final myUsername = profile?['username'] as String? ??
          user.displayName ??
          user.email?.split('@').first ??
          'User';

      await ref.read(friendServiceProvider).sendFriendRequest(
            fromUserId: user.uid,
            fromUsername: myUsername,
            toUserId: targetId,
            toUsername: target['username'] as String? ?? '',
            fromPhotoUrl: user.photoURL,
          );
    } catch (_) {
      if (mounted) {
        setState(() => _statusCache[targetId] = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send request.')),
        );
      }
    }
  }

  Future<void> _cancelRequest(String targetId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _statusCache[targetId] = null);
    try {
      await ref.read(friendServiceProvider).cancelFriendRequest(
            fromUserId: user.uid,
            toUserId: targetId,
          );
    } catch (_) {
      if (mounted) {
        setState(() => _statusCache[targetId] = 'pending_sent');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to cancel request.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Find Friends',
          style: TextStyle(
            fontFamily: 'AppFontMedium',
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          _SearchBar(
            controller: _controller,
            onChanged: _search,
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _results.isEmpty
                    ? _controller.text.isEmpty
                        ? const _EmptyHint()
                        : const _NoResults()
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                        itemCount: _results.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          indent: AppSpacing.md + 44 + AppSpacing.sm,
                          color: AppColors.babyBlueIce.withValues(alpha: AppOpacity.half),
                        ),
                        itemBuilder: (context, i) {
                          final r = _results[i];
                          final targetId = r['userId'] as String;
                          final status = _statusCache[targetId];
                          return _UserTile(
                            username: r['username'] as String? ?? '',
                            photoUrl: r['photoUrl'] as String?,
                            status: status,
                            onSend: () => _sendRequest(r),
                            onCancel: () => _cancelRequest(targetId),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ─── Search bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        autofocus: true,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: 'Search by username…',
          hintStyle: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: AppOpacity.half),
            fontSize: 15,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: AppColors.textSecondary.withValues(alpha: AppOpacity.half),
                    size: 18,
                  ),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.surfaceVariant,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.xl),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// ─── User tile ────────────────────────────────────────────────────────────────

class _UserTile extends StatelessWidget {
  final String username;
  final String? photoUrl;
  final String? status;
  final VoidCallback onSend;
  final VoidCallback onCancel;

  const _UserTile({
    required this.username,
    required this.onSend,
    required this.onCancel,
    this.photoUrl,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          _Avatar(photoUrl: photoUrl, username: username),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              username,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _ActionButton(status: status, onSend: onSend, onCancel: onCancel),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String? status;
  final VoidCallback onSend;
  final VoidCallback onCancel;

  const _ActionButton({
    required this.onSend,
    required this.onCancel,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    if (status == 'friends') {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs + 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: AppOpacity.whisper),
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_rounded,
              size: 14,
              color: AppColors.success.withValues(alpha: AppOpacity.bold),
            ),
            const SizedBox(width: 4),
            Text(
              'Friends',
              style: TextStyle(
                color: AppColors.success.withValues(alpha: AppOpacity.bold),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (status == 'pending_sent') {
      return TextButton(
        onPressed: onCancel,
        style: TextButton.styleFrom(
          backgroundColor: AppColors.babyBlueIce.withValues(alpha: AppOpacity.mild),
          foregroundColor: AppColors.textSecondary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.xl),
          ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text(
          'Pending',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      );
    }

    if (status == 'pending_received') {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs + 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: AppOpacity.whisper),
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        child: Text(
          'Sent you a request',
          style: TextStyle(
            color: AppColors.warning.withValues(alpha: 0.85),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    // No relationship
    return TextButton(
      onPressed: onSend,
      style: TextButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text(
        'Add',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ─── Avatar ───────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String? photoUrl;
  final String username;

  const _Avatar({required this.username, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.primaryDarker,
      backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
          ? CachedNetworkImageProvider(photoUrl!) as ImageProvider
          : null,
      child: photoUrl == null || photoUrl!.isEmpty
          ? Text(
              username.isNotEmpty ? username[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            )
          : null,
    );
  }
}

// ─── Empty states ─────────────────────────────────────────────────────────────

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person_search_rounded,
            size: 64,
            color: AppColors.babyBlueIce.withValues(alpha: AppOpacity.visible),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Search by username',
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: AppOpacity.prominent),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No users found',
        style: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: AppOpacity.prominent),
          fontSize: 15,
        ),
      ),
    );
  }
}
