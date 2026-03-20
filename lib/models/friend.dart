class Friend {
  final String userId;
  final String username;
  final String? photoUrl;
  final DateTime addedAt;

  const Friend({
    required this.userId,
    required this.username,
    required this.addedAt,
    this.photoUrl,
  });

  factory Friend.fromFirestore(Map<String, dynamic> data, String id) {
    return Friend(
      userId: id,
      username: data['username'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      addedAt: data['addedAt'] != null
          ? DateTime.tryParse(data['addedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'photoUrl': photoUrl,
      'addedAt': addedAt.toUtc().toIso8601String(),
    };
  }
}
