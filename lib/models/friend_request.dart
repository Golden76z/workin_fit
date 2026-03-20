class FriendRequest {
  final String id;
  final String fromUserId;
  final String fromUsername;
  final String? fromPhotoUrl;
  final String toUserId;
  final String toUsername;
  final String status; // 'pending'
  final DateTime createdAt;

  const FriendRequest({
    required this.id,
    required this.fromUserId,
    required this.fromUsername,
    required this.toUserId,
    required this.toUsername,
    required this.status,
    required this.createdAt,
    this.fromPhotoUrl,
  });

  factory FriendRequest.fromFirestore(Map<String, dynamic> data, String id) {
    return FriendRequest(
      id: id,
      fromUserId: data['fromUserId'] as String? ?? '',
      fromUsername: data['fromUsername'] as String? ?? '',
      fromPhotoUrl: data['fromPhotoUrl'] as String?,
      toUserId: data['toUserId'] as String? ?? '',
      toUsername: data['toUsername'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fromUserId': fromUserId,
      'fromUsername': fromUsername,
      'fromPhotoUrl': fromPhotoUrl,
      'toUserId': toUserId,
      'toUsername': toUsername,
      'status': status,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }
}
