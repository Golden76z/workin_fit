# Plan: Chat Text Messages & Unread Indicators

## Summary
Extend the existing workout-sharing chat with user-to-user text messaging and unread message badges.
The chat infrastructure (Firestore collections, models, providers, screens) is already in place —
this plan layers two missing features on top: a message-input bar in ConversationScreen and per-conversation
unread counters tracked in the conversation document.

## User Story
As a fitness app user, I want to send short text messages to friends in-app and see unread badges on conversations I haven't opened yet, so that I can communicate naturally alongside shared workouts.

## Problem → Solution
No text-input UI exists in ConversationScreen, and `ChatService` only has `sendWorkoutShare()`. Unread tracking is absent from the data model and UI. → Add `sendMessage()` + `markAsRead()` to `ChatService`, add `unreadCounts` map to the conversation document & model, add a text-input bar to `ConversationScreen`, and surface unread badges in `ChatTab`.

## Metadata
- **Complexity**: Medium
- **Source PRD**: N/A
- **PRD Phase**: N/A
- **Estimated Files**: 6

---

## UX Design

### Before
```
┌─────────────────────────────────────┐
│  Chat  [compose icon (disabled)]     │
│─────────────────────────────────────│
│  Alice    Shared a workout  5m       │  ← no unread badge
│  Bob      Shared a workout  1h       │
└─────────────────────────────────────┘

ConversationScreen:
┌─────────────────────────────────────┐
│  ← Alice                             │
│─────────────────────────────────────│
│       [WorkoutSummaryCard]           │
│                                      │
│  (no input field)                    │
└─────────────────────────────────────┘
```

### After
```
┌─────────────────────────────────────┐
│  Chat  [compose icon (disabled)]     │
│─────────────────────────────────────│
│  Alice    Shared a workout  5m  [2]  │  ← unread badge
│  Bob      Shared a workout  1h       │
└─────────────────────────────────────┘

ConversationScreen:
┌─────────────────────────────────────┐
│  ← Alice                             │
│─────────────────────────────────────│
│       [WorkoutSummaryCard]           │
│  Hey, great session!        ← bubble │
│                                      │
│  ┌────────────────────┐ [➤]         │
│  │ Message…           │              │
│  └────────────────────┘              │
└─────────────────────────────────────┘
```

### Interaction Changes
| Touchpoint | Before | After | Notes |
|---|---|---|---|
| ConversationScreen | Message list only, no input | Message list + sticky input bar | Input hides behind keyboard; auto-scroll on send |
| ChatTab list tile | No badge | Badge with unread count if > 0 | Uses Flutter Badge widget |
| Opening conversation | — | Resets unread count to 0 for current user | Firestore update on initState |
| Sending a text | Not possible | Sends text bubble, updates lastMessage + increments recipient's unreadCount | |

---

## Mandatory Reading

| Priority | File | Lines | Why |
|---|---|---|---|
| P0 | `lib/services/chat_service.dart` | all | Must mirror sendWorkoutShare transaction pattern exactly |
| P0 | `lib/models/chat_conversation.dart` | all | Must add unreadCounts field to model + serializers |
| P0 | `lib/models/chat_message.dart` | all | ChatMessage.toFirestore() used by both send methods |
| P1 | `lib/views/chat/conversation_screen.dart` | all | Must add input bar + markAsRead call |
| P1 | `lib/views/chat/chat_tab.dart` | all | Must add Badge widgets to list tiles |
| P2 | `lib/providers/chat_providers.dart` | all | Must add unreadTotalProvider |

## External Documentation
| Topic | Source | Key Takeaway |
|---|---|---|
| Flutter Badge widget | Flutter 3.x built-in | `Badge(label: Text('$count'), child: ...)` — no package needed |
| Firestore FieldValue.increment | Cloud Firestore SDK | `FieldValue.increment(1)` in update(); `-1` or set to 0 for decrement |

---

## Patterns to Mirror

### TRANSACTION_PATTERN
```dart
// SOURCE: lib/services/chat_service.dart:46-73
await _db.runTransaction((tx) async {
  final convSnap = await tx.get(convRef);
  final updateFields = <String, dynamic>{ ... };
  if (!convSnap.exists) {
    tx.set(convRef, {...updateFields, 'createdAt': nowIso});
  } else {
    tx.update(convRef, updateFields);
  }
  tx.set(msgRef, message.toFirestore());
});
```

### PROVIDER_PATTERN
```dart
// SOURCE: lib/providers/chat_providers.dart:7-13
final chatServiceProvider = Provider<ChatService>((ref) => ChatService());

final conversationsStreamProvider =
    StreamProvider<List<ChatConversation>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(chatServiceProvider).streamConversations(user.uid);
});
```

### CONSUMER_STATE_PATTERN
```dart
// SOURCE: lib/views/chat/conversation_screen.dart:30-46
class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }
```

### ERROR_HANDLING_PATTERN
```dart
// SOURCE: lib/views/chat/conversation_screen.dart:190-198
} catch (e, st) {
  debugPrint('ConversationScreen: _startWorkout failed — $e\n$st');
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not load workout. Please try again.')),
    );
  }
}
```

### FROM_FIRESTORE_PATTERN
```dart
// SOURCE: lib/models/chat_conversation.dart:22-45
factory ChatConversation.fromFirestore(Map<String, dynamic> data, String id) {
  final names = (data['participantNames'] as Map<String, dynamic>? ?? {})
      .map((k, v) => MapEntry(k, v as String? ?? ''));
  ...
  return ChatConversation(
    id: id,
    ...
    lastMessageAt: data['lastMessageAt'] != null
        ? DateTime.tryParse(data['lastMessageAt'] as String)
        : null,
  );
}
```

### BADGE_PATTERN (Flutter built-in)
```dart
// Flutter Badge widget — no import needed beyond material.dart
Badge(
  label: Text('$count'),
  backgroundColor: AppColors.primary,
  child: const Icon(Icons.chat_bubble_outline_rounded),
)
// For list tile trailing: wrap trailing widget in Badge
```

---

## Files to Change

| File | Action | Justification |
|---|---|---|
| `lib/models/chat_conversation.dart` | UPDATE | Add `unreadCounts` field + update fromFirestore/toFirestore |
| `lib/services/chat_service.dart` | UPDATE | Add `sendMessage()` and `markAsRead()` methods |
| `lib/providers/chat_providers.dart` | UPDATE | Add `unreadTotalProvider` |
| `lib/views/chat/conversation_screen.dart` | UPDATE | Add text input bar + `markAsRead` on init |
| `lib/views/chat/chat_tab.dart` | UPDATE | Add unread badges on list tiles |

## NOT Building
- Typing indicators (requires presence/ephemeral Firestore data)
- Read receipts per message (overkill for this feature)
- Message deletion or editing
- Push notifications
- Group chat
- Pagination / load-more (existing `.limitToLast(50)` is sufficient for now)
- Emoji picker widget (standard keyboard emoji already works in any TextField)

---

## Step-by-Step Tasks

### Task 1: Add `unreadCounts` to `ChatConversation` model
- **ACTION**: Update the model to carry a `Map<String, int>` of unread counts keyed by userId
- **IMPLEMENT**:
  ```dart
  // Add field to constructor + class body:
  final Map<String, int> unreadCounts;

  // In fromFirestore, parse the new field:
  unreadCounts: (data['unreadCounts'] as Map<String, dynamic>? ?? {})
      .map((k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0)),

  // In toFirestore(), add:
  'unreadCounts': unreadCounts,

  // Helper method:
  int unreadFor(String userId) => unreadCounts[userId] ?? 0;
  ```
- **MIRROR**: FROM_FIRESTORE_PATTERN — defensive map casting with `?? {}`
- **IMPORTS**: none new
- **GOTCHA**: The existing `toFirestore()` must also include the new field; omitting it would wipe it on the next write that uses this method. Since `sendMessage`/`sendWorkoutShare` in ChatService do NOT call `toFirestore()` on the conversation (they write field maps manually), `toFirestore()` is only used for any future full-doc writes — still add it for consistency.
- **VALIDATE**: `dart analyze lib/models/chat_conversation.dart` — zero errors; check that `unreadFor()` compiles.

### Task 2: Add `sendMessage()` and `markAsRead()` to `ChatService`
- **ACTION**: Add two new methods to `ChatService`
- **IMPLEMENT**:
  ```dart
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

    final convRef = _db.collection(FirebaseConstants.chatsCollection).doc(cid);
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
        // Increment recipient's unread count.
        'unreadCounts.$toUserId': FieldValue.increment(1),
      };

      if (!convSnap.exists) {
        tx.set(convRef, {
          ...updateFields,
          'createdAt': nowIso,
          'unreadCounts': {fromUserId: 0, toUserId: 1},
        });
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
  ```
- **MIRROR**: TRANSACTION_PATTERN — same runTransaction structure as sendWorkoutShare; note the `updateFields` approach and the if/else for first-time doc creation
- **IMPORTS**: `FieldValue` already imported via `cloud_firestore`
- **GOTCHA**: `FieldValue.increment(1)` cannot be used inside `tx.set(...)` because `set` expects a plain map. On first creation, write `unreadCounts: {fromUserId: 0, toUserId: 1}` as a concrete map; on subsequent calls, use `'unreadCounts.$toUserId': FieldValue.increment(1)` in the update map.
- **VALIDATE**: `dart analyze lib/services/chat_service.dart` — zero errors

### Task 3: Add `unreadTotalProvider` to `chat_providers.dart`
- **ACTION**: Expose the total unread count for the current user as a derived provider
- **IMPLEMENT**:
  ```dart
  /// Total unread message count across all conversations for the current user.
  final unreadTotalProvider = Provider<int>((ref) {
    final userId = ref.watch(currentUserProvider)?.uid ?? '';
    final convs = ref.watch(conversationsStreamProvider).valueOrNull ?? [];
    return convs.fold(0, (sum, c) => sum + c.unreadFor(userId));
  });
  ```
- **MIRROR**: PROVIDER_PATTERN — same guard pattern, derives from conversationsStreamProvider
- **IMPORTS**: none new (currentUserProvider and conversationsStreamProvider already imported)
- **GOTCHA**: Use `valueOrNull` (not `value`) to avoid `AsyncValue` errors; returns 0 when loading or error
- **VALIDATE**: `dart analyze lib/providers/chat_providers.dart` — zero errors

### Task 4: Add text input bar + `markAsRead` to `ConversationScreen`
- **ACTION**: Add a `TextEditingController` + bottom input bar; call `markAsRead` on open
- **IMPLEMENT**:
  ```dart
  // Add to _ConversationScreenState fields:
  final TextEditingController _inputController = TextEditingController();
  bool _sending = false;

  // In dispose():
  _inputController.dispose();

  // Add initState:
  @override
  void initState() {
    super.initState();
    // Mark conversation as read when opened.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = ref.read(currentUserProvider)?.uid;
      if (userId != null) {
        ref.read(chatServiceProvider).markAsRead(widget.chatId, userId);
      }
    });
  }

  // Add _sendMessage():
  Future<void> _sendMessage() async {
    final content = _inputController.text.trim();
    if (content.isEmpty) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    _inputController.clear();
    setState(() => _sending = true);
    try {
      final profile = await ref
          .read(firestoreServiceProvider)
          .getUserProfile(user.uid);
      final username =
          profile?['username'] as String? ?? user.displayName ?? 'User';
      // We need the other user's info — pass it from widget params
      await ref.read(chatServiceProvider).sendMessage(
            fromUserId: user.uid,
            fromUsername: username,
            fromPhotoUrl: user.photoURL,
            toUserId: widget.otherUserId,
            toUsername: widget.otherUserName,
            toPhotoUrl: widget.otherUserPhoto,
            content: content,
          );
    } catch (e, st) {
      debugPrint('ConversationScreen: _sendMessage failed — $e\n$st');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }
  ```

  NOTE: `ConversationScreen` currently lacks `otherUserId`. Add it as a required constructor param:
  ```dart
  const ConversationScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,   // ← NEW
    required this.otherUserName,
    this.otherUserPhoto,
  });
  final String otherUserId;      // ← NEW field
  ```
  Update callers in `chat_tab.dart` to pass `otherUserId: conv.otherUserId(currentUserId)`.

  Input bar — replace current `body: messagesAsync.when(...)` with a `Column`:
  ```dart
  body: Column(
    children: [
      Expanded(child: messagesAsync.when(...)),   // existing list
      _buildInputBar(),
    ],
  ),

  Widget _buildInputBar() {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.sm,
        top: AppSpacing.sm,
        bottom: AppSpacing.sm +
            MediaQuery.of(context).viewInsets.bottom.clamp(0.0, 0.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Message…',
                hintStyle: TextStyle(
                    color: AppColors.textSecondary
                        .withValues(alpha: AppOpacity.visible)),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                  borderSide: BorderSide.none,
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            onPressed: _sending ? null : _sendMessage,
            icon: const Icon(Icons.send_rounded),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
  ```
- **MIRROR**: CONSUMER_STATE_PATTERN for `initState` + dispose; ERROR_HANDLING_PATTERN for catch block
- **IMPORTS**: `firestoreServiceProvider` from `auth_provider.dart` (already imported); `AppOpacity`, `AppSpacing`, `AppRadii` from theme (already imported)
- **GOTCHA**: Do NOT import `workout_providers.dart` — it also defines `firestoreServiceProvider` which causes ambiguous import. The existing import of `auth_provider.dart` is sufficient. Also, `markAsRead` should be called via `addPostFrameCallback` (not directly in `initState`) so that Riverpod `ref.read` fires after first frame.
- **VALIDATE**: `dart analyze lib/views/chat/conversation_screen.dart` — zero errors; open conversation in simulator and confirm input bar appears above keyboard

### Task 5: Add unread badges to `ChatTab`
- **ACTION**: Show a `Badge` on each list tile with a positive unread count
- **IMPLEMENT**: In the `itemBuilder` for conversations list, wrap the trailing widget:
  ```dart
  // At top of build(), also watch unread counts:
  // (conversationsStreamProvider is already watched above)

  // In itemBuilder — compute unread count for this conversation:
  final unreadCount = conv.unreadFor(currentUserId);

  // Replace trailing:
  trailing: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (lastAt != null)
        Text(
          _formatTime(lastAt),
          style: TextStyle(
            color: AppColors.textSecondary
                .withValues(alpha: AppOpacity.visible),
            fontSize: 12,
          ),
        ),
      if (unreadCount > 0) ...[
        const SizedBox(width: AppSpacing.xs),
        Badge(
          label: Text(
            '$unreadCount',
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
          backgroundColor: AppColors.primary,
          child: const SizedBox.shrink(),
        ),
      ],
    ],
  ),
  ```
  Also pass the new `otherUserId` parameter when pushing `ConversationScreen`:
  ```dart
  onTap: () => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ConversationScreen(
        chatId: conv.id,
        otherUserId: conv.otherUserId(currentUserId),   // ← NEW
        otherUserName: otherName,
        otherUserPhoto: photoUrl,
      ),
    ),
  ),
  ```
- **MIRROR**: PROVIDER_PATTERN (no new provider needed here — `conversationsStreamProvider` already loaded)
- **IMPORTS**: `Badge` is built into `material.dart` — no new import needed
- **GOTCHA**: `Badge` with `child: SizedBox.shrink()` and placed in a `Row` is the cleanest pattern when you want the badge as a standalone element rather than decorating an icon. Alternatively, wrap the time text with Badge, but the standalone approach gives more layout control.
- **VALIDATE**: `dart analyze lib/views/chat/chat_tab.dart` — zero errors; confirm badge appears on tiles with unread > 0

---

## Testing Strategy

### Unit Tests
| Test | Input | Expected Output | Edge Case? |
|---|---|---|---|
| `chatId()` ordering | uid2 > uid1 | returns uid1_uid2 | Yes — ensure A↔B == B↔A |
| `unreadFor()` missing key | userId not in map | returns 0 | Yes |
| `ChatConversation.fromFirestore` unreadCounts | `{'uid1': 2}` | unreadFor('uid1') == 2 | No |
| `ChatConversation.fromFirestore` missing unreadCounts | no field | unreadFor(any) == 0 | Yes |

### Edge Cases Checklist
- [ ] Empty text field → send button does nothing
- [ ] Sending while `_sending = true` → button disabled
- [ ] Opening conversation with no messages → `markAsRead` still fires (no error)
- [ ] `unreadCounts` field absent from old conversation docs → defaults to `{}`
- [ ] Firestore offline → `markAsRead` silently fails (acceptable; just a UX counter)

---

## Validation Commands

### Static Analysis
```bash
dart analyze lib/models/chat_conversation.dart \
             lib/services/chat_service.dart \
             lib/providers/chat_providers.dart \
             lib/views/chat/conversation_screen.dart \
             lib/views/chat/chat_tab.dart
```
EXPECT: Zero errors (info-level lints acceptable)

### Manual Validation
- [ ] Open app, navigate to Chat tab
- [ ] Send a workout share to a friend — conversation appears
- [ ] Open conversation — input bar visible, no existing messages error
- [ ] Type a message and press send — message bubble appears in correct alignment
- [ ] Close conversation and re-open — unread counter on that tile resets
- [ ] From friend's device (or second account), receive text message — tile shows badge with count

---

## Acceptance Criteria
- [ ] Text messages can be sent and appear in real-time
- [ ] Unread badge shows on conversation list tile
- [ ] Opening a conversation resets unread count
- [ ] Workout shares continue to work unchanged
- [ ] Zero `dart analyze` errors

## Completion Checklist
- [ ] `unreadCounts` field in model + both serializers
- [ ] `sendMessage()` uses same transaction pattern as `sendWorkoutShare()`
- [ ] `markAsRead()` uses `.update({'unreadCounts.$userId': 0})`
- [ ] No hardcoded values
- [ ] `FieldValue.increment` used for recipient counter
- [ ] `firestoreServiceProvider` imported only from `auth_provider.dart`
- [ ] `otherUserId` added to `ConversationScreen` constructor and all callers updated
- [ ] `Badge` from built-in material (no new package)

## Risks
| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| `FieldValue.increment` in `tx.set` throws on new doc | Medium | Hard crash on first message | Use concrete `{toUserId: 1}` map in `tx.set` branch |
| `firestoreServiceProvider` ambiguous import | High if `workout_providers.dart` imported | Compile error | Import only `auth_provider.dart` |
| Old conversation docs lacking `unreadCounts` | High (all existing docs) | Null cast crash | `?? {}` defensive parsing in `fromFirestore` |
| Keyboard overlap hides input bar | Medium | UX degradation | Scaffold's `resizeToAvoidBottomInset: true` (default) handles this automatically |

## Notes
- Emoji support falls naturally out of this plan: the `TextField` accepts any Unicode input including emoji. No emoji picker widget is needed.
- Firestore Security Rules must allow a user to update `unreadCounts.<theirOwnUid>` on conversation docs they participate in. This is an existing doc, so the participants check already in rules covers it. The `markAsRead` write sets their own field to 0 — no new rules needed beyond what workout-sharing required.
- The `sendMessage()` method increments `unreadCounts.$toUserId` but does NOT touch the sender's own count. If a user has a conversation open and the other person sends a message, the stream update will briefly show an unread count before `markAsRead` fires — this is acceptable behavior.
