import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/models/program.dart';
import 'package:workin_fit/models/session.dart';
import 'package:workin_fit/models/workout_config.dart';

/// Curated preset workout catalog used for initial program rollout.
///
/// The same definitions are reused by:
/// - Firestore upload tooling (`data/programs/upload_preset_programs.dart`)
/// - Runtime fallbacks when preset docs are not yet available remotely
class PresetProgramCatalog {
  static final DateTime _seededAt = DateTime.utc(2026, 1, 1);

  static List<Session> buildSessions() => List<Session>.unmodifiable(_sessions);

  static List<Program> buildPrograms() => List<Program>.unmodifiable(_programs);

  /// Weekly training days by program ID (1=Mon ... 7=Sun).
  static const Map<String, List<int>> trainingDaysByProgramId =
      <String, List<int>>{
    'prog_beginner_full_body_4w': <int>[1, 3, 5],
    'prog_intermediate_strength_6w': <int>[1, 2, 4, 6],
    'prog_hiit_conditioning_4w': <int>[1, 2, 4, 6],
    'prog_core_abs_focus_4w': <int>[1, 3, 5, 6],
    'prog_upper_body_focus_4w': <int>[1, 2, 4, 5, 6],
    'prog_intermediate_ppl_6d_6w': <int>[1, 2, 3, 4, 5, 6],
    'prog_advanced_ppl_6d_8w': <int>[1, 2, 3, 4, 5, 6],
    'prog_intermediate_active_5d_4w': <int>[1, 2, 3, 4, 5],
  };

  /// Serializes a program map with schedule metadata for Firestore.
  static Map<String, dynamic> programToFirestore(Program program) {
    final Map<String, dynamic> data = program.toFirestore();
    final List<int>? trainingDays = trainingDaysByProgramId[program.id];
    if (trainingDays != null) {
      data['trainingDays'] = trainingDays;
      data['restDays'] = _restDaysFromTraining(trainingDays);
    }
    return data;
  }

  static List<int> _restDaysFromTraining(List<int> trainingDays) {
    final Set<int> training = trainingDays.toSet();
    return List<int>.generate(7, (index) => index + 1)
        .where((day) => !training.contains(day))
        .toList(growable: false);
  }

  static List<String> _repeatWeekly(List<String> weeklySessionIds, int weeks) {
    return List<String>.generate(
      weeklySessionIds.length * weeks,
      (index) => weeklySessionIds[index % weeklySessionIds.length],
      growable: false,
    );
  }

  static WorkoutConfig _sets(
    String exerciseId,
    int setCount,
    int reps, {
    int restBetweenSets = 60,
  }) {
    return SetsConfig(
      exerciseId: exerciseId,
      sets: setCount,
      reps: reps,
      restBetweenSets: restBetweenSets,
    );
  }

  static WorkoutConfig _timed(String exerciseId, int durationSeconds) {
    return TimedConfig(
      exerciseId: exerciseId,
      duration: durationSeconds,
    );
  }

  static WorkoutConfig _tabata(
    String exerciseId, {
    int workTime = 20,
    int restTime = 10,
    int rounds = 8,
    int setCount = 1,
    int restBetweenSets = 60,
  }) {
    return TabataConfig(
      exerciseId: exerciseId,
      workTime: workTime,
      restTime: restTime,
      rounds: rounds,
      sets: setCount,
      restBetweenSets: restBetweenSets,
    );
  }

  static final List<Session> _sessions = <Session>[
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
    Session(
      id: 'sess_bfb_day2',
      name: 'Beginner Full Body B',
      description: 'Lower-body stability and trunk control with light cardio.',
      workouts: <WorkoutConfig>[
        _sets('legs_006', 3, 10),
        _sets('legs_012', 3, 15),
        _sets('push_002', 3, 10),
        _timed('core_007', 45),
        _timed('core_008', 45),
        _timed('cardio_014', 90),
      ],
      restBetweenExercises: 75,
      difficulty: DifficultyLevel.beginner,
      createdAt: _seededAt,
    ),
    Session(
      id: 'sess_bfb_day3',
      name: 'Beginner Full Body C',
      description: 'Balanced full-body endurance with a short core finisher.',
      workouts: <WorkoutConfig>[
        _sets('push_001', 3, 8),
        _sets('pull_001', 3, 8),
        _sets('legs_020', 3, 12),
        _timed('core_004', 45),
        _timed('cardio_010', 90),
      ],
      restBetweenExercises: 75,
      difficulty: DifficultyLevel.beginner,
      createdAt: _seededAt,
    ),
    Session(
      id: 'sess_int_str_push',
      name: 'Intermediate Push Strength',
      description: 'Pressing volume for chest, shoulders, and triceps.',
      workouts: <WorkoutConfig>[
        _sets('push_003', 4, 10, restBetweenSets: 75),
        _sets('push_006', 4, 8, restBetweenSets: 75),
        _sets('push_013', 4, 10, restBetweenSets: 75),
        _sets('core_020', 3, 12),
        _timed('core_001', 60),
      ],
      restBetweenExercises: 90,
      difficulty: DifficultyLevel.intermediate,
      createdAt: _seededAt,
    ),
    Session(
      id: 'sess_int_str_lower',
      name: 'Intermediate Lower Strength',
      description: 'Lower-body unilateral strength and posterior chain focus.',
      workouts: <WorkoutConfig>[
        _sets('legs_004', 4, 10, restBetweenSets: 75),
        _sets('legs_007', 4, 12, restBetweenSets: 75),
        _sets('legs_018', 3, 10, restBetweenSets: 75),
        _sets('legs_011', 4, 15),
        _timed('core_012', 60),
      ],
      restBetweenExercises: 90,
      difficulty: DifficultyLevel.intermediate,
      createdAt: _seededAt,
    ),
    Session(
      id: 'sess_int_str_pull',
      name: 'Intermediate Pull Strength',
      description: 'Rowing, scapular strength, and upper-back endurance.',
      workouts: <WorkoutConfig>[
        _sets('pull_016', 4, 8, restBetweenSets: 75),
        _sets('pull_013', 4, 10, restBetweenSets: 75),
        _sets('pull_019', 4, 8, restBetweenSets: 75),
        _sets('pull_011', 3, 12),
        _timed('core_009', 45),
      ],
      restBetweenExercises: 90,
      difficulty: DifficultyLevel.intermediate,
      createdAt: _seededAt,
    ),
    Session(
      id: 'sess_int_str_power',
      name: 'Intermediate Full-Body Power',
      description: 'Explosive mixed training and conditioning block.',
      workouts: <WorkoutConfig>[
        _sets('legs_002', 4, 10, restBetweenSets: 75),
        _sets('push_010', 4, 10, restBetweenSets: 75),
        _sets('pull_020', 4, 8, restBetweenSets: 75),
        _tabata(
          'cardio_011',
          workTime: 30,
          restTime: 15,
          rounds: 6,
          setCount: 2,
          restBetweenSets: 90,
        ),
        _timed('core_003', 60),
      ],
      restBetweenExercises: 90,
      difficulty: DifficultyLevel.intermediate,
      createdAt: _seededAt,
    ),
    Session(
      id: 'sess_hiit_blast',
      name: 'HIIT Cardio Blast',
      description:
          'Fast intervals to raise heart rate and build repeatability.',
      workouts: <WorkoutConfig>[
        _tabata('cardio_002', setCount: 2),
        _tabata('cardio_005'),
        _tabata('cardio_010', workTime: 30, restTime: 15, rounds: 6),
        _timed('core_003', 60),
      ],
      restBetweenExercises: 45,
      difficulty: DifficultyLevel.intermediate,
      createdAt: _seededAt,
    ),
    Session(
      id: 'sess_hiit_metabolic_legs',
      name: 'HIIT Metabolic Legs',
      description: 'Leg-focused intervals with short active recoveries.',
      workouts: <WorkoutConfig>[
        _tabata('legs_002', setCount: 2),
        _tabata('cardio_012'),
        _timed('legs_012', 60),
        _timed('core_006', 60),
      ],
      restBetweenExercises: 45,
      difficulty: DifficultyLevel.intermediate,
      createdAt: _seededAt,
    ),
    Session(
      id: 'sess_hiit_total_body',
      name: 'HIIT Total Body',
      description:
          'Full-body interval density with push and lower-body bursts.',
      workouts: <WorkoutConfig>[
        _tabata('cardio_004', setCount: 2),
        _tabata('push_011', workTime: 30, restTime: 15, rounds: 6),
        _tabata('legs_008'),
        _timed('core_013', 60),
      ],
      restBetweenExercises: 45,
      difficulty: DifficultyLevel.intermediate,
      createdAt: _seededAt,
    ),
    Session(
      id: 'sess_hiit_engine',
      name: 'HIIT Engine Builder',
      description: 'Repeated explosive rounds to improve conditioning.',
      workouts: <WorkoutConfig>[
        _tabata('cardio_006', setCount: 2),
        _tabata('cardio_015'),
        _tabata('core_014', workTime: 30, restTime: 15, rounds: 6),
        _timed('core_018', 75),
      ],
      restBetweenExercises: 45,
      difficulty: DifficultyLevel.intermediate,
      createdAt: _seededAt,
    ),
    Session(
      id: 'sess_core_foundation',
      name: 'Core Foundation Control',
      description: 'Isometric trunk stability and anti-extension basics.',
      workouts: <WorkoutConfig>[
        _timed('core_001', 60),
        _timed('core_007', 60),
        _timed('core_008', 60),
        _timed('core_002', 45),
        _sets('core_011', 3, 15),
      ],
      restBetweenExercises: 60,
      difficulty: DifficultyLevel.beginner,
      createdAt: _seededAt,
    ),
    Session(
      id: 'sess_core_rotation',
      name: 'Core Rotation Stability',
      description: 'Rotational strength and lateral stability development.',
      workouts: <WorkoutConfig>[
        _sets('core_005', 4, 20),
        _sets('core_004', 4, 20),
        _timed('core_019', 45),
        _sets('core_012', 4, 15),
        _timed('core_018', 60),
      ],
      restBetweenExercises: 60,
      difficulty: DifficultyLevel.intermediate,
      createdAt: _seededAt,
    ),
    Session(
      id: 'sess_core_endurance',
      name: 'Core Endurance Day',
      description: 'Longer tension intervals for trunk endurance.',
      workouts: <WorkoutConfig>[
        _timed('core_009', 45),
        _timed('core_013', 60),
        _timed('core_020', 60),
        _timed('core_006', 60),
        _timed('cardio_009', 120),
      ],
      restBetweenExercises: 60,
      difficulty: DifficultyLevel.intermediate,
      createdAt: _seededAt,
    ),
    Session(
      id: 'sess_core_power',
      name: 'Core Power Abs',
      description: 'Dynamic ab work to finish the week with intensity.',
      workouts: <WorkoutConfig>[
        _sets('core_010', 4, 12),
        _sets('core_016', 3, 12),
        _timed('core_014', 90),
        _timed('core_015', 90),
        _timed('cardio_001', 90),
      ],
      restBetweenExercises: 60,
      difficulty: DifficultyLevel.intermediate,
      createdAt: _seededAt,
    ),
    Session(
      id: 'sess_upper_push_volume',
      name: 'Upper Push Volume',
      description: 'High-quality push volume for chest and triceps.',
      workouts: <WorkoutConfig>[
        _sets('push_001', 4, 12),
        _sets('push_005', 4, 12),
        _sets('push_013', 4, 10),
        _timed('core_001', 60),
      ],
      restBetweenExercises: 75,
      difficulty: DifficultyLevel.intermediate,
      createdAt: _seededAt,
    ),
    Session(
      id: 'sess_upper_pull_volume',
      name: 'Upper Pull Volume',
      description: 'Back and rear-shoulder endurance session.',
      workouts: <WorkoutConfig>[
        _sets('pull_001', 4, 10),
        _sets('pull_014', 4, 10),
        _sets('pull_018', 4, 15),
        _sets('pull_004', 3, 12),
        _timed('core_007', 60),
      ],
      restBetweenExercises: 75,
      difficulty: DifficultyLevel.intermediate,
      createdAt: _seededAt,
    ),
    Session(
      id: 'sess_upper_shoulders_arms',
      name: 'Upper Shoulders & Arms',
      description: 'Shoulder resilience and arm-focused accessory work.',
      workouts: <WorkoutConfig>[
        _sets('push_006', 4, 10),
        _sets('push_014', 4, 10),
        _sets('pull_006', 4, 12),
        _sets('pull_007', 4, 12),
        _timed('core_002', 45),
      ],
      restBetweenExercises: 75,
      difficulty: DifficultyLevel.intermediate,
      createdAt: _seededAt,
    ),
    Session(
      id: 'sess_upper_push_endurance',
      name: 'Upper Push Endurance',
      description: 'Push interval work with short conditioning finish.',
      workouts: <WorkoutConfig>[
        _tabata('push_011', setCount: 2),
        _sets('push_003', 3, 12),
        _sets('push_012', 3, 12),
        _timed('cardio_010', 120),
      ],
      restBetweenExercises: 75,
      difficulty: DifficultyLevel.intermediate,
      createdAt: _seededAt,
    ),
    Session(
      id: 'sess_upper_pull_core',
      name: 'Upper Pull & Core Mix',
      description: 'Pulling volume plus trunk-focused finisher.',
      workouts: <WorkoutConfig>[
        _sets('pull_020', 4, 10),
        _sets('pull_013', 4, 12),
        _timed('pull_009', 60),
        _sets('core_012', 3, 15),
        _timed('core_003', 90),
      ],
      restBetweenExercises: 75,
      difficulty: DifficultyLevel.intermediate,
      createdAt: _seededAt,
    ),

    // ── Active Rest ────────────────────────────────────────────────────────
    Session(
      id: 'sess_active_rest_breathwork',
      name: 'Breathwork & Mindfulness',
      description:
          'Guided breathing and light mobility to reduce stress and aid recovery.',
      workouts: <WorkoutConfig>[
        _timed('rest_001', 600),
        _timed('core_018', 60),
        _timed('pull_005', 60),
        _timed('pull_010', 60),
        _timed('rest_001', 300),
      ],
      restBetweenExercises: 30,
      difficulty: DifficultyLevel.beginner,
      createdAt: _seededAt,
    ),
    Session(
      id: 'sess_active_rest_jog',
      name: 'Easy Jog / Brisk Walk',
      description:
          '25 minutes of low-intensity steady-state cardio for active recovery.',
      workouts: <WorkoutConfig>[
        _timed('rest_002', 1500),
      ],
      restBetweenExercises: 0,
      difficulty: DifficultyLevel.beginner,
      createdAt: _seededAt,
    ),
    Session(
      id: 'sess_active_rest_mobility',
      name: 'Full Body Mobility',
      description:
          'Dynamic stretching and mobility drills to improve flexibility and reduce DOMS.',
      workouts: <WorkoutConfig>[
        _timed('rest_003', 300),
        _timed('core_018', 120),
        _timed('pull_003', 90),
        _timed('pull_005', 90),
        _timed('legs_009', 60),
        _timed('rest_003', 300),
      ],
      restBetweenExercises: 20,
      difficulty: DifficultyLevel.beginner,
      createdAt: _seededAt,
    ),

    // ── Intermediate Extended (~35–45 min) ─────────────────────────────────
    Session(
      id: 'sess_int_push_b',
      name: 'Intermediate Push B',
      description:
          'Shoulder and tricep-focused pressing volume at higher density.',
      workouts: <WorkoutConfig>[
        _sets('push_006', 4, 10, restBetweenSets: 90),
        _sets('push_009', 4, 8, restBetweenSets: 90),
        _sets('push_014', 4, 10, restBetweenSets: 90),
        _sets('push_020', 3, 8, restBetweenSets: 90),
        _sets('core_020', 3, 15),
        _timed('core_002', 90),
      ],
      restBetweenExercises: 90,
      difficulty: DifficultyLevel.intermediate,
      createdAt: _seededAt,
    ),
    Session(
      id: 'sess_int_pull_b',
      name: 'Intermediate Pull B',
      description:
          'Scapular, rotator-cuff, and row endurance for balanced upper-back development.',
      workouts: <WorkoutConfig>[
        _sets('pull_007', 4, 15, restBetweenSets: 90),
        _sets('pull_006', 4, 15, restBetweenSets: 90),
        _sets('pull_013', 4, 10, restBetweenSets: 90),
        _sets('pull_012', 3, 10, restBetweenSets: 90),
        _sets('pull_010', 3, 12),
        _timed('core_009', 60),
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
        _sets('legs_001', 4, 15, restBetweenSets: 90),
        _sets('legs_019', 4, 10, restBetweenSets: 90),
        _sets('legs_021', 4, 12, restBetweenSets: 90),
        _sets('legs_020', 3, 12, restBetweenSets: 90),
        _sets('legs_010', 3, 20),
        _timed('core_012', 90),
      ],
      restBetweenExercises: 90,
      difficulty: DifficultyLevel.intermediate,
      createdAt: _seededAt,
    ),

    // ── Advanced PPL (~50–60 min) ───────────────────────────────────────────
    Session(
      id: 'sess_adv_push_a',
      name: 'Advanced Push A',
      description:
          'High-volume chest and tricep strength block with explosive finisher.',
      workouts: <WorkoutConfig>[
        _sets('push_001', 5, 15, restBetweenSets: 90),
        _sets('push_009', 5, 8, restBetweenSets: 90),
        _sets('push_003', 5, 10, restBetweenSets: 90),
        _sets('push_016', 4, 6, restBetweenSets: 120),
        _tabata(
          'push_017',
          workTime: 20,
          restTime: 10,
          rounds: 8,
          setCount: 2,
          restBetweenSets: 90,
        ),
        _timed('core_001', 120),
      ],
      restBetweenExercises: 90,
      difficulty: DifficultyLevel.advanced,
      createdAt: _seededAt,
    ),
    Session(
      id: 'sess_adv_pull_a',
      name: 'Advanced Pull A',
      description:
          'Upper-back and scapular strength with high-volume bodyweight rows.',
      workouts: <WorkoutConfig>[
        _sets('pull_016', 5, 10, restBetweenSets: 90),
        _sets('pull_019', 5, 8, restBetweenSets: 90),
        _sets('pull_020', 5, 8, restBetweenSets: 90),
        _sets('pull_014', 4, 12, restBetweenSets: 90),
        _sets('pull_017', 3, 5, restBetweenSets: 120),
        _timed('core_017', 60),
      ],
      restBetweenExercises: 90,
      difficulty: DifficultyLevel.advanced,
      createdAt: _seededAt,
    ),
    Session(
      id: 'sess_adv_legs_a',
      name: 'Advanced Legs A',
      description:
          'Unilateral strength and explosive leg power with pistol progression.',
      workouts: <WorkoutConfig>[
        _sets('legs_003', 5, 5, restBetweenSets: 120),
        _sets('legs_004', 5, 8, restBetweenSets: 90),
        _sets('legs_008', 4, 10, restBetweenSets: 90),
        _sets('legs_023', 4, 8, restBetweenSets: 90),
        _tabata(
          'legs_024',
          workTime: 20,
          restTime: 10,
          rounds: 8,
          setCount: 2,
          restBetweenSets: 90,
        ),
        _timed('core_009', 90),
      ],
      restBetweenExercises: 90,
      difficulty: DifficultyLevel.advanced,
      createdAt: _seededAt,
    ),
    Session(
      id: 'sess_adv_push_b',
      name: 'Advanced Push B',
      description:
          'Overhead and handstand push strength with tricep accessory volume.',
      workouts: <WorkoutConfig>[
        _sets('push_019', 4, 3, restBetweenSets: 120),
        _sets('push_016', 4, 5, restBetweenSets: 120),
        _sets('push_006', 5, 12, restBetweenSets: 90),
        _sets('push_014', 4, 12, restBetweenSets: 90),
        _sets('core_020', 4, 20, restBetweenSets: 60),
        _timed('core_002', 120),
      ],
      restBetweenExercises: 90,
      difficulty: DifficultyLevel.advanced,
      createdAt: _seededAt,
    ),
    Session(
      id: 'sess_adv_pull_b',
      name: 'Advanced Pull B',
      description:
          'Row density, scapular endurance, and rear-delt isolation.',
      workouts: <WorkoutConfig>[
        _sets('pull_016', 5, 12, restBetweenSets: 90),
        _sets('pull_013', 5, 10, restBetweenSets: 90),
        _timed('pull_011', 90),
        _sets('pull_018', 4, 15, restBetweenSets: 75),
        _sets('pull_004', 3, 15, restBetweenSets: 75),
        _timed('core_003', 120),
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
        _sets('legs_018', 5, 8, restBetweenSets: 90),
        _sets('legs_013', 5, 8, restBetweenSets: 90),
        _sets('legs_022', 4, 6, restBetweenSets: 120),
        _tabata(
          'legs_002',
          workTime: 20,
          restTime: 10,
          rounds: 8,
          setCount: 2,
          restBetweenSets: 90,
        ),
        _sets('legs_025', 3, 30, restBetweenSets: 60),
        _timed('core_006', 90),
      ],
      restBetweenExercises: 90,
      difficulty: DifficultyLevel.advanced,
      createdAt: _seededAt,
    ),
  ];

  static final List<Program> _programs = <Program>[
    Program(
      id: 'prog_beginner_full_body_4w',
      name: 'Beginner Full Body (4 Weeks)',
      description:
          'A beginner-friendly plan to build consistency and full-body strength with manageable training density.',
      sessionIds: _repeatWeekly(
        <String>[
          'sess_bfb_day1',
          'sess_bfb_day2',
          'sess_bfb_day3',
        ],
        4,
      ),
      durationWeeks: 4,
      difficulty: DifficultyLevel.beginner,
      goals: <String>[
        'Build a repeatable weekly routine with low injury risk.',
        'Improve baseline strength across push, pull, and lower body.',
        'Increase trunk stability and light conditioning capacity.',
        'Rest days: Tuesday, Thursday, Saturday, Sunday.',
      ],
      daysPerWeek: 3,
      createdAt: _seededAt,
    ),
    Program(
      id: 'prog_intermediate_strength_6w',
      name: 'Intermediate Strength (6 Weeks)',
      description:
          'A structured 4-day split emphasizing progressive strength and full-body capacity over six weeks.',
      sessionIds: _repeatWeekly(
        <String>[
          'sess_int_str_push',
          'sess_int_str_lower',
          'sess_int_str_pull',
          'sess_int_str_power',
        ],
        6,
      ),
      durationWeeks: 6,
      difficulty: DifficultyLevel.intermediate,
      goals: <String>[
        'Increase total weekly training volume for major movement patterns.',
        'Develop lower- and upper-body strength endurance.',
        'Blend strength and conditioning without overreaching.',
        'Rest days: Wednesday, Friday, Sunday.',
      ],
      daysPerWeek: 4,
      createdAt: _seededAt,
    ),
    Program(
      id: 'prog_hiit_conditioning_4w',
      name: 'HIIT & Conditioning (4 Weeks)',
      description:
          'Interval-based sessions designed to improve work capacity, speed of recovery, and metabolic conditioning.',
      sessionIds: _repeatWeekly(
        <String>[
          'sess_hiit_blast',
          'sess_hiit_metabolic_legs',
          'sess_hiit_total_body',
          'sess_hiit_engine',
        ],
        4,
      ),
      durationWeeks: 4,
      difficulty: DifficultyLevel.intermediate,
      goals: <String>[
        'Raise aerobic and anaerobic performance through repeated intervals.',
        'Improve movement quality under fatigue.',
        'Build conditioning with short, high-effort sessions.',
        'Rest days: Wednesday, Friday, Sunday.',
      ],
      daysPerWeek: 4,
      createdAt: _seededAt,
    ),
    Program(
      id: 'prog_core_abs_focus_4w',
      name: 'Core & Abs Focus (4 Weeks)',
      description:
          'Dedicated core training across stability, rotation, endurance, and dynamic trunk power.',
      sessionIds: _repeatWeekly(
        <String>[
          'sess_core_foundation',
          'sess_core_rotation',
          'sess_core_endurance',
          'sess_core_power',
        ],
        4,
      ),
      durationWeeks: 4,
      difficulty: DifficultyLevel.intermediate,
      goals: <String>[
        'Strengthen anti-extension, anti-rotation, and lateral stability.',
        'Improve core endurance for better posture and movement control.',
        'Develop dynamic abdominal power and coordination.',
        'Rest days: Tuesday, Thursday, Sunday.',
      ],
      daysPerWeek: 4,
      createdAt: _seededAt,
    ),
    Program(
      id: 'prog_upper_body_focus_4w',
      name: 'Upper Body Focus (4 Weeks)',
      description:
          'A high-frequency upper-body block targeting push/pull balance, shoulder durability, and arm strength.',
      sessionIds: _repeatWeekly(
        <String>[
          'sess_upper_push_volume',
          'sess_upper_pull_volume',
          'sess_upper_shoulders_arms',
          'sess_upper_push_endurance',
          'sess_upper_pull_core',
        ],
        4,
      ),
      durationWeeks: 4,
      difficulty: DifficultyLevel.intermediate,
      goals: <String>[
        'Increase upper-body training frequency while preserving recovery.',
        'Build balanced push and pull strength endurance.',
        'Improve shoulder and scapular control through accessory volume.',
        'Rest days: Wednesday, Sunday.',
      ],
      daysPerWeek: 5,
      createdAt: _seededAt,
    ),
    Program(
      id: 'prog_intermediate_ppl_6d_6w',
      name: 'Intermediate PPL 6-Day (6 Weeks)',
      description:
          'A 6-day Push/Pull/Legs split for intermediate athletes. Each pattern is trained twice per week — A sessions Mon/Tue/Wed, B sessions Thu/Fri/Sat — with full rest on Sunday.',
      sessionIds: _repeatWeekly(
        <String>[
          'sess_int_str_push',
          'sess_int_str_pull',
          'sess_int_str_lower',
          'sess_int_push_b',
          'sess_int_pull_b',
          'sess_int_legs_b',
        ],
        6,
      ),
      durationWeeks: 6,
      difficulty: DifficultyLevel.intermediate,
      goals: <String>[
        'Train each major pattern twice per week for accelerated hypertrophy.',
        'Develop balanced push and pull volume with matched lower-body frequency.',
        'Build the capacity to sustain 6 consecutive training days.',
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
        'Achieve advanced calisthenics: handstand push-up, pistol squat, pseudo-planche.',
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
          'sess_int_str_push',
          'sess_int_str_pull',
          'sess_active_rest_mobility',
          'sess_int_str_lower',
          'sess_int_str_power',
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
  ];
}
