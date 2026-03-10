import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'dart:ui';

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
  exercise,
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
      case _WorkoutPhase.exercise:
        final WorkoutConfig? workout = _currentWorkout;
        if (workout == null) {
          return 0;
        }
        return _durationForWorkout(workout);
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
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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

  void _onPrimaryActionPressed() {
    if (_phase == _WorkoutPhase.finished) {
      Navigator.of(context).maybePop();
      return;
    }

    if (!_hasStarted) {
      setState(() {
        _hasStarted = true;
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

    if (_phase == _WorkoutPhase.getReady) {
      setState(() {
        _phase = _WorkoutPhase.exercise;
      });
      _startCurrentPhase();
      return;
    }

    if (_currentExerciseIndex + 1 >= _totalExercises) {
      setState(() {
        _phase = _WorkoutPhase.finished;
        _isRunning = false;
      });
      return;
    }

    setState(() {
      _currentExerciseIndex += 1;
      _phase = _WorkoutPhase.getReady;
    });
    _startCurrentPhase();
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
      case _WorkoutPhase.exercise:
        return localizations?.workout_phase_exercise ?? 'Exercise';
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
      return '${workout.rounds} rounds • ${workout.workTime}s / '
          '${workout.restTime}s';
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
          fillColor: _phase == _WorkoutPhase.getReady
              ? AppColors.warningSoft
              : AppColors.primaryLight,
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
        if (_hasStarted && !_isRunning)
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
    return _isRunning
        ? (localizations?.workout_hint_tap_pause ?? 'Tap timer to pause')
        : (_hasStarted
            ? (localizations?.workout_hint_tap_resume ?? 'Tap timer to resume')
            : (localizations?.workout_hint_tap_start ?? 'Tap timer to start'));
  }

  Widget _buildCurrentExerciseCard(BuildContext context, _WorkoutStep step) {
    final AppLocalizations? localizations = AppLocalizations.of(context);
    final String currentLabel =
        localizations?.workout_current_label ?? 'Current';

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
                  _workoutSummarySecondary(step.config),
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
      return 'Tabata - ${_formatDurationDot(workout.totalDuration)}s';
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
