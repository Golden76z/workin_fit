# Plan: Workout Sharing to Friends

## Summary
Allow users to share completed workouts with friends via an in-app chat system. After finishing a workout, the user can tap a share button, choose a friend, add an optional comment, and send a workout summary card that appears in both users' Chat tab. The recipient can read the stats and tap "Start This Workout" to re-run the same session.

## User Story
As a fitness app user, I want to share my completed workouts with friends, so that I can celebrate achievements and motivate friends to try the same sessions.

## Problem → Solution
Currently the Chat tab shows a placeholder ("coming soon"). After a workout completes the user has no way to share the result. → Build the full chat infrastructure (Firestore model + service + providers + UI), add a share sheet on the post-workout screen, and render shared workout cards in conversations with a "Start This Workout" CTA.

## Metadata
- **Complexity**: Large
- **Source PRD**: N/A (GitHub issue #30)
- **PRD Phase**: N/A
- **Estimated Files**: 12 new + 4 modified

---

## UX Design

### Before
```
┌─────────────────────────────────────────┐
│  WORKOUT COMPLETE 🏆                    │
│  Duration · Exercises · Reps · Work     │
│  [Per-exercise breakdown]               │
│                                         │
│  [No share option]                      │
│                                         │
│  [DONE]                                 │
└─────────────────────────────────────────┘

Chat Tab:
┌─────────────────────────────────────────┐
│  "No conversations yet — coming soon"   │
└─────────────────────────────────────────┘
```

### After
```
┌─────────────────────────────────────────┐
│  WORKOUT COMPLETE 🏆                    │
│  Duration · Exercises · Reps · Work     │
│  [Per-exercise breakdown]               │
│                                         │
│  [SHARE WITH A FRIEND]   [DONE]         │
└─────────────────────────────────────────┘

Share Sheet (bottom sheet):
┌─────────────────────────────────────────┐
│  Share "Push Day" 💪                    │
│  ┌──────────────────────────────────┐   │
│  │ 32 min · 5 exercises · 120 reps  │   │
│  └──────────────────────────────────┘   │
│  Add a comment... (optional)            │
│  ─── Friends ───                        │
│  ○ Alice     ○ Bob     ○ Carol          │
│                   [SEND]                │
└─────────────────────────────────────────┘

Chat Tab (list of conversations):
┌─────────────────────────────────────────┐
│  Chat                          [✏️]      │
│  ┌──────────────────────────────────┐   │
│  │ 👤 Alice  · Shared a workout 2m  │   │
│  └──────────────────────────────────┘   │
└─────────────────────────────────────────┘

Conversation Screen:
┌─────────────────────────────────────────┐
│  ← Alice                                │
│                                         │
│  ┌──────────────────────────────────┐   │
│  │ 💪 Push Day                      │   │
│  │ 32 min · 5 exercises · 120 reps  │   │
│  │ "Crushed it today!"              │   │
│  │          [START THIS WORKOUT]    │   │
│  └──────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

### Interaction Changes
| Touchpoint | Before | After | Notes |
|---|---|---|---|
| Workout completion screen | Done button only | Done + Share button | Share opens bottom sheet |
| Share sheet | N/A | Friend picker + comment + Send | Sends Firestore doc |
| Chat tab | "Coming soon" placeholder | Real conversation list | Streams from Firestore |
| Conversation screen | N/A (doesn't exist) | Full message thread | New route |
| Workout share card | N/A | Stats card + "Start" CTA | Appears in conversation |

---

## Mandatory Reading

Files that MUST be read before implementing:

| Priority | File | Lines | Why |
|---|---|---|---|
| P0 | `lib/features/workout/presentation/screens/workout_execution_screen.dart` | 1507-1733 | `_buildFinishedSummary()` — share button goes here |
| P0 | `lib/views/chat/chat_tab.dart` | 1-89 | Full replacement target |
| P0 | `lib/services/firestore_service.dart` | 1-100, 729-863 | Firestore patterns to follow for chat service |
| P0 | `lib/models/friend.dart` | all | Friend model pattern (fromFirestore, toFirestore) |
| P0 | `lib/providers/friend_providers.dart` | all | StreamProvider pattern to mirror for chat providers |
| P1 | `lib/core/constants/app_constants.dart` | all | Add chat collection constants here |
| P1 | `lib/core/constants/routes.dart` | all | Add conversation route |
| P1 | `lib/views/home/home_page.dart` | all | Understand tab structure |
| P1 | `lib/providers/workout_providers.dart` | all | Provider patterns (FutureProvider.family) |
| P2 | `lib/services/friend_service.dart` | all | Service class structure to mirror |
| P2 | `lib/views/social/social_tab.dart` | 1-100 | Widget/tab structural pattern |

## External Documentation
| Topic | Source | Key Takeaway |
|---|---|---|
| None needed | — | Feature uses established internal Firestore + Riverpod patterns |

---

## Patterns to Mirror

### NAMING_CONVENTION
```dart
// SOURCE: lib/models/friend.dart:1-33
class Friend {
  final String userId;
  final String username;
  final String? photoUrl;
  final DateTime addedAt;

  const Friend({...});

  factory Friend.fromFirestore(Map<String, dynamic> data, String id) {...}
  Map<String, dynamic> toFirestore() {...}
}
// → ChatMessage, ChatConversation, WorkoutShareData follow identical structure
```

### PROVIDER_PATTERN
```dart
// SOURCE: lib/providers/friend_providers.dart:8-25
final friendsStreamProvider = StreamProvider<List<Friend>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.read(friendServiceProvider).streamFriends(user.uid);
});
// → conversationsStreamProvider, messagesStreamProvider follow same guard pattern
```

### SERVICE_PATTERN
```dart
// SOURCE: lib/services/friend_service.dart (structure)
class FriendService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // Private _db instance, all methods return Future<void> or Stream<List<T>>
  // No constructor injection needed — matches codebase style
}
// → ChatService follows same structure
```

### FIRESTORE_BATCH_PATTERN
```dart
// SOURCE: lib/services/firestore_service.dart:760-850
final WriteBatch batch = _firestore.batch();
batch.set(historyDocRef, {...});
batch.set(monthDocRef, {...}, SetOptions(merge: true));
await batch.commit();
// → Sending a workout share updates BOTH chats/{chatId} AND chats/{chatId}/messages/{msgId}
```

### FIRESTORE_FROM_SNAPSHOT_PATTERN
```dart
// SOURCE: lib/services/friend_service.dart (stream methods)
Stream<List<Friend>> streamFriends(String userId) {
  return _db
    .collection('users').doc(userId).collection('friends')
    .snapshots()
    .map((snap) => snap.docs
      .map((doc) => Friend.fromFirestore(doc.data(), doc.id))
      .toList());
}
// → streamConversations, streamMessages follow identical .snapshots().map() chain
```

### ERROR_HANDLING
```dart
// SOURCE: lib/services/firestore_service.dart:857-859
} catch (e) {
  throw FirestoreException('Unexpected error saving workout history: $e');
}
// → ChatService wraps Firestore exceptions with descriptive messages; UI silently ignores
```

### BOTTOM_SHEET_PATTERN
```dart
// SOURCE: lib/features/workout/presentation/screens/workout_execution_screen.dart
// _openActualMetricsSheet() uses showModalBottomSheet with DraggableScrollableSheet
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => DraggableScrollableSheet(
    initialChildSize: 0.7,
    builder: (_, controller) => Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.lg)),
      ),
      child: ...,
    ),
  ),
);
// → ShareWorkoutSheet follows this exact structure
```

### WIDGET_CONSUMER_PATTERN
```dart
// SOURCE: lib/views/social/social_tab.dart (ConsumerStatefulWidget)
class SocialTab extends ConsumerStatefulWidget {
  const SocialTab({super.key});
  @override
  ConsumerState<SocialTab> createState() => _SocialTabState();
}
class _SocialTabState extends ConsumerState<SocialTab> {
  // ref.watch() for streams, ref.read() for one-time reads
}
// → ChatTab, ConversationScreen follow same pattern
```

### ROUTE_CONSTANT
```dart
// SOURCE: lib/core/constants/routes.dart
class RouteConstants {
  static const String chat = '/chat';
  // → Add: static const String conversation = '/chat/conversation';
}
```

---

## Firestore Data Structure

```
chats/{chatId}/                        ← chatId = [uid1, uid2].sort().join('_')
  participants: [uid1, uid2]
  participantNames: {uid1: "Alice", uid2: "Bob"}
  participantPhotos: {uid1: "url|null", uid2: "url|null"}
  lastMessage: "Shared a workout: Push Day"
  lastMessageAt: ISO8601 string
  lastMessageType: "workout_share" | "text"
  createdAt: serverTimestamp
  updatedAt: serverTimestamp

chats/{chatId}/messages/{messageId}/
  senderId: string
  type: "workout_share" | "text"
  content: string                       ← comment for workout_share, body for text
  workoutShare?: {
    sessionId: string
    sessionName: string
    durationSeconds: int
    exerciseCount: int
    totalReps: int
    totalWorkSeconds: int
    difficulty: string
    workoutHistoryId: string            ← doc ID under workout_history subcollection
  }
  createdAt: ISO8601 string
  createdAtEpochMs: int
```

---

## Files to Change

| File | Action | Justification |
|---|---|---|
| `lib/models/chat_message.dart` | CREATE | ChatMessage model with fromFirestore/toFirestore |
| `lib/models/chat_conversation.dart` | CREATE | ChatConversation model for list view |
| `lib/services/chat_service.dart` | CREATE | Firestore operations for chat + share |
| `lib/providers/chat_providers.dart` | CREATE | Riverpod providers for conversations + messages |
| `lib/widgets/workout_summary_card.dart` | CREATE | Reusable card widget showing workout stats |
| `lib/widgets/share_workout_sheet.dart` | CREATE | Bottom sheet: friend picker + comment + send |
| `lib/views/chat/chat_tab.dart` | MODIFY | Replace placeholder with ConversationList |
| `lib/views/chat/conversation_screen.dart` | CREATE | Message thread screen |
| `lib/core/constants/app_constants.dart` | MODIFY | Add messagesCollection constant |
| `lib/core/constants/routes.dart` | MODIFY | Add conversation route constant |
| `lib/views/home/home_page.dart` | MODIFY | Wire conversation route in onGenerateRoute or push |
| `lib/features/workout/presentation/screens/workout_execution_screen.dart` | MODIFY | Add Share button in `_buildFinishedSummary()` |

## NOT Building
- Text-only messaging between friends (only workout shares in scope; text field shown as optional comment on share, not a full text chat)
- Read receipts / typing indicators
- Push notifications for received shares
- Ability to delete/unsend a share
- Pagination of messages (load all for MVP)
- Group chats

---

## Step-by-Step Tasks

### Task 1: Add Firestore constants
- **ACTION**: Add `messagesCollection` to `FirebaseConstants` in `app_constants.dart`
- **IMPLEMENT**:
  ```dart
  static const String messagesCollection = 'messages';
  ```
- **MIRROR**: Existing constants pattern in `FirebaseConstants`
- **IMPORTS**: None
- **GOTCHA**: `chatsCollection` already exists (`'chats'`) — just add `messagesCollection`
- **VALIDATE**: File compiles without errors; grep for `messagesCollection` finds the new constant

### Task 2: Add conversation route constant
- **ACTION**: Add route in `RouteConstants`
- **IMPLEMENT**:
  ```dart
  static const String conversation = '/chat/conversation';
  ```
- **MIRROR**: `lib/core/constants/routes.dart` existing pattern
- **IMPORTS**: None
- **GOTCHA**: Route must be nested under `/chat` to stay semantically consistent
- **VALIDATE**: Grep finds `conversation` in routes.dart

### Task 3: Create ChatMessage model
- **ACTION**: Create `lib/models/chat_message.dart`
- **IMPLEMENT**:
  ```dart
  class WorkoutShareData {
    final String sessionId;
    final String sessionName;
    final int durationSeconds;
    final int exerciseCount;
    final int totalReps;
    final int totalWorkSeconds;
    final String difficulty;
    final String workoutHistoryId;

    const WorkoutShareData({
      required this.sessionId,
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
    final String content;  // comment for workoutShare, body for text
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
  ```
- **MIRROR**: `NAMING_CONVENTION` pattern (Friend model)
- **IMPORTS**: None (pure Dart)
- **GOTCHA**: `createdAt` stored as ISO8601 string (consistent with the rest of the app — NOT a Firestore Timestamp)
- **VALIDATE**: File compiles; `ChatMessage.fromFirestore` round-trips through `toFirestore()`

### Task 4: Create ChatConversation model
- **ACTION**: Create `lib/models/chat_conversation.dart`
- **IMPLEMENT**:
  ```dart
  class ChatConversation {
    final String id;             // chatId = sorted UIDs joined by '_'
    final List<String> participants;
    final Map<String, String> participantNames;
    final Map<String, String?> participantPhotos;
    final String lastMessage;
    final DateTime? lastMessageAt;
    final String lastMessageType;  // 'workout_share' | 'text'
    final DateTime createdAt;

    const ChatConversation({
      required this.id,
      required this.participants,
      required this.participantNames,
      required this.participantPhotos,
      required this.lastMessage,
      required this.lastMessageType,
      required this.createdAt,
      this.lastMessageAt,
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
      );
    }

    /// Returns the other participant's user ID (not the current user).
    String otherUserId(String currentUserId) =>
        participants.firstWhere((id) => id != currentUserId,
            orElse: () => '');

    /// Returns the other participant's display name.
    String otherUserName(String currentUserId) =>
        participantNames[otherUserId(currentUserId)] ?? '';

    /// Returns the other participant's photo URL (may be null).
    String? otherUserPhoto(String currentUserId) =>
        participantPhotos[otherUserId(currentUserId)];
  }
  ```
- **MIRROR**: `NAMING_CONVENTION` pattern
- **IMPORTS**: None
- **GOTCHA**: `createdAt` from Firestore may be a `serverTimestamp` — guard with null-safe parse
- **VALIDATE**: Compiles cleanly

### Task 5: Create ChatService
- **ACTION**: Create `lib/services/chat_service.dart`
- **IMPLEMENT**:
  ```dart
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
      required String comment,   // may be empty
    }) async {
      final cid = chatId(fromUserId, toUserId);
      final now = DateTime.now().toUtc();
      final nowIso = now.toIso8601String();
      final batch = _db.batch();

      final convRef = _db.collection(FirebaseConstants.chatsCollection).doc(cid);
      final msgRef = convRef
          .collection(FirebaseConstants.messagesCollection)
          .doc();

      final message = ChatMessage(
        id: msgRef.id,
        senderId: fromUserId,
        type: ChatMessageType.workoutShare,
        content: comment,
        workoutShare: shareData,
        createdAt: now,
      );

      // Upsert conversation doc (merge: true keeps existing fields)
      batch.set(
        convRef,
        {
          'participants': [fromUserId, toUserId],
          'participantNames': {fromUserId: fromUsername, toUserId: toUsername},
          'participantPhotos': {fromUserId: fromPhotoUrl, toUserId: toPhotoUrl},
          'lastMessage': 'Shared a workout: ${shareData.sessionName}',
          'lastMessageAt': nowIso,
          'lastMessageType': 'workout_share',
          'updatedAt': FieldValue.serverTimestamp(),
          'createdAt': nowIso,
        },
        SetOptions(merge: true),
      );

      // Add message to subcollection
      batch.set(msgRef, message.toFirestore());

      await batch.commit();
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
          .snapshots()
          .map((snap) => snap.docs
              .map((doc) => ChatMessage.fromFirestore(doc.data(), doc.id))
              .toList());
    }
  }
  ```
- **MIRROR**: `SERVICE_PATTERN`, `FIRESTORE_BATCH_PATTERN`, `FIRESTORE_FROM_SNAPSHOT_PATTERN`
- **IMPORTS**: `cloud_firestore`, app_constants, chat models
- **GOTCHA**: The Firestore query `.where('participants', arrayContains: userId).orderBy('lastMessageAt')` requires a **composite index**. Add it to `firestore.indexes.json` or create it via Firebase Console when the query fails in dev. The error message in the console will contain the direct link.
- **VALIDATE**: Manual test: calling `sendWorkoutShare()` creates two Firestore docs; `streamConversations` emits the new conversation

### Task 6: Create chat Riverpod providers
- **ACTION**: Create `lib/providers/chat_providers.dart`
- **IMPLEMENT**:
  ```dart
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
    return ref.read(chatServiceProvider).streamConversations(user.uid);
  });

  final messagesStreamProvider =
      StreamProvider.family<List<ChatMessage>, String>((ref, chatId) {
    return ref.read(chatServiceProvider).streamMessages(chatId);
  });
  ```
- **MIRROR**: `PROVIDER_PATTERN` (friend_providers.dart)
- **IMPORTS**: flutter_riverpod, auth_provider, models, chat_service
- **GOTCHA**: `messagesStreamProvider` uses `.family<List<ChatMessage>, String>` — pass the chatId as argument when watching: `ref.watch(messagesStreamProvider(chatId))`
- **VALIDATE**: Providers compile; `conversationsStreamProvider` is watchable in a ConsumerWidget

### Task 7: Create WorkoutSummaryCard widget
- **ACTION**: Create `lib/widgets/workout_summary_card.dart`
- **IMPLEMENT**:
  ```dart
  import 'package:flutter/material.dart';
  import 'package:workin_fit/core/theme/colors.dart';
  import 'package:workin_fit/core/theme/app_dimensions.dart';
  import 'package:workin_fit/models/chat_message.dart';

  class WorkoutSummaryCard extends StatelessWidget {
    const WorkoutSummaryCard({
      super.key,
      required this.shareData,
      required this.comment,
      this.onStartWorkout,   // null → no button shown (sender's own card)
    });

    final WorkoutShareData shareData;
    final String comment;
    final VoidCallback? onStartWorkout;

    @override
    Widget build(BuildContext context) {
      final minutes = shareData.durationSeconds ~/ 60;
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.md),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.fitness_center_rounded,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    shareData.sessionName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                _Chip('$minutes min'),
                _Chip('${shareData.exerciseCount} exercises'),
                if (shareData.totalReps > 0) _Chip('${shareData.totalReps} reps'),
              ],
            ),
            if (comment.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                '"$comment"',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                ),
              ),
            ],
            if (onStartWorkout != null) ...[
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onStartWorkout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.sm),
                    ),
                  ),
                  child: const Text('Start This Workout'),
                ),
              ),
            ],
          ],
        ),
      );
    }
  }

  class _Chip extends StatelessWidget {
    const _Chip(this.label);
    final String label;

    @override
    Widget build(BuildContext context) {
      return Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppSpacing.xs),
        ),
        child: Text(
          label,
          style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600),
        ),
      );
    }
  }
  ```
- **MIRROR**: Widget/theme patterns from social_tab.dart; AppColors, AppSpacing constants
- **IMPORTS**: flutter/material, core/theme, models/chat_message
- **GOTCHA**: Use `withValues(alpha: ...)` not `withOpacity()` — matches app codebase style
- **VALIDATE**: Widget renders in isolation; shows session name, chips, optional comment, optional button

### Task 8: Create ShareWorkoutSheet
- **ACTION**: Create `lib/widgets/share_workout_sheet.dart`
- **IMPLEMENT**:
  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:workin_fit/core/theme/colors.dart';
  import 'package:workin_fit/core/theme/app_dimensions.dart';
  import 'package:workin_fit/features/auth/domain/auth_provider.dart';
  import 'package:workin_fit/models/chat_message.dart';
  import 'package:workin_fit/models/friend.dart';
  import 'package:workin_fit/providers/chat_providers.dart';
  import 'package:workin_fit/providers/friend_providers.dart';
  import 'package:workin_fit/widgets/workout_summary_card.dart';

  class ShareWorkoutSheet extends ConsumerStatefulWidget {
    const ShareWorkoutSheet({super.key, required this.shareData});
    final WorkoutShareData shareData;

    @override
    ConsumerState<ShareWorkoutSheet> createState() => _ShareWorkoutSheetState();
  }

  class _ShareWorkoutSheetState extends ConsumerState<ShareWorkoutSheet> {
    final TextEditingController _commentController = TextEditingController();
    Friend? _selectedFriend;
    bool _sending = false;

    @override
    void dispose() {
      _commentController.dispose();
      super.dispose();
    }

    Future<void> _send() async {
      final friend = _selectedFriend;
      if (friend == null) return;
      final user = ref.read(currentUserProvider);
      if (user == null) return;
      final profile = ref.read(currentUserProfileProvider);

      setState(() => _sending = true);
      try {
        await ref.read(chatServiceProvider).sendWorkoutShare(
          fromUserId: user.uid,
          fromUsername: profile?.username ?? user.displayName ?? '',
          fromPhotoUrl: user.photoURL,
          toUserId: friend.userId,
          toUsername: friend.username,
          toPhotoUrl: friend.photoUrl,
          shareData: widget.shareData,
          comment: _commentController.text.trim(),
        );
        if (mounted) Navigator.of(context).pop();
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to share. Please try again.')),
          );
        }
      } finally {
        if (mounted) setState(() => _sending = false);
      }
    }

    @override
    Widget build(BuildContext context) {
      final friendsAsync = ref.watch(friendsStreamProvider);

      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(AppSpacing.lg)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
                child: Text(
                  'Share Workout',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    // Preview card
                    WorkoutSummaryCard(shareData: widget.shareData, comment: ''),
                    const SizedBox(height: AppSpacing.md),
                    // Comment field
                    TextField(
                      controller: _commentController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Add a comment... (optional)',
                        hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4)),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.sm),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Friends list
                    const Text(
                      'Send to',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    friendsAsync.when(
                      data: (friends) {
                        if (friends.isEmpty) {
                          return const Text(
                            'Add friends to share workouts!',
                            style: TextStyle(color: Colors.white54),
                          );
                        }
                        return Column(
                          children: friends
                              .map((f) => RadioListTile<Friend>(
                                    value: f,
                                    groupValue: _selectedFriend,
                                    onChanged: (v) =>
                                        setState(() => _selectedFriend = v),
                                    title: Text(f.username,
                                        style: const TextStyle(
                                            color: Colors.white)),
                                    activeColor: AppColors.primary,
                                    contentPadding: EdgeInsets.zero,
                                  ))
                              .toList(),
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const Text(
                        'Could not load friends.',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed:
                        (_selectedFriend == null || _sending) ? null : _send,
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary),
                    child: _sending
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Send'),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
  ```
- **MIRROR**: `BOTTOM_SHEET_PATTERN`, `WIDGET_CONSUMER_PATTERN`
- **IMPORTS**: flutter, riverpod, auth_provider, models, providers, widgets
- **GOTCHA**: `currentUserProfileProvider` — verify name in auth_provider.dart before using; it may be `userProfileProvider`. Read auth_provider.dart to confirm the correct provider that exposes the user's username.
- **VALIDATE**: Sheet opens, shows preview card, comment field, and friend radio buttons; Send triggers `chatService.sendWorkoutShare()`

### Task 9: Add Share button to workout completion screen
- **ACTION**: Modify `_buildFinishedSummary()` in `workout_execution_screen.dart`
- **IMPLEMENT**: In the button row at the bottom of `_buildFinishedSummary()`, add a "Share" outlined button alongside the existing "Done" button:
  ```dart
  // Find the existing Done / action buttons area in _buildFinishedSummary
  // Add this before or alongside the done button:
  OutlinedButton.icon(
    onPressed: () {
      final String workoutHistoryDocId = ''; // use _lastSavedHistoryDocId if stored
      final shareData = WorkoutShareData(
        sessionId: widget.session.id,
        sessionName: widget.session.name,
        durationSeconds: _workoutStartedAt != null
            ? DateTime.now().difference(_workoutStartedAt!).inSeconds
            : widget.session.estimatedDuration,
        exerciseCount: widget.session.workouts.length,
        totalReps: _totalDoneReps,   // already computed in _saveWorkoutHistoryIfNeeded
        totalWorkSeconds: _totalDoneWorkSeconds,
        difficulty: widget.session.difficulty.name,
        workoutHistoryId: '',  // empty string for MVP if not trivially available
      );
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ShareWorkoutSheet(shareData: shareData),
      );
    },
    icon: const Icon(Icons.share_rounded),
    label: const Text('Share'),
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary),
    ),
  ),
  ```
- **MIRROR**: Existing button styles in `_buildFinishedSummary()`
- **IMPORTS**: Add at top of file:
  ```dart
  import 'package:workin_fit/models/chat_message.dart';
  import 'package:workin_fit/widgets/share_workout_sheet.dart';
  ```
- **GOTCHA**: `_totalDoneReps` and `_totalDoneWorkSeconds` are local variables inside `_saveWorkoutHistoryIfNeeded()`. Elevate them to instance fields (or store them after the save) so `_buildFinishedSummary()` can access them. Add:
  ```dart
  int _totalDoneReps = 0;
  int _totalDoneWorkSeconds = 0;
  ```
  as class-level fields, and assign them inside `_saveWorkoutHistoryIfNeeded()` before calling `saveWorkoutHistory()`.
- **VALIDATE**: Share button appears on completion screen; tapping opens ShareWorkoutSheet with correct session name and stats

### Task 10: Implement ChatTab with conversation list
- **ACTION**: Replace placeholder body in `chat_tab.dart` with a real conversation list
- **IMPLEMENT**:
  ```dart
  // Replace the body Center widget with:
  body: ref.watch(conversationsStreamProvider).when(
    data: (conversations) {
      if (conversations.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline_rounded,
                    size: 64,
                    color: AppColors.primary.withValues(alpha: AppOpacity.moderate)),
                const SizedBox(height: AppSpacing.md),
                const Text('No conversations yet',
                    style: TextStyle(color: Colors.white,
                        fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Share your workouts with friends after completing them.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: AppOpacity.visible)),
                ),
              ],
            ),
          ),
        );
      }
      final currentUserId =
          ref.read(currentUserProvider)?.uid ?? '';
      return ListView.separated(
        itemCount: conversations.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
        itemBuilder: (context, index) {
          final conv = conversations[index];
          final otherName = conv.otherUserName(currentUserId);
          final photoUrl = conv.otherUserPhoto(currentUserId);
          final lastAt = conv.lastMessageAt;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              backgroundImage:
                  photoUrl != null ? NetworkImage(photoUrl) : null,
              child: photoUrl == null
                  ? Text(otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
                      style: const TextStyle(color: AppColors.primary))
                  : null,
            ),
            title: Text(otherName,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
            subtitle: Text(
              conv.lastMessage,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: lastAt != null
                ? Text(
                    _formatTime(lastAt),
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 12),
                  )
                : null,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ConversationScreen(
                  chatId: conv.id,
                  otherUserName: otherName,
                  otherUserPhoto: photoUrl,
                ),
              ),
            ),
          );
        },
      );
    },
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (_, __) => const Center(
        child: Text('Could not load chats.',
            style: TextStyle(color: Colors.white54))),
  ),
  ```
  Add helper at class level:
  ```dart
  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
  ```
  Change `ChatTab extends StatelessWidget` → `extends ConsumerWidget` and update `build(BuildContext context)` → `build(BuildContext context, WidgetRef ref)`.
- **MIRROR**: `WIDGET_CONSUMER_PATTERN`
- **IMPORTS**: Add chat_providers, chat_tab imports for ConversationScreen, routes
- **GOTCHA**: Convert to `ConsumerWidget` (not `ConsumerStatefulWidget`) since no local mutable state is needed
- **VALIDATE**: Tab shows empty state or list; tapping a conversation navigates to ConversationScreen

### Task 11: Create ConversationScreen
- **ACTION**: Create `lib/views/chat/conversation_screen.dart`
- **IMPLEMENT**:
  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:workin_fit/core/constants/routes.dart';
  import 'package:workin_fit/core/theme/colors.dart';
  import 'package:workin_fit/core/theme/app_dimensions.dart';
  import 'package:workin_fit/features/auth/domain/auth_provider.dart';
  import 'package:workin_fit/models/chat_message.dart';
  import 'package:workin_fit/models/session.dart';
  import 'package:workin_fit/providers/chat_providers.dart';
  import 'package:workin_fit/providers/workout_providers.dart';
  import 'package:workin_fit/widgets/workout_summary_card.dart';

  class ConversationScreen extends ConsumerWidget {
    const ConversationScreen({
      super.key,
      required this.chatId,
      required this.otherUserName,
      this.otherUserPhoto,
    });

    final String chatId;
    final String otherUserName;
    final String? otherUserPhoto;

    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final currentUserId = ref.watch(currentUserProvider)?.uid ?? '';
      final messagesAsync = ref.watch(messagesStreamProvider(chatId));

      return Scaffold(
        backgroundColor: AppColors.surfaceVariant,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                backgroundImage: otherUserPhoto != null
                    ? NetworkImage(otherUserPhoto!)
                    : null,
                child: otherUserPhoto == null
                    ? Text(
                        otherUserName.isNotEmpty
                            ? otherUserName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            color: AppColors.primary, fontSize: 13))
                    : null,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(otherUserName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        body: messagesAsync.when(
          data: (messages) {
            if (messages.isEmpty) {
              return const Center(
                child: Text('No messages yet.',
                    style: TextStyle(color: Colors.white54)),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg.senderId == currentUserId;
                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: msg.type == ChatMessageType.workoutShare &&
                            msg.workoutShare != null
                        ? SizedBox(
                            width: MediaQuery.of(context).size.width * 0.78,
                            child: WorkoutSummaryCard(
                              shareData: msg.workoutShare!,
                              comment: msg.content,
                              onStartWorkout: isMe
                                  ? null
                                  : () => _startWorkout(
                                      context, ref, msg.workoutShare!),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? AppColors.primary.withValues(alpha: 0.8)
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(AppSpacing.md),
                            ),
                            child: Text(msg.content,
                                style: const TextStyle(color: Colors.white)),
                          ),
                  ),
                );
              },
            );
          },
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(
              child: Text('Could not load messages.',
                  style: TextStyle(color: Colors.white54))),
        ),
      );
    }

    void _startWorkout(
        BuildContext context, WidgetRef ref, WorkoutShareData share) async {
      // Look up the session by ID and navigate to execution screen
      final session = await ref
          .read(sessionByIdProvider(share.sessionId).future);
      if (session == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Workout session not found.')),
          );
        }
        return;
      }
      if (context.mounted) {
        Navigator.of(context).pushNamed(
          RouteConstants.workoutExecution,
          arguments: session,
        );
      }
    }
  }
  ```
- **MIRROR**: `WIDGET_CONSUMER_PATTERN`, navigation pattern from session_detail
- **IMPORTS**: As shown in code
- **GOTCHA**: `_startWorkout` calls `sessionByIdProvider` which is a `FutureProvider.family`. The session must exist in Firestore OR be a preset session. For shared sessions, the recipient may not have it in their local cache — verify `sessionByIdProvider` queries Firestore (not only local Hive). If it does local-only, add a Firestore fallback.
- **VALIDATE**: Workout share card renders with stats; "Start This Workout" navigates to `workoutExecution` route with the correct Session

---

## Testing Strategy

### Unit Tests
| Test | Input | Expected Output | Edge Case? |
|---|---|---|---|
| `ChatMessage.fromFirestore` round-trip | Valid map | Identical values | No |
| `ChatMessage.fromFirestore` missing fields | Empty map | Default values, no throw | Yes |
| `WorkoutShareData.fromMap` numeric types | int / double / String | Correct int cast | Yes |
| `ChatConversation.otherUserId` | Two participants | Returns the non-current | No |
| `ChatService.chatId` | uid order varies | Deterministic same ID | Yes |

### Edge Cases Checklist
- [ ] User has no friends → share sheet shows "Add friends" message
- [ ] Friend list has 1 friend → auto-select or show single radio
- [ ] Session not found by recipient (deleted/private) → "Workout not found" snack
- [ ] Firestore write fails → snack bar error, sheet stays open
- [ ] `durationSeconds = 0` → show "< 1 min" or "0 min" gracefully
- [ ] Very long session name → ellipsis in card title
- [ ] `workoutShare` field missing in old message docs → `workoutShare == null`, card not shown

---

## Validation Commands

### Static Analysis
```bash
flutter analyze
```
EXPECT: Zero new errors (warnings about unused imports are acceptable during development)

### Build Check
```bash
flutter build apk --debug
```
EXPECT: Successful build, no compilation errors

### Full Test Suite
```bash
flutter test
```
EXPECT: All existing tests pass; new unit tests pass

### Manual Validation — Share Flow
- [ ] Complete a workout session
- [ ] "Share" button appears on completion screen
- [ ] Tapping opens bottom sheet with workout preview card
- [ ] Session name, duration, exercise count match actual workout
- [ ] Friend list shows friends (test with at least 1 friend added)
- [ ] Selecting a friend enables Send button
- [ ] Adding a comment shows it in the preview
- [ ] Tapping Send closes sheet; no error
- [ ] Open Chat tab — conversation appears with correct friend name and "Shared a workout: X"

### Manual Validation — Recipient Flow
- [ ] Log in as the recipient friend
- [ ] Chat tab shows new conversation
- [ ] Open conversation — workout card visible with stats and comment
- [ ] "Start This Workout" button visible on card
- [ ] Tapping "Start This Workout" navigates to workout execution screen with correct session

---

## Acceptance Criteria
- [ ] Share button appears after workout completion
- [ ] Bottom sheet shows workout summary card (name, duration, exercises, reps)
- [ ] Optional comment field works
- [ ] Friends list is populated from existing friend data
- [ ] Shared workout appears in friend's Chat tab
- [ ] Recipient can open conversation and see workout share card
- [ ] "Start This Workout" button navigates to execution screen with the shared session
- [ ] Shares are stored in Firestore under `chats/{chatId}/messages`

## Completion Checklist
- [ ] All models follow fromFirestore/toFirestore pattern
- [ ] All providers follow null-guard pattern (`if (user == null) return const Stream.empty()`)
- [ ] Error handling matches codebase style (catch → snack bar for UI, rethrow for service)
- [ ] `withValues(alpha: ...)` used instead of `withOpacity()`
- [ ] No hardcoded strings (use AppColors, AppSpacing constants)
- [ ] FirebaseConstants updated with `messagesCollection`
- [ ] RouteConstants updated with `conversation`
- [ ] Firestore composite index created for `participants arrayContains + lastMessageAt orderBy`

## Risks
| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Firestore composite index missing | High | App query throws until index created | Create index via Firebase Console during dev; document in task 5 |
| `sessionByIdProvider` returns null for shared sessions | Medium | "Start This Workout" fails | Add Firestore direct-fetch fallback in `_startWorkout` |
| `currentUserProfileProvider` name mismatch | Low | Compile error in ShareWorkoutSheet | Read auth_provider.dart and confirm provider name before coding Task 8 |
| Sender and recipient both push real-time updates simultaneously | Low | Minor UI jitter | Firestore offline persistence handles this naturally |

## Notes
- `chatsCollection = 'chats'` already exists in `FirebaseConstants` — only `messagesCollection` needs adding.
- The `withValues(alpha:)` API is the Flutter 3.27+ replacement for `withOpacity()` — already used throughout this codebase.
- The "Start This Workout" feature relies on `sessionByIdProvider` being able to fetch sessions by ID for sessions the current user doesn't own. Confirm this works before finalising Task 11, or add a direct Firestore lookup fallback.
- Text-only messaging is intentionally out of scope for this issue. The comment field on the share is the only text input.
