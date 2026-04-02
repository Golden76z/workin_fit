import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workin_fit/core/constants/app_constants.dart';
import 'package:workin_fit/models/chat_conversation.dart';
import 'package:workin_fit/models/chat_message.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Deterministic chat ID: sort UIDs so A↔B == B↔A.
  String chatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  /// Send a workout share message. Creates the conversation doc if absent.
  Future<void> sendWorkoutShare({
    required String fromUserId,
    required String fromUsername,
    String? fromPhotoUrl,
    required String toUserId,
    required String toUsername,
    String? toPhotoUrl,
    required WorkoutShareData shareData,
    required String comment,
  }) async {
    final cid = chatId(fromUserId, toUserId);
    final now = DateTime.now().toUtc();
    final nowIso = now.toIso8601String();

    final convRef =
        _db.collection(FirebaseConstants.chatsCollection).doc(cid);
    final msgRef =
        convRef.collection(FirebaseConstants.messagesCollection).doc();

    final message = ChatMessage(
      id: msgRef.id,
      senderId: fromUserId,
      type: ChatMessageType.workoutShare,
      content: comment,
      workoutShare: shareData,
      createdAt: now,
    );

    // Use a transaction so that 'createdAt' is written only when the conversation
    // document is first created, and not overwritten on subsequent shares.
    await _db.runTransaction((tx) async {
      final convSnap = await tx.get(convRef);
      final updateFields = <String, dynamic>{
        'participants': [fromUserId, toUserId],
        'participantNames': {
          fromUserId: fromUsername,
          toUserId: toUsername,
        },
        'participantPhotos': {
          fromUserId: fromPhotoUrl,
          toUserId: toPhotoUrl,
        },
        'lastMessage': shareData.sessionName,
        'lastMessageAt': nowIso,
        'lastMessageType': 'workout_share',
        'updatedAt': FieldValue.serverTimestamp(),
        'unreadCounts.$toUserId': FieldValue.increment(1),
      };

      if (!convSnap.exists) {
        // First time — write the full document including createdAt.
        // FieldValue.increment not allowed in tx.set, use concrete map.
        tx.set(convRef, {
          ...updateFields,
          'createdAt': nowIso,
          'unreadCounts': {fromUserId: 0, toUserId: 1},
        }..remove('unreadCounts.$toUserId'));
      } else {
        // Subsequent share — update only the mutable fields.
        tx.update(convRef, updateFields);
      }

      tx.set(msgRef, message.toFirestore());
    });
  }

  /// Send a plain text message. Creates the conversation doc if absent.
  Future<void> sendMessage({
    required String fromUserId,
    required String fromUsername,
    String? fromPhotoUrl,
    required String toUserId,
    required String toUsername,
    String? toPhotoUrl,
    required String content,
  }) async {
    final cid = chatId(fromUserId, toUserId);
    final now = DateTime.now().toUtc();
    final nowIso = now.toIso8601String();

    final convRef =
        _db.collection(FirebaseConstants.chatsCollection).doc(cid);
    final msgRef =
        convRef.collection(FirebaseConstants.messagesCollection).doc();

    final message = ChatMessage(
      id: msgRef.id,
      senderId: fromUserId,
      type: ChatMessageType.text,
      content: content,
      createdAt: now,
    );

    await _db.runTransaction((tx) async {
      final convSnap = await tx.get(convRef);
      final updateFields = <String, dynamic>{
        'participants': [fromUserId, toUserId],
        'participantNames': {fromUserId: fromUsername, toUserId: toUsername},
        'participantPhotos': {fromUserId: fromPhotoUrl, toUserId: toPhotoUrl},
        'lastMessage': content,
        'lastMessageAt': nowIso,
        'lastMessageType': 'text',
        'updatedAt': FieldValue.serverTimestamp(),
        'unreadCounts.$toUserId': FieldValue.increment(1),
      };

      if (!convSnap.exists) {
        tx.set(convRef, {
          ...updateFields,
          'createdAt': nowIso,
          // Use a concrete map on first create — FieldValue.increment is not
          // allowed inside tx.set().
          'unreadCounts': {fromUserId: 0, toUserId: 1},
        }..remove('unreadCounts.$toUserId'));
      } else {
        tx.update(convRef, updateFields);
      }
      tx.set(msgRef, message.toFirestore());
    });
  }

  /// Reset unread count to zero for [userId] in conversation [cid].
  Future<void> markAsRead(String cid, String userId) async {
    await _db
        .collection(FirebaseConstants.chatsCollection)
        .doc(cid)
        .update({'unreadCounts.$userId': 0});
  }

  /// Stream of conversations for [userId], ordered by most recent.
  Stream<List<ChatConversation>> streamConversations(String userId) {
    return _db
        .collection(FirebaseConstants.chatsCollection)
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) =>
                ChatConversation.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Stream of messages for [cid], ordered chronologically.
  Stream<List<ChatMessage>> streamMessages(String cid) {
    return _db
        .collection(FirebaseConstants.chatsCollection)
        .doc(cid)
        .collection(FirebaseConstants.messagesCollection)
        .orderBy('createdAtEpochMs')
        .limitToLast(50)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ChatMessage.fromFirestore(doc.data(), doc.id))
            .toList());
  }
}
