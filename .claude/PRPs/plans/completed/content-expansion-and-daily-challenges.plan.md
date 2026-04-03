# Plan: Content Expansion & Daily Challenges

## Summary
Two coordinated additions: (A) expand the preset workout catalog with longer intermediate/advanced sessions, 6-day programs, and active-rest sessions (jogging, meditation, mobility), and (B) wire the existing `_DailyChallengeCard` placeholder on the home dashboard to real data — a bundled challenge catalog, a completion provider, and Firestore-persisted progress.

## User Story
As a fitness user, I want varied, appropriately-challenging preset programs (including 6-day options and active recovery days), and a fresh daily challenge on my home screen that I can complete and track, so that I have clear progressive targets each day.

## Problem → Solution
- **Preset content**: All 5 programs max out at 5 days/week; intermediate sessions are ~15–25 min; no advanced programs exist; no active-rest sessions.
  → Add 12 new sessions (3 active rest, 3 intermediate extended, 6 advanced) and 3 new programs (6-day intermediate PPL, 6-day advanced PPL, 5-day with active recovery).
- **Daily challenge**: `_DailyChallengeCard` at `home_dashboard_tab.dart:706` is 100% hardcoded (static "100 push-ups", "42/100", "247 participants"). No model, no provider, no real data.
  → Add `DailyChallenge` model, `DailyChallengesCatalog` (30 pre-built challenges), `challengeProviders.dart`, completion tracking in Firestore, and convert `_DailyChallengeCard` to a `ConsumerWidget`.

## Metadata
- **Complexity**: Large
- **Source PRD**: N/A
- **PRD Phase**: N/A
- **Estimated Files**: 11

---

## UX Design

### Before
```
Home Dashboard
├── SessionHeroCard (real data)
├── _DailyChallengeCard  ← hardcoded "100 push-ups / 42 of 100 / 247 participants"
├── WarmupSelector
├── Programs Carousel    ← 5 preset programs (max 3–5 days/week, all beginner/intermediate)
└── Sessions Carousel    ← 22 preset sessions (short, no active rest)
```

### After
```
Home Dashboard
├── SessionHeroCard (real data)
├── _DailyChallengeCard  ← real DailyChallenge from catalog, user completion stored in Firestore
├── WarmupSelector
├── Programs Carousel    ← 8 preset programs (+3 new: 6-day int, 6-day adv, 5-day w/ active rest)
└── Sessions Carousel    ← 34 preset sessions (+12 new)
```

### Interaction Changes
| Touchpoint | Before | After | Notes |
|---|---|---|---|
| Daily challenge card | Static text, tap does nothing | Taps toggle completion (filled progress bar) | Completion persisted in Firestore |
| Programs carousel | 5 cards, max 5 days/week | 8 cards, 6-day options visible | New programs use `homePresetProgramsProvider` (still capped at 5 on home, all visible in Programs tab) |
| Sessions carousel | 22 sessions | 34 sessions (incl. active rest) | Active rest sessions appear in full session list |

---

## Mandatory Reading

| Priority | File | Lines | Why |
|---|---|---|---|
| P0 | `lib/data/preset_program_catalog.dart` | 1–527 | Exact pattern for _sessions + _programs lists; _sets/_timed/_tabata helpers |
| P0 | `lib/views/home/home_dashboard_tab.dart` | 706–890 | Existing `_DailyChallengeCard` placeholder to replace |
| P1 | `lib/models/session.dart` | all | Session model and Hive typeIds |
| P1 | `lib/models/enums.dart` | all | DifficultyLevel, WorkoutType enums (Hive typeIds 10–12) |
| P1 | `lib/models/program.dart` | all | Program model, `toFirestore()` method |
| P1 | `lib/providers/workout_providers.dart` | 96–103, 239–248 | `presetSessionsProvider`, `homePresetProgramsProvider` patterns to mirror |
| P2 | `lib/services/firestore_service.dart` | all | Firestore CRUD patterns for new challenge methods |
| P2 | `data/programs/upload_preset_programs.dart` | all | Upload script pattern |
| P2 | `data/exercises/all.json` | any entry | Exercise JSON schema |

---

## Patterns to Mirror

### PRESET_SESSION_DEFINITION
```dart
// SOURCE: lib/data/preset_program_catalog.dart:93–108
Session(
  id: 'sess_bfb_day1',
  name: 'Beginner Full Body A',
  description: 'Foundational push, lower body, pull, and core work.',
  workouts: <WorkoutConfig>[
    _sets('push_008', 3, 10),
    _sets('legs_001', 3, 12),
    _sets('pull_015', 3, 10),
    _timed('core_001', 45),
    _timed('cardio_001', 60),
  ],
  restBetweenExercises: 75,
  difficulty: DifficultyLevel.beginner,
  createdAt: _seededAt,
),
```

### PRESET_PROGRAM_DEFINITION
```dart
// SOURCE: lib/data/preset_program_catalog.dart:400–424
Program(
  id: 'prog_beginner_full_body_4w',
  name: 'Beginner Full Body (4 Weeks)',
  description: 'A beginner-friendly plan ...',
  sessionIds: _repeatWeekly(
    <String>['sess_bfb_day1', 'sess_bfb_day2', 'sess_bfb_day3'],
    4,
  ),
  durationWeeks: 4,
  difficulty: DifficultyLevel.beginner,
  goals: <String>[
    'Build a repeatable weekly routine with low injury risk.',
    'Rest days: Tuesday, Thursday, Saturday, Sunday.',
  ],
  daysPerWeek: 3,
  createdAt: _seededAt,
),
```

### TRAINING_DAYS_MAP
```dart
// SOURCE: lib/data/preset_program_catalog.dart:19–26
static const Map<String, List<int>> trainingDaysByProgramId = <String, List<int>>{
  'prog_beginner_full_body_4w': <int>[1, 3, 5],        // Mon, Wed, Fri
  'prog_upper_body_focus_4w': <int>[1, 2, 4, 5, 6],   // 5 days
};
```

### FUTURE_PROVIDER_PATTERN
```dart
// SOURCE: lib/providers/workout_providers.dart:96–103
final presetSessionsProvider = FutureProvider<List<Session>>((ref) async {
  final syncService = ref.watch(syncServiceProvider);
  try {
    return await syncService.getPresetSessions();
  } catch (_) {
    return [];
  }
});
```

### CONSUMER_WIDGET_SECTION
```dart
// SOURCE: lib/views/home/home_dashboard_tab.dart (sessions carousel pattern)
class _SessionsCarousel extends ConsumerWidget {
  final bool isFrench;
  const _SessionsCarousel({required this.isFrench});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(presetSessionsProvider);
    return SizedBox(
      height: 120,
      child: sessionsAsync.when(
        data: (sessions) { ... },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}
```

### HIVE_MODEL_PATTERN
```dart
// SOURCE: lib/models/session.dart:9–58
@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 1)
class Session extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final String name;
  // ...
  factory Session.fromJson(Map<String, dynamic> json) => _$SessionFromJson(json);
  Map<String, dynamic> toJson() => _$SessionToJson(this);
}
```

### EXERCISE_JSON_SCHEMA
```json
// SOURCE: data/exercises/all.json (entry for push_001)
{
  "id": "rest_001",
  "name": "Meditation & Deep Breathing",
  "nameKey": "exercise_rest_001_name",
  "description": "...",
  "descriptionKey": "exercise_rest_001_description",
  "beginnerTips": "...",
  "beginnerTipsKey": "exercise_rest_001_beginner_tips",
  "difficulty": "beginner",
  "muscleGroups": ["cardio"],
  "equipment": [],
  "imageMuscleUrl": "",
  "imageTutorialUrl": ""
}
```

---

## Files to Change

| File | Action | Justification |
|---|---|---|
| `data/exercises/all.json` | UPDATE | Add 3 active-rest exercise entries |
| `data/exercises/beginner.json` | UPDATE | Mirror the 3 new entries (active rest = beginner difficulty) |
| `lib/data/preset_program_catalog.dart` | UPDATE | Add 12 sessions + 3 programs + trainingDays entries |
| `lib/models/daily_challenge.dart` | CREATE | DailyChallenge + DailyChallengeType Hive/JSON models |
| `lib/models/enums.dart` | UPDATE | Add `DailyChallengeType` enum with Hive typeId 13 |
| `lib/data/daily_challenges_catalog.dart` | CREATE | 30 pre-built DailyChallenge definitions |
| `lib/providers/challenge_providers.dart` | CREATE | `todaysChallengeProvider`, `challengeCompletionProvider`, actions |
| `lib/services/firestore_service.dart` | UPDATE | Add `getChallengeCompletion`, `setChallengeCompleted` methods |
| `lib/views/home/home_dashboard_tab.dart` | UPDATE | Convert `_DailyChallengeCard` from `StatelessWidget` to `ConsumerWidget` |
| `lib/core/utils/hive_setup.dart` (or equivalent) | UPDATE | Register new DailyChallenge Hive adapter |
| `data/programs/upload_preset_programs.dart` | UPDATE | Include new sessions/programs in upload |

---

## NOT Building

- Admin tooling to create/edit challenges remotely
- Social "247 participants" real-time count (keep static or remove)
- Challenge leaderboard or ranking
- Rep-counting integration into workout execution (challenges stay manually completed for now)
- Push notifications for daily challenge reminders
- Streak bonuses or reward point redemption UI

---

## Step-by-Step Tasks

### Task 1: Add Active-Rest Exercises to JSON Catalog
- **ACTION**: Add 3 new exercise entries to exercise JSON files
- **IMPLEMENT**:
  ```json
  // Append to data/exercises/all.json AND data/exercises/beginner.json
  {
    "id": "rest_001",
    "name": "Meditation & Deep Breathing",
    "nameKey": "exercise_rest_001_name",
    "description": "Focused mindfulness session. Sit or lie still, close your eyes, and practise box breathing: inhale 4s, hold 4s, exhale 4s, hold 4s. Reduces cortisol and accelerates recovery.",
    "descriptionKey": "exercise_rest_001_description",
    "beginnerTips": "Start with 5-minute sessions. A wandering mind is normal — gently redirect to the breath without judgement.",
    "beginnerTipsKey": "exercise_rest_001_beginner_tips",
    "difficulty": "beginner",
    "muscleGroups": ["cardio"],
    "equipment": [],
    "imageMuscleUrl": "",
    "imageTutorialUrl": ""
  },
  {
    "id": "rest_002",
    "name": "Easy Jog / Brisk Walk",
    "nameKey": "exercise_rest_002_name",
    "description": "Low-intensity steady-state cardio. Keep pace conversational — you should complete full sentences without gasping. Promotes blood flow and active recovery without adding training stress.",
    "descriptionKey": "exercise_rest_002_description",
    "beginnerTips": "If your heart rate exceeds 130 bpm, slow to a walk. The goal is circulation, not intensity.",
    "beginnerTipsKey": "exercise_rest_002_beginner_tips",
    "difficulty": "beginner",
    "muscleGroups": ["cardio"],
    "equipment": [],
    "imageMuscleUrl": "",
    "imageTutorialUrl": ""
  },
  {
    "id": "rest_003",
    "name": "Full Body Mobility Flow",
    "nameKey": "exercise_rest_003_name",
    "description": "Dynamic and static stretching targeting major muscle groups in sequence. Improves range of motion, reduces soreness, and primes the body for the next training day.",
    "descriptionKey": "exercise_rest_003_description",
    "beginnerTips": "Move at breath pace. Never bounce into a stretch. Work from ankles upward: ankles → hips → thoracic spine → shoulders → neck.",
    "beginnerTipsKey": "exercise_rest_003_beginner_tips",
    "difficulty": "beginner",
    "muscleGroups": ["cardio"],
    "equipment": [],
    "imageMuscleUrl": "",
    "imageTutorialUrl": ""
  }
  ```
- **MIRROR**: EXERCISE_JSON_SCHEMA
- **GOTCHA**: `nameKey`, `descriptionKey`, `beginnerTipsKey` must follow the pattern `exercise_{id}_{field}`. The app uses these keys for localization lookup — wrong keys won't crash but will fall back to raw strings.
- **VALIDATE**: `python3 -c "import json; d=json.load(open('data/exercises/all.json')); print([e['id'] for e in d if e['id'].startswith('rest_')])"` → should print `['rest_001', 'rest_002', 'rest_003']`

### Task 2: Add Active-Rest Sessions to PresetProgramCatalog
- **ACTION**: Append 3 new sessions to `_sessions` list in `lib/data/preset_program_catalog.dart`
- **IMPLEMENT**: Add after the last upper-body session (`sess_upper_pull_core`):
  ```dart
  // ── Active Rest ───────────────────────────────────────────────────────────
  Session(
    id: 'sess_active_rest_breathwork',
    name: 'Breathwork & Mindfulness',
    description: 'Guided breathing and light mobility to reduce stress and aid recovery.',
    workouts: <WorkoutConfig>[
      _timed('rest_001', 600),   // 10 min meditation
      _timed('core_018', 60),    // Plank to Downward Dog
      _timed('pull_005', 60),    // Wall Angels
      _timed('pull_010', 60),    // Scapular Wall Slides
      _timed('rest_001', 300),   // 5 min close meditation
    ],
    restBetweenExercises: 30,
    difficulty: DifficultyLevel.beginner,
    createdAt: _seededAt,
  ),
  Session(
    id: 'sess_active_rest_jog',
    name: 'Easy Jog / Brisk Walk',
    description: '25 minutes of low-intensity steady-state cardio for active recovery.',
    workouts: <WorkoutConfig>[
      _timed('rest_002', 1500),  // 25 min easy jog
    ],
    restBetweenExercises: 0,
    difficulty: DifficultyLevel.beginner,
    createdAt: _seededAt,
  ),
  Session(
    id: 'sess_active_rest_mobility',
    name: 'Full Body Mobility',
    description: 'Dynamic stretching and mobility drills to improve flexibility and reduce DOMS.',
    workouts: <WorkoutConfig>[
      _timed('rest_003', 300),   // 5 min mobility flow warm-up
      _timed('core_018', 120),   // Plank to Downward Dog
      _timed('pull_003', 90),    // Reverse Snow Angels
      _timed('pull_005', 90),    // Wall Angels
      _timed('legs_009', 60),    // Side Lunge (hip opener)
      _timed('rest_003', 300),   // 5 min close mobility flow
    ],
    restBetweenExercises: 20,
    difficulty: DifficultyLevel.beginner,
    createdAt: _seededAt,
  ),
  ```
- **MIRROR**: PRESET_SESSION_DEFINITION
- **GOTCHA**: `_timed` takes `(exerciseId, durationSeconds)`. `rest_002` used for 1500s = 25 min single-exercise session — this is valid; `exerciseCount` will be 1.
- **VALIDATE**: `buildSessions().where((s) => s.id.startsWith('sess_active')).length == 3`

### Task 3: Add Extended Intermediate Sessions
- **ACTION**: Append 3 new intermediate sessions (35–45 min target)
- **IMPLEMENT**: Add after active-rest sessions:
  ```dart
  // ── Intermediate Extended ─────────────────────────────────────────────────
  Session(
    id: 'sess_int_push_b',
    name: 'Intermediate Push B',
    description: 'Shoulder and tricep-focused pressing volume at higher density.',
    workouts: <WorkoutConfig>[
      _sets('push_006', 4, 10, restBetweenSets: 90),  // Pike Push-up
      _sets('push_009', 4, 8,  restBetweenSets: 90),  // Archer Push-up
      _sets('push_014', 4, 10, restBetweenSets: 90),  // Diamond Tricep Dips
      _sets('push_020', 3, 8,  restBetweenSets: 90),  // Dive Bomber Push-up
      _sets('core_020', 3, 15),                         // Plank Up-Downs
      _timed('core_002', 90),                           // Side Plank
    ],
    restBetweenExercises: 90,
    difficulty: DifficultyLevel.intermediate,
    createdAt: _seededAt,
  ),
  Session(
    id: 'sess_int_pull_b',
    name: 'Intermediate Pull B',
    description: 'Scapular, rotator-cuff, and row endurance for balanced upper-back development.',
    workouts: <WorkoutConfig>[
      _sets('pull_007', 4, 15, restBetweenSets: 90),  // Prone T Raise
      _sets('pull_006', 4, 15, restBetweenSets: 90),  // Prone Y Raise
      _sets('pull_013', 4, 10, restBetweenSets: 90),  // Single Arm Row
      _sets('pull_012', 3, 10, restBetweenSets: 90),  // Reverse Plank Walk
      _sets('pull_010', 3, 12),                         // Scapular Wall Slides
      _timed('core_009', 60),                           // Hollow Body Hold
    ],
    restBetweenExercises: 90,
    difficulty: DifficultyLevel.intermediate,
    createdAt: _seededAt,
  ),
  Session(
    id: 'sess_int_legs_b',
    name: 'Intermediate Legs B',
    description: 'Quad-dominant session with glute and calf finishers.',
    workouts: <WorkoutConfig>[
      _sets('legs_001', 4, 15, restBetweenSets: 90),  // Bodyweight Squat
      _sets('legs_019', 4, 10, restBetweenSets: 90),  // Skater Squats
      _sets('legs_021', 4, 12, restBetweenSets: 90),  // Sumo Squat
      _sets('legs_020', 3, 12, restBetweenSets: 90),  // Step-up
      _sets('legs_010', 3, 20),                         // Calf Raise
      _timed('core_012', 90),                           // Reverse Crunches
    ],
    restBetweenExercises: 90,
    difficulty: DifficultyLevel.intermediate,
    createdAt: _seededAt,
  ),
  ```
- **MIRROR**: PRESET_SESSION_DEFINITION
- **GOTCHA**: `_sets` helper signature is `(exerciseId, setCount, reps, {int restBetweenSets = 60})`. The named param is `restBetweenSets`, not `rest`.
- **VALIDATE**: `buildSessions().where((s) => s.id.startsWith('sess_int_') && s.id.endsWith('_b')).length == 3`

### Task 4: Add Advanced Sessions
- **ACTION**: Append 6 advanced sessions to `_sessions`
- **IMPLEMENT**:
  ```dart
  // ── Advanced PPL ──────────────────────────────────────────────────────────
  Session(
    id: 'sess_adv_push_a',
    name: 'Advanced Push A',
    description: 'High-volume chest and tricep strength block with explosive finisher.',
    workouts: <WorkoutConfig>[
      _sets('push_001', 5, 15, restBetweenSets: 90),   // Push-up
      _sets('push_009', 5, 8,  restBetweenSets: 90),   // Archer Push-up
      _sets('push_003', 5, 10, restBetweenSets: 90),   // Decline Push-up
      _sets('push_016', 4, 6,  restBetweenSets: 120),  // Pseudo Planche Push-up
      _tabata('push_017', workTime: 20, restTime: 10, rounds: 8, setCount: 2, restBetweenSets: 90),
      _timed('core_001', 120),
    ],
    restBetweenExercises: 90,
    difficulty: DifficultyLevel.advanced,
    createdAt: _seededAt,
  ),
  Session(
    id: 'sess_adv_pull_a',
    name: 'Advanced Pull A',
    description: 'Upper-back and scapular strength with high-volume bodyweight rows.',
    workouts: <WorkoutConfig>[
      _sets('pull_016', 5, 10, restBetweenSets: 90),   // Australian Pull-up
      _sets('pull_019', 5, 8,  restBetweenSets: 90),   // Wide Grip Inverted Row
      _sets('pull_020', 5, 8,  restBetweenSets: 90),   // Close Grip Inverted Row
      _sets('pull_014', 4, 12, restBetweenSets: 90),   // Towel Row
      _sets('pull_017', 3, 5,  restBetweenSets: 120),  // Pull-up Negative
      _timed('core_017', 60),                            // L-Sit
    ],
    restBetweenExercises: 90,
    difficulty: DifficultyLevel.advanced,
    createdAt: _seededAt,
  ),
  Session(
    id: 'sess_adv_legs_a',
    name: 'Advanced Legs A',
    description: 'Unilateral strength and explosive leg power with pistol progression.',
    workouts: <WorkoutConfig>[
      _sets('legs_003', 5, 5,  restBetweenSets: 120),  // Pistol Squat
      _sets('legs_004', 5, 8,  restBetweenSets: 90),   // Bulgarian Split Squat
      _sets('legs_008', 4, 10, restBetweenSets: 90),   // Jumping Lunge
      _sets('legs_023', 4, 8,  restBetweenSets: 90),   // Cossack Squat
      _tabata('legs_024', workTime: 20, restTime: 10, rounds: 8, setCount: 2, restBetweenSets: 90),
      _timed('core_009', 90),                            // Hollow Body Hold
    ],
    restBetweenExercises: 90,
    difficulty: DifficultyLevel.advanced,
    createdAt: _seededAt,
  ),
  Session(
    id: 'sess_adv_push_b',
    name: 'Advanced Push B',
    description: 'Overhead and handstand push strength with tricep accessory volume.',
    workouts: <WorkoutConfig>[
      _sets('push_019', 4, 3,  restBetweenSets: 120),  // Handstand Push-up
      _sets('push_016', 4, 5,  restBetweenSets: 120),  // Pseudo Planche Push-up
      _sets('push_006', 5, 12, restBetweenSets: 90),   // Pike Push-up
      _sets('push_014', 4, 12, restBetweenSets: 90),   // Diamond Tricep Dips
      _sets('core_020', 4, 20, restBetweenSets: 60),   // Plank Up-Downs
      _timed('core_002', 120),                           // Side Plank
    ],
    restBetweenExercises: 90,
    difficulty: DifficultyLevel.advanced,
    createdAt: _seededAt,
  ),
  Session(
    id: 'sess_adv_pull_b',
    name: 'Advanced Pull B',
    description: 'Row density, scapular endurance, and rear-delt isolation.',
    workouts: <WorkoutConfig>[
      _sets('pull_016', 5, 12, restBetweenSets: 90),  // Australian Pull-up
      _sets('pull_013', 5, 10, restBetweenSets: 90),  // Single Arm Row
      _timed('pull_011', 90),                           // Isometric Pull Hold
      _sets('pull_018', 4, 15, restBetweenSets: 75),  // Reverse Fly
      _sets('pull_004', 3, 15, restBetweenSets: 75),  // Y-T-W Raises
      _timed('core_003', 120),                          // Mountain Climbers
    ],
    restBetweenExercises: 90,
    difficulty: DifficultyLevel.advanced,
    createdAt: _seededAt,
  ),
  Session(
    id: 'sess_adv_legs_b',
    name: 'Advanced Legs B',
    description: 'Hip-hinge dominance and explosive jump power finisher.',
    workouts: <WorkoutConfig>[
      _sets('legs_018', 5, 8,  restBetweenSets: 90),   // Single Leg Deadlift
      _sets('legs_013', 5, 8,  restBetweenSets: 90),   // Single Leg Glute Bridge
      _sets('legs_022', 4, 6,  restBetweenSets: 120),  // Single Leg Squat
      _tabata('legs_002', workTime: 20, restTime: 10, rounds: 8, setCount: 2, restBetweenSets: 90),
      _sets('legs_025', 3, 30, restBetweenSets: 60),   // Wall Sit Pulse
      _timed('core_006', 90),                            // Flutter Kicks
    ],
    restBetweenExercises: 90,
    difficulty: DifficultyLevel.advanced,
    createdAt: _seededAt,
  ),
  ```
- **MIRROR**: PRESET_SESSION_DEFINITION
- **GOTCHA**: `_tabata` helper signature: `(exerciseId, {int workTime, int restTime, int rounds, int setCount, int restBetweenSets})`. Do NOT confuse `setCount` with positional `sets` parameter.
- **VALIDATE**: `buildSessions().where((s) => s.difficulty == DifficultyLevel.advanced).length == 6`

### Task 5: Add New Programs and Training-Days Entries
- **ACTION**: Append 3 programs to `_programs` and add their entries to `trainingDaysByProgramId`
- **IMPLEMENT**:

  **trainingDaysByProgramId** update (add after existing entries):
  ```dart
  'prog_intermediate_ppl_6d_6w':    <int>[1, 2, 3, 4, 5, 6],  // Mon–Sat
  'prog_advanced_ppl_6d_8w':        <int>[1, 2, 3, 4, 5, 6],  // Mon–Sat
  'prog_intermediate_active_5d_4w': <int>[1, 2, 3, 4, 5],     // Mon–Fri
  ```

  **_programs** list (append after `prog_upper_body_focus_4w`):
  ```dart
  Program(
    id: 'prog_intermediate_ppl_6d_6w',
    name: 'Intermediate PPL 6-Day (6 Weeks)',
    description:
        'A 6-day Push/Pull/Legs split for intermediate athletes. Each pattern is trained twice per week — A sessions on Monday/Tuesday/Wednesday, B sessions on Thursday/Friday/Saturday — with full rest on Sunday.',
    sessionIds: _repeatWeekly(
      <String>[
        'sess_int_str_push',  // Push A
        'sess_int_str_pull',  // Pull A
        'sess_int_str_lower', // Legs A
        'sess_int_push_b',    // Push B
        'sess_int_pull_b',    // Pull B
        'sess_int_legs_b',    // Legs B
      ],
      6,
    ),
    durationWeeks: 6,
    difficulty: DifficultyLevel.intermediate,
    goals: <String>[
      'Train each major pattern twice per week for accelerated hypertrophy.',
      'Develop balanced push and pull volume with matched lower-body frequency.',
      'Build the capacity to sustain 6 consecutive training days with active recovery.',
      'Rest day: Sunday.',
    ],
    daysPerWeek: 6,
    createdAt: _seededAt,
  ),
  Program(
    id: 'prog_advanced_ppl_6d_8w',
    name: 'Advanced PPL 6-Day (8 Weeks)',
    description:
        'High-volume Push/Pull/Legs split for advanced bodyweight athletes. Emphasises progressive overload through density and exercise complexity over 8 weeks.',
    sessionIds: _repeatWeekly(
      <String>[
        'sess_adv_push_a',
        'sess_adv_pull_a',
        'sess_adv_legs_a',
        'sess_adv_push_b',
        'sess_adv_pull_b',
        'sess_adv_legs_b',
      ],
      8,
    ),
    durationWeeks: 8,
    difficulty: DifficultyLevel.advanced,
    goals: <String>[
      'Achieve advanced calisthenics movements: handstand push-up, pistol squat, pseudo-planche push-up.',
      'Maximise push/pull/legs frequency while preserving Sunday recovery.',
      'Build structural balance across all planes of movement.',
      'Rest day: Sunday.',
    ],
    daysPerWeek: 6,
    createdAt: _seededAt,
  ),
  Program(
    id: 'prog_intermediate_active_5d_4w',
    name: 'Intermediate Active Recovery (4 Weeks)',
    description:
        'A 5-day intermediate program that integrates structured active recovery days — mobility and breathwork — to maximise adaptation while minimising cumulative fatigue.',
    sessionIds: _repeatWeekly(
      <String>[
        'sess_int_str_push',          // Mon: Push strength
        'sess_int_str_pull',          // Tue: Pull strength
        'sess_active_rest_mobility',  // Wed: Active rest
        'sess_int_str_lower',         // Thu: Legs strength
        'sess_int_str_power',         // Fri: Full-body power
      ],
      4,
    ),
    durationWeeks: 4,
    difficulty: DifficultyLevel.intermediate,
    goals: <String>[
      'Sustain consistent weekly training without accumulated fatigue.',
      'Experience structured active recovery as a training tool, not just rest.',
      'Improve mobility and breathing patterns alongside strength work.',
      'Rest days: Saturday, Sunday.',
    ],
    daysPerWeek: 5,
    createdAt: _seededAt,
  ),
  ```
- **MIRROR**: PRESET_PROGRAM_DEFINITION, TRAINING_DAYS_MAP
- **GOTCHA**: `_repeatWeekly(list, weeks)` produces `list.length * weeks` total session IDs. For 6-day × 6 weeks = 36 sessions in `sessionIds`. Verify the count matches `daysPerWeek × durationWeeks`.
- **VALIDATE**: `buildPrograms().length == 8` and `trainingDaysByProgramId.length == 8`

### Task 6: Update Upload Script
- **ACTION**: No code change needed — `upload_preset_programs.dart` already calls `PresetProgramCatalog.buildSessions()` and `buildPrograms()` dynamically. New entries are picked up automatically.
- **IMPLEMENT**: Run the upload after code changes:
  ```bash
  flutter pub run data/programs/upload_preset_programs.dart --dry-run
  # verify output: "Preparing 34 preset sessions and 8 preset programs."
  flutter pub run data/programs/upload_preset_programs.dart
  ```
  Also run the exercise upload:
  ```bash
  # Check if exercise upload script exists
  flutter pub run data/exercises/upload_exercises.dart --dry-run
  ```
- **GOTCHA**: The upload uses `SetOptions(merge: true)` so existing documents are safely overwritten. New docs are simply added.
- **VALIDATE**: After upload, Firestore `preset_sessions` collection has 34 docs, `programs` has 8 docs.

### Task 7: Create DailyChallenge Model
- **ACTION**: Create `lib/models/daily_challenge.dart` with Hive + JSON serialization
- **IMPLEMENT**:
  ```dart
  // lib/models/daily_challenge.dart
  import 'package:hive/hive.dart';
  import 'package:json_annotation/json_annotation.dart';
  import 'package:workin_fit/models/enums.dart';

  part 'daily_challenge.g.dart';

  @JsonSerializable(explicitToJson: true)
  @HiveType(typeId: 8)
  class DailyChallenge extends HiveObject {
    @HiveField(0) final String id;
    @HiveField(1) final String title;
    @HiveField(2) final String description;
    @HiveField(3) final DailyChallengeType type;
    @HiveField(4) final DifficultyLevel difficulty;
    @HiveField(5) final int target;       // reps, seconds, or count
    @HiveField(6) final String unit;      // 'reps', 'seconds', 'sessions'
    @HiveField(7) final String? exerciseId;
    @HiveField(8) final String? sessionId;
    @HiveField(9) final int rewardPoints;

    const DailyChallenge({
      required this.id,
      required this.title,
      required this.description,
      required this.type,
      required this.difficulty,
      required this.target,
      required this.unit,
      this.exerciseId,
      this.sessionId,
      this.rewardPoints = 10,
    });

    factory DailyChallenge.fromJson(Map<String, dynamic> json) =>
        _$DailyChallengeFromJson(json);
    Map<String, dynamic> toJson() => _$DailyChallengeToJson(this);
  }
  ```

  Add `DailyChallengeType` to `lib/models/enums.dart` (typeId 13):
  ```dart
  @HiveType(typeId: 13)
  enum DailyChallengeType {
    @HiveField(0)
    exercise, // Complete N reps of a specific exercise

    @HiveField(1)
    session,  // Complete a specific named session

    @HiveField(2)
    freestyle, // Open challenge: "Do something active for 20 minutes"
  }
  ```
- **MIRROR**: HIVE_MODEL_PATTERN
- **GOTCHA**: typeIds 0–12 are taken (see existing models). Use typeId 8 for `DailyChallenge` and typeId 13 for the new enum — verify no conflicts exist first by grepping `@HiveType`.
- **VALIDATE**: Run `flutter pub run build_runner build --delete-conflicting-outputs` — should generate `daily_challenge.g.dart` and `enums.g.dart` without errors.

### Task 8: Create DailyChallengesCatalog
- **ACTION**: Create `lib/data/daily_challenges_catalog.dart` with 30 pre-built challenge definitions
- **IMPLEMENT**: Use day-of-year modulo to select today's challenges (3 shown at a time):
  ```dart
  // lib/data/daily_challenges_catalog.dart
  import 'package:workin_fit/models/daily_challenge.dart';
  import 'package:workin_fit/models/enums.dart';

  class DailyChallengesCatalog {
    static List<DailyChallenge> get all => List.unmodifiable(_challenges);

    /// Returns 3 challenges for the given date, cycling through the catalog.
    static List<DailyChallenge> forDate(DateTime date) {
      final int dayOfYear = date.difference(DateTime(date.year)).inDays;
      final int offset = (dayOfYear * 3) % _challenges.length;
      return [
        _challenges[offset % _challenges.length],
        _challenges[(offset + 1) % _challenges.length],
        _challenges[(offset + 2) % _challenges.length],
      ];
    }

    static const List<DailyChallenge> _challenges = <DailyChallenge>[
      // Beginner — exercise
      DailyChallenge(id: 'dc_001', title: '50 Push-ups', description: 'Complete 50 push-ups across any number of sets.', type: DailyChallengeType.exercise, difficulty: DifficultyLevel.beginner, target: 50, unit: 'reps', exerciseId: 'push_001', rewardPoints: 10),
      DailyChallenge(id: 'dc_002', title: '3-Minute Plank', description: 'Accumulate 3 minutes of plank hold across sets.', type: DailyChallengeType.exercise, difficulty: DifficultyLevel.beginner, target: 180, unit: 'seconds', exerciseId: 'core_001', rewardPoints: 10),
      DailyChallenge(id: 'dc_003', title: '100 Jumping Jacks', description: 'Complete 100 jumping jacks to get the blood flowing.', type: DailyChallengeType.exercise, difficulty: DifficultyLevel.beginner, target: 100, unit: 'reps', exerciseId: 'cardio_001', rewardPoints: 10),
      DailyChallenge(id: 'dc_004', title: '60 Squats', description: 'Complete 60 bodyweight squats throughout the day.', type: DailyChallengeType.exercise, difficulty: DifficultyLevel.beginner, target: 60, unit: 'reps', exerciseId: 'legs_001', rewardPoints: 10),
      DailyChallenge(id: 'dc_005', title: 'Breathwork Session', description: 'Complete one breathwork & mindfulness session.', type: DailyChallengeType.session, difficulty: DifficultyLevel.beginner, target: 1, unit: 'sessions', sessionId: 'sess_active_rest_breathwork', rewardPoints: 10),
      DailyChallenge(id: 'dc_006', title: '45 Glute Bridges', description: 'Complete 45 glute bridges to activate the posterior chain.', type: DailyChallengeType.exercise, difficulty: DifficultyLevel.beginner, target: 45, unit: 'reps', exerciseId: 'legs_012', rewardPoints: 10),
      DailyChallenge(id: 'dc_007', title: '30 Dead Bugs', description: 'Complete 30 dead bug reps for core stability.', type: DailyChallengeType.exercise, difficulty: DifficultyLevel.beginner, target: 30, unit: 'reps', exerciseId: 'core_007', rewardPoints: 10),
      DailyChallenge(id: 'dc_008', title: 'Mobility Flow', description: 'Complete the Full Body Mobility session.', type: DailyChallengeType.session, difficulty: DifficultyLevel.beginner, target: 1, unit: 'sessions', sessionId: 'sess_active_rest_mobility', rewardPoints: 10),
      DailyChallenge(id: 'dc_009', title: '80 High Knees', description: 'Hit 80 high knee reps (40 each leg).', type: DailyChallengeType.exercise, difficulty: DifficultyLevel.beginner, target: 80, unit: 'reps', exerciseId: 'cardio_002', rewardPoints: 10),
      DailyChallenge(id: 'dc_010', title: '40 Bird Dogs', description: 'Complete 40 bird-dog reps for trunk control.', type: DailyChallengeType.exercise, difficulty: DifficultyLevel.beginner, target: 40, unit: 'reps', exerciseId: 'core_008', rewardPoints: 10),
      // Intermediate — exercise
      DailyChallenge(id: 'dc_011', title: '100 Push-ups', description: 'Complete 100 push-ups across any number of sets.', type: DailyChallengeType.exercise, difficulty: DifficultyLevel.intermediate, target: 100, unit: 'reps', exerciseId: 'push_001', rewardPoints: 20),
      DailyChallenge(id: 'dc_012', title: '5-Minute Plank', description: 'Accumulate 5 minutes of plank hold.', type: DailyChallengeType.exercise, difficulty: DifficultyLevel.intermediate, target: 300, unit: 'seconds', exerciseId: 'core_001', rewardPoints: 20),
      DailyChallenge(id: 'dc_013', title: '50 Burpees', description: 'Complete 50 burpees. Time yourself.', type: DailyChallengeType.exercise, difficulty: DifficultyLevel.intermediate, target: 50, unit: 'reps', exerciseId: 'cardio_004', rewardPoints: 25),
      DailyChallenge(id: 'dc_014', title: '60 Jump Squats', description: 'Complete 60 jump squats for explosive leg power.', type: DailyChallengeType.exercise, difficulty: DifficultyLevel.intermediate, target: 60, unit: 'reps', exerciseId: 'legs_002', rewardPoints: 20),
      DailyChallenge(id: 'dc_015', title: 'HIIT Blast Session', description: 'Complete the HIIT Cardio Blast session.', type: DailyChallengeType.session, difficulty: DifficultyLevel.intermediate, target: 1, unit: 'sessions', sessionId: 'sess_hiit_blast', rewardPoints: 25),
      DailyChallenge(id: 'dc_016', title: '80 Russian Twists', description: 'Complete 80 Russian twists for rotational core strength.', type: DailyChallengeType.exercise, difficulty: DifficultyLevel.intermediate, target: 80, unit: 'reps', exerciseId: 'core_005', rewardPoints: 20),
      DailyChallenge(id: 'dc_017', title: '40 Archer Push-ups', description: 'Complete 40 archer push-up reps (20 each side).', type: DailyChallengeType.exercise, difficulty: DifficultyLevel.intermediate, target: 40, unit: 'reps', exerciseId: 'push_009', rewardPoints: 20),
      DailyChallenge(id: 'dc_018', title: '50 Jumping Lunges', description: 'Complete 50 jumping lunge reps (25 each leg).', type: DailyChallengeType.exercise, difficulty: DifficultyLevel.intermediate, target: 50, unit: 'reps', exerciseId: 'legs_008', rewardPoints: 20),
      DailyChallenge(id: 'dc_019', title: 'Core Power Session', description: 'Complete the Core Power Abs session.', type: DailyChallengeType.session, difficulty: DifficultyLevel.intermediate, target: 1, unit: 'sessions', sessionId: 'sess_core_power', rewardPoints: 25),
      DailyChallenge(id: 'dc_020', title: '60 V-Ups', description: 'Complete 60 V-up reps for dynamic core power.', type: DailyChallengeType.exercise, difficulty: DifficultyLevel.intermediate, target: 60, unit: 'reps', exerciseId: 'core_010', rewardPoints: 20),
      // Advanced — exercise & session
      DailyChallenge(id: 'dc_021', title: '200 Push-ups', description: 'Complete 200 push-ups at any pace across the day.', type: DailyChallengeType.exercise, difficulty: DifficultyLevel.advanced, target: 200, unit: 'reps', exerciseId: 'push_001', rewardPoints: 40),
      DailyChallenge(id: 'dc_022', title: '10 Pistol Squats Each Side', description: 'Complete 10 pistol squats per leg.', type: DailyChallengeType.exercise, difficulty: DifficultyLevel.advanced, target: 20, unit: 'reps', exerciseId: 'legs_003', rewardPoints: 35),
      DailyChallenge(id: 'dc_023', title: 'Advanced Push A Session', description: 'Complete the Advanced Push A session in full.', type: DailyChallengeType.session, difficulty: DifficultyLevel.advanced, target: 1, unit: 'sessions', sessionId: 'sess_adv_push_a', rewardPoints: 40),
      DailyChallenge(id: 'dc_024', title: '100 Burpees', description: 'Complete 100 burpees. Track your total time.', type: DailyChallengeType.exercise, difficulty: DifficultyLevel.advanced, target: 100, unit: 'reps', exerciseId: 'cardio_004', rewardPoints: 50),
      DailyChallenge(id: 'dc_025', title: '30 Australian Pull-ups', description: 'Complete 30 Australian pull-up reps.', type: DailyChallengeType.exercise, difficulty: DifficultyLevel.advanced, target: 30, unit: 'reps', exerciseId: 'pull_016', rewardPoints: 35),
      DailyChallenge(id: 'dc_026', title: 'Advanced Legs A Session', description: 'Complete the Advanced Legs A session from start to finish.', type: DailyChallengeType.session, difficulty: DifficultyLevel.advanced, target: 1, unit: 'sessions', sessionId: 'sess_adv_legs_a', rewardPoints: 40),
      DailyChallenge(id: 'dc_027', title: '10-Minute L-Sit Accumulation', description: 'Accumulate 600 seconds of L-Sit hold.', type: DailyChallengeType.exercise, difficulty: DifficultyLevel.advanced, target: 600, unit: 'seconds', exerciseId: 'core_017', rewardPoints: 40),
      DailyChallenge(id: 'dc_028', title: '50 Hollow Body Holds', description: 'Accumulate 50 reps of 5-second hollow body holds.', type: DailyChallengeType.freestyle, difficulty: DifficultyLevel.advanced, target: 50, unit: 'reps', exerciseId: 'core_009', rewardPoints: 35),
      DailyChallenge(id: 'dc_029', title: 'Easy Jog Day', description: 'Complete the Easy Jog / Brisk Walk session.', type: DailyChallengeType.session, difficulty: DifficultyLevel.beginner, target: 1, unit: 'sessions', sessionId: 'sess_active_rest_jog', rewardPoints: 15),
      DailyChallenge(id: 'dc_030', title: '60 Cossack Squats', description: 'Complete 60 Cossack squats (30 each side) for hip mobility and strength.', type: DailyChallengeType.exercise, difficulty: DifficultyLevel.advanced, target: 60, unit: 'reps', exerciseId: 'legs_023', rewardPoints: 35),
    ];
  }
  ```
- **MIRROR**: PRESET_PROGRAM_DEFINITION (same static-list-of-const-objects pattern)
- **GOTCHA**: `DailyChallenge` constructor uses `const` — all fields must be compile-time constants. Remove `DateTime` fields. Hive `HiveObject` cannot be used with `const` constructors — use `@HiveType` but do NOT extend `HiveObject` if using `const`. Alternatively, don't cache challenges locally with Hive (Hive is only for completion records).
- **VALIDATE**: `DailyChallengesCatalog.all.length == 30` and `DailyChallengesCatalog.forDate(DateTime.now()).length == 3`

### Task 9: Create Challenge Providers
- **ACTION**: Create `lib/providers/challenge_providers.dart`
- **IMPLEMENT**:
  ```dart
  // lib/providers/challenge_providers.dart
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:workin_fit/data/daily_challenges_catalog.dart';
  import 'package:workin_fit/models/daily_challenge.dart';
  import 'package:workin_fit/providers/workout_providers.dart';
  import 'package:workin_fit/services/firestore_service.dart';

  /// Today's 3 challenges derived from the catalog (no network needed).
  final todaysChallengesProvider = Provider<List<DailyChallenge>>((ref) {
    return DailyChallengesCatalog.forDate(DateTime.now());
  });

  /// Completion state for a specific challenge ID for the current user today.
  /// Returns true if completed, false otherwise.
  final challengeCompletionProvider =
      FutureProvider.family<bool, String>((ref, challengeId) async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return false;
    final firestore = ref.watch(firestoreServiceProvider);
    try {
      return await firestore.getChallengeCompletion(
        userId: userId,
        challengeId: challengeId,
        date: DateTime.now(),
      );
    } catch (_) {
      return false;
    }
  });

  /// Actions: mark a challenge as completed or uncompleted.
  final challengeActionsProvider =
      Provider<ChallengeActions>((ref) => ChallengeActions(ref));

  class ChallengeActions {
    final Ref ref;
    ChallengeActions(this.ref);

    Future<void> markCompleted(String challengeId) async {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) return;
      await ref.read(firestoreServiceProvider).setChallengeCompleted(
            userId: userId,
            challengeId: challengeId,
            date: DateTime.now(),
            completed: true,
          );
      ref.invalidate(challengeCompletionProvider(challengeId));
    }

    Future<void> markUncompleted(String challengeId) async {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) return;
      await ref.read(firestoreServiceProvider).setChallengeCompleted(
            userId: userId,
            challengeId: challengeId,
            date: DateTime.now(),
            completed: false,
          );
      ref.invalidate(challengeCompletionProvider(challengeId));
    }
  }
  ```
- **MIRROR**: FUTURE_PROVIDER_PATTERN
- **GOTCHA**: `challengeCompletionProvider` uses `.family<bool, String>` — the family arg is `challengeId`. `ref.invalidate(challengeCompletionProvider(challengeId))` invalidates only that ID's cache.
- **VALIDATE**: Provider compiles without errors. `flutter analyze lib/providers/challenge_providers.dart` → 0 errors.

### Task 10: Add Firestore Methods for Challenge Completion
- **ACTION**: Add `getChallengeCompletion` and `setChallengeCompleted` to `FirestoreService`
- **IMPLEMENT**: Completions are stored at `users/{userId}/challenge_completions/{date_challengeId}`. Using a composite key `YYYY-MM-DD_challengeId` makes each day's completion a separate document with no TTL complexity.
  ```dart
  // Add to lib/services/firestore_service.dart

  String _completionDocId(String challengeId, DateTime date) {
    final d = date.toLocal();
    return '${d.year.toString().padLeft(4,'0')}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}_$challengeId';
  }

  Future<bool> getChallengeCompletion({
    required String userId,
    required String challengeId,
    required DateTime date,
  }) async {
    final docId = _completionDocId(challengeId, date);
    final doc = await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(userId)
        .collection('challenge_completions')
        .doc(docId)
        .get();
    return doc.exists && (doc.data()?['completed'] == true);
  }

  Future<void> setChallengeCompleted({
    required String userId,
    required String challengeId,
    required DateTime date,
    required bool completed,
  }) async {
    final docId = _completionDocId(challengeId, date);
    await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(userId)
        .collection('challenge_completions')
        .doc(docId)
        .set({
          'challengeId': challengeId,
          'completed': completed,
          'date': Timestamp.fromDate(date),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }
  ```
- **MIRROR**: Look at existing `FirestoreService.getStreakData` or `subscribeUserToProgram` for the pattern of `_firestore.collection(...).doc(...).collection(...)`
- **GOTCHA**: The subcollection name `'challenge_completions'` is not yet in `FirebaseConstants`. Add it: `static const String challengeCompletionsCollection = 'challenge_completions';` and use the constant instead of the raw string.
- **VALIDATE**: `flutter analyze lib/services/firestore_service.dart` → 0 errors.

### Task 11: Wire _DailyChallengeCard to Real Data
- **ACTION**: Convert `_DailyChallengeCard` from `StatelessWidget` to `ConsumerWidget`; replace all hardcoded values with live data
- **IMPLEMENT**: The card currently shows 1 challenge. Show the first of today's 3 challenges with a completion toggle:
  ```dart
  // lib/views/home/home_dashboard_tab.dart — replace lines 706–890

  class _DailyChallengeCard extends ConsumerWidget {
    final bool isFrench;
    const _DailyChallengeCard({required this.isFrench});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final challenges = ref.watch(todaysChallengesProvider);
      if (challenges.isEmpty) return const SizedBox.shrink();
      final challenge = challenges.first;
      final completionAsync = ref.watch(challengeCompletionProvider(challenge.id));
      final bool isCompleted = completionAsync.valueOrNull ?? false;

      return GestureDetector(
        onTap: () {
          final actions = ref.read(challengeActionsProvider);
          if (isCompleted) {
            actions.markUncompleted(challenge.id);
          } else {
            actions.markCompleted(challenge.id);
          }
        },
        child: AnimatedOpacity(
          opacity: isCompleted ? 0.7 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(_homeBlockRadius),
              border: Border.all(
                color: isCompleted
                    ? AppColors.success.withValues(alpha: AppOpacity.mild)
                    : AppColors.warning.withValues(alpha: AppOpacity.mild),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: (isCompleted ? AppColors.success : AppColors.warning)
                      .withValues(alpha: AppOpacity.faint),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: <Widget>[
                      // Icon container
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isCompleted
                                ? <Color>[AppColors.success, AppColors.success.withValues(alpha: 0.7)]
                                : <Color>[AppColors.warning, AppColors.warningSoft],
                          ),
                          borderRadius: BorderRadius.circular(_homeBlockRadius),
                        ),
                        child: Icon(
                          isCompleted ? Icons.check_rounded : Icons.emoji_events_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      // Text column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              isFrench ? 'DÉFI DU JOUR' : 'DAILY CHALLENGE',
                              style: TextStyle(
                                color: isCompleted ? AppColors.success : AppColors.warning,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              challenge.title,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'AppFontMedium',
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              challenge.description,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isCompleted ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
                        color: isCompleted ? AppColors.success : AppColors.warning,
                        size: 22,
                      ),
                    ],
                  ),
                ),
                // Progress bar strip
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(_homeBlockRadius),
                  ),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md, 0, AppSpacing.md, AppSpacing.xs,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              isFrench ? 'Progression' : 'Progress',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              isCompleted
                                  ? (isFrench ? 'Complété ✓' : 'Done ✓')
                                  : '0 / ${challenge.target} ${challenge.unit}',
                              style: TextStyle(
                                color: isCompleted ? AppColors.success : AppColors.warning,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Progress bar
                      LinearProgressIndicator(
                        value: isCompleted ? 1.0 : 0.0,
                        backgroundColor: AppColors.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCompleted ? AppColors.success : AppColors.warning,
                        ),
                        minHeight: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
  ```
- **MIRROR**: CONSUMER_WIDGET_SECTION
- **IMPORTS** to add at the top of `home_dashboard_tab.dart`:
  ```dart
  import 'package:workin_fit/providers/challenge_providers.dart';
  ```
- **GOTCHA**: `completionAsync.valueOrNull` safely returns `null` if still loading — defaults to `false` (not completed). Do NOT use `completionAsync.value` directly as it throws on loading/error state.
- **VALIDATE**: Hot reload the app; the card shows today's real challenge title, toggles border color green on tap, `flutter analyze` → 0 errors.

### Task 12: Register Hive Adapters
- **ACTION**: Find and update Hive initialization to register the new `DailyChallenge` adapter
- **IMPLEMENT**: Search for `registerAdapter` calls (likely in `main.dart` or a `hive_setup.dart`):
  ```dart
  // Add alongside existing adapter registrations:
  Hive.registerAdapter(DailyChallengeAdapter());
  Hive.registerAdapter(DailyChallengeTypeAdapter());
  ```
  Add the import:
  ```dart
  import 'package:workin_fit/models/daily_challenge.dart';
  ```
- **GOTCHA**: Run `flutter pub run build_runner build --delete-conflicting-outputs` first to generate `daily_challenge.g.dart`. Without the generated file, `DailyChallengeAdapter` doesn't exist yet.
- **VALIDATE**: App launches without Hive registration errors.

---

## Testing Strategy

### Unit Tests

| Test | Input | Expected Output | Edge Case? |
|---|---|---|---|
| `DailyChallengesCatalog.forDate` | `DateTime(2026, 1, 1)` | 3 challenges | No |
| `DailyChallengesCatalog.forDate` | Same date called twice | Same 3 challenges | No |
| `DailyChallengesCatalog.forDate` | Consecutive days | Different leading challenge | Yes |
| `DailyChallengesCatalog.all.length` | — | 30 | No |
| `PresetProgramCatalog.buildSessions().length` | — | 34 | No |
| `PresetProgramCatalog.buildPrograms().length` | — | 8 | No |
| `buildPrograms advanced count` | — | 1 advanced program | No |
| `trainingDaysByProgramId` keys | — | 8 keys | No |

### Edge Cases Checklist
- [ ] `forDate` wraps around correctly (day 365 mod 30 = 5, day 0 = 0)
- [ ] `challengeCompletionProvider` returns `false` when userId is null (not logged in)
- [ ] `_DailyChallengeCard` shows SizedBox.shrink() if `todaysChallengesProvider` returns empty
- [ ] Upload dry-run shows 34 sessions and 8 programs before any Firestore write
- [ ] Tap-to-complete is idempotent (tapping again toggles back)
- [ ] New sessions with `rest_*` exercise IDs render correctly even if exercise details not yet loaded (they use `TimedConfig` so duration is always known)

---

## Validation Commands

### Generate Hive Adapters
```bash
cd /home/golden/Desktop/dev/dart/workin_fit
/home/golden/fvm/versions/stable/bin/flutter pub run build_runner build --delete-conflicting-outputs
```
EXPECT: `daily_challenge.g.dart` generated, `enums.g.dart` regenerated. Zero errors.

### Static Analysis
```bash
/home/golden/fvm/versions/stable/bin/flutter analyze
```
EXPECT: Zero errors. Pre-existing trailing-comma infos are acceptable.

### Unit Tests
```bash
/home/golden/fvm/versions/stable/bin/flutter test test/unit/
```
EXPECT: All existing tests pass (159 baseline). New catalog tests pass.

### Dry-Run Upload Verification
```bash
/home/golden/fvm/versions/stable/bin/flutter pub run data/programs/upload_preset_programs.dart --dry-run
```
EXPECT: `Preparing 34 preset sessions and 8 preset programs.`

---

## Acceptance Criteria
- [ ] `PresetProgramCatalog.buildSessions()` returns 34 sessions
- [ ] `PresetProgramCatalog.buildPrograms()` returns 8 programs (3 beginner, 4 intermediate, 1 advanced)
- [ ] 3 active-rest sessions (beginner difficulty) present
- [ ] 3 intermediate extended sessions and 6 advanced sessions present
- [ ] Upload dry-run confirms correct counts
- [ ] `DailyChallengesCatalog.all.length == 30`
- [ ] `DailyChallengesCatalog.forDate(date)` always returns 3 challenges
- [ ] `_DailyChallengeCard` shows real challenge title and description
- [ ] Tapping the card marks it complete (green border, check icon, "Done ✓")
- [ ] Tapping again undoes completion
- [ ] Completion survives app restart (persisted in Firestore)
- [ ] All 159+ tests pass
- [ ] `flutter analyze` → 0 errors

## Completion Checklist
- [ ] Code follows discovered patterns (static catalog, FutureProvider, ConsumerWidget)
- [ ] Error handling matches codebase style (silent catch in providers, `valueOrNull` in UI)
- [ ] New Hive adapters registered at app startup
- [ ] No hardcoded values in `_DailyChallengeCard` (all from `DailyChallenge` model)
- [ ] `DailyChallengeType` added to `enums.dart` with typeId 13
- [ ] `FirebaseConstants.challengeCompletionsCollection` added
- [ ] `_repeatWeekly` usage verified: new program session counts match `daysPerWeek × durationWeeks`
- [ ] Upload script tested with `--dry-run` before live execution

## Risks
| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Hive typeId collision | Low | High (crash) | Grep `@HiveType` before assigning typeIds 8 and 13 |
| `rest_*` exercise IDs not in Firestore at runtime | Medium | Low (TimedConfig still works; exercise detail fails gracefully) | Run exercise upload before program upload |
| `build_runner` conflict on enums.g.dart regeneration | Low | Medium | Use `--delete-conflicting-outputs` flag |
| `_DailyChallengeCard` replacement breaks existing UI | Low | Medium | Match existing card dimensions exactly; test on device |
| `const DailyChallenge(...)` constructor conflicts with `HiveObject` base class | Medium | High | Do NOT extend `HiveObject` in `DailyChallenge`; challenges are not cached locally |

## Notes
- **Hive caching not needed for challenges**: challenges are static (in code); only completion state goes to Firestore. So `DailyChallenge` uses `@JsonSerializable` but does NOT extend `HiveObject` and does NOT need a Hive adapter registered.
- **homePresetProgramsProvider already caps at 5**: the home screen Programs carousel will still show only 5. To show all 8, the Sessions tab "Programs" view (if it exists) should use the uncapped `programsProvider`. No change needed to the cap logic.
- **Active rest session duration**: `sess_active_rest_jog` has 1 workout of 1500s. `session.estimatedDuration` will return 1500s = 25 min. `session.durationDisplay` = "25 min". This is correct.
- **`const` constructor for DailyChallenge**: because all 30 challenges are defined as compile-time constants in the catalog, `DailyChallenge` must use a `const` constructor. Remove `DateTime? createdAt` from the constructor or make it non-const optional.
