import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/app_opacity.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/exercise_localization.dart';
import 'package:workin_fit/models/workout_config.dart';

/// Bottom sheet for configuring a single exercise (sets, tabata, or timed).
/// Returns a [WorkoutConfig] via [Navigator.pop], or null if dismissed.
class ExerciseConfigBottomSheet extends StatefulWidget {
  final Exercise exercise;
  final WorkoutConfig? initialConfig;
  /// When true, the exercise is inside a circuit — no sets, no rest.
  /// Only reps or timed duration are relevant.
  final bool isCircuitExercise;

  const ExerciseConfigBottomSheet({
    required this.exercise,
    super.key,
    this.initialConfig,
    this.isCircuitExercise = false,
  });

  static Future<WorkoutConfig?> show(
    BuildContext context, {
    required Exercise exercise,
    WorkoutConfig? initialConfig,
    bool isCircuitExercise = false,
  }) {
    return showModalBottomSheet<WorkoutConfig>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExerciseConfigBottomSheet(
        exercise: exercise,
        initialConfig: initialConfig,
        isCircuitExercise: isCircuitExercise,
      ),
    );
  }

  @override
  State<ExerciseConfigBottomSheet> createState() =>
      _ExerciseConfigBottomSheetState();
}

class _ExerciseConfigBottomSheetState
    extends State<ExerciseConfigBottomSheet> {
  late WorkoutType _type;

  // Sets fields
  late int _sets;
  late int _reps;
  late int _restBetweenSets; // seconds

  // Tabata fields
  late int _workTime; // seconds
  late int _tabataRestTime; // seconds
  late int _rounds;
  late int _tabataSets;
  late int _restBetweenTabataSets; // seconds

  // Timed fields
  late int _duration; // seconds

  @override
  void initState() {
    super.initState();
    final cfg = widget.initialConfig;
    if (cfg is SetsConfig) {
      _type = WorkoutType.sets;
    } else if (cfg is TabataConfig) {
      // Tabata not available in circuits — fall back to sets (reps).
      _type = widget.isCircuitExercise ? WorkoutType.sets : WorkoutType.tabata;
    } else if (cfg is TimedConfig) {
      _type = WorkoutType.timed;
    } else {
      _type = WorkoutType.sets;
    }

    _sets = (cfg is SetsConfig) ? cfg.sets : 3;
    _reps = (cfg is SetsConfig) ? cfg.reps : 10;
    _restBetweenSets = (cfg is SetsConfig) ? cfg.restBetweenSets : 60;
    _workTime = (cfg is TabataConfig) ? cfg.workTime : 20;
    _tabataRestTime = (cfg is TabataConfig) ? cfg.restTime : 10;
    _rounds = (cfg is TabataConfig) ? cfg.rounds : 8;
    _tabataSets = (cfg is TabataConfig) ? cfg.sets : 1;
    _restBetweenTabataSets = (cfg is TabataConfig) ? cfg.restBetweenSets : 60;
    _duration = (cfg is TimedConfig) ? cfg.duration : 60;
  }

  WorkoutConfig _buildConfig() {
    switch (_type) {
      case WorkoutType.sets:
        return SetsConfig(
          exerciseId: widget.exercise.id,
          sets: widget.isCircuitExercise ? 1 : _sets,
          reps: _reps,
          restBetweenSets: widget.isCircuitExercise ? 0 : _restBetweenSets,
        );
      case WorkoutType.tabata:
        return TabataConfig(
          exerciseId: widget.exercise.id,
          workTime: _workTime,
          restTime: _tabataRestTime,
          rounds: _rounds,
          sets: _tabataSets,
          restBetweenSets: _restBetweenTabataSets,
        );
      case WorkoutType.timed:
        return TimedConfig(
          exerciseId: widget.exercise.id,
          duration: _duration,
        );
      case WorkoutType.circuit:
        // Circuit is built in the session builder, not here.
        return TimedConfig(exerciseId: widget.exercise.id, duration: _duration);
    }
  }

  String _formatSeconds(int s) {
    if (s < 60) return '${s}s';
    final m = s ~/ 60;
    final rem = s % 60;
    return rem == 0 ? '${m}m' : '${m}m ${rem}s';
  }

  String _typeLabel(WorkoutType t) {
    switch (t) {
      case WorkoutType.sets:
        // In circuit context there are no sets — just reps.
        return widget.isCircuitExercise ? 'Reps' : 'Sets';
      case WorkoutType.tabata:
        return 'Tabata';
      case WorkoutType.timed:
        return 'Timed';
      case WorkoutType.circuit:
        return 'Circuit';
    }
  }

  String _summaryText() {
    switch (_type) {
      case WorkoutType.sets:
        if (widget.isCircuitExercise) return '$_reps reps';
        return '$_sets sets × $_reps reps · rest ${_formatSeconds(_restBetweenSets)}';
      case WorkoutType.tabata:
        final totalSeconds =
            (_workTime + _tabataRestTime) * _rounds * _tabataSets;
        return '$_rounds rounds · ${_formatSeconds(_workTime)} work / ${_formatSeconds(_tabataRestTime)} rest · ~${_formatSeconds(totalSeconds)}';
      case WorkoutType.timed:
        return 'Hold for ${_formatSeconds(_duration)}';
      case WorkoutType.circuit:
        return 'Hold for ${_formatSeconds(_duration)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final systemBarPadding = MediaQuery.paddingOf(context).bottom;
    final exerciseName = widget.exercise.getLocalizedName(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // ── Gradient header ──────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[AppColors.primaryDarker, AppColors.primary],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Column(
              children: <Widget>[
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: AppOpacity.medium),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Exercise name + type badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        exerciseName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'AppFontMedium',
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: AppOpacity.soft),
                        borderRadius: BorderRadius.circular(AppRadii.xl),
                      ),
                      child: Text(
                        _typeLabel(_type),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Content ──────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md + keyboardInset + systemBarPadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // ── Type selector ──────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: AppOpacity.faint),
                    borderRadius: BorderRadius.circular(AppRadii.md + 4),
                  ),
                  child: Row(
                    children: WorkoutType.values
                        .where((t) {
                          if (t == WorkoutType.circuit) return false;
                          if (widget.isCircuitExercise && t == WorkoutType.tabata) return false;
                          return true;
                        })
                        .map((t) {
                      final selected = _type == t;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _type = t);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.surface
                                  : Colors.transparent,
                              borderRadius:
                                  BorderRadius.circular(AppRadii.md),
                              boxShadow: selected
                                  ? <BoxShadow>[
                                      BoxShadow(
                                        color: AppColors.primary
                                            .withValues(alpha: AppOpacity.light),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                _typeLabel(t),
                                style: TextStyle(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.textSecondary
                                          .withValues(alpha: AppOpacity.prominent),
                                  fontSize: 13,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // ── Config fields card ────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    border: Border.all(
                      color:
                          AppColors.babyBlueIce.withValues(alpha: AppOpacity.half),
                    ),
                  ),
                  child: Column(
                    children: _buildFields(),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // ── Summary ────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: AppOpacity.faint),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Center(
                    child: Text(
                      _summaryText(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // ── Confirm button ────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                      ),
                    ),
                    onPressed: () =>
                        Navigator.of(context).pop(_buildConfig()),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFields() {
    switch (_type) {
      case WorkoutType.sets:
        // Circuit: one pass only — just pick reps, no sets or rest.
        if (widget.isCircuitExercise) {
          return [
            _FieldRow(
              isLast: true,
              child: _StepperRow(
                label: 'Reps',
                value: _reps,
                min: 1,
                max: 100,
                onChanged: (v) => setState(() => _reps = v),
              ),
            ),
          ];
        }
        return [
          _FieldRow(
            child: _StepperRow(
              label: 'Sets',
              value: _sets,
              min: 1,
              max: 20,
              onChanged: (v) => setState(() => _sets = v),
            ),
          ),
          _FieldDivider(),
          _FieldRow(
            child: _StepperRow(
              label: 'Reps',
              value: _reps,
              min: 1,
              max: 100,
              onChanged: (v) => setState(() => _reps = v),
            ),
          ),
          _FieldDivider(),
          _FieldRow(
            isLast: true,
            child: _SliderRow(
              label: 'Rest between sets',
              value: _restBetweenSets,
              min: 10,
              max: 300,
              step: 5,
              display: _formatSeconds(_restBetweenSets),
              onChanged: (v) => setState(() => _restBetweenSets = v),
            ),
          ),
        ];
      case WorkoutType.tabata:
        final extras = _tabataSets > 1
            ? <Widget>[
                _FieldDivider(),
                _FieldRow(
                  isLast: true,
                  child: _SliderRow(
                    label: 'Rest between sets',
                    value: _restBetweenTabataSets,
                    min: 10,
                    max: 300,
                    step: 5,
                    display: _formatSeconds(_restBetweenTabataSets),
                    onChanged: (v) =>
                        setState(() => _restBetweenTabataSets = v),
                  ),
                ),
              ]
            : <Widget>[const SizedBox.shrink()];
        return [
          _FieldRow(
            child: _SliderRow(
              label: 'Work time',
              value: _workTime,
              min: 5,
              max: 60,
              step: 5,
              display: _formatSeconds(_workTime),
              onChanged: (v) => setState(() => _workTime = v),
            ),
          ),
          _FieldDivider(),
          _FieldRow(
            child: _SliderRow(
              label: 'Rest time',
              value: _tabataRestTime,
              min: 5,
              max: 60,
              step: 5,
              display: _formatSeconds(_tabataRestTime),
              onChanged: (v) => setState(() => _tabataRestTime = v),
            ),
          ),
          _FieldDivider(),
          _FieldRow(
            child: _StepperRow(
              label: 'Rounds',
              value: _rounds,
              min: 1,
              max: 20,
              onChanged: (v) => setState(() => _rounds = v),
            ),
          ),
          _FieldDivider(),
          _FieldRow(
            isLast: _tabataSets <= 1,
            child: _StepperRow(
              label: 'Sets',
              value: _tabataSets,
              min: 1,
              max: 10,
              onChanged: (v) => setState(() => _tabataSets = v),
            ),
          ),
          ...extras,
        ];
      case WorkoutType.timed:
        return [
          _FieldRow(
            isLast: true,
            child: _SliderRow(
              label: 'Duration',
              value: _duration,
              min: 5,
              max: 600,
              step: 5,
              display: _formatSeconds(_duration),
              onChanged: (v) => setState(() => _duration = v),
            ),
          ),
        ];
      case WorkoutType.circuit:
        return [];
    }
  }
}

// ─── Field layout helpers ──────────────────────────────────────────────────────

class _FieldRow extends StatelessWidget {
  final Widget child;
  final bool isLast;

  const _FieldRow({required this.child, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: child,
    );
  }
}

class _FieldDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: AppSpacing.md,
      endIndent: AppSpacing.md,
      color: AppColors.babyBlueIce.withValues(alpha: AppOpacity.medium),
    );
  }
}

// ─── Stepper row ───────────────────────────────────────────────────────────────

class _StepperRow extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _StepperRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _StepButton(
          icon: Icons.remove_rounded,
          enabled: value > min,
          onTap: () => onChanged(value - 1),
        ),
        SizedBox(
          width: 48,
          child: Center(
            child: Text(
              '$value',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        _StepButton(
          icon: Icons.add_rounded,
          enabled: value < max,
          onTap: () => onChanged(value + 1),
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _StepButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled
          ? () {
              HapticFeedback.selectionClick();
              onTap();
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary
              : AppColors.primaryPastel.withValues(alpha: AppOpacity.light),
          borderRadius: BorderRadius.circular(AppRadii.md),
          boxShadow: enabled
              ? <BoxShadow>[
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: AppOpacity.light),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled
              ? Colors.white
              : AppColors.textSecondary.withValues(alpha: AppOpacity.firm),
        ),
      ),
    );
  }
}

// ─── Slider row ────────────────────────────────────────────────────────────────

class _SliderRow extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final String display;
  final ValueChanged<int> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.display,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: AppOpacity.faint),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Text(
                display,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor:
                AppColors.primaryPastel.withValues(alpha: AppOpacity.firm),
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: AppOpacity.light),
            trackHeight: 3,
          ),
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: (max - min) ~/ step,
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
      ],
    );
  }
}
