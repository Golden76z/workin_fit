class ChatConversation {
  final String id;
  final List<String> participants;
  final Map<String, String> participantNames;
  final Map<String, String?> participantPhotos;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final String lastMessageType;
  final DateTime createdAt;
  final Map<String, int> unreadCounts;

  const ChatConversation({
    required this.id,
    required this.participants,
    required this.participantNames,
    required this.participantPhotos,
    required this.lastMessage,
    required this.lastMessageType,
    required this.createdAt,
    this.lastMessageAt,
    this.unreadCounts = const {},
  });

  factory ChatConversation.fromFirestore(
      Map<String, dynamic> data, String id) {
    final names = (data['participantNames'] as Map<String, dynamic>? ?? {})
        .map((k, v) => MapEntry(k, v as String? ?? ''));
    final photos = (data['participantPhotos'] as Map<String, dynamic>? ?? {})
        .map((k, v) => MapEntry(k, v as String?));
    final participants = (data['participants'] as List<dynamic>? ?? [])
        .map((e) => e as String)
        .toList();
    return ChatConversation(
      id: id,
      participants: participants,
      participantNames: names,
      participantPhotos: photos,
      lastMessage: data['lastMessage'] as String? ?? '',
      lastMessageAt: data['lastMessageAt'] != null
          ? DateTime.tryParse(data['lastMessageAt'] as String)
          : null,
      lastMessageType: data['lastMessageType'] as String? ?? 'text',
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      unreadCounts: (data['unreadCounts'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0)),
    );
  }

  int unreadFor(String userId) => unreadCounts[userId] ?? 0;

  Map<String, dynamic> toFirestore() => {
        'participants': participants,
        'participantNames': participantNames,
        'participantPhotos': participantPhotos,
        'lastMessage': lastMessage,
        'lastMessageAt': lastMessageAt?.toUtc().toIso8601String(),
        'lastMessageType': lastMessageType,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'unreadCounts': unreadCounts,
      };

  String otherUserId(String currentUserId) =>
      participants.firstWhere((id) => id != currentUserId,
          orElse: () => '');

  String otherUserName(String currentUserId) =>
      participantNames[otherUserId(currentUserId)] ?? '';

  String? otherUserPhoto(String currentUserId) =>
      participantPhotos[otherUserId(currentUserId)];
}
