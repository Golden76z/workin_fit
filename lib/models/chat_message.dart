class WorkoutShareData {
  final String sessionId;
  final String ownerId;
  final String sessionName;
  final int durationSeconds;
  final int exerciseCount;
  final int totalReps;
  final int totalWorkSeconds;
  final String difficulty;
  final String workoutHistoryId;

  const WorkoutShareData({
    required this.sessionId,
    required this.ownerId,
    required this.sessionName,
    required this.durationSeconds,
    required this.exerciseCount,
    required this.totalReps,
    required this.totalWorkSeconds,
    required this.difficulty,
    required this.workoutHistoryId,
  });

  factory WorkoutShareData.fromMap(Map<String, dynamic> data) {
    return WorkoutShareData(
      sessionId: data['sessionId'] as String? ?? '',
      ownerId: data['ownerId'] as String? ?? '',
      sessionName: data['sessionName'] as String? ?? '',
      durationSeconds: _asInt(data['durationSeconds']),
      exerciseCount: _asInt(data['exerciseCount']),
      totalReps: _asInt(data['totalReps']),
      totalWorkSeconds: _asInt(data['totalWorkSeconds']),
      difficulty: data['difficulty'] as String? ?? '',
      workoutHistoryId: data['workoutHistoryId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'sessionId': sessionId,
    'ownerId': ownerId,
    'sessionName': sessionName,
    'durationSeconds': durationSeconds,
    'exerciseCount': exerciseCount,
    'totalReps': totalReps,
    'totalWorkSeconds': totalWorkSeconds,
    'difficulty': difficulty,
    'workoutHistoryId': workoutHistoryId,
  };

  static int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.round();
    return 0;
  }
}

enum ChatMessageType { text, workoutShare }

class ChatMessage {
  final String id;
  final String senderId;
  final ChatMessageType type;
  final String content;
  final WorkoutShareData? workoutShare;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.type,
    required this.content,
    required this.createdAt,
    this.workoutShare,
  });

  factory ChatMessage.fromFirestore(Map<String, dynamic> data, String id) {
    final typeStr = data['type'] as String? ?? 'text';
    final type = typeStr == 'workout_share'
        ? ChatMessageType.workoutShare
        : ChatMessageType.text;
    final wsData = data['workoutShare'];
    return ChatMessage(
      id: id,
      senderId: data['senderId'] as String? ?? '',
      type: type,
      content: data['content'] as String? ?? '',
      workoutShare: wsData is Map<String, dynamic>
          ? WorkoutShareData.fromMap(wsData)
          : null,
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'senderId': senderId,
    'type': type == ChatMessageType.workoutShare ? 'workout_share' : 'text',
    'content': content,
    if (workoutShare != null) 'workoutShare': workoutShare!.toMap(),
    'createdAt': createdAt.toUtc().toIso8601String(),
    'createdAtEpochMs': createdAt.toUtc().millisecondsSinceEpoch,
  };
}
