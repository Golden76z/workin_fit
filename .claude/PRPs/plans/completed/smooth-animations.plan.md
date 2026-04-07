# Plan: Smooth Animations Enhancement

## Summary
Add professional animations throughout the app using the three already-installed but unused packages: `flutter_animate` (staggered list entries, content reveals), `shimmer` (skeleton loading states), and `TweenAnimationBuilder` (progress bars). Also adds Hero transitions between exercise list thumbnails and the detail screen. No new dependencies needed.

## User Story
As a user, I want smooth, polished animations throughout the app, so that interactions feel responsive and the app feels premium.

## Problem → Solution
Static instant rendering + CircularProgressIndicator everywhere → Staggered list entries, skeleton screens during load, Hero image transitions, animated progress bars, trophy unlock feedback.

## Metadata
- **Complexity**: Medium
- **Source PRD**: N/A
- **PRD Phase**: N/A
- **Estimated Files**: 6 modified + 0 created

---

## UX Design

### Before
```
┌──────────────────────┐
│ ○ (spinner)          │  ← Loading states everywhere
│                      │
│ [Item] appears       │  ← Instant list appearance
│ [Item] appears       │
│ [Item] appears       │
│                      │
│ ████ progress bar    │  ← Static, no animation
│ 🏆 → 🏆 same card   │  ← No unlock feedback
└──────────────────────┘
```

### After
```
┌──────────────────────┐
│ ░░░░░░░░░░░░░░░      │  ← Shimmer skeleton
│ ░░░░░░░░░░░           │
│                      │
│ [Item] fades in ↑    │  ← Staggered 0ms
│ [Item] fades in ↑    │  ← Staggered 50ms
│ [Item] fades in ↑    │  ← Staggered 100ms
│                      │
│ ████ animates →      │  ← Progress bar fills on load
│ 🏆 pulses on unlock  │  ← Scale + glow on unlock
└──────────────────────┘
```

### Interaction Changes
| Touchpoint | Before | After | Notes |
|---|---|---|---|
| Exercise list load | CircularProgressIndicator | Shimmer skeleton rows | 3 placeholder cards |
| Exercise list items | Instant render | Stagger fade+slide up 50ms apart | Cap at 8 items staggered |
| Exercise → Detail | FadeTransition+SlideTransition (existing) | + Hero on tutorial image | Shared element transition |
| Sessions list | Instant render | Stagger fade+slide up 50ms apart | |
| Achievements progress bar | Static fill | TweenAnimationBuilder 0→value 600ms | On first build |
| Trophy card unlock state | AnimatedContainer border/shadow | + scale pulse via flutter_animate | Plays once when unlocked=true |
| Home dashboard | Instant sections | Fade+slide entry 80ms stagger | Cards enter on page load |

---

## Mandatory Reading

| Priority | File | Lines | Why |
|---|---|---|---|
| P0 | `lib/core/theme/app_dimensions.dart` | all | Add AppAnimations constants here |
| P0 | `lib/features/workout/presentation/screens/exercise_list_screen.dart` | 295-325, 439-540 | SliverList.builder + _ExerciseCard structure |
| P0 | `lib/features/workout/presentation/screens/exercise_detail_screen.dart` | 36-51, 403-430 | Existing page transition + _SectionImage |
| P1 | `lib/views/home/sessions_tab.dart` | 400-430, 546-570 | ListView.builder + _SessionCard |
| P1 | `lib/views/achievements/achievements_page.dart` | 140-175, 389-460 | _SummaryBanner progress bar + _TrophyCard |
| P2 | `lib/views/home/home_dashboard_tab.dart` | 1-100 | Dashboard section structure |

## External Documentation
| Topic | Source | Key Takeaway |
|---|---|---|
| flutter_animate | pub.dev/packages/flutter_animate | `.animate().fadeIn(duration:).slideY(begin:)` chaining |
| shimmer | pub.dev/packages/shimmer | `Shimmer.fromColors(baseColor:, highlightColor:, child:)` |

---

## Patterns to Mirror

### EXISTING_PAGE_TRANSITION
```dart
// SOURCE: lib/features/workout/presentation/screens/exercise_detail_screen.dart:28-50
return PageRouteBuilder<void>(
  transitionDuration: const Duration(milliseconds: 420),
  reverseTransitionDuration: const Duration(milliseconds: 300),
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    final fadeCurve = CurvedAnimation(parent: animation, curve: Curves.easeOut);
    final slideCurve = CurvedAnimation(parent: animation, curve: Curves.easeOutQuart);
    return FadeTransition(
      opacity: fadeCurve,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(slideCurve),
        child: child,
      ),
    );
  },
);
```

### FLUTTER_ANIMATE_STAGGER (to introduce)
```dart
// Pattern for list items — wrap the item widget, NOT the ListView
child: _SessionCard(...).animate(delay: (index * 50).ms)
  .fadeIn(duration: 200.ms)
  .slideY(begin: 0.12, end: 0, duration: 220.ms, curve: Curves.easeOutCubic),
// GOTCHA: Cap delay: min(index, 8) * 50 so items 9+ don't have 450ms+ delays
```

### SHIMMER_SKELETON (to introduce)
```dart
// SOURCE: pubspec.yaml:30 — shimmer: ^3.0.0
import 'package:shimmer/shimmer.dart';
Shimmer.fromColors(
  baseColor: AppColors.surface,
  highlightColor: AppColors.surfaceVariant,
  child: Container(
    height: 100,
    margin: const EdgeInsets.only(bottom: 2),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(4),
    ),
  ),
);
```

### ANIMATED_PROGRESS_BAR (to introduce)
```dart
// Replace static LinearProgressIndicator with:
TweenAnimationBuilder<double>(
  tween: Tween<double>(begin: 0, end: pct),
  duration: const Duration(milliseconds: 600),
  curve: Curves.easeOutCubic,
  builder: (context, value, _) => LinearProgressIndicator(
    value: value,
    minHeight: 6,
    backgroundColor: Colors.white.withValues(alpha: AppOpacity.medium),
    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
  ),
)
```

### HERO_IMAGE (to introduce)
```dart
// Wrap source image (list) and destination image (detail) with same tag:
Hero(
  tag: exercise.imageTutorialUrl,  // unique per exercise, available in both screens
  child: _ExerciseImage(imageUrl: exercise.imageTutorialUrl, ...),
)
```

### APP_COLORS_REFERENCE
```dart
// SOURCE: lib/core/theme/colors.dart
// Shimmer colors:
AppColors.surface      // base color (slightly lighter)
AppColors.surfaceVariant  // highlight color (slightly darker)
```

---

## Files to Change

| File | Action | Justification |
|---|---|---|
| `lib/core/theme/app_dimensions.dart` | UPDATE | Add `AppAnimations` class with standardized durations and curves |
| `lib/features/workout/presentation/screens/exercise_list_screen.dart` | UPDATE | Shimmer skeleton + stagger on _ExerciseCard + Hero on thumbnail |
| `lib/features/workout/presentation/screens/exercise_detail_screen.dart` | UPDATE | Hero receive on tutorial image in _SectionImage |
| `lib/views/home/sessions_tab.dart` | UPDATE | Stagger on _SessionCard and _ProgramCard in ListView.builder |
| `lib/views/achievements/achievements_page.dart` | UPDATE | Animated progress bar + trophy card reveal via flutter_animate |
| `lib/views/home/home_dashboard_tab.dart` | UPDATE | Staggered section entry animations on initial load |

## NOT Building
- Custom ripple effects or InkWell customization
- Lottie JSON animations (no .json assets in project)
- Animation for auth screens (low traffic, not worth complexity)
- WorkoutExecutionScreen animations (already has timer, very performance-sensitive)
- Profile avatar Hero (complex custom ring widget, layout issues risk)
- Chat screen animations (message bubbles — different rhythm, separate feature)
- Route-level transition changes (4 detail screens already have good transitions)

---

## Step-by-Step Tasks

### Task 1: Add AppAnimations constants
- **ACTION**: Add `AppAnimations` class to `app_dimensions.dart`
- **IMPLEMENT**:
```dart
class AppAnimations {
  // Durations
  static const Duration fastest = Duration(milliseconds: 150);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration progressBar = Duration(milliseconds: 600);

  // Stagger interval between list items
  static const int staggerMs = 50;
  static const int staggerMaxItems = 8; // items beyond this use max delay

  // Curves
  static const Curve defaultIn = Curves.easeOutCubic;
  static const Curve defaultOut = Curves.easeInCubic;
  static const Curve spring = Curves.elasticOut;
}
```
- **MIRROR**: AppSpacing / AppRadii pattern in the same file
- **IMPORTS**: none (no import needed, it's in the theme file)
- **GOTCHA**: Keep this file import-free (no `flutter_animate` imports here — constants only)
- **VALIDATE**: `flutter analyze lib/core/theme/app_dimensions.dart` — zero issues

### Task 2: Exercise list — shimmer skeleton loading state
- **ACTION**: In `exercise_list_screen.dart`, replace the `loading:` branch with a shimmer skeleton
- **IMPLEMENT**: Find the `AsyncValue.when(loading: () => ...)` or `if (exercisesAsync.isLoading)` guard. Replace the loading widget with:
```dart
// loading: () =>
SliverList.builder(
  itemCount: 5,
  itemBuilder: (context, index) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
    child: Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surfaceVariant,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    ),
  ),
)
```
- **MIRROR**: SHIMMER_SKELETON pattern
- **IMPORTS**: `import 'package:shimmer/shimmer.dart';`
- **GOTCHA**: Height `100` should match the actual `_ExerciseCard` approximate height. Adjust after checking rendered height. The shimmer sliver must be wrapped in `SliverPadding` matching the real list padding.
- **VALIDATE**: Hot reload, navigate to exercise list with slow connection simulation — shimmer appears

### Task 3: Exercise list — stagger animation on cards + Hero on thumbnail
- **ACTION**: In `exercise_list_screen.dart` `itemBuilder`, wrap `_ExerciseCard` with `flutter_animate` stagger. Also wrap the `_ExerciseImage` inside `_ExerciseCard` with `Hero`.
- **IMPLEMENT**:

  **In itemBuilder (line ~304):**
  ```dart
  return Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
    child: _ExerciseCard(
      exercise: exercise,
      ...
    ).animate(delay: (min(index, AppAnimations.staggerMaxItems) * AppAnimations.staggerMs).ms)
      .fadeIn(duration: AppAnimations.fast)
      .slideY(begin: 0.1, end: 0, duration: AppAnimations.fast, curve: AppAnimations.defaultIn),
  );
  ```

  **In `_ExerciseCard.build`, around the `ClipRRect` that wraps `_ExerciseImage` (line ~522):**
  ```dart
  Hero(
    tag: exercise.imageTutorialUrl,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: SizedBox(
        width: mediaWidth,
        height: mediaHeight,
        child: _ExerciseImage(imageUrl: exercise.imageTutorialUrl, shaderVelocity: shaderVelocity),
      ),
    ),
  ),
  ```

- **MIRROR**: FLUTTER_ANIMATE_STAGGER + HERO_IMAGE patterns
- **IMPORTS**: `import 'package:flutter_animate/flutter_animate.dart';`, `import 'dart:math' show min;`
- **GOTCHA**: `dart:math`'s `min` conflicts if there's already a `math` import — use `math.min` or alias. The Hero tag must be a non-empty string; skip Hero if `exercise.imageTutorialUrl.isEmpty`.
- **VALIDATE**: List scrolls smoothly, items fade in staggered, `flutter analyze` clean

### Task 4: Exercise detail — Hero receive on tutorial image
- **ACTION**: In `exercise_detail_screen.dart`, wrap the tutorial `_SectionImage` / `_ExerciseMedia` with `Hero` using the same tag as Task 3.
- **IMPLEMENT**: Find the `_SectionImage` widget that renders `exercise.imageTutorialUrl` (around line 133-145). The `_SectionImage` contains `_ExerciseMedia(url: imageUrl)`. Add a `heroTag` parameter to `_SectionImage`:
```dart
// Add to _SectionImage constructor:
final String? heroTag;
const _SectionImage({required this.imageUrl, required this.label, this.heroTag});

// In _SectionImage.build, wrap the child of ClipRRect (or the ClipRRect itself):
heroTag != null
    ? Hero(tag: heroTag!, child: _ExerciseMedia(url: imageUrl))
    : _ExerciseMedia(url: imageUrl)
```
Then pass `heroTag: exercise.imageTutorialUrl` at the call site for the tutorial image section only.
- **MIRROR**: HERO_IMAGE pattern
- **IMPORTS**: none new
- **GOTCHA**: The Hero in the list is wrapped in `ClipRRect`. The Hero in detail should NOT be wrapped in a separate ClipRRect (let the transition handle shape) — or both must have the same ClipRRect to avoid shape jump. Use `Hero` outside `ClipRRect` in detail, and the transition will interpolate the clip naturally via Flutter's Hero flight mechanism.
- **VALIDATE**: Tap exercise in list → detail screen shows Hero image transition (image flies from card position to detail position)

### Task 5: Sessions tab — stagger on session and program cards
- **ACTION**: In `sessions_tab.dart`, wrap `_SessionCard` and `_ProgramCard` in `flutter_animate` stagger in their respective `ListView.builder` itemBuilders.
- **IMPLEMENT**:
```dart
// sessions itemBuilder (around line 413):
child: _SessionCard(
  session: session,
  ...
).animate(delay: (min(index, AppAnimations.staggerMaxItems) * AppAnimations.staggerMs).ms)
  .fadeIn(duration: AppAnimations.fast)
  .slideY(begin: 0.1, end: 0, duration: AppAnimations.fast, curve: AppAnimations.defaultIn),

// programs itemBuilder (find the _ProgramCard equivalent location):
child: _ProgramCard(
  program: program,
  ...
).animate(delay: (min(index, AppAnimations.staggerMaxItems) * AppAnimations.staggerMs).ms)
  .fadeIn(duration: AppAnimations.fast)
  .slideY(begin: 0.1, end: 0, duration: AppAnimations.fast, curve: AppAnimations.defaultIn),
```
- **MIRROR**: FLUTTER_ANIMATE_STAGGER pattern
- **IMPORTS**: `import 'package:flutter_animate/flutter_animate.dart';`, `import 'dart:math' show min;`
- **GOTCHA**: `ListView.builder` with `physics: const ClampingScrollPhysics()` — the stagger plays correctly. Don't add stagger to Dismissible or draggable items as it fights the gesture.
- **VALIDATE**: Switch to Sessions tab → cards animate in staggered

### Task 6: Achievements — animated progress bars + trophy reveal
- **ACTION**: In `achievements_page.dart`:
  1. Replace `LinearProgressIndicator` in `_SummaryBanner` (line ~158) with `TweenAnimationBuilder`
  2. Replace `LinearProgressIndicator` in `_CategorySection` (line ~324) with `TweenAnimationBuilder`
  3. Add `flutter_animate` scale pulse to `_TrophyCard` when `unlocked == true`
- **IMPLEMENT**:

  **Progress bar (both locations, same pattern):**
  ```dart
  TweenAnimationBuilder<double>(
    tween: Tween<double>(begin: 0, end: pct),
    duration: AppAnimations.progressBar,
    curve: AppAnimations.defaultIn,
    builder: (context, value, _) => LinearProgressIndicator(
      value: value,
      minHeight: 6,   // keep existing minHeight
      backgroundColor: Colors.white.withValues(alpha: AppOpacity.medium),
      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
    ),
  )
  ```

  **Trophy card unlock reveal** — in `_TrophyCard.build`, wrap the entire `AnimatedContainer` return value:
  ```dart
  return AnimatedContainer(
    duration: ...,
    ...
  ).animate(target: unlocked ? 1 : 0)
    .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0), duration: 300.ms)
    .shimmer(duration: 600.ms, color: rankColor.withValues(alpha: 0.3));
  ```
  Note: `.animate(target:)` replays when `unlocked` changes.

- **MIRROR**: ANIMATED_PROGRESS_BAR pattern
- **IMPORTS**: `import 'package:flutter_animate/flutter_animate.dart';`
- **GOTCHA**: The category progress bar uses a different `pct` variable than the summary banner. Find both separately. `TweenAnimationBuilder` replays when `tween.end` changes — this is correct behavior (new achievements re-animate). The `rankColor` in the shimmer is only meaningful when `unlocked==true`; the `target: 0` prevents the animation from playing on locked cards.
- **VALIDATE**: Navigate to Achievements → progress bar fills from 0, unlocked trophies have shimmer glow

### Task 7: Home dashboard — staggered section entry
- **ACTION**: In `home_dashboard_tab.dart`, add `flutter_animate` fadeIn+slideY to the major content sections rendered in the `CustomScrollView` slivers (daily challenge card, active program section, quick actions).
- **IMPLEMENT**: Find the `SliverToBoxAdapter` children that render the dashboard sections. Wrap each section widget:
```dart
SliverToBoxAdapter(
  child: DailyChallengeSection(...).animate()
    .fadeIn(duration: AppAnimations.medium, delay: 0.ms)
    .slideY(begin: 0.08, end: 0, duration: AppAnimations.medium, curve: AppAnimations.defaultIn),
),
SliverToBoxAdapter(
  child: ActiveProgramSection(...).animate()
    .fadeIn(duration: AppAnimations.medium, delay: 80.ms)
    .slideY(begin: 0.08, end: 0, duration: AppAnimations.medium, curve: AppAnimations.defaultIn),
),
// Add 80ms stagger for each subsequent major section
```
- **MIRROR**: FLUTTER_ANIMATE_STAGGER pattern (delay-based, not index-based for sections)
- **IMPORTS**: `import 'package:flutter_animate/flutter_animate.dart';`
- **GOTCHA**: The dashboard rebuilds when Riverpod providers update. Use `.animate(onPlay: (c) => c.forward())` to ensure animation only plays once on initial build, not on every state rebuild. OR use `key: const ValueKey('dashboard-section-N')` on the animated widget so Flutter keeps the same animation instance across rebuilds.
- **VALIDATE**: Navigate to Dashboard tab → sections slide up sequentially

---

## Testing Strategy

### Unit Tests
No unit tests needed — purely UI/animation code with no business logic.

### Edge Cases Checklist
- [ ] List with 0 items — stagger with empty list doesn't crash
- [ ] List with 1 item — single item animates correctly (delay = 0ms)
- [ ] Exercise with empty `imageTutorialUrl` — Hero skipped, no crash
- [ ] Achievement with `pct = 0` — progress bar stays at 0 (no negative tween)
- [ ] Achievement with `pct = 1.0` — progress bar fills completely
- [ ] Dashboard rebuilds on pull-to-refresh — animations don't replay (use ValueKey)
- [ ] Low-end device (animations enabled) — all durations ≤ 300ms per item

---

## Validation Commands

### Static Analysis
```bash
/home/golden/fvm/versions/stable/bin/flutter analyze lib/core/theme/app_dimensions.dart lib/features/workout/presentation/screens/exercise_list_screen.dart lib/features/workout/presentation/screens/exercise_detail_screen.dart lib/views/home/sessions_tab.dart lib/views/achievements/achievements_page.dart lib/views/home/home_dashboard_tab.dart
```
EXPECT: Zero issues

### Build Check
```bash
/home/golden/fvm/versions/stable/bin/flutter build apk --debug
```
EXPECT: Build succeeds, no errors

### Manual Validation
- [ ] Exercise list → shimmer shows during load, then items stagger in
- [ ] Tap exercise card → Hero image flies to detail screen
- [ ] Back from detail → Hero flies back to list card position
- [ ] Sessions tab → cards stagger in on first load
- [ ] Achievements → progress bar animates from 0 to value on page open
- [ ] Unlocked trophy card has shimmer glow, locked does not
- [ ] Home dashboard → sections fade+slide in sequentially
- [ ] Pull-to-refresh on dashboard → sections do NOT re-animate (stable)
- [ ] No jank on list scroll after animations complete

---

## Acceptance Criteria
- [ ] All 7 tasks completed
- [ ] `flutter analyze` zero issues on all 6 changed files
- [ ] `flutter build apk --debug` succeeds
- [ ] Shimmer shows on exercise list load
- [ ] Hero transition works exercise list → detail and back
- [ ] Stagger works on Sessions tab cards
- [ ] Progress bars animate on Achievements page
- [ ] Dashboard sections have staggered entry
- [ ] All animation durations ≤ 300ms (except progress bar at 600ms which is intentional)

## Completion Checklist
- [ ] `AppAnimations` constants used consistently (no magic numbers)
- [ ] `dart:math`'s `min` used to cap stagger delay
- [ ] Hero tags are non-empty strings (guarded)
- [ ] `TweenAnimationBuilder` replays correctly when data changes
- [ ] flutter_animate `.animate(target:)` on trophy only plays on unlock transition
- [ ] No `flutter_animate` on WorkoutExecutionScreen (excluded)
- [ ] No `flutter_animate` on auth screens (excluded)

## Risks
| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Dashboard re-animates on every rebuild | High | Medium | Use `ValueKey` on animated sections |
| Hero tag collision (two exercises with same imageUrl) | Low | Low | Unlikely with real URLs; if happens, append exercise.id |
| `flutter_animate` version conflict with existing deps | Low | High | Already in pubspec.yaml at ^4.3.0 — no change needed |
| Shimmer height mismatch with actual card height | Medium | Low | Tune height constant after visual check |
| Stagger makes list feel slow if too many items | Medium | Medium | Cap at staggerMaxItems=8 — items 9+ animate simultaneously |

## Notes
- `flutter_animate`, `shimmer`, and `lottie` are already in pubspec.yaml — zero `flutter pub add` needed
- The 4 existing detail screen transitions (exercise, session, program, history) are already good — leave them untouched
- `lottie` is available but there are no .json animation assets in the project; skip Lottie for this pass
- All durations follow the rule: list items ≤ 250ms, page content ≤ 300ms, progress bars = 600ms (intentional, feels satisfying)
- flutter_animate's `.animate()` extension works on any Widget — no wrapper class needed
