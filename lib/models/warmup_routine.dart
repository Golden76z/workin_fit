import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/session.dart';
import 'package:workin_fit/models/workout_config.dart';

/// An immutable warmup routine combining a category, duration, exercises, and exercise metadata.
class WarmupRoutine {
  final WarmupCategory category;
  final int durationMinutes;
  /// Timed workout configs (exerciseId matches a WarmupExercise stub)
  final List<TimedConfig> workoutConfigs;
  /// Self-contained exercise stubs (no network dependency)
  final List<Exercise> exercises;

  const WarmupRoutine({
    required this.category,
    required this.durationMinutes,
    required this.workoutConfigs,
    required this.exercises,
  });

  /// Stable Firestore document id derived from the routine's key
  /// (category + duration), e.g. `fullBody_5`.
  String get docKey => '${category.name}_$durationMinutes';

  /// Serialize to a Firestore document. Each step pairs a [TimedConfig] with its
  /// matching exercise stub so [fromFirestore] can rebuild both.
  Map<String, dynamic> toFirestore() {
    final Map<String, Exercise> byId = <String, Exercise>{
      for (final Exercise e in exercises) e.id: e,
    };
    return <String, dynamic>{
      'category': category.name,
      'durationMinutes': durationMinutes,
      'steps': <Map<String, dynamic>>[
        for (final TimedConfig config in workoutConfigs)
          <String, dynamic>{
            'exerciseId': config.exerciseId,
            'duration': config.duration,
            'name': byId[config.exerciseId]?.name ?? config.exerciseId,
            'description': byId[config.exerciseId]?.description ?? '',
            'muscleGroups': (byId[config.exerciseId]?.muscleGroups ??
                    const <MuscleGroup>[MuscleGroup.cardio])
                .map((MuscleGroup m) => m.name)
                .toList(),
          },
      ],
    };
  }

  /// Rebuild a routine from a Firestore document. Unknown enum values fall back
  /// to sane defaults. [id]/[data] must contain `category`, `durationMinutes`
  /// and a `steps` list.
  factory WarmupRoutine.fromFirestore(Map<String, dynamic> data) {
    final WarmupCategory category = WarmupCategory.values.firstWhere(
      (WarmupCategory c) => c.name == (data['category'] as String?),
      orElse: () => WarmupCategory.fullBody,
    );
    final int durationMinutes = (data['durationMinutes'] as num?)?.toInt() ?? 5;

    final List<dynamic> rawSteps =
        (data['steps'] as List<dynamic>?) ?? const <dynamic>[];
    final List<TimedConfig> configs = <TimedConfig>[];
    final List<Exercise> exercises = <Exercise>[];
    for (final dynamic raw in rawSteps) {
      if (raw is! Map) continue;
      final Map<String, dynamic> step =
          raw.map((dynamic k, dynamic v) => MapEntry(k.toString(), v));
      final String exerciseId = step['exerciseId'] as String? ?? '';
      if (exerciseId.isEmpty) continue;
      final int duration = (step['duration'] as num?)?.toInt() ?? 30;
      final List<MuscleGroup> muscles =
          ((step['muscleGroups'] as List<dynamic>?) ?? const <dynamic>[])
              .map(
                (dynamic m) => MuscleGroup.values.firstWhere(
                  (MuscleGroup mg) => mg.name == m.toString(),
                  orElse: () => MuscleGroup.cardio,
                ),
              )
              .toList();
      configs.add(TimedConfig(exerciseId: exerciseId, duration: duration));
      exercises.add(
        Exercise(
          id: exerciseId,
          name: step['name'] as String? ?? exerciseId,
          description: step['description'] as String? ?? '',
          imageMuscleUrl: '',
          imageTutorialUrl: '',
          muscleGroups:
              muscles.isEmpty ? const <MuscleGroup>[MuscleGroup.cardio] : muscles,
          difficulty: DifficultyLevel.beginner,
        ),
      );
    }
    return WarmupRoutine(
      category: category,
      durationMinutes: durationMinutes,
      workoutConfigs: configs,
      exercises: exercises,
    );
  }

  /// Build a Session object suitable for WorkoutExecutionScreen
  Session toSession() {
    return Session(
      id: 'warmup_${category.name}_${durationMinutes}m',
      name: _sessionName(),
      description: _sessionDescription(),
      workouts: workoutConfigs,
      difficulty: DifficultyLevel.beginner,
      restBetweenExercises: 10,
      transitionTime: 3,
    );
  }

  String _sessionName() {
    final categoryName = switch (category) {
      WarmupCategory.fullBody => 'Full Body',
      WarmupCategory.upperBody => 'Upper Body',
      WarmupCategory.lowerBody => 'Lower Body',
      WarmupCategory.core => 'Core',
      WarmupCategory.cardio => 'Cardio',
    };
    return '$durationMinutes min $categoryName Warmup';
  }

  String _sessionDescription() {
    return switch (category) {
      WarmupCategory.fullBody => 'Whole body activation warmup',
      WarmupCategory.upperBody => 'Arms, shoulders & chest warmup',
      WarmupCategory.lowerBody => 'Legs, hips & glutes warmup',
      WarmupCategory.core => 'Abs & lower back warmup',
      WarmupCategory.cardio => 'Cardio warmup to get your heart rate up',
    };
  }
}
