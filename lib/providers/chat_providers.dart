import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/features/auth/domain/auth_provider.dart';
import 'package:workin_fit/models/chat_conversation.dart';
import 'package:workin_fit/models/chat_message.dart';
import 'package:workin_fit/services/chat_service.dart';

final chatServiceProvider = Provider<ChatService>((ref) => ChatService());

final conversationsStreamProvider =
    StreamProvider<List<ChatConversation>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(chatServiceProvider).streamConversations(user.uid);
});

final messagesStreamProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, chatId) {
  return ref.watch(chatServiceProvider).streamMessages(chatId);
});
