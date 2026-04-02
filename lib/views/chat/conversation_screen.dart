import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/constants/routes.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/app_opacity.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/features/auth/domain/auth_provider.dart';
import 'package:workin_fit/models/chat_message.dart';
import 'package:workin_fit/providers/chat_providers.dart';
import 'package:workin_fit/widgets/workout_summary_card.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserPhoto,
  });

  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserPhoto;

  @override
  ConsumerState<ConversationScreen> createState() =>
      _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    // Mark conversation as read when opened.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = ref.read(currentUserProvider)?.uid;
      if (userId != null) {
        ref.read(chatServiceProvider).markAsRead(widget.chatId, userId);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(
            _scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _sendMessage() async {
    final content = _inputController.text.trim();
    if (content.isEmpty) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    _inputController.clear();
    setState(() => _sending = true);
    try {
      final profile =
          await ref.read(firestoreServiceProvider).getUserProfile(user.uid);
      final username =
          profile?['username'] as String? ?? user.displayName ?? 'User';
      await ref.read(chatServiceProvider).sendMessage(
            fromUserId: user.uid,
            fromUsername: username,
            fromPhotoUrl: user.photoURL,
            toUserId: widget.otherUserId,
            toUsername: widget.otherUserName,
            toPhotoUrl: widget.otherUserPhoto,
            content: content,
          );
    } catch (e, st) {
      debugPrint('ConversationScreen: _sendMessage failed — $e\n$st');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to send. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(currentUserProvider)?.uid ?? '';
    final messagesAsync =
        ref.watch(messagesStreamProvider(widget.chatId));

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor:
                  AppColors.primary.withValues(alpha: AppOpacity.faint),
              backgroundImage: widget.otherUserPhoto != null
                  ? NetworkImage(widget.otherUserPhoto!)
                  : null,
              child: widget.otherUserPhoto == null
                  ? Text(
                      widget.otherUserName.isNotEmpty
                          ? widget.otherUserName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          color: AppColors.primary, fontSize: 13),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              widget.otherUserName,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                fontFamily: 'AppFontMedium',
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }
                // Scroll to the newest message whenever the list updates.
                _scrollToBottom();
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == currentUserId;
                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: msg.type == ChatMessageType.workoutShare &&
                                msg.workoutShare != null
                            ? SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.78,
                                child: WorkoutSummaryCard(
                                  shareData: msg.workoutShare!,
                                  comment: msg.content,
                                  onStartWorkout: isMe
                                      ? null
                                      : () => _startWorkout(
                                          context, msg.workoutShare!),
                                ),
                              )
                            : Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.72,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? AppColors.primary
                                          .withValues(alpha: 0.8)
                                      : AppColors.surface,
                                  borderRadius:
                                      BorderRadius.circular(AppRadii.md),
                                ),
                                child: Text(
                                  msg.content,
                                  style: const TextStyle(
                                      color: AppColors.textPrimary),
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
                  'Could not load messages.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          ),
          _buildInputBar(context),
        ],
      ),
    );
  }

  Widget _buildInputBar(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Message…',
                hintStyle: TextStyle(
                    color: AppColors.textSecondary
                        .withValues(alpha: AppOpacity.visible)),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                  borderSide: BorderSide.none,
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            onPressed: _sending ? null : _sendMessage,
            icon: const Icon(Icons.send_rounded),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Future<void> _startWorkout(
    BuildContext context,
    WorkoutShareData share,
  ) async {
    final firestoreService = ref.read(firestoreServiceProvider);
    try {
      final session = await firestoreService.getSessionByOwner(
          share.ownerId, share.sessionId);
      if (session == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Workout session not found.')),
          );
        }
        return;
      }
      if (context.mounted) {
        Navigator.of(context).pushNamed(
          RouteConstants.workoutExecution,
          arguments: session,
        );
      }
    } catch (e, st) {
      debugPrint('ConversationScreen: _startWorkout failed — $e\n$st');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Could not load workout. Please try again.')),
        );
      }
    }
  }
}
