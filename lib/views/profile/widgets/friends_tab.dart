import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/app_opacity.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/features/auth/domain/auth_provider.dart';
import 'package:workin_fit/models/friend.dart';
import 'package:workin_fit/models/friend_request.dart';
import 'package:workin_fit/providers/friend_providers.dart';
import 'package:workin_fit/views/social/friend_search_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Friends tab content — add button + requests + friends list
// ─────────────────────────────────────────────────────────────────────────────

class FriendsTabContent extends ConsumerWidget {
  final bool isFrench;

  const FriendsTabContent({required this.isFrench, super.key});

  void _openSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const FriendSearchScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsAsync = ref.watch(friendsStreamProvider);
    final requestsAsync = ref.watch(incomingRequestsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(friendsStreamProvider);
        ref.invalidate(incomingRequestsProvider);
        await Future<void>.delayed(const Duration(milliseconds: 600));
      },
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          104,
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          // ── Add friends button ──────────────────────────────────
          _AddFriendsButton(
            label: isFrench ? 'Trouver des amis' : 'Find Friends',
            onTap: () => _openSearch(context),
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Requests section (shown only when pending > 0) ──────
          requestsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (requests) {
              if (requests.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _FriendsSectionHeader(
                    label: isFrench
                        ? 'Demandes (${requests.length})'
                        : 'Requests (${requests.length})',
                  ),
                  _FriendsSectionCard(
                    children: requests.map((r) {
                      return _RequestRow(
                        request: r,
                        onAccept: () => _accept(context, ref, r),
                        onReject: () => _reject(context, ref, r),
                        isLast: r == requests.last,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              );
            },
          ),

          // ── Friends list ────────────────────────────────────────
          friendsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            error: (_, __) => Center(
              child: Text(
                isFrench
                    ? 'Impossible de charger les amis'
                    : 'Failed to load friends',
                style: TextStyle(
                  color: AppColors.textSecondary
                      .withValues(alpha: AppOpacity.prominent),
                ),
              ),
            ),
            data: (friends) {
              if (friends.isEmpty) {
                return _FriendsEmptyState(
                  isFrench: isFrench,
                  onSearch: () => _openSearch(context),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _FriendsSectionHeader(
                    label: isFrench
                        ? 'Amis (${friends.length})'
                        : 'Friends (${friends.length})',
                  ),
                  _FriendsSectionCard(
                    children: friends.map((f) {
                      return _FriendRow(
                        friend: f,
                        onRemove: () => _confirmRemove(context, ref, f),
                        isLast: f == friends.last,
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _accept(
    BuildContext context,
    WidgetRef ref,
    FriendRequest request,
  ) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    try {
      final profile =
          await ref.read(firestoreServiceProvider).getUserProfile(user.uid);
      final myUsername = profile?['username'] as String? ??
          user.displayName ??
          user.email?.split('@').first ??
          'User';
      await ref.read(friendServiceProvider).acceptFriendRequest(
            requestId: request.id,
            fromUserId: request.fromUserId,
            fromUsername: request.fromUsername,
            toUserId: request.toUserId,
            toUsername: myUsername,
            fromPhotoUrl: request.fromPhotoUrl,
            toPhotoUrl: user.photoURL,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You and ${request.fromUsername} are now friends!',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to accept request.')),
        );
      }
    }
  }

  Future<void> _reject(
    BuildContext context,
    WidgetRef ref,
    FriendRequest request,
  ) async {
    try {
      await ref
          .read(friendServiceProvider)
          .rejectFriendRequest(requestId: request.id);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to decline request.')),
        );
      }
    }
  }

  void _confirmRemove(BuildContext context, WidgetRef ref, Friend friend) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isFrench ? 'Retirer un ami' : 'Remove friend'),
        content: Text(
          isFrench
              ? 'Retirer ${friend.username} de vos amis ?'
              : 'Remove ${friend.username} from your friends?',
        ),
        actions: <TextButton>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isFrench ? 'Annuler' : 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final user = ref.read(currentUserProvider);
              if (user == null) return;
              try {
                await ref.read(friendServiceProvider).removeFriend(
                      userId: user.uid,
                      friendId: friend.userId,
                    );
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to remove friend.'),
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(isFrench ? 'Retirer' : 'Remove'),
          ),
        ],
      ),
    );
  }
}

// ─── Friends tab helper widgets ───────────────────────────────────────────────

class _AddFriendsButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AddFriendsButton({required this.label, required this.onTap});

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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: AppOpacity.muted),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.primary.withValues(alpha: AppOpacity.hairline),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: AppOpacity.faint),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_add_rounded,
                color: AppColors.primary,
                size: 17,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary.withValues(alpha: AppOpacity.firm),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendsSectionHeader extends StatelessWidget {
  final String label;

  const _FriendsSectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        bottom: AppSpacing.xs,
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: AppOpacity.visible),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _FriendsSectionCard extends StatelessWidget {
  final List<Widget> children;

  const _FriendsSectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(
          color: AppColors.babyBlueIce.withValues(alpha: AppOpacity.half),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withValues(alpha: AppOpacity.hairline),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _FriendRow extends StatelessWidget {
  final Friend friend;
  final VoidCallback onRemove;
  final bool isLast;

  const _FriendRow({
    required this.friend,
    required this.onRemove,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xxs,
          ),
          leading: _FriendAvatar(
            photoUrl: friend.photoUrl,
            username: friend.username,
          ),
          title: Text(
            friend.username,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.person_remove_rounded,
              color: AppColors.textSecondary.withValues(alpha: AppOpacity.firm),
              size: 20,
            ),
            onPressed: onRemove,
            tooltip: 'Remove friend',
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: AppSpacing.md + 44 + AppSpacing.sm,
            color: AppColors.babyBlueIce.withValues(alpha: AppOpacity.half),
          ),
      ],
    );
  }
}

class _RequestRow extends StatelessWidget {
  final FriendRequest request;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final bool isLast;

  const _RequestRow({
    required this.request,
    required this.onAccept,
    required this.onReject,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: <Widget>[
              _FriendAvatar(
                photoUrl: request.fromPhotoUrl,
                username: request.fromUsername,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      request.fromUsername,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'wants to be your friend',
                      style: TextStyle(
                        color: AppColors.textSecondary
                            .withValues(alpha: AppOpacity.prominent),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              _FriendActionButton(
                icon: Icons.check_rounded,
                color: AppColors.success,
                onTap: onAccept,
              ),
              const SizedBox(width: AppSpacing.xs),
              _FriendActionButton(
                icon: Icons.close_rounded,
                color: AppColors.error,
                onTap: onReject,
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: AppSpacing.md + 44 + AppSpacing.sm,
            color: AppColors.babyBlueIce.withValues(alpha: AppOpacity.half),
          ),
      ],
    );
  }
}

class _FriendAvatar extends StatelessWidget {
  final String? photoUrl;
  final String username;

  const _FriendAvatar({required this.username, this.photoUrl});

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

class _FriendActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FriendActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: AppOpacity.whisper),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

class _FriendsEmptyState extends StatelessWidget {
  final bool isFrench;
  final VoidCallback onSearch;

  const _FriendsEmptyState({required this.isFrench, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.group_rounded,
              size: 64,
              color:
                  AppColors.babyBlueIce.withValues(alpha: AppOpacity.visible),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              isFrench ? 'Pas encore d\'amis' : 'No friends yet',
              style: TextStyle(
                color: AppColors.textSecondary
                    .withValues(alpha: AppOpacity.prominent),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            TextButton.icon(
              onPressed: onSearch,
              icon: const Icon(Icons.person_add_rounded),
              label: Text(isFrench ? 'Trouver des amis' : 'Find Friends'),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.sm,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
