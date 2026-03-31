import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_chrome.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/features/auth/domain/auth_provider.dart';
import 'package:workin_fit/models/friend.dart';
import 'package:workin_fit/models/friend_request.dart';
import 'package:workin_fit/providers/friend_providers.dart';
import 'package:workin_fit/views/social/friend_search_screen.dart';
import 'package:workin_fit/core/theme/app_opacity.dart';

class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomingAsync = ref.watch(incomingRequestsProvider);
    final incomingCount = incomingAsync.valueOrNull?.length ?? 0;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.surfaceVariant,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          systemOverlayStyle: AppChrome.topSurfaceOverlay,
          flexibleSpace: const AppTopBarBackground(),
          title: const Text(
            'Friends',
            style: TextStyle(
              fontFamily: 'AppFontMedium',
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add_rounded),
              tooltip: 'Find friends',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const FriendSearchScreen(),
                ),
              ),
            ),
          ],
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              fontFamily: 'AppFontMedium',
            ),
            tabs: [
              const Tab(text: 'Friends'),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Requests'),
                    if (incomingCount > 0) ...[
                      const SizedBox(width: 6),
                      _Badge(count: incomingCount),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _FriendsTab(),
            _RequestsTab(),
          ],
        ),
      ),
    );
  }
}

// ─── Badge ────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final int count;

  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─── Friends tab ──────────────────────────────────────────────────────────────

class _FriendsTab extends ConsumerWidget {
  const _FriendsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsAsync = ref.watch(friendsStreamProvider);

    return friendsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (e, _) => Center(
        child: Text(
          'Failed to load friends',
          style: TextStyle(
              color: AppColors.textSecondary
                  .withValues(alpha: AppOpacity.prominent)),
        ),
      ),
      data: (friends) {
        if (friends.isEmpty) {
          return _EmptyFriends(
            onSearch: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const FriendSearchScreen(),
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          itemCount: friends.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            indent: AppSpacing.md + 44 + AppSpacing.sm,
            color: AppColors.babyBlueIce.withValues(alpha: AppOpacity.half),
          ),
          itemBuilder: (context, i) => _FriendTile(
            friend: friends[i],
            onRemove: () => _confirmRemove(context, ref, friends[i]),
          ),
        );
      },
    );
  }

  void _confirmRemove(BuildContext context, WidgetRef ref, Friend friend) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove friend'),
        content: Text('Remove ${friend.username} from your friends?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
                    const SnackBar(content: Text('Failed to remove friend.')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

class _FriendTile extends StatelessWidget {
  final Friend friend;
  final VoidCallback onRemove;

  const _FriendTile({required this.friend, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xxs,
      ),
      leading: _Avatar(photoUrl: friend.photoUrl, username: friend.username),
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
    );
  }
}

// ─── Requests tab ─────────────────────────────────────────────────────────────

class _RequestsTab extends ConsumerWidget {
  const _RequestsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(incomingRequestsProvider);

    return requestsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (e, _) => Center(
        child: Text(
          'Failed to load requests',
          style: TextStyle(
              color: AppColors.textSecondary
                  .withValues(alpha: AppOpacity.prominent)),
        ),
      ),
      data: (requests) {
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.mark_email_read_rounded,
                  size: 64,
                  color: AppColors.babyBlueIce
                      .withValues(alpha: AppOpacity.visible),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No pending requests',
                  style: TextStyle(
                    color: AppColors.textSecondary
                        .withValues(alpha: AppOpacity.prominent),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          itemCount: requests.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            indent: AppSpacing.md + 44 + AppSpacing.sm,
            color: AppColors.babyBlueIce.withValues(alpha: AppOpacity.half),
          ),
          itemBuilder: (context, i) => _RequestTile(
            request: requests[i],
            onAccept: () => _accept(context, ref, requests[i]),
            onReject: () => _reject(context, ref, requests[i]),
          ),
        );
      },
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
            content: Text('You and ${request.fromUsername} are now friends!'),
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
}

class _RequestTile extends StatelessWidget {
  final FriendRequest request;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _RequestTile({
    required this.request,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          _Avatar(
            photoUrl: request.fromPhotoUrl,
            username: request.fromUsername,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
          _IconActionButton(
            icon: Icons.check_rounded,
            color: AppColors.success,
            onTap: onAccept,
            tooltip: 'Accept',
          ),
          const SizedBox(width: AppSpacing.xs),
          _IconActionButton(
            icon: Icons.close_rounded,
            color: AppColors.error,
            onTap: onReject,
            tooltip: 'Decline',
          ),
        ],
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;

  const _IconActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
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
      ),
    );
  }
}

// ─── Shared avatar ────────────────────────────────────────────────────────────

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

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyFriends extends StatelessWidget {
  final VoidCallback onSearch;

  const _EmptyFriends({required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.group_rounded,
            size: 64,
            color: AppColors.babyBlueIce.withValues(alpha: AppOpacity.visible),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No friends yet',
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
            label: const Text('Find Friends'),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.xl),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
