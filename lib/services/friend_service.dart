import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workin_fit/core/constants/app_constants.dart';
import 'package:workin_fit/models/friend.dart';
import 'package:workin_fit/models/friend_request.dart';

class FriendService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Search ────────────────────────────────────────────────────────────────

  /// Search users by username prefix (case-insensitive via usernameSearch field).
  Future<List<Map<String, dynamic>>> searchUsersByUsername(
    String query,
    String currentUserId,
  ) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    final snapshot = await _db
        .collection(FirebaseConstants.usersCollection)
        .where('usernameSearch', isGreaterThanOrEqualTo: q)
        .where('usernameSearch', isLessThanOrEqualTo: '$q\uf8ff')
        .limit(20)
        .get();

    return snapshot.docs
        .where((doc) => doc.id != currentUserId)
        .map((doc) => {'userId': doc.id, ...doc.data()})
        .toList();
  }

  // ── Friend requests ───────────────────────────────────────────────────────

  /// Returns the doc ID used for a request between two users.
  String _requestId(String fromUserId, String toUserId) =>
      '${fromUserId}_$toUserId';

  /// Send a friend request.
  Future<void> sendFriendRequest({
    required String fromUserId,
    required String fromUsername,
    required String toUserId,
    required String toUsername,
    String? fromPhotoUrl,
  }) async {
    final docId = _requestId(fromUserId, toUserId);
    await _db
        .collection(FirebaseConstants.friendRequestsCollection)
        .doc(docId)
        .set({
      'fromUserId': fromUserId,
      'fromUsername': fromUsername,
      'fromPhotoUrl': fromPhotoUrl,
      'toUserId': toUserId,
      'toUsername': toUsername,
      'status': 'pending',
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    });
  }

  /// Cancel a sent friend request.
  Future<void> cancelFriendRequest({
    required String fromUserId,
    required String toUserId,
  }) async {
    final docId = _requestId(fromUserId, toUserId);
    await _db
        .collection(FirebaseConstants.friendRequestsCollection)
        .doc(docId)
        .delete();
  }

  /// Accept a friend request. Creates friend docs for both users atomically.
  Future<void> acceptFriendRequest({
    required String requestId,
    required String fromUserId,
    required String fromUsername,
    required String toUserId,
    required String toUsername,
    String? fromPhotoUrl,
    String? toPhotoUrl,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final batch = _db.batch();

    // Create friend entry for the receiver
    batch.set(
      _db
          .collection(FirebaseConstants.usersCollection)
          .doc(toUserId)
          .collection(FirebaseConstants.friendsCollection)
          .doc(fromUserId),
      {
        'username': fromUsername,
        'photoUrl': fromPhotoUrl,
        'addedAt': now,
      },
    );

    // Create friend entry for the sender
    batch.set(
      _db
          .collection(FirebaseConstants.usersCollection)
          .doc(fromUserId)
          .collection(FirebaseConstants.friendsCollection)
          .doc(toUserId),
      {
        'username': toUsername,
        'photoUrl': toPhotoUrl,
        'addedAt': now,
      },
    );

    // Delete the request
    batch.delete(
      _db
          .collection(FirebaseConstants.friendRequestsCollection)
          .doc(requestId),
    );

    await batch.commit();
  }

  /// Reject (delete) a friend request.
  Future<void> rejectFriendRequest({required String requestId}) async {
    await _db
        .collection(FirebaseConstants.friendRequestsCollection)
        .doc(requestId)
        .delete();
  }

  /// Remove a friend (deletes both sides atomically).
  Future<void> removeFriend({
    required String userId,
    required String friendId,
  }) async {
    final batch = _db.batch();

    batch.delete(
      _db
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .collection(FirebaseConstants.friendsCollection)
          .doc(friendId),
    );

    batch.delete(
      _db
          .collection(FirebaseConstants.usersCollection)
          .doc(friendId)
          .collection(FirebaseConstants.friendsCollection)
          .doc(userId),
    );

    await batch.commit();
  }

  // ── Streams ───────────────────────────────────────────────────────────────

  /// Real-time stream of the user's friends list.
  Stream<List<Friend>> streamFriends(String userId) {
    return _db
        .collection(FirebaseConstants.usersCollection)
        .doc(userId)
        .collection(FirebaseConstants.friendsCollection)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map(
          (s) => s.docs
              .map((doc) => Friend.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Real-time stream of incoming pending friend requests.
  Stream<List<FriendRequest>> streamIncomingRequests(String userId) {
    return _db
        .collection(FirebaseConstants.friendRequestsCollection)
        .where('toUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (s) => s.docs
              .map((doc) => FriendRequest.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Real-time stream of outgoing pending friend requests.
  Stream<List<FriendRequest>> streamOutgoingRequests(String userId) {
    return _db
        .collection(FirebaseConstants.friendRequestsCollection)
        .where('fromUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map(
          (s) => s.docs
              .map((doc) => FriendRequest.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  // ── Status helpers ────────────────────────────────────────────────────────

  /// Returns the relationship status between currentUser and targetUser.
  /// Possible values: null (none), 'friends', 'pending_sent', 'pending_received'
  Future<String?> getFriendStatus(
    String currentUserId,
    String targetUserId,
  ) async {
    // Check if already friends
    final friendDoc = await _db
        .collection(FirebaseConstants.usersCollection)
        .doc(currentUserId)
        .collection(FirebaseConstants.friendsCollection)
        .doc(targetUserId)
        .get();
    if (friendDoc.exists) return 'friends';

    // Check if request was sent
    final sentDoc = await _db
        .collection(FirebaseConstants.friendRequestsCollection)
        .doc(_requestId(currentUserId, targetUserId))
        .get();
    if (sentDoc.exists) return 'pending_sent';

    // Check if request was received
    final receivedDoc = await _db
        .collection(FirebaseConstants.friendRequestsCollection)
        .doc(_requestId(targetUserId, currentUserId))
        .get();
    if (receivedDoc.exists) return 'pending_received';

    return null;
  }
}
