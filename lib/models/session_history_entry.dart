import 'dart:convert';

/// A record of a completed session, persisted in Hive as JSON.
class SessionHistoryEntry {
  final String sessionId;
  final String sessionName;
  final String durationDisplay;
  final DateTime completedAt;

  const SessionHistoryEntry({
    required this.sessionId,
    required this.sessionName,
    required this.durationDisplay,
    required this.completedAt,
  });

  /// Hive key: milliseconds since epoch (unique per entry).
  String get hiveKey => completedAt.millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'sessionName': sessionName,
        'durationDisplay': durationDisplay,
        'completedAt': completedAt.toIso8601String(),
      };

  factory SessionHistoryEntry.fromJson(Map<String, dynamic> json) =>
      SessionHistoryEntry(
        sessionId: json['sessionId'] as String,
        sessionName: json['sessionName'] as String,
        durationDisplay: json['durationDisplay'] as String,
        completedAt: DateTime.parse(json['completedAt'] as String),
      );

  static String encode(SessionHistoryEntry entry) =>
      jsonEncode(entry.toJson());

  static SessionHistoryEntry decode(String raw) =>
      SessionHistoryEntry.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
}
