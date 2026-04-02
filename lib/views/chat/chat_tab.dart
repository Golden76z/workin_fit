import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_chrome.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/app_opacity.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/features/auth/domain/auth_provider.dart';
import 'package:workin_fit/providers/chat_providers.dart';
import 'package:workin_fit/views/chat/conversation_screen.dart';

class ChatTab extends ConsumerWidget {
  const ChatTab({super.key});

  static String _formatTime(DateTime dt) {
    final now = DateTime.now().toUtc();
    final diff = now.difference(dt.toUtc());
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsStreamProvider);
    final currentUserId = ref.watch(currentUserProvider)?.uid ?? '';

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
            Opacity(
              opacity: 0.35,
              child: IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: null,
                tooltip: 'New conversation — coming soon',
              ),
            ),
          ],
        ),
        body: conversationsAsync.when(
          data: (conversations) {
            if (conversations.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: AppColors.primary
                              .withValues(alpha: AppOpacity.faint),
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
                        'Share your workouts with friends after completing them.',
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
              );
            }

            return ListView.separated(
              itemCount: conversations.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: Colors.white.withValues(alpha: 0.08),
              ),
              itemBuilder: (context, index) {
                final conv = conversations[index];
                final otherUserId = conv.otherUserId(currentUserId);
                final otherName = conv.otherUserName(currentUserId);
                final photoUrl = conv.otherUserPhoto(currentUserId);
                final lastAt = conv.lastMessageAt;
                final unreadCount = conv.unreadFor(currentUserId);

                return ListTile(
                  tileColor: AppColors.surface,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary
                        .withValues(alpha: AppOpacity.faint),
                    backgroundImage: photoUrl != null
                        ? NetworkImage(photoUrl)
                        : null,
                    child: photoUrl == null
                        ? Text(
                            otherName.isNotEmpty
                                ? otherName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                                color: AppColors.primary),
                          )
                        : null,
                  ),
                  title: Text(
                    otherName,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: unreadCount > 0
                          ? FontWeight.w700
                          : FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    conv.lastMessage,
                    style: TextStyle(
                      color: AppColors.textSecondary
                          .withValues(alpha: AppOpacity.bold),
                      fontSize: 13,
                      fontWeight: unreadCount > 0
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (lastAt != null)
                        Text(
                          _formatTime(lastAt),
                          style: TextStyle(
                            color: AppColors.textSecondary
                                .withValues(alpha: AppOpacity.visible),
                            fontSize: 12,
                          ),
                        ),
                      if (unreadCount > 0) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Badge(
                          label: Text(
                            '$unreadCount',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 11),
                          ),
                          backgroundColor: AppColors.primary,
                          child: const SizedBox.shrink(),
                        ),
                      ],
                    ],
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ConversationScreen(
                        chatId: conv.id,
                        otherUserId: otherUserId,
                        otherUserName: otherName,
                        otherUserPhoto: photoUrl,
                      ),
                    ),
                  ),
                );
              },
            );
          },
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(
            child: Text(
              'Could not load chats.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}
