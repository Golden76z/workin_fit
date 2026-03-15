import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workin_fit/models/session_history_entry.dart';

const _kHistoryBox = 'session_history';

// ---------------------------------------------------------------------------
// Box provider
// ---------------------------------------------------------------------------

/// Opens (or returns already-open) the Hive box used for history.
final _historyBoxProvider = FutureProvider<Box<String>>((ref) async {
  if (Hive.isBoxOpen(_kHistoryBox)) {
    return Hive.box<String>(_kHistoryBox);
  }
  return Hive.openBox<String>(_kHistoryBox);
});

// ---------------------------------------------------------------------------
// History list provider
// ---------------------------------------------------------------------------

/// All history entries, newest first.
final sessionHistoryProvider =
    FutureProvider<List<SessionHistoryEntry>>((ref) async {
  final box = await ref.watch(_historyBoxProvider.future);
  final entries = box.values
      .map((raw) {
        try {
          return SessionHistoryEntry.decode(raw);
        } catch (_) {
          return null;
        }
      })
      .whereType<SessionHistoryEntry>()
      .toList()
    ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  return entries;
});

// ---------------------------------------------------------------------------
// Actions provider
// ---------------------------------------------------------------------------

final sessionHistoryActionsProvider =
    Provider<SessionHistoryActions>((ref) => SessionHistoryActions(ref));

class SessionHistoryActions {
  final Ref ref;
  SessionHistoryActions(this.ref);

  Future<void> addEntry(SessionHistoryEntry entry) async {
    final box = await ref.read(_historyBoxProvider.future);
    await box.put(entry.hiveKey, SessionHistoryEntry.encode(entry));
    ref.invalidate(sessionHistoryProvider);
  }

  Future<void> clearHistory() async {
    final box = await ref.read(_historyBoxProvider.future);
    await box.clear();
    ref.invalidate(sessionHistoryProvider);
  }
}
