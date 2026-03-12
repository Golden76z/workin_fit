import 'dart:async';
import 'dart:ui';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/l10n/app_localizations.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/exercise_localization_helper.dart';
import 'package:workin_fit/models/session.dart';
import 'package:workin_fit/models/workout_config.dart';
import 'package:workin_fit/providers/workout_providers.dart';

enum _WorkoutPhase {
  getReady,
  setActive,
  setRest,
  exercise,
  exerciseRest,
  finished,
}

class WorkoutExecutionScreen extends ConsumerStatefulWidget {
  final Session session;
  final List<Exercise>? seededExercises;

  const WorkoutExecutionScreen({
    required this.session,
    this.seededExercises,
    super.key,
  });

  @override
  ConsumerState<WorkoutExecutionScreen> createState() =>
      _WorkoutExecutionScreenState();
}

class _WorkoutExecutionScreenState extends ConsumerState<WorkoutExecutionScreen>
    with WidgetsBindingObserver {
  final CountDownController _timerController = CountDownController();
  static const SystemUiOverlayStyle _transparentSystemOverlay =
      SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarContrastEnforced: false,
  );

  int _currentExerciseIndex = 0;
  int _timerVersion = 0;
  _WorkoutPhase _phase = _WorkoutPhase.getReady;
  bool _hasStarted = false;
  bool _isRunning = false;
  DateTime? _workoutStartedAt;
  bool _workoutHistorySaved = false;
  final Map<int, _ExerciseActualMetrics> _actualMetricsByIndex =
      <int, _ExerciseActualMetrics>{};
  int _currentSet = 0;
  final Map<int, List<int?>> _completedSetsRepsPerExercise =
      <int, List<int?>>{};
  final Map<int, List<int>> _setElapsedSeconds = <int, List<int>>{};
  final Stopwatch _setStopwatch = Stopwatch();
  Timer? _setTickTimer;

  // Tabata-specific state
  int _tabataCurrentRound = 0;
  int _tabataCurrentSet = 0;
  bool _tabataIsWork = true;

  int get _totalExercises => widget.session.workouts.length;

  WorkoutConfig? get _currentWorkout {
    if (_totalExercises == 0) {
      return null;
    }
    return widget.session.workouts[_currentExerciseIndex];
  }

  WorkoutConfig? get _nextWorkout {
    final int nextIndex = _currentExerciseIndex + 1;
    if (nextIndex >= _totalExercises) {
      return null;
    }
    return widget.session.workouts[nextIndex];
  }

  int get _phaseDuration {
    switch (_phase) {
      case _WorkoutPhase.getReady:
        final int transitionTime = widget.session.transitionTime;
        if (transitionTime > 0) {
          return transitionTime;
        }
        return 5;
      case _WorkoutPhase.setActive:
        return 0;
      case _WorkoutPhase.setRest:
        final WorkoutConfig? workout = _currentWorkout;
        if (workout is SetsConfig) {
          final int rest = workout.restBetweenSets;
          return rest > 0 ? rest : 60;
        }
        if (workout is TabataConfig) {
          final int rest = workout.restBetweenSets;
          return rest > 0 ? rest : 60;
        }
        return 60;
      case _WorkoutPhase.exercise:
        final WorkoutConfig? workout = _currentWorkout;
        if (workout == null) {
          return 0;
        }
        if (workout is TabataConfig) {
          final int duration =
              _tabataIsWork ? workout.workTime : workout.restTime;
          return duration > 0 ? duration : 1;
        }
        return _durationForWorkout(workout);
      case _WorkoutPhase.exerciseRest:
        final int rest = widget.session.restBetweenExercises;
        return rest > 0 ? rest : 120;
      case _WorkoutPhase.finished:
        return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _setTickTimer?.cancel();
    _setStopwatch.stop();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _startSetTicker() {
    _setStopwatch
      ..reset()
      ..start();
    _setTickTimer?.cancel();
    _setTickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  void _stopSetTicker() {
    _setStopwatch.stop();
    _setTickTimer?.cancel();
    _setTickTimer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      return;
    }
    if (_isRunning) {
      _pauseTimer();
    }
  }

  int _durationForWorkout(WorkoutConfig workout) {
    int duration;
    if (workout is TimedConfig) {
      duration = workout.duration;
    } else if (workout is TabataConfig) {
      duration = workout.totalDuration;
    } else if (workout is SetsConfig) {
      duration = workout.estimatedTotalTime;
    } else {
      duration = 30;
    }
    if (duration <= 0) {
      return 1;
    }
    return duration;
  }

  int _plannedWorkDurationForWorkout(WorkoutConfig workout) {
    if (workout is TimedConfig) {
      return workout.duration;
    }
    if (workout is TabataConfig) {
      return workout.totalWorkTime * workout.sets;
    }
    if (workout is SetsConfig) {
      return workout.estimatedWorkDuration;
    }
    return _durationForWorkout(workout);
  }

  _ExerciseActualMetrics? _actualMetricsAt(int index) {
    return _actualMetricsByIndex[index];
  }

  bool get _hasAnyActualMetrics {
    return _actualMetricsByIndex.values.any(
      (_ExerciseActualMetrics metrics) => metrics.hasAnyInput,
    );
  }

  int _doneDurationForWorkout({
    required WorkoutConfig workout,
    required _ExerciseActualMetrics? actual,
  }) {
    final int? manualDuration = actual?.doneDurationSeconds;
    if (manualDuration != null && manualDuration > 0) {
      return manualDuration;
    }

    if (workout is TimedConfig) {
      final int timedSeconds = actual?.doneTimedSeconds ?? workout.duration;
      return timedSeconds > 0 ? timedSeconds : workout.duration;
    }

    if (workout is TabataConfig) {
      final int rounds = actual?.doneRounds ?? workout.rounds;
      final int clampedRounds = rounds < 0 ? 0 : rounds;
      return clampedRounds * (workout.workTime + workout.restTime);
    }

    if (workout is SetsConfig) {
      final int reps = actual?.doneReps ?? workout.totalReps;
      final int safeReps = reps < 0 ? 0 : reps;
      final int sets = actual?.doneSets ?? workout.sets;
      final int safeSets = sets < 0 ? 0 : sets;
      final int restSeconds =
          safeSets > 1 ? (safeSets - 1) * workout.restBetweenSets : 0;
      return (safeReps * 3) + restSeconds;
    }

    return _durationForWorkout(workout);
  }

  int _doneWorkDurationForWorkout({
    required WorkoutConfig workout,
    required _ExerciseActualMetrics? actual,
  }) {
    final int? manualWorkSeconds = actual?.doneWorkSeconds;
    if (manualWorkSeconds != null && manualWorkSeconds > 0) {
      return manualWorkSeconds;
    }

    if (workout is TimedConfig) {
      final int timedSeconds = actual?.doneTimedSeconds ?? workout.duration;
      return timedSeconds > 0 ? timedSeconds : workout.duration;
    }

    if (workout is TabataConfig) {
      final int rounds = actual?.doneRounds ?? workout.rounds;
      final int clampedRounds = rounds < 0 ? 0 : rounds;
      return clampedRounds * workout.workTime;
    }

    if (workout is SetsConfig) {
      final int reps = actual?.doneReps ?? workout.totalReps;
      final int safeReps = reps < 0 ? 0 : reps;
      return safeReps * 3;
    }

    return _plannedWorkDurationForWorkout(workout);
  }

  int _doneSetsForWorkout({
    required SetsConfig workout,
    required _ExerciseActualMetrics? actual,
  }) {
    final int value = actual?.doneSets ?? workout.sets;
    return value < 0 ? 0 : value;
  }

  int _doneRepsForWorkout({
    required SetsConfig workout,
    required _ExerciseActualMetrics? actual,
  }) {
    final int value = actual?.doneReps ?? workout.totalReps;
    return value < 0 ? 0 : value;
  }

  int _doneRoundsForWorkout({
    required TabataConfig workout,
    required _ExerciseActualMetrics? actual,
  }) {
    final int value = actual?.doneRounds ?? (workout.rounds * workout.sets);
    return value < 0 ? 0 : value;
  }

  int _doneTimedSecondsForWorkout({
    required TimedConfig workout,
    required _ExerciseActualMetrics? actual,
  }) {
    final int value = actual?.doneTimedSeconds ?? workout.duration;
    return value < 0 ? 0 : value;
  }

  Map<String, dynamic> _serializeWorkoutPlan({
    required WorkoutConfig workout,
    required int index,
    required _ExerciseActualMetrics? actual,
  }) {
    final int doneDurationSeconds = _doneDurationForWorkout(
      workout: workout,
      actual: actual,
    );
    final int doneWorkSeconds = _doneWorkDurationForWorkout(
      workout: workout,
      actual: actual,
    );

    final Map<String, dynamic> data = <String, dynamic>{
      'index': index,
      'exerciseId': workout.exerciseId,
      'type': workout.type.name,
      'plannedDurationSeconds': _durationForWorkout(workout),
      'plannedWorkSeconds': _plannedWorkDurationForWorkout(workout),
      'doneDurationSeconds': doneDurationSeconds,
      'doneWorkSeconds': doneWorkSeconds,
      'actualDurationSeconds': actual?.doneDurationSeconds,
    };

    if (workout is SetsConfig) {
      final int doneSets = _doneSetsForWorkout(
        workout: workout,
        actual: actual,
      );
      final int doneReps = _doneRepsForWorkout(
        workout: workout,
        actual: actual,
      );
      data.addAll(<String, dynamic>{
        'sets': workout.sets,
        'reps': workout.reps,
        'totalReps': workout.totalReps,
        'restBetweenSets': workout.restBetweenSets,
        'weight': workout.weight,
        'weightUnit': workout.weightUnit,
        'doneSets': doneSets,
        'doneReps': doneReps,
        'doneWeight': actual?.doneWeight ?? workout.weight,
        'doneWeightUnit': actual?.doneWeightUnit ?? workout.weightUnit,
        'actualSets': actual?.doneSets,
        'actualReps': actual?.doneReps,
        'actualWeight': actual?.doneWeight,
        'actualWeightUnit': actual?.doneWeightUnit,
        'setElapsedSeconds': _setElapsedSeconds[index] ?? <int>[],
      });
    } else if (workout is TabataConfig) {
      final int doneRounds = _doneRoundsForWorkout(
        workout: workout,
        actual: actual,
      );
      data.addAll(<String, dynamic>{
        'sets': workout.sets,
        'rounds': workout.rounds,
        'workTime': workout.workTime,
        'restTime': workout.restTime,
        'restBetweenSets': workout.restBetweenSets,
        'doneRounds': doneRounds,
        'actualRounds': actual?.doneRounds,
      });
    } else if (workout is TimedConfig) {
      final int doneTimedSeconds = _doneTimedSecondsForWorkout(
        workout: workout,
        actual: actual,
      );
      data.addAll(<String, dynamic>{
        'duration': workout.duration,
        'doneDuration': doneTimedSeconds,
        'actualDuration': actual?.doneTimedSeconds,
      });
    }

    return data;
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  String _dateKey(DateTime localDate) {
    return '${localDate.year}-${_twoDigits(localDate.month)}-${_twoDigits(localDate.day)}';
  }

  String _monthKey(DateTime localDate) {
    return '${localDate.year}-${_twoDigits(localDate.month)}';
  }

  String _weekKey(DateTime localDate) {
    final DateTime weekStart = localDate.subtract(
      Duration(days: localDate.weekday - DateTime.monday),
    );
    return _dateKey(weekStart);
  }

  int? _parsePositiveInt(String rawValue) {
    final String trimmed = rawValue.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final int? parsed = int.tryParse(trimmed);
    if (parsed == null || parsed < 0) {
      return null;
    }
    return parsed;
  }

  double? _parsePositiveDouble(String rawValue) {
    final String trimmed = rawValue.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final double? parsed = double.tryParse(trimmed);
    if (parsed == null || parsed < 0) {
      return null;
    }
    return parsed;
  }

  Future<void> _openActualMetricsSheet({
    required WorkoutConfig workout,
    required int index,
    required String exerciseName,
  }) async {
    final _ExerciseActualMetrics? existing = _actualMetricsAt(index);
    final TextEditingController repsController = TextEditingController(
      text: existing?.doneReps?.toString() ??
          (workout is SetsConfig ? workout.totalReps.toString() : ''),
    );
    final TextEditingController setsController = TextEditingController(
      text: existing?.doneSets?.toString() ??
          (workout is SetsConfig ? workout.sets.toString() : ''),
    );
    final TextEditingController weightController = TextEditingController(
      text: existing?.doneWeight?.toString() ??
          (workout is SetsConfig && workout.weight != null
              ? workout.weight!.toString()
              : ''),
    );
    final TextEditingController weightUnitController = TextEditingController(
      text: existing?.doneWeightUnit ??
          (workout is SetsConfig ? (workout.weightUnit ?? '') : ''),
    );
    final TextEditingController roundsController = TextEditingController(
      text: existing?.doneRounds?.toString() ??
          (workout is TabataConfig ? workout.rounds.toString() : ''),
    );
    final TextEditingController timedSecondsController = TextEditingController(
      text: existing?.doneTimedSeconds?.toString() ??
          (workout is TimedConfig ? workout.duration.toString() : ''),
    );
    final TextEditingController durationController = TextEditingController(
      text: existing?.doneDurationSeconds?.toString() ?? '',
    );
    final TextEditingController workSecondsController = TextEditingController(
      text: existing?.doneWorkSeconds?.toString() ?? '',
    );

    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.surface,
        builder: (BuildContext context) {
          final bool isFrench = Localizations.localeOf(context)
              .languageCode
              .toLowerCase()
              .startsWith('fr');
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md +
                    MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      isFrench
                          ? 'Enregistrer les performances réelles'
                          : 'Log actual performance',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'AppFontMedium',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      exerciseName,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (workout is SetsConfig) ...<Widget>[
                      _ActualInputField(
                        controller: setsController,
                        label: 'Sets done',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _ActualInputField(
                        controller: repsController,
                        label: 'Total reps done',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _ActualInputField(
                              controller: weightController,
                              label: 'Weight used',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          SizedBox(
                            width: 96,
                            child: _ActualInputField(
                              controller: weightUnitController,
                              label: 'Unit',
                              keyboardType: TextInputType.text,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                    ],
                    if (workout is TabataConfig) ...<Widget>[
                      _ActualInputField(
                        controller: roundsController,
                        label: 'Rounds done',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                    ],
                    if (workout is TimedConfig) ...<Widget>[
                      _ActualInputField(
                        controller: timedSecondsController,
                        label: 'Seconds done',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                    ],
                    _ActualInputField(
                      controller: durationController,
                      label: 'Total duration done (sec)',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _ActualInputField(
                      controller: workSecondsController,
                      label: 'Active work done (sec)',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _actualMetricsByIndex.remove(index);
                              });
                              Navigator.of(context).pop();
                            },
                            child: const Text('Clear'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              final _ExerciseActualMetrics metrics =
                                  _ExerciseActualMetrics(
                                doneSets: _parsePositiveInt(
                                  setsController.text,
                                ),
                                doneReps: _parsePositiveInt(
                                  repsController.text,
                                ),
                                doneWeight: _parsePositiveDouble(
                                  weightController.text,
                                ),
                                doneWeightUnit: weightUnitController.text.trim()
                                        .isEmpty
                                    ? null
                                    : weightUnitController.text.trim(),
                                doneRounds: _parsePositiveInt(
                                  roundsController.text,
                                ),
                                doneTimedSeconds: _parsePositiveInt(
                                  timedSecondsController.text,
                                ),
                                doneDurationSeconds: _parsePositiveInt(
                                  durationController.text,
                                ),
                                doneWorkSeconds: _parsePositiveInt(
                                  workSecondsController.text,
                                ),
                              );
                              setState(() {
                                if (metrics.hasAnyInput) {
                                  _actualMetricsByIndex[index] = metrics;
                                } else {
                                  _actualMetricsByIndex.remove(index);
                                }
                              });
                              Navigator.of(context).pop();
                            },
                            child: const Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } finally {
      repsController.dispose();
      setsController.dispose();
      weightController.dispose();
      weightUnitController.dispose();
      roundsController.dispose();
      timedSecondsController.dispose();
      durationController.dispose();
      workSecondsController.dispose();
    }
  }

  void _onPrimaryActionPressed() {
    if (_phase == _WorkoutPhase.finished) {
      Navigator.of(context).maybePop();
      return;
    }

    if (_phase == _WorkoutPhase.setActive) {
      _onSetCompleted();
      return;
    }

    if (!_hasStarted) {
      setState(() {
        _hasStarted = true;
        _workoutStartedAt ??= DateTime.now();
      });
      _startCurrentPhase();
      return;
    }

    if (_isRunning) {
      _pauseTimer();
    } else {
      _resumeTimer();
    }
  }

  void _startCurrentPhase() {
    if (_phase == _WorkoutPhase.setActive) {
      _startSetTicker();
      setState(() {
        _isRunning = false;
      });
      return;
    }

    final int duration = _phaseDuration;
    if (duration <= 0) {
      _onPhaseCompleted();
      return;
    }

    setState(() {
      _isRunning = true;
      _timerVersion += 1;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _phase == _WorkoutPhase.finished) {
        return;
      }
      _timerController.restart(duration: duration);
    });
  }

  void _pauseTimer() {
    _timerController.pause();
    setState(() {
      _isRunning = false;
    });
  }

  void _resumeTimer() {
    _timerController.resume();
    setState(() {
      _isRunning = true;
    });
  }

  void _onPhaseCompleted() {
    if (!mounted) {
      return;
    }

    SystemSound.play(SystemSoundType.alert);

    switch (_phase) {
      case _WorkoutPhase.getReady:
        final WorkoutConfig? workout = _currentWorkout;
        if (workout is SetsConfig) {
          setState(() {
            _phase = _WorkoutPhase.setActive;
            _currentSet = 0;
            _isRunning = false;
          });
        } else {
          setState(() {
            _phase = _WorkoutPhase.exercise;
            if (workout is TabataConfig) {
              _tabataCurrentRound = 0;
              _tabataCurrentSet = 0;
              _tabataIsWork = true;
            }
          });
          _startCurrentPhase();
        }
        break;

      case _WorkoutPhase.exercise:
        final WorkoutConfig? workout = _currentWorkout;
        if (workout is TabataConfig) {
          _onTabataIntervalCompleted(workout);
        } else {
          _advanceToNextExerciseOrFinish();
        }
        break;

      case _WorkoutPhase.setRest:
        final WorkoutConfig? workout = _currentWorkout;
        if (workout is TabataConfig) {
          // Resume Tabata after rest between sets
          setState(() {
            _phase = _WorkoutPhase.exercise;
            _tabataIsWork = true;
          });
          _startCurrentPhase();
        } else {
          setState(() {
            _phase = _WorkoutPhase.setActive;
            _isRunning = false;
          });
        }
        break;

      case _WorkoutPhase.exerciseRest:
        setState(() {
          _currentExerciseIndex += 1;
          _phase = _WorkoutPhase.getReady;
          _currentSet = 0;
          _tabataCurrentRound = 0;
          _tabataCurrentSet = 0;
          _tabataIsWork = true;
        });
        _startCurrentPhase();
        break;

      case _WorkoutPhase.setActive:
      case _WorkoutPhase.finished:
        break;
    }
  }

  void _onSetCompleted() {
    if (!mounted) return;
    final WorkoutConfig? workout = _currentWorkout;
    if (workout is! SetsConfig) return;

    _stopSetTicker();
    final int elapsedSeconds = _setStopwatch.elapsed.inSeconds;
    _setElapsedSeconds
        .putIfAbsent(_currentExerciseIndex, () => <int>[])
        .add(elapsedSeconds);

    SystemSound.play(SystemSoundType.alert);

    final List<int?> completedSets = _completedSetsRepsPerExercise.putIfAbsent(
      _currentExerciseIndex,
      () => <int?>[],
    );
    completedSets.add(null);

    final bool isLastSet = _currentSet + 1 >= workout.sets;

    if (isLastSet) {
      _syncCompletedSetsToActualMetrics();
      _advanceToNextExerciseOrFinish();
    } else {
      setState(() {
        _currentSet += 1;
        _phase = _WorkoutPhase.setRest;
      });
      _startCurrentPhase();
    }
  }

  void _onTabataIntervalCompleted(TabataConfig workout) {
    if (!mounted) return;
    SystemSound.play(SystemSoundType.alert);

    if (_tabataIsWork) {
      // Work interval done → start rest interval for this round
      setState(() {
        _tabataIsWork = false;
      });
      _startCurrentPhase();
    } else {
      // Rest interval done → advance round or set
      final bool isLastRound = _tabataCurrentRound + 1 >= workout.rounds;
      if (!isLastRound) {
        setState(() {
          _tabataCurrentRound += 1;
          _tabataIsWork = true;
        });
        _startCurrentPhase();
      } else {
        final bool isLastSet = _tabataCurrentSet + 1 >= workout.sets;
        if (!isLastSet) {
          // More sets remaining → rest between sets
          setState(() {
            _tabataCurrentSet += 1;
            _tabataCurrentRound = 0;
            _tabataIsWork = true;
            _phase = _WorkoutPhase.setRest;
          });
          _startCurrentPhase();
        } else {
          // All sets done → sync metrics then next exercise or finish
          _syncTabataRoundsToActualMetrics(workout);
          _advanceToNextExerciseOrFinish();
        }
      }
    }
  }

  void _skipRest() {
    if (!mounted) return;
    _timerController.pause();
    _onPhaseCompleted();
  }

  void _advanceToNextExerciseOrFinish() {
    if (_currentExerciseIndex + 1 >= _totalExercises) {
      setState(() {
        _phase = _WorkoutPhase.finished;
        _isRunning = false;
      });
      _saveWorkoutHistoryIfNeeded();
    } else {
      setState(() {
        _phase = _WorkoutPhase.exerciseRest;
      });
      _startCurrentPhase();
    }
  }

  void _syncTabataRoundsToActualMetrics(TabataConfig workout) {
    final int completedRounds =
        _tabataCurrentSet * workout.rounds + _tabataCurrentRound + 1;
    final _ExerciseActualMetrics? existing =
        _actualMetricsByIndex[_currentExerciseIndex];
    _actualMetricsByIndex[_currentExerciseIndex] = _ExerciseActualMetrics(
      doneRounds: completedRounds,
      doneSets: existing?.doneSets,
      doneReps: existing?.doneReps,
      doneWeight: existing?.doneWeight,
      doneWeightUnit: existing?.doneWeightUnit,
      doneTimedSeconds: existing?.doneTimedSeconds,
      doneDurationSeconds: existing?.doneDurationSeconds,
      doneWorkSeconds: existing?.doneWorkSeconds,
    );
  }

  void _syncCompletedSetsToActualMetrics() {
    final WorkoutConfig? workout = _currentWorkout;
    if (workout is! SetsConfig) return;
    final int completedSets =
        _completedSetsRepsPerExercise[_currentExerciseIndex]?.length ??
        workout.sets;
    final _ExerciseActualMetrics? existing =
        _actualMetricsByIndex[_currentExerciseIndex];
    _actualMetricsByIndex[_currentExerciseIndex] = _ExerciseActualMetrics(
      doneSets: completedSets,
      doneReps: existing?.doneReps ?? (completedSets * workout.reps),
      doneWeight: existing?.doneWeight ?? workout.weight,
      doneWeightUnit: existing?.doneWeightUnit ?? workout.weightUnit,
      doneRounds: existing?.doneRounds,
      doneTimedSeconds: existing?.doneTimedSeconds,
      doneDurationSeconds: existing?.doneDurationSeconds,
      doneWorkSeconds: existing?.doneWorkSeconds,
    );
  }

  Future<void> _saveWorkoutHistoryIfNeeded() async {
    if (_workoutHistorySaved) {
      return;
    }

    final String? userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      return;
    }

    final DateTime completedAt = DateTime.now();
    final DateTime startedAt = _workoutStartedAt ?? completedAt;
    final DateTime completedAtUtc = completedAt.toUtc();
    final DateTime startedAtUtc = startedAt.toUtc();
    int durationSeconds = completedAt.difference(startedAt).inSeconds;
    if (durationSeconds <= 0) {
      durationSeconds = widget.session.estimatedDuration;
    }

    final List<Map<String, dynamic>> workoutPlans =
        widget.session.workouts.asMap().entries.map((entry) {
      final _ExerciseActualMetrics? actual = _actualMetricsAt(entry.key);
      return _serializeWorkoutPlan(
        workout: entry.value,
        index: entry.key,
        actual: actual,
      );
    }).toList();

    final Map<String, Map<String, dynamic>> exerciseAggregateById =
        <String, Map<String, dynamic>>{};
    for (final MapEntry<int, WorkoutConfig> entry
        in widget.session.workouts.asMap().entries) {
      final WorkoutConfig workout = entry.value;
      final _ExerciseActualMetrics? actual = _actualMetricsAt(entry.key);
      final Map<String, dynamic> aggregate =
          exerciseAggregateById.putIfAbsent(workout.exerciseId, () {
        return <String, dynamic>{
          'exerciseId': workout.exerciseId,
          'workoutCount': 0,
          'plannedDurationSeconds': 0,
          'plannedWorkSeconds': 0,
          'plannedSets': 0,
          'plannedReps': 0,
          'plannedRounds': 0,
          'plannedTimedSeconds': 0,
          'doneDurationSeconds': 0,
          'doneWorkSeconds': 0,
          'doneSets': 0,
          'doneReps': 0,
          'doneRounds': 0,
          'doneTimedSeconds': 0,
        };
      });

      aggregate['workoutCount'] = (aggregate['workoutCount'] as int) + 1;
      aggregate['plannedDurationSeconds'] =
          (aggregate['plannedDurationSeconds'] as int) +
          _durationForWorkout(workout);
      aggregate['plannedWorkSeconds'] =
          (aggregate['plannedWorkSeconds'] as int) +
          _plannedWorkDurationForWorkout(workout);
      final int doneDurationSeconds = _doneDurationForWorkout(
        workout: workout,
        actual: actual,
      );
      final int doneWorkSeconds = _doneWorkDurationForWorkout(
        workout: workout,
        actual: actual,
      );
      aggregate['doneDurationSeconds'] =
          (aggregate['doneDurationSeconds'] as int) +
          doneDurationSeconds;
      aggregate['doneWorkSeconds'] =
          (aggregate['doneWorkSeconds'] as int) +
          doneWorkSeconds;

      if (workout is SetsConfig) {
        final int doneSets = _doneSetsForWorkout(
          workout: workout,
          actual: actual,
        );
        final int doneReps = _doneRepsForWorkout(
          workout: workout,
          actual: actual,
        );
        aggregate['plannedSets'] =
            (aggregate['plannedSets'] as int) + workout.sets;
        aggregate['plannedReps'] =
            (aggregate['plannedReps'] as int) + workout.totalReps;
        aggregate['doneSets'] = (aggregate['doneSets'] as int) + doneSets;
        aggregate['doneReps'] = (aggregate['doneReps'] as int) + doneReps;
      } else if (workout is TabataConfig) {
        final int doneRounds = _doneRoundsForWorkout(
          workout: workout,
          actual: actual,
        );
        aggregate['plannedRounds'] =
            (aggregate['plannedRounds'] as int) + workout.rounds;
        aggregate['doneRounds'] = (aggregate['doneRounds'] as int) + doneRounds;
      } else if (workout is TimedConfig) {
        final int doneTimedSeconds = _doneTimedSecondsForWorkout(
          workout: workout,
          actual: actual,
        );
        aggregate['plannedTimedSeconds'] =
            (aggregate['plannedTimedSeconds'] as int) + workout.duration;
        aggregate['doneTimedSeconds'] =
            (aggregate['doneTimedSeconds'] as int) + doneTimedSeconds;
      }
    }
    final List<Map<String, dynamic>> exerciseSummaries =
        exerciseAggregateById.values.toList()
          ..sort(
            (a, b) => (a['exerciseId'] as String).compareTo(
              b['exerciseId'] as String,
            ),
          );
    final int totalPlannedReps = exerciseSummaries.fold<int>(
      0,
      (sum, exercise) => sum + (exercise['plannedReps'] as int),
    );
    final int totalDoneReps = exerciseSummaries.fold<int>(
      0,
      (sum, exercise) => sum + (exercise['doneReps'] as int),
    );
    final int totalDoneWorkSeconds = exerciseSummaries.fold<int>(
      0,
      (sum, exercise) => sum + (exercise['doneWorkSeconds'] as int),
    );

    final int plannedWorkoutDurationSeconds = widget.session.workouts
        .fold<int>(0, (sum, workout) => sum + _durationForWorkout(workout));
    final int plannedWorkSeconds = widget.session.workouts.fold<int>(
      0,
      (sum, workout) => sum + _plannedWorkDurationForWorkout(workout),
    );
    final int exerciseCount = widget.session.exerciseCount;
    final int transitionSeconds = exerciseCount * widget.session.transitionTime;
    final int interExerciseRestSeconds = exerciseCount > 1
        ? (exerciseCount - 1) * widget.session.restBetweenExercises
        : 0;

    try {
      await ref.read(firestoreServiceProvider).saveWorkoutHistory(
        userId: userId,
        sessionId: widget.session.id,
        completedAt: completedAtUtc,
        duration: durationSeconds,
        metadata: <String, dynamic>{
          'sessionName': widget.session.name,
          'description': widget.session.description,
          'exerciseCount': exerciseCount,
          'difficulty': widget.session.difficulty.name,
          'workoutTypes': widget.session.workouts
              .map((WorkoutConfig workout) => workout.type.name)
              .toSet()
              .toList(),
          'isCustomSession': widget.session.isCustom,
          'startedAt': startedAtUtc.toIso8601String(),
          'completedAtLocal': completedAt.toIso8601String(),
          'dateKey': _dateKey(completedAt),
          'weekKey': _weekKey(completedAt),
          'monthKey': _monthKey(completedAt),
          'timezoneOffsetMinutes': completedAt.timeZoneOffset.inMinutes,
          'plannedDurationSeconds': widget.session.estimatedDuration,
          'plannedWorkoutDurationSeconds': plannedWorkoutDurationSeconds,
          'plannedWorkSeconds': plannedWorkSeconds,
          'totalPlannedReps': totalPlannedReps,
          'totalDoneReps': totalDoneReps,
          'totalDoneWorkSeconds': totalDoneWorkSeconds,
          'plannedTransitionSeconds': transitionSeconds,
          'plannedInterExerciseRestSeconds': interExerciseRestSeconds,
          'actualMetricsAvailable': _hasAnyActualMetrics,
          'calories': null,
          'heartRateAvg': null,
          'heartRateMax': null,
          'exerciseSummaries': exerciseSummaries,
          'workouts': workoutPlans,
        },
      );
      _workoutHistorySaved = true;
    } catch (_) {
      // Keep workout completion UX smooth if history write fails.
    }
  }

  String _resolveLocalizedValue(BuildContext context, String rawValue) {
    final AppLocalizations? localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return rawValue;
    }
    final String? localizedValue = ExerciseLocalizationHelper.getString(
      localizations,
      rawValue,
    );
    return localizedValue ?? rawValue;
  }

  String _exerciseName(BuildContext context, _WorkoutStep step, int index) {
    final Exercise? exercise = step.exercise;
    if (exercise == null) {
      final AppLocalizations? localizations = AppLocalizations.of(context);
      if (localizations != null) {
        return localizations.workout_unnamed_exercise(index + 1);
      }
      return 'Exercise ${index + 1}';
    }
    return _resolveLocalizedValue(context, exercise.name);
  }

  String _phaseLabel() {
    final AppLocalizations? localizations = AppLocalizations.of(context);
    switch (_phase) {
      case _WorkoutPhase.getReady:
        return localizations?.workout_phase_get_ready ?? 'Get ready';
      case _WorkoutPhase.setActive:
        final WorkoutConfig? workout = _currentWorkout;
        if (workout is SetsConfig) {
          return 'Set ${_currentSet + 1} of ${workout.sets}';
        }
        return 'Set';
      case _WorkoutPhase.setRest:
        final WorkoutConfig? workout = _currentWorkout;
        if (workout is TabataConfig) {
          return 'Set Rest · $_tabataCurrentSet/${workout.sets}';
        }
        return 'Rest';
      case _WorkoutPhase.exercise:
        final WorkoutConfig? workout = _currentWorkout;
        if (workout is TabataConfig) {
          final String phase = _tabataIsWork ? 'WORK' : 'REST';
          return '$phase · ${_tabataCurrentRound + 1}/${workout.rounds}';
        }
        return localizations?.workout_phase_exercise ?? 'Exercise';
      case _WorkoutPhase.exerciseRest:
        return 'Exercise Rest';
      case _WorkoutPhase.finished:
        return localizations?.workout_phase_finished ?? 'Workout complete';
    }
  }

  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    final String twoDigitSeconds = remainingSeconds.toString().padLeft(2, '0');
    return '$minutes:$twoDigitSeconds';
  }

  String _workoutSummary(WorkoutConfig workout) {
    if (workout is TimedConfig) {
      return 'Timed • ${_formatDuration(workout.duration)}';
    }
    if (workout is TabataConfig) {
      final String setInfo =
          workout.sets > 1 ? ' · ${workout.sets} sets' : '';
      return '${workout.rounds} rounds · ${workout.workTime}s/${workout.restTime}s$setInfo';
    }
    if (workout is SetsConfig) {
      return '${workout.sets} x ${workout.reps} reps';
    }
    return 'Workout';
  }

  List<_WorkoutStep> _buildWorkoutSteps(List<Exercise> exercises) {
    final Map<String, Exercise> exerciseById = <String, Exercise>{
      for (final Exercise exercise in exercises) exercise.id: exercise,
    };
    return widget.session.workouts
        .map(
          (WorkoutConfig workout) => _WorkoutStep(
            config: workout,
            exercise: exerciseById[workout.exerciseId],
          ),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Exercise>> exercisesAsync =
        widget.seededExercises != null
            ? AsyncValue<List<Exercise>>.data(widget.seededExercises!)
            : ref.watch(exercisesProvider);

    return exercisesAsync.when(
      data: (List<Exercise> exercises) {
        final List<_WorkoutStep> steps = _buildWorkoutSteps(exercises);

        if (steps.isEmpty) {
          return _buildStateScaffold(
            message: AppLocalizations.of(context)?.workout_state_no_exercises ??
                'No exercises in this session.',
            textColor: AppColors.textSecondary,
          );
        }

        final _WorkoutStep currentStep = steps[_currentExerciseIndex];
        final _WorkoutStep? nextStep =
            _nextWorkout == null ? null : steps[_currentExerciseIndex + 1];

        return _wrapWithTransparentSystemBars(
          Scaffold(
            backgroundColor: AppColors.electricSapphire,
            body: SafeArea(
              bottom: false,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double timerDiameter = (constraints.maxWidth * 0.68)
                      .clamp(
                        AppSizes.workoutTimerDiameter + AppSpacing.xl,
                        AppSizes.workoutTimerDiameter + (AppSpacing.xxxl * 1.6),
                      )
                      .toDouble();
                  const double timerTop = AppSpacing.xl + AppSpacing.md;
                  final double baseLowerSectionTop =
                      timerTop + (timerDiameter * 0.68);
                  final double baseLowerSectionHeight =
                      constraints.maxHeight - baseLowerSectionTop;
                  final double lowerSectionHeight =
                      (baseLowerSectionHeight * 0.75)
                          .clamp(0, constraints.maxHeight)
                          .toDouble();
                  final double lowerSectionTop =
                      constraints.maxHeight - lowerSectionHeight;

                  return Stack(
                    children: [
                      const Positioned.fill(
                        child: ColoredBox(color: AppColors.electricSapphire),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: lowerSectionTop,
                        bottom: 0,
                        child: _buildLowerGlassSection(
                          context: context,
                          currentStep: currentStep,
                          nextStep: nextStep,
                        ),
                      ),
                      Positioned(
                        top: timerTop,
                        left: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _onPrimaryActionPressed,
                          behavior: HitTestBehavior.opaque,
                          child: Center(
                            child: _buildTimer(diameter: timerDiameter),
                          ),
                        ),
                      ),
                      Positioned(
                        top: AppSpacing.sm,
                        left: AppSpacing.md,
                        child: _buildBackButton(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
      loading: () => _wrapWithTransparentSystemBars(
        const Scaffold(
          backgroundColor: AppColors.surfaceVariant,
          body: SafeArea(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
      error: (Object error, StackTrace stackTrace) => _buildStateScaffold(
        message: AppLocalizations.of(
              context,
            )?.workout_state_load_error(error.toString()) ??
            'Failed to load exercises: $error',
        textColor: AppColors.errorSoft,
      ),
    );
  }

  Widget _buildStateScaffold({
    required String message,
    required Color textColor,
  }) {
    return _wrapWithTransparentSystemBars(
      Scaffold(
        backgroundColor: AppColors.surfaceVariant,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _wrapWithTransparentSystemBars(Widget child) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _transparentSystemOverlay,
      child: child,
    );
  }

  Widget _buildBackButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: AppColors.background.withValues(alpha: 0.28),
        ),
      ),
      child: SizedBox(
        width: AppSpacing.xxxl + AppSpacing.xs,
        height: AppSpacing.xxxl - AppSpacing.xs,
        child: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.background,
          ),
        ),
      ),
    );
  }

  Widget _buildLowerGlassSection({
    required BuildContext context,
    required _WorkoutStep currentStep,
    required _WorkoutStep? nextStep,
  }) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadii.xl),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppSpacing.sm,
          sigmaY: AppSpacing.sm,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.darkAccentLight.withValues(alpha: 0.74),
            border: Border(
              top: BorderSide(
                color: AppColors.accent.withValues(alpha: 0.16),
              ),
            ),
          ),
          child: SingleChildScrollView(
            child: _buildExerciseCardsTransition(
              context: context,
              currentStep: currentStep,
              nextStep: nextStep,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseCardsTransition({
    required BuildContext context,
    required _WorkoutStep currentStep,
    required _WorkoutStep? nextStep,
  }) {
    if (_phase == _WorkoutPhase.exerciseRest) {
      return _buildRestPanelContent(
        context: context,
        currentStep: currentStep,
        nextStep: nextStep,
      );
    }
    return ClipRect(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCurrentExerciseCardTransition(
            context: context,
            currentStep: currentStep,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildNextExercisePreviewTransition(
            context: context,
            nextStep: nextStep,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentExerciseCardTransition({
    required BuildContext context,
    required _WorkoutStep currentStep,
  }) {
    final ValueKey<String> activeKey =
        ValueKey<String>('current-$_currentExerciseIndex');

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 1050),
      reverseDuration: const Duration(milliseconds: 900),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      transitionBuilder: (Widget child, Animation<double> animation) {
        final bool isIncoming = child.key == activeKey;
        return _buildExerciseCardTransition(
          child: child,
          animation: animation,
          isIncoming: isIncoming,
          incomingStartOffsetY: 0.42,
          outgoingEndOffsetY: -0.56,
          incomingStartScale: 0.88,
          incomingFadeDelay: 0.18,
          outgoingFadeStart: 0.32,
        );
      },
      child: KeyedSubtree(
        key: activeKey,
        child: _buildCurrentExerciseCard(context, currentStep),
      ),
    );
  }

  Widget _buildNextExercisePreviewTransition({
    required BuildContext context,
    required _WorkoutStep? nextStep,
  }) {
    final String nextKeyLabel = nextStep == null
        ? 'next-final-$_currentExerciseIndex'
        : 'next-${_currentExerciseIndex + 1}';
    final ValueKey<String> activeKey = ValueKey<String>(nextKeyLabel);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 1050),
      reverseDuration: const Duration(milliseconds: 900),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      transitionBuilder: (Widget child, Animation<double> animation) {
        final bool isIncoming = child.key == activeKey;
        return _buildExerciseCardTransition(
          child: child,
          animation: animation,
          isIncoming: isIncoming,
          incomingStartOffsetY: 0.56,
          outgoingEndOffsetY: -1.02,
          incomingStartScale: 0.95,
          incomingFadeDelay: 0.34,
          outgoingFadeStart: 0.24,
        );
      },
      child: KeyedSubtree(
        key: activeKey,
        child: _buildNextExercisePreview(context, nextStep),
      ),
    );
  }

  Widget _buildExerciseCardTransition({
    required Widget child,
    required Animation<double> animation,
    required bool isIncoming,
    required double incomingStartOffsetY,
    required double outgoingEndOffsetY,
    required double incomingStartScale,
    required double incomingFadeDelay,
    required double outgoingFadeStart,
  }) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (BuildContext context, Widget? transitionChild) {
        final double progress =
            isIncoming ? animation.value : 1 - animation.value;
        final double motionProgress = Curves.easeInOutCubic.transform(progress);
        final double translationY = lerpDouble(
          isIncoming ? incomingStartOffsetY : 0,
          isIncoming ? 0 : outgoingEndOffsetY,
          motionProgress,
        )!;
        final double opacity = isIncoming
            ? Curves.easeOutCubic.transform(
                _normalizeProgress(
                  value: progress,
                  start: incomingFadeDelay,
                ),
              )
            : 1 -
                Curves.easeOutCubic.transform(
                  _normalizeProgress(
                    value: progress,
                    start: outgoingFadeStart,
                  ),
                );
        final double scale = isIncoming
            ? lerpDouble(
                incomingStartScale,
                1,
                Curves.easeOutCubic.transform(progress),
              )!
            : 1;

        return Opacity(
          opacity: opacity.clamp(0, 1).toDouble(),
          child: FractionalTranslation(
            translation: Offset(0, translationY),
            child: Transform.scale(
              alignment: Alignment.topCenter,
              scale: scale,
              child: transitionChild,
            ),
          ),
        );
      },
    );
  }

  double _normalizeProgress({
    required double value,
    required double start,
  }) {
    final double normalized = ((value - start) / (1 - start)).clamp(0, 1);
    return normalized.toDouble();
  }

  Widget _buildTimer({required double diameter}) {
    if (_phase == _WorkoutPhase.finished) {
      return Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.success.withValues(alpha: 0.2),
          border: Border.all(
            color: AppColors.success,
            width: AppSpacing.xs - 2,
          ),
        ),
        child: const Icon(
          Icons.check_rounded,
          color: AppColors.success,
          size: AppSpacing.xxxl * 2,
        ),
      );
    }

    if (_phase == _WorkoutPhase.setActive) {
      return _buildSetActiveCircle(diameter: diameter);
    }

    final Color fillColor;
    if (_phase == _WorkoutPhase.setRest ||
        _phase == _WorkoutPhase.exerciseRest ||
        _phase == _WorkoutPhase.getReady) {
      fillColor = AppColors.warningSoft;
    } else if (_phase == _WorkoutPhase.exercise &&
        _currentWorkout is TabataConfig) {
      fillColor = _tabataIsWork ? AppColors.success : AppColors.errorSoft;
    } else {
      fillColor = AppColors.primaryLight;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        CircularCountDownTimer(
          key: ValueKey<String>(
            'timer-$_currentExerciseIndex-${_phase.name}'
            '-$_timerVersion',
          ),
          duration: _phaseDuration,
          initialDuration: 0,
          controller: _timerController,
          width: diameter,
          height: diameter,
          ringColor: AppColors.primaryAbyss.withValues(alpha: 0.45),
          fillColor: fillColor,
          backgroundColor: AppColors.primaryPastel.withValues(alpha: 0.48),
          strokeWidth: AppSizes.workoutTimerStroke,
          strokeCap: StrokeCap.round,
          textStyle: const TextStyle(
            color: AppColors.darkTextPrimary,
            fontSize: 42,
            fontWeight: FontWeight.w700,
            fontFamily: 'AppFontMedium',
          ),
          textFormat: CountdownTextFormat.MM_SS,
          isReverse: true,
          isReverseAnimation: true,
          isTimerTextShown: true,
          autoStart: false,
          onComplete: _onPhaseCompleted,
        ),
        IgnorePointer(
          child: SizedBox(
            width: diameter * 0.62,
            height: diameter * 0.68,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _phaseLabel(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.background,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'AppFontMedium',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    _buildTimerSeparator(),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTimerSeparator(),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      _timerHintLabel(),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: const TextStyle(
                        color: AppColors.darkTextPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (_hasStarted && !_isRunning && _phase != _WorkoutPhase.setActive)
          IgnorePointer(
            child: Container(
              width: diameter * 0.36,
              height: diameter * 0.36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryAbyss.withValues(alpha: 0.28),
                border: Border.all(
                  color: AppColors.background.withValues(alpha: 0.35),
                ),
              ),
              child: const Icon(
                Icons.pause_rounded,
                color: AppColors.background,
                size: AppSpacing.xxxl + AppSpacing.sm,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTimerSeparator() {
    return Container(
      width: AppSpacing.xxxl + AppSpacing.md,
      height: 1,
      color: AppColors.background.withValues(alpha: 0.34),
    );
  }

  String _timerHintLabel() {
    final AppLocalizations? localizations = AppLocalizations.of(context);
    if (_phase == _WorkoutPhase.setRest || _phase == _WorkoutPhase.exerciseRest) {
      return _isRunning ? 'Tap to pause' : 'Tap to resume';
    }
    return _isRunning
        ? (localizations?.workout_hint_tap_pause ?? 'Tap timer to pause')
        : (_hasStarted
            ? (localizations?.workout_hint_tap_resume ?? 'Tap timer to resume')
            : (localizations?.workout_hint_tap_start ?? 'Tap timer to start'));
  }

  Widget _buildSetActiveCircle({required double diameter}) {
    final WorkoutConfig? workout = _currentWorkout;
    final int totalSets = workout is SetsConfig ? workout.sets : 1;
    final int reps = workout is SetsConfig ? workout.reps : 0;
    final double? weight = workout is SetsConfig ? workout.weight : null;
    final String? weightUnit = workout is SetsConfig ? workout.weightUnit : null;

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryAbyss.withValues(alpha: 0.35),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.55),
          width: AppSizes.workoutTimerStroke,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'SET',
            style: TextStyle(
              color: AppColors.background.withValues(alpha: 0.75),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          Text(
            '${_currentSet + 1}',
            style: const TextStyle(
              color: AppColors.background,
              fontSize: 72,
              fontWeight: FontWeight.w800,
              fontFamily: 'AppFontMedium',
              height: 0.9,
            ),
          ),
          Text(
            'of $totalSets',
            style: TextStyle(
              color: AppColors.background.withValues(alpha: 0.7),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(
                color: AppColors.primaryLight.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              weight != null
                  ? '$reps reps · $weight${weightUnit ?? ''}'
                  : '$reps reps',
              style: const TextStyle(
                color: AppColors.background,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _formatDuration(_setStopwatch.elapsed.inSeconds),
            style: TextStyle(
              color: AppColors.background.withValues(alpha: 0.6),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: 'AppFontMedium',
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildTimerSeparator(),
          const SizedBox(height: AppSpacing.xxs),
          const Text(
            'Tap to complete set',
            style: TextStyle(
              color: AppColors.darkTextPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetDots({
    required int totalSets,
    required int completedSets,
    int? currentSetIndex,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSets, (int index) {
        final bool isDone = index < completedSets;
        final bool isCurrent =
            currentSetIndex != null && index == currentSetIndex;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isCurrent ? 14 : 10,
          height: isCurrent ? 14 : 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone
                ? AppColors.success
                : (isCurrent
                    ? AppColors.primary
                    : AppColors.primaryLight.withValues(alpha: 0.35)),
            border: isCurrent
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
        );
      }),
    );
  }

  Widget _buildRoundDots({
    required int totalRounds,
    required int completedRounds,
    required int currentRound,
    required bool isWork,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalRounds, (int index) {
        final bool isDone = index < completedRounds;
        final bool isCurrent = index == currentRound;
        Color dotColor;
        if (isDone) {
          dotColor = AppColors.success;
        } else if (isCurrent) {
          dotColor = isWork ? AppColors.success : AppColors.errorSoft;
        } else {
          dotColor = AppColors.primaryLight.withValues(alpha: 0.35);
        }
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isCurrent ? 14 : 10,
          height: isCurrent ? 14 : 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dotColor,
            border: isCurrent
                ? Border.all(
                    color: isWork ? AppColors.success : AppColors.errorSoft,
                    width: 2,
                  )
                : null,
          ),
        );
      }),
    );
  }

  Widget _buildRestPanelContent({
    required BuildContext context,
    required _WorkoutStep currentStep,
    required _WorkoutStep? nextStep,
  }) {
    final String nextName = nextStep != null
        ? _resolveLocalizedValue(
            context,
            nextStep.exercise?.name ?? 'Next exercise',
          )
        : 'Last exercise done!';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color: AppColors.warning.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_bottom_rounded,
                  color: AppColors.warning,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rest before next exercise',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'AppFontMedium',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Up next: $nextName',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            icon: const Icon(Icons.skip_next_rounded),
            label: const Text(
              'Skip Rest',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            ),
            onPressed: _skipRest,
          ),
        ),
        if (nextStep != null) ...[
          const SizedBox(height: AppSpacing.sm),
          _buildNextExercisePreviewTransition(
            context: context,
            nextStep: nextStep,
          ),
        ],
      ],
    );
  }

  Widget _buildCurrentExerciseCard(BuildContext context, _WorkoutStep step) {
    final AppLocalizations? localizations = AppLocalizations.of(context);
    final String currentLabel =
        localizations?.workout_current_label ?? 'Current';
    final _ExerciseActualMetrics? actualMetrics = _actualMetricsAt(
      _currentExerciseIndex,
    );
    final bool hasActualMetrics = actualMetrics?.hasAnyInput ?? false;
    final bool isFrench = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('fr');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                Text(
                  '$currentLabel - ${_exerciseName(context, step, _currentExerciseIndex)}',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'AppFontMedium',
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  _phase == _WorkoutPhase.setActive && step.config is SetsConfig
                      ? () {
                          final SetsConfig c = step.config as SetsConfig;
                          return 'Set ${_currentSet + 1} of ${c.sets} · ${c.reps} reps'
                              '${c.weight != null ? ' · ${c.weight}${c.weightUnit ?? ''}' : ''}';
                        }()
                      : _phase == _WorkoutPhase.setRest && step.config is SetsConfig
                          ? () {
                              final SetsConfig c = step.config as SetsConfig;
                              return 'Rest · Up next: Set ${_currentSet + 1} of ${c.sets} · ${c.reps} reps';
                            }()
                          : _workoutSummarySecondary(step.config),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.sm),
            child: SizedBox(
              width: double.infinity,
              height: AppSizes.workoutCurrentImageHeight,
              child: _buildExerciseImage(step.exercise),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Text(
              _exerciseTips(context, step.exercise),
              textAlign: TextAlign.left,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          if ((_phase == _WorkoutPhase.setActive ||
                  _phase == _WorkoutPhase.setRest) &&
              step.config is SetsConfig) ...[
            _buildSetDots(
              totalSets: (step.config as SetsConfig).sets,
              completedSets:
                  _completedSetsRepsPerExercise[_currentExerciseIndex]?.length ??
                  0,
              currentSetIndex:
                  _phase == _WorkoutPhase.setActive ? _currentSet : null,
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          if (_phase == _WorkoutPhase.exercise &&
              step.config is TabataConfig) ...[
            _buildRoundDots(
              totalRounds: (step.config as TabataConfig).rounds,
              completedRounds: _tabataCurrentRound,
              currentRound: _tabataCurrentRound,
              isWork: _tabataIsWork,
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          if (_phase == _WorkoutPhase.setActive)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.check_circle_outline_rounded, size: 22),
                label: Text(
                  isFrench ? 'Série terminée ✓' : 'Set Done ✓',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'AppFontMedium',
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm,
                  ),
                ),
                onPressed: _onSetCompleted,
              ),
            )
          else if (_phase == _WorkoutPhase.setRest)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.skip_next_rounded),
                label: Text(
                  isFrench ? 'Passer le repos' : 'Skip Rest',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                ),
                onPressed: _skipRest,
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: Icon(
                  hasActualMetrics
                      ? Icons.check_circle_rounded
                      : Icons.edit_note_rounded,
                ),
                label: Text(
                  hasActualMetrics
                      ? (isFrench ? 'Données réelles enregistrées' : 'Actuals saved')
                      : (isFrench ? 'Saisir les données réelles' : 'Log actuals'),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: hasActualMetrics
                      ? AppColors.success
                      : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.xs,
                  ),
                ),
                onPressed: () async {
                  if (_isRunning) {
                    _pauseTimer();
                  }
                  await _openActualMetricsSheet(
                    workout: step.config,
                    index: _currentExerciseIndex,
                    exerciseName: _exerciseName(
                      context,
                      step,
                      _currentExerciseIndex,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  String _exerciseTips(BuildContext context, Exercise? exercise) {
    final String rawTips = exercise?.beginnerTips?.trim() ?? '';
    if (rawTips.isNotEmpty) {
      return _resolveLocalizedValue(context, rawTips);
    }

    final String rawDescription = exercise?.description.trim() ?? '';
    if (rawDescription.isNotEmpty) {
      return _resolveLocalizedValue(context, rawDescription);
    }

    return AppLocalizations.of(context)?.workout_tips_fallback ??
        'Keep your core engaged and move with control.';
  }

  String _workoutSummarySecondary(WorkoutConfig workout) {
    if (workout is TimedConfig) {
      return 'Timed - ${_formatDurationDot(workout.duration)}s';
    }
    if (workout is TabataConfig) {
      if (_phase == _WorkoutPhase.exercise) {
        final String intervalLabel = _tabataIsWork ? 'Work' : 'Rest';
        final String setInfo = workout.sets > 1
            ? ' · Set ${_tabataCurrentSet + 1}/${workout.sets}'
            : '';
        return '$intervalLabel · Round ${_tabataCurrentRound + 1}/${workout.rounds}$setInfo';
      }
      if (_phase == _WorkoutPhase.setRest) {
        return 'Set Rest · Up next: Set ${_tabataCurrentSet + 1}/${workout.sets}';
      }
      final String setInfo =
          workout.sets > 1 ? ' · ${workout.sets} sets' : '';
      return 'Tabata · ${workout.rounds} rounds$setInfo';
    }
    if (workout is SetsConfig) {
      return 'Sets - ${_formatDurationDot(workout.estimatedTotalTime)}s';
    }
    return 'Workout';
  }

  String _formatDurationDot(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '$minutes.${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildExerciseImage(Exercise? exercise) {
    final String imageUrl = exercise?.imageTutorialUrl ?? '';
    if (imageUrl.isEmpty) {
      return const _MissingExerciseImage();
    }

    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (
          BuildContext context,
          Object error,
          StackTrace? stackTrace,
        ) {
          return const _MissingExerciseImage();
        },
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (
        BuildContext context,
        Object error,
        StackTrace? stackTrace,
      ) {
        return const _MissingExerciseImage();
      },
    );
  }

  Widget _buildNextExercisePreview(
    BuildContext context,
    _WorkoutStep? nextStep,
  ) {
    final AppLocalizations? localizations = AppLocalizations.of(context);

    if (nextStep == null) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.babyBlueIce,
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.flag_rounded,
              color: AppColors.success,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                localizations?.workout_final_exercise ??
                    'Final exercise in progress.',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.darkAccentLight,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Row(
        children: [
          SizedBox(
            width: AppSizes.workoutNextImageSize * 1.65,
            height: AppSizes.workoutNextImageSize,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.sm),
              child: _buildExerciseImage(nextStep.exercise),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Container(
            width: 1,
            height: AppSizes.workoutNextImageSize - AppSpacing.xs,
            color: AppColors.darkPrimaryDarker.withValues(alpha: 0.32),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations?.workout_next_label ?? 'Next exercise',
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  _exerciseName(
                    context,
                    nextStep,
                    _currentExerciseIndex + 1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.darkPrimaryDarker,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'AppFontMedium',
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  _workoutSummary(nextStep.config),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.darkPrimaryDarker,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActualInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;

  const _ActualInputField({
    required this.controller,
    required this.label,
    required this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        isDense: true,
      ),
    );
  }
}

class _ExerciseActualMetrics {
  final int? doneSets;
  final int? doneReps;
  final double? doneWeight;
  final String? doneWeightUnit;
  final int? doneRounds;
  final int? doneTimedSeconds;
  final int? doneDurationSeconds;
  final int? doneWorkSeconds;

  const _ExerciseActualMetrics({
    this.doneSets,
    this.doneReps,
    this.doneWeight,
    this.doneWeightUnit,
    this.doneRounds,
    this.doneTimedSeconds,
    this.doneDurationSeconds,
    this.doneWorkSeconds,
  });

  bool get hasAnyInput {
    return doneSets != null ||
        doneReps != null ||
        doneWeight != null ||
        (doneWeightUnit?.trim().isNotEmpty ?? false) ||
        doneRounds != null ||
        doneTimedSeconds != null ||
        doneDurationSeconds != null ||
        doneWorkSeconds != null;
  }
}

class _WorkoutStep {
  final WorkoutConfig config;
  final Exercise? exercise;

  const _WorkoutStep({
    required this.config,
    required this.exercise,
  });
}

class _MissingExerciseImage extends StatelessWidget {
  const _MissingExerciseImage();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.surfaceVariant,
      child: Center(
        child: Icon(
          Icons.fitness_center_rounded,
          size: 44,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}
