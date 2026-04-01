class ActiveProgramState {
  final String programId;
  final DateTime startDate;

  const ActiveProgramState({
    required this.programId,
    required this.startDate,
  });

  DateTime get startDateOnly =>
      DateTime(startDate.year, startDate.month, startDate.day);

  int elapsedDays({DateTime? now}) {
    final DateTime today = now ?? DateTime.now();
    final DateTime todayOnly = DateTime(today.year, today.month, today.day);
    return todayOnly.difference(startDateOnly).inDays;
  }

  static ActiveProgramState? fromUserProfile(Map<String, dynamic>? data) {
    if (data == null) return null;

    final String programId = (data['activeProgramId'] as String? ?? '').trim();
    if (programId.isEmpty) return null;

    final DateTime? parsedStartDate = _parseDateTime(
      data['activeProgramStartDate'],
    );
    if (parsedStartDate == null) return null;

    return ActiveProgramState(
      programId: programId,
      startDate: DateTime(
        parsedStartDate.year,
        parsedStartDate.month,
        parsedStartDate.day,
      ),
    );
  }

  static DateTime? _parseDateTime(dynamic raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw;
    if (raw is String) return DateTime.tryParse(raw);

    try {
      final DateTime converted = (raw as dynamic).toDate() as DateTime;
      return converted;
    } catch (_) {
      return null;
    }
  }
}
