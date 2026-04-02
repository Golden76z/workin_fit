# Plan: Home Screen Design Enhancements

## Summary
Refine the home dashboard to be cleaner and more data-driven across 5 targeted changes: remove the arch banner decoration, unify the two session hero cards into one real-data card with the gradient design, move warmup category selection into a bottom-sheet modal triggered by the Start button, cap the Programs and Sessions carousels to preset-only data (5 programs, 10 sessions), and remove the sign-out button.

## User Story
As a user, I want a cleaner home screen that shows real workout data in the hero cards and doesn't overwhelm me with too many items, so that the home screen feels polished and focused.

## Problem → Solution
- Arch clipper creates a heavy, dated bottom curve → flat/subtle bottom edge (no clip)
- Two side-by-side session cards (hardcoded hero + real program day) → single gradient hero card showing real active program data
- Warmup category button in home screen clutters layout and requires full navigation → category selection as bottom sheet on Start tap
- Programs carousel shows ALL programs (preset + user), Sessions carousel shows hardcoded data → Programs limited to 5 presets, Sessions from `presetSessionsProvider` limited to 10
- Sign-out button in home body → removed (to be placed elsewhere)

## Metadata
- **Complexity**: Medium
- **Source PRD**: N/A
- **PRD Phase**: N/A
- **Estimated Files**: 2 (home_dashboard_tab.dart, workout_providers.dart)

---

## UX Design

### Before
```
┌──────────────────────────────────────────┐
│  ╔══════════════════════════════════╗    │
│  ║  Good morning, Name             ║    │
│  ║  [streak] [week] [trophies]     ║    │
│  ╚══════════╗ arch curve ╔══════════╝   │
│             ╚════════════╝              │
│  [SESSION OF THE DAY - hardcoded]       │
│  [CURRENT PROGRAM DAY - real data]      │
│  [DAILY CHALLENGE]                      │
│  Warmup: [🔧 Category chip] [2][5][10]  │
│          [▶ Start warmup]               │
│  Programs: [card][card][card]...all     │
│  Sessions: [card][card][card]...hc      │
│  [Sign out button]                      │
└──────────────────────────────────────────┘
```

### After
```
┌──────────────────────────────────────────┐
│  ╔══════════════════════════════════╗    │
│  ║  Good morning, Name             ║    │
│  ║  [streak] [week] [trophies]     ║    │
│  ╚══════════════════════════════════╝    │
│        (no arch — flat/subtle bottom)   │
│  [SESSION HERO CARD - gradient + real]  │
│    (shows active program session data)  │
│  [DAILY CHALLENGE]                      │
│  Warmup: [2 min][5 min][10 min]         │
│          [▶ Start warmup]               │
│   ← tapping Start opens bottom sheet:  │
│     ┌─ Choose focus area ─────────┐    │
│     │ [Full Body] [Upper Body]... │    │
│     │ [Confirm ▶] (disabled until │    │
│     │  selection made)            │    │
│     └─────────────────────────────┘    │
│  Programs: [card][card]...(max 5)       │
│  Sessions: [card][card]...(max 10 real) │
│  (no sign-out button)                   │
└──────────────────────────────────────────┘
```

### Interaction Changes
| Touchpoint | Before | After | Notes |
|---|---|---|---|
| Banner bottom edge | Arch clipper curve | Flat bottom, no ClipPath | Remove `_ArchClipper` and `ClipPath` wrapper |
| Session hero card | Hardcoded "Full Body Power" gradient card | Gradient card with real active program session data | Merge `_SessionOfTheDayCard` + `_CurrentProgramDayCard` |
| Current program day card | Separate simpler bordered card | Removed; merged into hero card | Delete `_CurrentProgramDayCard` |
| Warmup category chip | Tapping opens `WarmupCategoryScreen` as new route | Removed; category selected in bottom sheet | Remove category chip from `_WarmupSelector` |
| Start warmup button | Immediately starts warmup with current category | Opens category selection bottom sheet first | Bottom sheet has disabled Confirm until selection |
| Programs carousel | All programs (preset + user), unlimited | Preset only, max 5 | New `homePresetProgramsProvider` |
| Sessions carousel | Hardcoded `_SessionData` list | Real `presetSessionsProvider` data, max 10 | Convert `_SessionsCarousel` to `ConsumerWidget` |
| Sign-out button | `_LogoutButton` at bottom of home | Removed entirely | Delete `_LogoutButton` class and usage |

---

## Mandatory Reading

| Priority | File | Lines | Why |
|---|---|---|---|
| P0 (critical) | `lib/views/home/home_dashboard_tab.dart` | 208-273 | `_HomeBannerSliver` + `_ArchClipper` to modify |
| P0 (critical) | `lib/views/home/home_dashboard_tab.dart` | 503-707 | `_SessionOfTheDayCard` design to reuse |
| P0 (critical) | `lib/views/home/home_dashboard_tab.dart` | 884-1141 | `_CurrentProgramDayCard` + `_ProgramCardContainer` to remove/merge |
| P0 (critical) | `lib/views/home/home_dashboard_tab.dart` | 1143-1343 | `_WarmupSelector` — category chip + Start button |
| P0 (critical) | `lib/views/home/home_dashboard_tab.dart` | 1345-1565 | `_ProgramsCarousel` + `_ProgramCard` |
| P0 (critical) | `lib/views/home/home_dashboard_tab.dart` | 1567-1783 | `_SessionsCarousel` + `_SessionCard` + `_SessionData` |
| P0 (critical) | `lib/views/home/home_dashboard_tab.dart` | 1882-1909 | `_LogoutButton` to delete |
| P1 (important) | `lib/providers/workout_providers.dart` | 95-103 | `presetSessionsProvider` — source for sessions carousel |
| P1 (important) | `lib/providers/workout_providers.dart` | 226-237 | `programsProvider` — source for programs carousel |
| P1 (important) | `lib/features/warmup/presentation/screens/warmup_category_screen.dart` | 1-137 | Category cards to reuse in bottom sheet |
| P2 (reference) | `lib/core/theme/app_dimensions.dart` | all | `AppSpacing`, `AppRadii` constants |
| P2 (reference) | `lib/core/theme/colors.dart` | all | `AppColors` constants |
| P2 (reference) | `lib/core/theme/app_opacity.dart` | all | `AppOpacity` constants |

## External Documentation
| Topic | Source | Key Takeaway |
|---|---|---|
| N/A | N/A | Feature uses established internal patterns only |

---

## Patterns to Mirror

### NAMING_CONVENTION
```dart
// SOURCE: lib/views/home/home_dashboard_tab.dart:503
class _SessionOfTheDayCard extends StatelessWidget { ... }
// Private classes start with _ for file-private widgets
// ConsumerWidget when using ref.watch, ConsumerStatefulWidget when needing state
```

### CARD_GRADIENT_DESIGN
```dart
// SOURCE: lib/views/home/home_dashboard_tab.dart:510-666
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppRadii.sm),
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[AppColors.primaryDark, AppColors.primary, AppColors.cornflowerBlue],
      stops: <double>[0.0, 0.45, 1.0],
    ),
    boxShadow: <BoxShadow>[
      BoxShadow(
        color: AppColors.primary.withValues(alpha: AppOpacity.moderate),
        blurRadius: 24,
        offset: const Offset(0, 10),
      ),
    ],
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(AppRadii.sm),
    child: Stack(
      children: <Widget>[
        // Decorative ring top-right: Positioned(right: -36, top: -36, ...)
        // Decorative ring bottom-left: Positioned(left: -20, bottom: -44, ...)
        // Content: Padding(padding: EdgeInsets.all(AppSpacing.lg), child: Column(...))
      ],
    ),
  ),
)
```

### SESSION_META_CHIP
```dart
// SOURCE: lib/views/home/home_dashboard_tab.dart:671-707
class _SessionMetaChip extends StatelessWidget {
  // Container with white semi-transparent bg, row of Icon + Text
  // Used for: timer, exercise count, difficulty level
}
```

### CONSUMER_WIDGET_PATTERN
```dart
// SOURCE: lib/views/home/home_dashboard_tab.dart:884-887
class _CurrentProgramDayCard extends ConsumerWidget {
  final bool isFrench;
  const _CurrentProgramDayCard({required this.isFrench});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final someAsync = ref.watch(someProvider);
    return someAsync.when(
      data: (data) { ... },
      loading: () => ...,
      error: (_, __) => ...,
    );
  }
}
```

### BOTTOM_SHEET_PATTERN
```dart
// Standard Flutter bottom sheet pattern used in this codebase:
showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  backgroundColor: AppColors.background,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
  ),
  builder: (context) => StatefulBuilder(
    builder: (context, setState) { ... }
  ),
);
```

### PROVIDER_FAMILY_PATTERN
```dart
// SOURCE: lib/providers/workout_providers.dart:96-103
final presetSessionsProvider = FutureProvider<List<Session>>((ref) async {
  final syncService = ref.watch(syncServiceProvider);
  try {
    return await syncService.getPresetSessions();
  } catch (_) {
    return [];
  }
});
```

### ASYNC_WHEN_PATTERN
```dart
// SOURCE: lib/views/home/home_dashboard_tab.dart:1373-1430
return programsAsync.when(
  data: (programs) {
    if (programs.isEmpty) { return Center(child: Text(...)); }
    return ListView.separated( ... );
  },
  loading: () => ListView.separated( /* skeleton */ ),
  error: (_, __) => Center(child: Text(...)),
);
```

---

## Files to Change

| File | Action | Justification |
|---|---|---|
| `lib/views/home/home_dashboard_tab.dart` | UPDATE | All 5 UI changes |
| `lib/providers/workout_providers.dart` | UPDATE | Add `homePresetProgramsProvider` (max 5) |

## NOT Building

- Warmup category screen (`warmup_category_screen.dart`) stays as-is (still used elsewhere if needed)
- Navigation or routing changes to other tabs
- Profile/settings screen for sign-out (sign-out button is removed, future placement is out of scope)
- Sessions carousel "See all" navigation (currently a no-op, leave as-is)
- Programs carousel "See all" navigation (currently a no-op, leave as-is)
- Any change to `_DailyChallengeCard`, `_QuickAccessRow`, or other sections
- Warmup duration buttons (keep as-is)

---

## Step-by-Step Tasks

### Task 1: Remove Arch — Flatten the banner bottom edge
- **ACTION**: Remove `ClipPath` + `_ArchClipper` from `_HomeBannerSliver`, delete `_ArchClipper` class
- **IMPLEMENT**:
  In `_HomeBannerSliver.build`, replace:
  ```dart
  return SliverToBoxAdapter(
    child: ClipPath(
      clipper: _ArchClipper(),
      child: AppTopBarBackground(
        child: Padding( ... )
      ),
    ),
  );
  ```
  With:
  ```dart
  return SliverToBoxAdapter(
    child: AppTopBarBackground(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          topPadding + AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg,  // reduced bottom padding (no arch offset needed)
        ),
        child: Column( ... ),
      ),
    ),
  );
  ```
  Then delete the entire `_ArchClipper` class (lines 388-406).
- **MIRROR**: NAMING_CONVENTION
- **IMPORTS**: None new
- **GOTCHA**: Bottom padding was `AppSpacing.lg + AppSpacing.md` to compensate for the arch offset. Reduce to just `AppSpacing.lg` since arch is gone.
- **VALIDATE**: Hot reload; banner should have a clean flat bottom edge, no arch curve.

### Task 2: Merge session hero cards — real data with gradient design
- **ACTION**: Replace `_SessionOfTheDayCard` (hardcoded) and `_CurrentProgramDayCard` (real data) with a single `_SessionHeroCard` that uses the gradient design of the old `_SessionOfTheDayCard` but reads from `activeProgramStateProvider` and `programByIdProvider`
- **IMPLEMENT**:
  1. In `_HomeDashboardTabState.build`, replace:
     ```dart
     // Session of the Day
     _SessionOfTheDayCard(isFrench: isFrench),
     const SizedBox(height: AppSpacing.md),
     // Active Program Day
     _CurrentProgramDayCard(isFrench: isFrench),
     ```
     With:
     ```dart
     _SessionHeroCard(isFrench: isFrench),
     ```
  2. Create `_SessionHeroCard extends ConsumerWidget`:
     - Watches `activeProgramStateProvider`
     - If active program: also watches `programByIdProvider(activeProgramState.programId)`
     - **No active program state**: render gradient card with "SESSION OF THE DAY" label, placeholder title "Ready to train?", subtitle prompt to start a program, play button
     - **Has active program + loaded**: render gradient card with:
       - Label: isFrench ? 'SÉANCE DU JOUR' : 'SESSION OF THE DAY'
       - Title: the program name
       - Subtitle: `Week $currentWeek / Day $currentDay` info
       - Meta chips: duration chip (show `estimatedDuration` if available), exercises count, difficulty
       - Tapping navigates to `ProgramDetailScreen.route(program: program)`
     - **Loading state**: show gradient card with a white `CircularProgressIndicator` centered
     - Design: EXACTLY the same as `_SessionOfTheDayCard` — same gradient, same decorative rings, same `_SessionMetaChip` chips
     - Compute `currentDay`, `currentWeek`, `progress` using same arithmetic as old `_CurrentProgramDayCard` (lines 949-963)
  3. Delete `_SessionOfTheDayCard` class and `_CurrentProgramDayCard` class and `_ProgramCardContainer` class
- **MIRROR**: CARD_GRADIENT_DESIGN, CONSUMER_WIDGET_PATTERN, SESSION_META_CHIP, ASYNC_WHEN_PATTERN
- **IMPORTS**: Need `ProgramDetailScreen` (already imported), `activeProgramStateProvider`, `programByIdProvider` (already imported via `workout_providers.dart`)
- **GOTCHA**: The old `_ProgramCardContainer` is only used by `_CurrentProgramDayCard`. Delete it too. The `progress` field was used for a `LinearProgressIndicator` — can optionally add that as a subtle strip at the bottom of the gradient card or omit it for simplicity. Keep it omitted for the first pass (cleaner card).
- **VALIDATE**: Hot reload; see a single gradient card. If user has an active program, it shows program name + day info. If no active program, shows placeholder. Tapping navigates to program detail.

### Task 3: Warmup — category selection via bottom sheet on Start tap
- **ACTION**: Remove the category chip from `_WarmupSelector`, convert Start button to open a category-selection bottom sheet before launching the workout
- **IMPLEMENT**:
  1. Remove the category chip `GestureDetector` block (lines 1178-1213) and the `SizedBox(height: AppSpacing.sm)` after it from `_WarmupSelectorState.build`
  2. Replace the `FilledButton.icon` `onPressed` handler:
     ```dart
     onPressed: () {
       _showCategorySheet(context);
     },
     ```
  3. Add method `_showCategorySheet` to `_WarmupSelectorState`:
     ```dart
     void _showCategorySheet(BuildContext context) {
       WarmupCategory? selected = ref.read(warmupCategoryProvider);
       showModalBottomSheet<void>(
         context: context,
         isScrollControlled: true,
         backgroundColor: AppColors.surface,
         shape: const RoundedRectangleBorder(
           borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
         ),
         builder: (sheetContext) => StatefulBuilder(
           builder: (sheetContext, setSheetState) {
             return Padding(
               padding: const EdgeInsets.fromLTRB(
                 AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.lg),
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   // Handle
                   Center(
                     child: Container(
                       width: 40, height: 4,
                       decoration: BoxDecoration(
                         color: AppColors.primaryLight.withValues(alpha: AppOpacity.moderate),
                         borderRadius: BorderRadius.circular(2),
                       ),
                     ),
                   ),
                   const SizedBox(height: AppSpacing.md),
                   Text(
                     widget.isFrench ? 'Zone d\'échauffement' : 'Choose focus area',
                     style: const TextStyle(
                       color: AppColors.textPrimary,
                       fontSize: 18, fontWeight: FontWeight.w700,
                       fontFamily: 'AppFontMedium',
                     ),
                   ),
                   const SizedBox(height: AppSpacing.sm),
                   // Category list (reuse _categoryLabels)
                   for (final entry in _categoryLabels.entries)
                     _WarmupCategoryTile(
                       category: entry.key,
                       label: widget.isFrench ? entry.value.$2 : entry.value.$1,
                       isSelected: selected == entry.key,
                       onTap: () => setSheetState(() => selected = entry.key),
                     ),
                   const SizedBox(height: AppSpacing.md),
                   SizedBox(
                     width: double.infinity,
                     child: FilledButton.icon(
                       onPressed: selected == null ? null : () {
                         ref.read(warmupCategoryProvider.notifier).state = selected!;
                         Navigator.of(sheetContext).pop();
                         // Start workout
                         final routine = ref.read(warmupRoutineProvider);
                         final exercises = ref.read(warmupExercisesProvider);
                         Navigator.of(context).push(
                           MaterialPageRoute<void>(
                             builder: (_) => WorkoutExecutionScreen(
                               session: routine.toSession(),
                               seededExercises: exercises,
                             ),
                           ),
                         );
                       },
                       icon: const Icon(Icons.play_arrow_rounded, size: 20),
                       label: Text(
                         widget.isFrench ? 'Confirmer et démarrer' : 'Confirm & Start',
                         style: const TextStyle(fontWeight: FontWeight.w600),
                       ),
                       style: FilledButton.styleFrom(
                         backgroundColor: AppColors.primary,
                         disabledBackgroundColor:
                             AppColors.primary.withValues(alpha: AppOpacity.moderate),
                         foregroundColor: Colors.white,
                         padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                         shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(AppRadii.sm),
                         ),
                       ),
                     ),
                   ),
                 ],
               ),
             );
           },
         ),
       );
     }
     ```
  4. Add private helper class `_WarmupCategoryTile` (file-private):
     ```dart
     class _WarmupCategoryTile extends StatelessWidget {
       final WarmupCategory category;
       final String label;
       final bool isSelected;
       final VoidCallback onTap;
       const _WarmupCategoryTile({
         required this.category,
         required this.label,
         required this.isSelected,
         required this.onTap,
       });
       @override
       Widget build(BuildContext context) {
         return GestureDetector(
           onTap: onTap,
           child: AnimatedContainer(
             duration: const Duration(milliseconds: 150),
             margin: const EdgeInsets.only(bottom: AppSpacing.xs),
             padding: const EdgeInsets.symmetric(
               horizontal: AppSpacing.md, vertical: AppSpacing.sm),
             decoration: BoxDecoration(
               color: isSelected
                   ? AppColors.primary.withValues(alpha: AppOpacity.subtle)
                   : AppColors.surface,
               borderRadius: BorderRadius.circular(AppRadii.md),
               border: Border.all(
                 color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                 width: isSelected ? 2 : 1,
               ),
             ),
             child: Row(
               children: [
                 Text(
                   label,
                   style: TextStyle(
                     color: isSelected ? AppColors.primary : AppColors.textPrimary,
                     fontSize: 15, fontWeight: FontWeight.w600,
                   ),
                 ),
                 const Spacer(),
                 if (isSelected)
                   const Icon(Icons.check_circle_rounded,
                       color: AppColors.primary, size: 20),
               ],
             ),
           ),
         );
       }
     }
     ```
  5. Update the existing Start button label in `_WarmupSelectorState` to simply say "Start warmup" (remove the duration from the label since category is now selected in the sheet):
     ```dart
     label: Text(
       widget.isFrench ? 'Démarrer l\'échauffement' : 'Start warmup',
       ...
     ),
     ```
- **MIRROR**: BOTTOM_SHEET_PATTERN, NAMING_CONVENTION
- **IMPORTS**: `WarmupCategoryScreen` import can be removed; `WorkoutExecutionScreen` still needed
- **GOTCHA**: `showModalBottomSheet` needs `context` from the `build` method — pass it to `_showCategorySheet`. After popping the bottom sheet, the `context` is used for the Navigator push, so check `if (context.mounted)` before pushing.
  The `warmupRoutineProvider` reads from `warmupCategoryProvider` state, so update the category in the notifier BEFORE reading `warmupRoutineProvider`.
- **VALIDATE**: Hot reload; home screen shows only duration buttons + Start button. Tapping Start opens bottom sheet with category list. Confirm button disabled when nothing selected. Selecting a category enables Confirm. Tapping Confirm updates state and navigates to workout.

### Task 4: Add `homePresetProgramsProvider` (limit 5)
- **ACTION**: Add a new provider in `workout_providers.dart` that returns preset-only programs capped at 5
- **IMPLEMENT**:
  ```dart
  /// Programs for the home screen — preset only, max 5.
  final homePresetProgramsProvider = FutureProvider<List<Program>>((ref) async {
    final syncService = ref.watch(syncServiceProvider);
    try {
      final all = await syncService.getPrograms();  // no userId = presets only
      return all.take(5).toList();
    } catch (_) {
      return [];
    }
  });
  ```
  Add after the existing `programsProvider` block (after line 237).
- **MIRROR**: PROVIDER_FAMILY_PATTERN
- **IMPORTS**: None new
- **GOTCHA**: `syncService.getPrograms()` without a `userId` returns preset-only programs per `SyncService.getPrograms` implementation (line 302-310 — if `userId == null`, `userPrograms` stays empty). Use `.take(5)` to cap.
- **VALIDATE**: Check that `homePresetProgramsProvider` compiles. Will be used in Task 5.

### Task 5: Update Programs carousel to use `homePresetProgramsProvider`
- **ACTION**: Replace `programsProvider` with `homePresetProgramsProvider` in `_ProgramsCarouselBody`
- **IMPLEMENT**:
  In `_ProgramsCarouselBody.build`, change:
  ```dart
  final programsAsync = ref.watch(programsProvider);
  ```
  To:
  ```dart
  final programsAsync = ref.watch(homePresetProgramsProvider);
  ```
  Also update the empty-state message since these are now preset programs:
  ```dart
  // (optional) no change needed to the message text
  ```
- **MIRROR**: ASYNC_WHEN_PATTERN
- **IMPORTS**: `homePresetProgramsProvider` is in the same `workout_providers.dart` file already imported
- **GOTCHA**: `activeProgramId` still comes from `activeProgramStateProvider` — keep that line unchanged to preserve the "Active" badge on the correct program card.
- **VALIDATE**: Hot reload; Programs carousel shows max 5 cards. If user has a user-created program, it does NOT appear here (only presets).

### Task 6: Convert Sessions carousel to use real preset data (limit 10)
- **ACTION**: Replace `_SessionsCarousel` (hardcoded) with a `ConsumerWidget` that reads from `presetSessionsProvider` capped at 10. Keep `_SessionCard` design; adapt to use `Session` model instead of `_SessionData`.
- **IMPLEMENT**:
  1. Delete `_SessionData` class and the `static const List<_SessionData> _sessions` constant.
  2. Convert `_SessionsCarousel` to `ConsumerStatelessWidget`:
     ```dart
     class _SessionsCarousel extends ConsumerWidget {
       final bool isFrench;
       const _SessionsCarousel({required this.isFrench});

       @override
       Widget build(BuildContext context, WidgetRef ref) {
         final sessionsAsync = ref.watch(presetSessionsProvider);
         return SizedBox(
           height: 120,
           child: sessionsAsync.when(
             data: (sessions) {
               final capped = sessions.take(10).toList();
               if (capped.isEmpty) {
                 return Center(
                   child: Text(
                     isFrench ? 'Aucune séance disponible.' : 'No sessions available.',
                     style: const TextStyle(
                       color: AppColors.textSecondary, fontSize: 13),
                   ),
                 );
               }
               return ListView.separated(
                 scrollDirection: Axis.horizontal,
                 physics: const BouncingScrollPhysics(),
                 clipBehavior: Clip.none,
                 itemCount: capped.length,
                 separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                 itemBuilder: (context, index) =>
                     _SessionCard(session: capped[index], isFrench: isFrench),
               );
             },
             loading: () => ListView.separated(
               scrollDirection: Axis.horizontal,
               physics: const NeverScrollableScrollPhysics(),
               itemCount: 3,
               separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
               itemBuilder: (_, __) => Container(
                 width: 180,
                 decoration: BoxDecoration(
                   color: AppColors.neutral300,
                   borderRadius: BorderRadius.circular(AppRadii.sm),
                 ),
               ),
             ),
             error: (_, __) => Center(
               child: Text(
                 isFrench ? 'Impossible de charger les séances.'
                           : 'Could not load sessions.',
                 style: const TextStyle(
                   color: AppColors.textSecondary, fontSize: 13),
               ),
             ),
           ),
         );
       }
     }
     ```
  3. Update `_SessionCard` to accept `Session` instead of `_SessionData`:
     ```dart
     class _SessionCard extends StatelessWidget {
       final Session session;
       final bool isFrench;
       const _SessionCard({required this.session, required this.isFrench});
     ```
     Map `Session` fields to the card design:
     - Title: `session.name`
     - Duration: `'${session.estimatedDuration ~/ 60} min'` (convert seconds to minutes)
     - Exercises count: `session.workouts.length`
     - Level color / label: use `AppDifficultyTheme.paletteFor(session.difficulty).accentColor` for `levelColor`, `AppDifficultyTheme.label(session.difficulty, isFrench: isFrench)` for level text
     - Icon: pick based on session name (same heuristic as `_ProgramCard._iconForProgram` — extract a shared helper or inline)
- **MIRROR**: ASYNC_WHEN_PATTERN, CONSUMER_WIDGET_PATTERN
- **IMPORTS**: `Session` model already imported; `AppDifficultyTheme` already imported
- **GOTCHA**: `session.estimatedDuration` is in seconds. Convert: `session.estimatedDuration ~/ 60`. If `workouts` is empty, `estimatedDuration` might be 0 → show `'—'` instead. `presetSessionsProvider` is already in `workout_providers.dart` (line 96).
- **VALIDATE**: Hot reload; Sessions carousel shows real session names (not hardcoded "Push Day", "Leg Day"). Max 10 items. Shows loading skeletons while loading, error message on failure.

### Task 7: Remove the sign-out button
- **ACTION**: Delete `_LogoutButton` class and its call-site in the build method
- **IMPLEMENT**:
  1. In `_HomeDashboardTabState.build`, remove:
     ```dart
     // Logout
     _LogoutButton(
       isFrench: isFrench,
       onLogout: () async { ... },
     ),
     ```
  2. Delete the `_LogoutButton` class entirely (lines 1886-1909).
  3. Remove the unused import of `AuthenticationView` if it is no longer referenced elsewhere in this file. Check: `AuthenticationView` was only used in `_LogoutButton.onLogout`. Remove import if nothing else uses it.
- **MIRROR**: N/A
- **IMPORTS**: Remove `import 'package:workin_fit/views/auth/authentication_view.dart';` if no other usage remains in the file
- **GOTCHA**: `authActionsProvider` was only used by the logout callback. Remove it from the imports if nothing else in this file uses it. Check `auth_provider.dart` import too.
- **VALIDATE**: Hot reload; bottom of home screen shows quick-access cards, then the 104px spacer — no sign-out button.

---

## Testing Strategy

### Unit Tests
| Test | Input | Expected Output | Edge Case? |
|---|---|---|---|
| homePresetProgramsProvider caps at 5 | mock returning 8 programs | list.length == 5 | No |
| homePresetProgramsProvider empty | sync throws | returns [] | Yes |

### Widget Tests
These are UI-centric changes; manual validation is primary. No new widget tests required for this task (existing auth_screens_test.dart and current test suite are not affected).

### Edge Cases Checklist
- [ ] No active program → hero card shows placeholder (no crash)
- [ ] Active program loading → hero card shows spinner inside gradient
- [ ] Active program load error → hero card shows error text inside gradient
- [ ] presetSessionsProvider returns 0 sessions → sessions carousel shows empty-state text
- [ ] presetSessionsProvider returns >10 sessions → carousel shows exactly 10
- [ ] homePresetProgramsProvider returns 0 programs → programs carousel shows empty-state text
- [ ] Warmup bottom sheet opened → Confirm button disabled
- [ ] Category selected in sheet → Confirm button enabled
- [ ] Confirm tapped → sheet closes, workout starts

---

## Validation Commands

### Static Analysis
```bash
cd /home/golden/Desktop/dev/dart/workin_fit
flutter analyze lib/views/home/home_dashboard_tab.dart lib/providers/workout_providers.dart
```
EXPECT: Zero errors, zero warnings

### Full Build Check
```bash
flutter build apk --debug 2>&1 | tail -20
# or faster:
flutter pub get && flutter analyze
```
EXPECT: No errors

### Run Existing Tests
```bash
flutter test
```
EXPECT: All 159 existing tests pass, no regressions

### Manual Validation
- [ ] Home screen banner: flat bottom edge, no arch curve
- [ ] Session hero card: single gradient card (not two stacked cards)
- [ ] Hero card (no active program): shows placeholder with play button
- [ ] Hero card (active program): shows program name, week/day, meta chips
- [ ] Warmup section: no category chip button visible
- [ ] Tapping "Start warmup" → bottom sheet appears
- [ ] Bottom sheet shows 5 category options
- [ ] Confirm button is disabled (grayed) with no selection
- [ ] Selecting a category enables Confirm button
- [ ] Confirm → sheet closes, workout launches
- [ ] Programs carousel: max 5 cards, preset programs only
- [ ] Sessions carousel: real session names, max 10 cards
- [ ] No sign-out button at the bottom of home screen

---

## Acceptance Criteria
- [ ] All 7 tasks completed
- [ ] `flutter analyze` reports zero errors
- [ ] All 159 existing tests pass
- [ ] Banner has no arch/curve
- [ ] Single session hero card using real data with gradient design
- [ ] Warmup category selected via bottom sheet, not navigation
- [ ] Programs carousel limited to 5 preset programs
- [ ] Sessions carousel shows real data, max 10
- [ ] Sign-out button gone from home screen

## Completion Checklist
- [ ] Code follows private-class naming convention (`_ClassName`)
- [ ] All `async` calls use `.when()` pattern for loading/error states
- [ ] No hardcoded strings without `isFrench` branching
- [ ] No mutation — new instances created where needed
- [ ] `context.mounted` checked before Navigator calls in async callbacks
- [ ] No unnecessary scope additions beyond the 5 listed changes
- [ ] Self-contained — no questions needed during implementation

## Risks
| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| `warmupRoutineProvider` depends on `warmupCategoryProvider` — reading after notifier update may not reflect new state synchronously | Medium | High | Read `warmupRoutineProvider` AFTER `ref.read(warmupCategoryProvider.notifier).state = selected` so the provider recalculates with new category |
| Session `estimatedDuration = 0` for empty sessions | Low | Low | Show `'—'` when duration ≤ 0 |
| `context.mounted` false after await in logout (already removed) | N/A | N/A | Removed entirely |
| Removing `_ProgramCardContainer` may break if used elsewhere | Low | Medium | Grep for `_ProgramCardContainer` before deleting — it's only in this file |

## Notes
- `_ArchClipper` is only referenced inside `_HomeBannerSliver` — safe to delete entirely
- The `WarmupCategoryScreen` import (`warmup_category_screen.dart`) should be removed since direct navigation to it is no longer needed from home
- The `_categoryLabels` map in `_WarmupSelectorState` is already defined and can be directly reused in `_showCategorySheet` via `_WarmupCategoryTile`
- `AppDifficultyTheme.paletteFor(session.difficulty).accentColor` is used in `_ProgramCard` already — follow the exact same pattern for sessions
- The decorative ring positions in the gradient card (right: -36, top: -36 and left: -20, bottom: -44) should remain UNCHANGED — they are part of the established design language
