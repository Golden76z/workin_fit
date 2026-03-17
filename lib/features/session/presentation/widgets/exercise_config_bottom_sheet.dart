import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
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

  const ExerciseConfigBottomSheet({
    required this.exercise,
    super.key,
    this.initialConfig,
  });

  static Future<WorkoutConfig?> show(
    BuildContext context, {
    required Exercise exercise,
    WorkoutConfig? initialConfig,
  }) {
    return showModalBottomSheet<WorkoutConfig>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExerciseConfigBottomSheet(
        exercise: exercise,
        initialConfig: initialConfig,
      ),
    );
  }

  @override
  State<ExerciseConfigBottomSheet> createState() =>
      _ExerciseConfigBottomSheetState();
}

class _ExerciseConfigBottomSheetState extends State<ExerciseConfigBottomSheet> {
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
      _sets = cfg.sets;
      _reps = cfg.reps;
      _restBetweenSets = cfg.restBetweenSets;
    } else if (cfg is TabataConfig) {
      _type = WorkoutType.tabata;
      _workTime = cfg.workTime;
      _tabataRestTime = cfg.restTime;
      _rounds = cfg.rounds;
      _tabataSets = cfg.sets;
      _restBetweenTabataSets = cfg.restBetweenSets;
    } else if (cfg is TimedConfig) {
      _type = WorkoutType.timed;
      _duration = cfg.duration;
    } else {
      _type = WorkoutType.sets;
    }

    // Defaults if no initial config
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
          sets: _sets,
          reps: _reps,
          restBetweenSets: _restBetweenSets,
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
    }
  }

  String _formatSeconds(int s) {
    if (s < 60) return '${s}s';
    final m = s ~/ 60;
    final rem = s % 60;
    return rem == 0 ? '${m}m' : '${m}m ${rem}s';
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final exerciseName = widget.exercise.getLocalizedName(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Exercise name
          Text(
            exerciseName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'AppFontMedium',
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Workout type selector
          Row(
            children: WorkoutType.values.map((t) {
              final selected = _type == t;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: GestureDetector(
                    onTap: () => setState(() => _type = t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : AppColors.primaryPastel.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.primaryLight.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _typeLabel(t),
                          style: TextStyle(
                            color:
                                selected ? Colors.white : AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Config fields
          if (_type == WorkoutType.sets) ...[
            _StepperRow(
              label: 'Sets',
              value: _sets,
              min: 1,
              max: 20,
              onChanged: (v) => setState(() => _sets = v),
            ),
            const SizedBox(height: AppSpacing.sm),
            _StepperRow(
              label: 'Reps',
              value: _reps,
              min: 1,
              max: 100,
              onChanged: (v) => setState(() => _reps = v),
            ),
            const SizedBox(height: AppSpacing.sm),
            _SliderRow(
              label: 'Rest between sets',
              value: _restBetweenSets,
              min: 10,
              max: 300,
              step: 5,
              display: _formatSeconds(_restBetweenSets),
              onChanged: (v) => setState(() => _restBetweenSets = v),
            ),
          ] else if (_type == WorkoutType.tabata) ...[
            _SliderRow(
              label: 'Work time',
              value: _workTime,
              min: 5,
              max: 60,
              step: 5,
              display: _formatSeconds(_workTime),
              onChanged: (v) => setState(() => _workTime = v),
            ),
            const SizedBox(height: AppSpacing.sm),
            _SliderRow(
              label: 'Rest time',
              value: _tabataRestTime,
              min: 5,
              max: 60,
              step: 5,
              display: _formatSeconds(_tabataRestTime),
              onChanged: (v) => setState(() => _tabataRestTime = v),
            ),
            const SizedBox(height: AppSpacing.sm),
            _StepperRow(
              label: 'Rounds',
              value: _rounds,
              min: 1,
              max: 20,
              onChanged: (v) => setState(() => _rounds = v),
            ),
            const SizedBox(height: AppSpacing.sm),
            _StepperRow(
              label: 'Sets',
              value: _tabataSets,
              min: 1,
              max: 10,
              onChanged: (v) => setState(() => _tabataSets = v),
            ),
            if (_tabataSets > 1) ...[
              const SizedBox(height: AppSpacing.sm),
              _SliderRow(
                label: 'Rest between sets',
                value: _restBetweenTabataSets,
                min: 10,
                max: 300,
                step: 5,
                display: _formatSeconds(_restBetweenTabataSets),
                onChanged: (v) => setState(() => _restBetweenTabataSets = v),
              ),
            ],
          ] else ...[
            _SliderRow(
              label: 'Duration',
              value: _duration,
              min: 5,
              max: 600,
              step: 5,
              display: _formatSeconds(_duration),
              onChanged: (v) => setState(() => _duration = v),
            ),
          ],

          const SizedBox(height: AppSpacing.lg),

          // Summary line
          Center(
            child: Text(
              _summaryText(),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Confirm button
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
              onPressed: () => Navigator.of(context).pop(_buildConfig()),
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
    );
  }

  String _typeLabel(WorkoutType t) {
    switch (t) {
      case WorkoutType.sets:
        return 'Sets';
      case WorkoutType.tabata:
        return 'Tabata';
      case WorkoutType.timed:
        return 'Timed';
    }
  }

  String _summaryText() {
    switch (_type) {
      case WorkoutType.sets:
        return '$_sets sets × $_reps reps · rest ${_formatSeconds(_restBetweenSets)}';
      case WorkoutType.tabata:
        final totalSeconds =
            (_workTime + _tabataRestTime) * _rounds * _tabataSets;
        return '$_rounds rounds · ${_formatSeconds(_workTime)} work / ${_formatSeconds(_tabataRestTime)} rest · ~${_formatSeconds(totalSeconds)}';
      case WorkoutType.timed:
        return 'Hold for ${_formatSeconds(_duration)}';
    }
  }
}

// ---------------------------------------------------------------------------
// Helper widgets
// ---------------------------------------------------------------------------

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
      children: [
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
          width: 44,
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
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primaryPastel.withValues(alpha: 0.5)
              : AppColors.primaryPastel.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled
              ? AppColors.primary
              : AppColors.textSecondary.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

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
      children: [
        Row(
          children: [
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
            Text(
              display,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.primaryPastel.withValues(alpha: 0.4),
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.15),
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
