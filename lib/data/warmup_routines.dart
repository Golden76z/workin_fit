import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/warmup_routine.dart';
import 'package:workin_fit/models/workout_config.dart';

/// Static warmup exercise and routine data.
/// All 15 combinations: 5 categories × 3 durations (2, 5, 10 min).
class WarmupData {
  WarmupData._(); // prevent instantiation

  static WarmupRoutine getRoutine(
    WarmupCategory category,
    int durationMinutes,
  ) {
    final key = (category, durationMinutes);
    final routine = _routines[key];
    if (routine == null) {
      throw ArgumentError(
        'No warmup routine for $category / ${durationMinutes}min',
      );
    }
    return routine;
  }

  static final Map<(WarmupCategory, int), WarmupRoutine> _routines = {
    // ── Full Body ─────────────────────────────────────────────────────────────
    (WarmupCategory.fullBody, 2): WarmupRoutine(
      category: WarmupCategory.fullBody,
      durationMinutes: 2,
      workoutConfigs: [
        TimedConfig(exerciseId: 'warmup_jumping_jacks', duration: 30),
        TimedConfig(exerciseId: 'warmup_arm_circles', duration: 25),
        TimedConfig(exerciseId: 'warmup_bodyweight_squats', duration: 30),
      ],
      exercises: [
        _jumpingJacks,
        _armCircles,
        _bodyweightSquats,
      ],
    ),
    (WarmupCategory.fullBody, 5): WarmupRoutine(
      category: WarmupCategory.fullBody,
      durationMinutes: 5,
      workoutConfigs: [
        TimedConfig(exerciseId: 'warmup_jumping_jacks', duration: 50),
        TimedConfig(exerciseId: 'warmup_arm_circles', duration: 45),
        TimedConfig(exerciseId: 'warmup_bodyweight_squats', duration: 50),
        TimedConfig(exerciseId: 'warmup_hip_circles', duration: 45),
        TimedConfig(exerciseId: 'warmup_high_knees', duration: 50),
      ],
      exercises: [
        _jumpingJacks,
        _armCircles,
        _bodyweightSquats,
        _hipCircles,
        _highKnees,
      ],
    ),
    (WarmupCategory.fullBody, 10): WarmupRoutine(
      category: WarmupCategory.fullBody,
      durationMinutes: 10,
      workoutConfigs: [
        TimedConfig(exerciseId: 'warmup_jumping_jacks', duration: 60),
        TimedConfig(exerciseId: 'warmup_arm_circles', duration: 60),
        TimedConfig(exerciseId: 'warmup_bodyweight_squats', duration: 60),
        TimedConfig(exerciseId: 'warmup_hip_circles', duration: 60),
        TimedConfig(exerciseId: 'warmup_high_knees', duration: 60),
        TimedConfig(exerciseId: 'warmup_inchworms', duration: 60),
        TimedConfig(exerciseId: 'warmup_leg_swings', duration: 60),
        TimedConfig(exerciseId: 'warmup_cat_cow', duration: 60),
      ],
      exercises: [
        _jumpingJacks,
        _armCircles,
        _bodyweightSquats,
        _hipCircles,
        _highKnees,
        _inchworms,
        _legSwings,
        _catCow,
      ],
    ),

    // ── Upper Body ────────────────────────────────────────────────────────────
    (WarmupCategory.upperBody, 2): WarmupRoutine(
      category: WarmupCategory.upperBody,
      durationMinutes: 2,
      workoutConfigs: [
        TimedConfig(exerciseId: 'warmup_arm_circles', duration: 25),
        TimedConfig(exerciseId: 'warmup_shoulder_rolls', duration: 25),
        TimedConfig(exerciseId: 'warmup_wall_push_ups', duration: 30),
      ],
      exercises: [
        _armCircles,
        _shoulderRolls,
        _wallPushUps,
      ],
    ),
    (WarmupCategory.upperBody, 5): WarmupRoutine(
      category: WarmupCategory.upperBody,
      durationMinutes: 5,
      workoutConfigs: [
        TimedConfig(exerciseId: 'warmup_arm_circles', duration: 45),
        TimedConfig(exerciseId: 'warmup_shoulder_rolls', duration: 45),
        TimedConfig(exerciseId: 'warmup_wall_push_ups', duration: 50),
        TimedConfig(exerciseId: 'warmup_chest_opener', duration: 45),
        TimedConfig(exerciseId: 'warmup_band_pull_aparts', duration: 50),
      ],
      exercises: [
        _armCircles,
        _shoulderRolls,
        _wallPushUps,
        _chestOpener,
        _bandPullAparts,
      ],
    ),
    (WarmupCategory.upperBody, 10): WarmupRoutine(
      category: WarmupCategory.upperBody,
      durationMinutes: 10,
      workoutConfigs: [
        TimedConfig(exerciseId: 'warmup_arm_circles', duration: 60),
        TimedConfig(exerciseId: 'warmup_shoulder_rolls', duration: 60),
        TimedConfig(exerciseId: 'warmup_wall_push_ups', duration: 60),
        TimedConfig(exerciseId: 'warmup_chest_opener', duration: 60),
        TimedConfig(exerciseId: 'warmup_band_pull_aparts', duration: 60),
        TimedConfig(exerciseId: 'warmup_tricep_overhead', duration: 60),
        TimedConfig(exerciseId: 'warmup_wrist_circles', duration: 60),
        TimedConfig(exerciseId: 'warmup_neck_rolls', duration: 60),
      ],
      exercises: [
        _armCircles,
        _shoulderRolls,
        _wallPushUps,
        _chestOpener,
        _bandPullAparts,
        _tricepOverhead,
        _wristCircles,
        _neckRolls,
      ],
    ),

    // ── Lower Body ────────────────────────────────────────────────────────────
    (WarmupCategory.lowerBody, 2): WarmupRoutine(
      category: WarmupCategory.lowerBody,
      durationMinutes: 2,
      workoutConfigs: [
        TimedConfig(exerciseId: 'warmup_leg_swings', duration: 25),
        TimedConfig(exerciseId: 'warmup_hip_circles', duration: 30),
        TimedConfig(exerciseId: 'warmup_bodyweight_squats', duration: 30),
      ],
      exercises: [
        _legSwings,
        _hipCircles,
        _bodyweightSquats,
      ],
    ),
    (WarmupCategory.lowerBody, 5): WarmupRoutine(
      category: WarmupCategory.lowerBody,
      durationMinutes: 5,
      workoutConfigs: [
        TimedConfig(exerciseId: 'warmup_leg_swings', duration: 45),
        TimedConfig(exerciseId: 'warmup_hip_circles', duration: 50),
        TimedConfig(exerciseId: 'warmup_bodyweight_squats', duration: 50),
        TimedConfig(exerciseId: 'warmup_calf_raises', duration: 45),
        TimedConfig(exerciseId: 'warmup_lateral_lunges', duration: 50),
      ],
      exercises: [
        _legSwings,
        _hipCircles,
        _bodyweightSquats,
        _calfRaises,
        _lateralLunges,
      ],
    ),
    (WarmupCategory.lowerBody, 10): WarmupRoutine(
      category: WarmupCategory.lowerBody,
      durationMinutes: 10,
      workoutConfigs: [
        TimedConfig(exerciseId: 'warmup_leg_swings', duration: 60),
        TimedConfig(exerciseId: 'warmup_hip_circles', duration: 60),
        TimedConfig(exerciseId: 'warmup_bodyweight_squats', duration: 60),
        TimedConfig(exerciseId: 'warmup_calf_raises', duration: 60),
        TimedConfig(exerciseId: 'warmup_lateral_lunges', duration: 60),
        TimedConfig(exerciseId: 'warmup_glute_bridges', duration: 60),
        TimedConfig(exerciseId: 'warmup_standing_quad_stretch', duration: 60),
        TimedConfig(exerciseId: 'warmup_hamstring_stretch', duration: 60),
      ],
      exercises: [
        _legSwings,
        _hipCircles,
        _bodyweightSquats,
        _calfRaises,
        _lateralLunges,
        _gluteBridges,
        _standingQuadStretch,
        _hamstringStretch,
      ],
    ),

    // ── Core ──────────────────────────────────────────────────────────────────
    (WarmupCategory.core, 2): WarmupRoutine(
      category: WarmupCategory.core,
      durationMinutes: 2,
      workoutConfigs: [
        TimedConfig(exerciseId: 'warmup_cat_cow', duration: 25),
        TimedConfig(exerciseId: 'warmup_dead_bug', duration: 30),
        TimedConfig(exerciseId: 'warmup_bird_dog', duration: 30),
      ],
      exercises: [
        _catCow,
        _deadBug,
        _birdDog,
      ],
    ),
    (WarmupCategory.core, 5): WarmupRoutine(
      category: WarmupCategory.core,
      durationMinutes: 5,
      workoutConfigs: [
        TimedConfig(exerciseId: 'warmup_cat_cow', duration: 45),
        TimedConfig(exerciseId: 'warmup_dead_bug', duration: 50),
        TimedConfig(exerciseId: 'warmup_bird_dog', duration: 50),
        TimedConfig(exerciseId: 'warmup_plank_hold', duration: 45),
        TimedConfig(exerciseId: 'warmup_mountain_climbers', duration: 50),
      ],
      exercises: [
        _catCow,
        _deadBug,
        _birdDog,
        _plankHold,
        _mountainClimbers,
      ],
    ),
    (WarmupCategory.core, 10): WarmupRoutine(
      category: WarmupCategory.core,
      durationMinutes: 10,
      workoutConfigs: [
        TimedConfig(exerciseId: 'warmup_cat_cow', duration: 60),
        TimedConfig(exerciseId: 'warmup_dead_bug', duration: 60),
        TimedConfig(exerciseId: 'warmup_bird_dog', duration: 60),
        TimedConfig(exerciseId: 'warmup_plank_hold', duration: 60),
        TimedConfig(exerciseId: 'warmup_mountain_climbers', duration: 60),
        TimedConfig(exerciseId: 'warmup_russian_twists', duration: 60),
        TimedConfig(exerciseId: 'warmup_hip_bridges', duration: 60),
        TimedConfig(exerciseId: 'warmup_hollow_body', duration: 60),
      ],
      exercises: [
        _catCow,
        _deadBug,
        _birdDog,
        _plankHold,
        _mountainClimbers,
        _russianTwists,
        _hipBridges,
        _hollowBody,
      ],
    ),

    // ── Cardio ────────────────────────────────────────────────────────────────
    (WarmupCategory.cardio, 2): WarmupRoutine(
      category: WarmupCategory.cardio,
      durationMinutes: 2,
      workoutConfigs: [
        TimedConfig(exerciseId: 'warmup_jumping_jacks', duration: 30),
        TimedConfig(exerciseId: 'warmup_high_knees', duration: 30),
        TimedConfig(exerciseId: 'warmup_butt_kicks', duration: 25),
      ],
      exercises: [
        _jumpingJacks,
        _highKnees,
        _buttKicks,
      ],
    ),
    (WarmupCategory.cardio, 5): WarmupRoutine(
      category: WarmupCategory.cardio,
      durationMinutes: 5,
      workoutConfigs: [
        TimedConfig(exerciseId: 'warmup_jumping_jacks', duration: 50),
        TimedConfig(exerciseId: 'warmup_high_knees', duration: 50),
        TimedConfig(exerciseId: 'warmup_butt_kicks', duration: 45),
        TimedConfig(exerciseId: 'warmup_jump_rope_mimic', duration: 50),
        TimedConfig(exerciseId: 'warmup_skaters', duration: 50),
      ],
      exercises: [
        _jumpingJacks,
        _highKnees,
        _buttKicks,
        _jumpRopeMimic,
        _skaters,
      ],
    ),
    (WarmupCategory.cardio, 10): WarmupRoutine(
      category: WarmupCategory.cardio,
      durationMinutes: 10,
      workoutConfigs: [
        TimedConfig(exerciseId: 'warmup_jumping_jacks', duration: 60),
        TimedConfig(exerciseId: 'warmup_high_knees', duration: 60),
        TimedConfig(exerciseId: 'warmup_butt_kicks', duration: 60),
        TimedConfig(exerciseId: 'warmup_jump_rope_mimic', duration: 60),
        TimedConfig(exerciseId: 'warmup_skaters', duration: 60),
        TimedConfig(exerciseId: 'warmup_box_step_ups', duration: 60),
        TimedConfig(exerciseId: 'warmup_burpee_warmup', duration: 60),
        TimedConfig(exerciseId: 'warmup_speed_shuffle', duration: 60),
      ],
      exercises: [
        _jumpingJacks,
        _highKnees,
        _buttKicks,
        _jumpRopeMimic,
        _skaters,
        _boxStepUps,
        _burpeeWarmup,
        _speedShuffle,
      ],
    ),
  };

  // ── Helper ─────────────────────────────────────────────────────────────────

  static Exercise _ex(
    String id,
    String name,
    String description,
    List<MuscleGroup> muscles,
  ) {
    return Exercise(
      id: id,
      name: name,
      description: description,
      imageMuscleUrl: '',
      imageTutorialUrl: '',
      muscleGroups: muscles,
      difficulty: DifficultyLevel.beginner,
    );
  }

  // ── Shared exercise definitions ────────────────────────────────────────────

  // Full Body / Cardio shared
  static final Exercise _jumpingJacks = _ex(
    'warmup_jumping_jacks',
    'Jumping Jacks',
    'Stand with feet together, arms at sides. Jump and spread feet while raising arms overhead. Return to start.',
    [MuscleGroup.cardio],
  );

  static final Exercise _highKnees = _ex(
    'warmup_high_knees',
    'High Knees',
    'Run in place, driving your knees up toward your chest with each step. Pump your arms for balance.',
    [MuscleGroup.cardio, MuscleGroup.quads],
  );

  // Full Body / Upper Body shared
  static final Exercise _armCircles = _ex(
    'warmup_arm_circles',
    'Arm Circles',
    'Extend arms out to the sides at shoulder height. Make small circles forward, then reverse direction.',
    [MuscleGroup.shoulders],
  );

  // Full Body / Lower Body shared
  static final Exercise _bodyweightSquats = _ex(
    'warmup_bodyweight_squats',
    'Bodyweight Squats',
    'Stand with feet shoulder-width apart. Lower your hips back and down until thighs are parallel to the floor, then drive back up.',
    [MuscleGroup.quads, MuscleGroup.glutes],
  );

  static final Exercise _hipCircles = _ex(
    'warmup_hip_circles',
    'Hip Circles',
    'Stand with hands on hips. Rotate your hips in wide circles, keeping your upper body relatively still.',
    [MuscleGroup.glutes, MuscleGroup.lowerBack],
  );

  static final Exercise _legSwings = _ex(
    'warmup_leg_swings',
    'Leg Swings',
    'Hold a wall for balance. Swing one leg forward and back in a controlled arc, then switch legs.',
    [MuscleGroup.hamstrings, MuscleGroup.glutes],
  );

  // Full Body / Core shared
  static final Exercise _catCow = _ex(
    'warmup_cat_cow',
    'Cat-Cow Stretch',
    'On hands and knees, alternate between arching your back upward (cat) and letting it sag downward (cow) with each breath.',
    [MuscleGroup.lowerBack, MuscleGroup.abs],
  );

  // Full Body exclusive (10 min)
  static final Exercise _inchworms = _ex(
    'warmup_inchworms',
    'Inchworms',
    'Stand tall, hinge forward and walk hands out to a plank position. Walk hands back to feet and stand. Repeat.',
    [MuscleGroup.back, MuscleGroup.hamstrings],
  );

  // ── Upper Body exercises ───────────────────────────────────────────────────

  static final Exercise _shoulderRolls = _ex(
    'warmup_shoulder_rolls',
    'Shoulder Rolls',
    'Roll your shoulders forward in slow circles for several reps, then reverse the direction.',
    [MuscleGroup.shoulders],
  );

  static final Exercise _wallPushUps = _ex(
    'warmup_wall_push_ups',
    'Wall Push-Ups',
    'Stand an arm\'s length from a wall. Place hands on the wall and perform push-up motion, bending elbows to bring chest toward the wall.',
    [MuscleGroup.chest, MuscleGroup.shoulders, MuscleGroup.triceps],
  );

  static final Exercise _chestOpener = _ex(
    'warmup_chest_opener',
    'Chest Opener Stretch',
    'Clasp hands behind your back, squeeze shoulder blades together, and lift arms slightly while opening the chest.',
    [MuscleGroup.chest, MuscleGroup.shoulders],
  );

  static final Exercise _bandPullAparts = _ex(
    'warmup_band_pull_aparts',
    'Band Pull-Aparts Mimic',
    'Hold arms in front at shoulder height. Mimic pulling a resistance band apart by squeezing shoulder blades together as arms move out to the sides.',
    [MuscleGroup.shoulders, MuscleGroup.back],
  );

  static final Exercise _tricepOverhead = _ex(
    'warmup_tricep_overhead',
    'Tricep Overhead Stretch',
    'Raise one arm overhead, bend the elbow so the hand drops behind your head. Use the other hand to gently press the elbow inward. Switch sides.',
    [MuscleGroup.triceps],
  );

  static final Exercise _wristCircles = _ex(
    'warmup_wrist_circles',
    'Wrist Circles',
    'Extend arms in front. Rotate wrists in slow circles, first clockwise then counter-clockwise.',
    [MuscleGroup.forearms],
  );

  static final Exercise _neckRolls = _ex(
    'warmup_neck_rolls',
    'Neck Rolls',
    'Slowly drop your chin to your chest and gently roll your head in a half-circle from one shoulder to the other. Keep movements slow and controlled.',
    [MuscleGroup.shoulders],
  );

  // ── Lower Body exercises ───────────────────────────────────────────────────

  static final Exercise _calfRaises = _ex(
    'warmup_calf_raises',
    'Calf Raises',
    'Stand with feet hip-width apart. Rise up onto the balls of your feet, hold briefly at the top, then lower back down.',
    [MuscleGroup.calves],
  );

  static final Exercise _lateralLunges = _ex(
    'warmup_lateral_lunges',
    'Lateral Lunges',
    'Stand with feet together. Step wide to the side, bend the stepping knee while keeping the other leg straight. Push back to start and repeat on the other side.',
    [MuscleGroup.quads, MuscleGroup.hamstrings, MuscleGroup.glutes],
  );

  static final Exercise _gluteBridges = _ex(
    'warmup_glute_bridges',
    'Glute Bridges',
    'Lie on your back with knees bent and feet flat. Drive hips upward by squeezing glutes until body forms a straight line from knees to shoulders. Lower slowly.',
    [MuscleGroup.glutes],
  );

  static final Exercise _standingQuadStretch = _ex(
    'warmup_standing_quad_stretch',
    'Standing Quad Stretch',
    'Stand on one foot and pull the opposite ankle toward your glutes. Keep knees together and stand tall. Hold, then switch sides.',
    [MuscleGroup.quads],
  );

  static final Exercise _hamstringStretch = _ex(
    'warmup_hamstring_stretch',
    'Hamstring Stretch',
    'Stand and extend one leg forward with heel on the ground and toes up. Hinge at the hips and lean forward gently until you feel a stretch. Switch sides.',
    [MuscleGroup.hamstrings],
  );

  // ── Core exercises ─────────────────────────────────────────────────────────

  static final Exercise _deadBug = _ex(
    'warmup_dead_bug',
    'Dead Bug',
    'Lie on your back with arms pointing to the ceiling and knees at 90 degrees. Slowly lower the opposite arm and leg toward the floor while keeping your lower back pressed down. Return and repeat.',
    [MuscleGroup.abs, MuscleGroup.lowerBack],
  );

  static final Exercise _birdDog = _ex(
    'warmup_bird_dog',
    'Bird Dog',
    'Start on hands and knees. Extend one arm forward and the opposite leg back, keeping hips level. Hold briefly, return, and switch sides.',
    [MuscleGroup.abs, MuscleGroup.lowerBack],
  );

  static final Exercise _plankHold = _ex(
    'warmup_plank_hold',
    'Plank Hold',
    'Support yourself on forearms and toes with body in a straight line. Brace your core and hold the position.',
    [MuscleGroup.abs, MuscleGroup.lowerBack, MuscleGroup.shoulders],
  );

  static final Exercise _mountainClimbers = _ex(
    'warmup_mountain_climbers',
    'Mountain Climbers',
    'Start in a high plank. Drive one knee toward your chest, then quickly switch legs in a running motion while keeping hips level.',
    [MuscleGroup.abs, MuscleGroup.cardio],
  );

  static final Exercise _russianTwists = _ex(
    'warmup_russian_twists',
    'Russian Twists',
    'Sit with knees bent, lean back slightly and lift feet off the floor. Rotate your torso left and right, touching hands to the ground on each side.',
    [MuscleGroup.obliques, MuscleGroup.abs],
  );

  static final Exercise _hipBridges = _ex(
    'warmup_hip_bridges',
    'Hip Bridges',
    'Lie on your back, knees bent, feet flat. Press through heels to lift your hips until your body forms a straight line. Squeeze glutes at the top, then lower.',
    [MuscleGroup.glutes, MuscleGroup.lowerBack],
  );

  static final Exercise _hollowBody = _ex(
    'warmup_hollow_body',
    'Hollow Body Hold',
    'Lie on your back, press lower back into the floor, lift shoulders and legs slightly. Extend arms overhead and hold the banana-like position.',
    [MuscleGroup.abs],
  );

  // ── Cardio exercises ───────────────────────────────────────────────────────

  static final Exercise _buttKicks = _ex(
    'warmup_butt_kicks',
    'Butt Kicks',
    'Jog in place while kicking your heels up toward your glutes with each step. Keep a quick, light pace.',
    [MuscleGroup.cardio, MuscleGroup.hamstrings],
  );

  static final Exercise _jumpRopeMimic = _ex(
    'warmup_jump_rope_mimic',
    'Jump Rope Mimic',
    'Mimic jumping rope without an actual rope: bounce lightly on the balls of your feet and rotate your wrists as if turning a rope.',
    [MuscleGroup.cardio, MuscleGroup.calves],
  );

  static final Exercise _skaters = _ex(
    'warmup_skaters',
    'Skaters',
    'Leap sideways from one foot to the other, mimicking a speed skater. Swing the opposite arm across your body and touch down briefly before switching.',
    [MuscleGroup.cardio, MuscleGroup.glutes, MuscleGroup.quads],
  );

  static final Exercise _boxStepUps = _ex(
    'warmup_box_step_ups',
    'Box Step Ups Mimic',
    'Step one foot onto an imaginary box (or a low step), bring the other foot up, then step back down. Alternate the leading foot.',
    [MuscleGroup.cardio, MuscleGroup.quads, MuscleGroup.glutes],
  );

  static final Exercise _burpeeWarmup = _ex(
    'warmup_burpee_warmup',
    'Burpee Warm-up',
    'Perform a slow, controlled burpee: squat down, walk hands to plank, do an optional push-up, walk hands back, and stand. No jumping required.',
    [MuscleGroup.cardio, MuscleGroup.chest],
  );

  static final Exercise _speedShuffle = _ex(
    'warmup_speed_shuffle',
    'Speed Shuffle',
    'Stand in an athletic stance. Shuffle quickly side to side for several steps, then reverse direction. Keep hips low and feet light.',
    [MuscleGroup.cardio, MuscleGroup.quads],
  );
}
