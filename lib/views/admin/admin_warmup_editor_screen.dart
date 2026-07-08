import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/core/utils/content_moderation.dart';
import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/warmup_routine.dart';
import 'package:workin_fit/models/workout_config.dart';
import 'package:workin_fit/providers/admin_providers.dart';
import 'package:workin_fit/views/admin/widgets/admin_guard.dart';

/// Create or edit an admin-authored warmup routine. A routine is keyed by
/// (category, duration); saving overrides the built-in routine for that key for
/// all users (see `warmupRoutineProvider`).
class AdminWarmupEditorScreen extends ConsumerStatefulWidget {
  const AdminWarmupEditorScreen({this.existing, super.key});

  final WarmupRoutine? existing;

  static Route<void> route({WarmupRoutine? existing}) => MaterialPageRoute<void>(
        builder: (_) => AdminWarmupEditorScreen(existing: existing),
      );

  @override
  ConsumerState<AdminWarmupEditorScreen> createState() =>
      _AdminWarmupEditorScreenState();
}

class _StepDraft {
  _StepDraft({String name = '', int seconds = 30, String description = ''})
      : nameController = TextEditingController(text: name),
        secondsController = TextEditingController(text: seconds.toString()),
        descriptionController = TextEditingController(text: description);

  final TextEditingController nameController;
  final TextEditingController secondsController;
  final TextEditingController descriptionController;

  void dispose() {
    nameController.dispose();
    secondsController.dispose();
    descriptionController.dispose();
  }
}

class _AdminWarmupEditorScreenState
    extends ConsumerState<AdminWarmupEditorScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  static const List<int> _durations = <int>[2, 5, 10];

  late WarmupCategory _category;
  late int _duration;
  final List<_StepDraft> _steps = <_StepDraft>[];
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final WarmupRoutine? r = widget.existing;
    _category = r?.category ?? WarmupCategory.fullBody;
    _duration = r?.durationMinutes ?? 5;
    if (r != null && r.workoutConfigs.isNotEmpty) {
      final Map<String, Exercise> byId = <String, Exercise>{
        for (final Exercise e in r.exercises) e.id: e,
      };
      for (final TimedConfig c in r.workoutConfigs) {
        final Exercise? ex = byId[c.exerciseId];
        _steps.add(
          _StepDraft(
            name: ex?.name ?? c.exerciseId,
            seconds: c.duration,
            description: ex?.description ?? '',
          ),
        );
      }
    } else {
      _steps.add(_StepDraft());
    }
  }

  @override
  void dispose() {
    for (final _StepDraft s in _steps) {
      s.dispose();
    }
    super.dispose();
  }

  String _slug(String name) => name
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one step.')),
      );
      return;
    }

    setState(() => _saving = true);

    final List<TimedConfig> configs = <TimedConfig>[];
    final List<Exercise> exercises = <Exercise>[];
    for (int i = 0; i < _steps.length; i++) {
      final _StepDraft s = _steps[i];
      final String name = s.nameController.text.trim();
      final int seconds = int.tryParse(s.secondsController.text.trim()) ?? 30;
      final String slug = _slug(name);
      final String exerciseId = 'warmup_${slug.isEmpty ? 'step' : slug}_$i';
      configs.add(TimedConfig(exerciseId: exerciseId, duration: seconds));
      exercises.add(
        Exercise(
          id: exerciseId,
          name: name,
          description: s.descriptionController.text.trim(),
          imageMuscleUrl: '',
          imageTutorialUrl: '',
          muscleGroups: const <MuscleGroup>[MuscleGroup.cardio],
          difficulty: DifficultyLevel.beginner,
        ),
      );
    }

    final WarmupRoutine routine = WarmupRoutine(
      category: _category,
      durationMinutes: _duration,
      workoutConfigs: configs,
      exercises: exercises,
    );

    try {
      await ref.read(adminActionsProvider).saveWarmup(routine);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Warmup updated' : 'Warmup created')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: Text(_isEditing ? 'Edit warmup' : 'New warmup'),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: <Widget>[
                _label(context, 'Category'),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: WarmupCategory.values.map((WarmupCategory c) {
                    final bool sel = c == _category;
                    return ChoiceChip(
                      label: Text(c.name),
                      selected: sel,
                      onSelected: (_) => setState(() => _category = c),
                      backgroundColor: AppColors.surface,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: sel ? Colors.white : AppColors.textSecondary,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
                _label(context, 'Duration (minutes)'),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  children: _durations.map((int d) {
                    final bool sel = d == _duration;
                    return ChoiceChip(
                      label: Text('$d'),
                      selected: sel,
                      onSelected: (_) => setState(() => _duration = d),
                      backgroundColor: AppColors.surface,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: sel ? Colors.white : AppColors.textSecondary,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Overrides the built-in “${_category.name} / $_duration min” '
                  'routine for everyone.',
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _label(context, 'Steps'),
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => _steps.add(_StepDraft())),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add step'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                ..._steps.asMap().entries.map((MapEntry<int, _StepDraft> e) {
                  return _StepCard(
                    index: e.key,
                    step: e.value,
                    onRemove: _steps.length > 1
                        ? () => setState(() => _steps.removeAt(e.key).dispose())
                        : null,
                  );
                }),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                      ),
                    ),
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_isEditing ? 'Save changes' : 'Create warmup'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) => Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
      );
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.index,
    required this.step,
    required this.onRemove,
  });

  final int index;
  final _StepDraft step;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  controller: step.nameController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _dec('Step ${index + 1} name'),
                  validator: (String? v) => (v == null || v.trim().isEmpty)
                      ? 'Name required'
                      : ContentModeration.validate(v),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              SizedBox(
                width: 88,
                child: TextFormField(
                  controller: step.secondsController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _dec('Secs'),
                  validator: (String? v) =>
                      (int.tryParse(v?.trim() ?? '') ?? 0) <= 0 ? '>0' : null,
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.remove_circle_outline_rounded),
                color: onRemove == null
                    ? AppColors.textTertiary
                    : AppColors.error,
                tooltip: 'Remove step',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          TextFormField(
            controller: step.descriptionController,
            maxLines: 2,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: _dec('Description (optional)'),
            validator: ContentModeration.validate,
          ),
        ],
      ),
    );
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        isDense: true,
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: BorderSide.none,
        ),
      );
}
