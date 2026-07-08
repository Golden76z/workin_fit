import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/core/utils/content_moderation.dart';
import 'package:workin_fit/models/daily_challenge.dart';
import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/providers/admin_providers.dart';
import 'package:workin_fit/views/admin/widgets/admin_guard.dart';

/// Create or edit a single daily challenge, written to the `daily_challenges`
/// collection. Authored challenges take over from the static catalog on the
/// home screen (see `todaysChallengesProvider`).
class AdminDailyChallengeEditorScreen extends ConsumerStatefulWidget {
  const AdminDailyChallengeEditorScreen({this.existing, super.key});

  final DailyChallenge? existing;

  static Route<void> route({DailyChallenge? existing}) =>
      MaterialPageRoute<void>(
        builder: (_) => AdminDailyChallengeEditorScreen(existing: existing),
      );

  @override
  ConsumerState<AdminDailyChallengeEditorScreen> createState() =>
      _AdminDailyChallengeEditorScreenState();
}

class _AdminDailyChallengeEditorScreenState
    extends ConsumerState<AdminDailyChallengeEditorScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _target;
  late final TextEditingController _reward;
  late final TextEditingController _linkedId; // exerciseId or sessionId

  late DailyChallengeType _type;
  late DifficultyLevel _difficulty;
  late String _unit;
  bool _saving = false;

  /// Known units plus any custom unit carried by the challenge being edited.
  final List<String> _units = <String>['reps', 'seconds', 'sessions'];

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final DailyChallenge? c = widget.existing;
    _title = TextEditingController(text: c?.title ?? '');
    _description = TextEditingController(text: c?.description ?? '');
    _target = TextEditingController(text: c?.target.toString() ?? '');
    _reward = TextEditingController(text: (c?.rewardPoints ?? 10).toString());
    _type = c?.type ?? DailyChallengeType.exercise;
    _difficulty = c?.difficulty ?? DifficultyLevel.beginner;
    _unit = c?.unit ?? 'reps';
    if (!_units.contains(_unit)) _units.add(_unit);
    _linkedId = TextEditingController(
      text: c?.exerciseId ?? c?.sessionId ?? '',
    );
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _target.dispose();
    _reward.dispose();
    _linkedId.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final String linked = _linkedId.text.trim();
    final String id = widget.existing?.id ??
        'dc_custom_${const Uuid().v4().substring(0, 6)}';

    final DailyChallenge challenge = DailyChallenge(
      id: id,
      title: _title.text.trim(),
      description: _description.text.trim(),
      type: _type,
      difficulty: _difficulty,
      target: int.tryParse(_target.text.trim()) ?? 0,
      unit: _unit,
      exerciseId:
          _type == DailyChallengeType.session || linked.isEmpty ? null : linked,
      sessionId:
          _type == DailyChallengeType.session && linked.isNotEmpty
              ? linked
              : null,
      rewardPoints: int.tryParse(_reward.text.trim()) ?? 10,
    );

    try {
      await ref.read(adminActionsProvider).saveDailyChallenge(challenge);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Challenge updated' : 'Challenge created')),
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
    final bool linksSession = _type == DailyChallengeType.session;
    return AdminGuard(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: Text(_isEditing ? 'Edit challenge' : 'New challenge'),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: <Widget>[
                _field(
                  controller: _title,
                  label: 'Title',
                  validator: (String? v) => (v == null || v.trim().isEmpty)
                      ? 'Title is required'
                      : ContentModeration.validate(v),
                ),
                const SizedBox(height: AppSpacing.md),
                _field(
                  controller: _description,
                  label: 'Description',
                  maxLines: 2,
                  validator: (String? v) => (v == null || v.trim().isEmpty)
                      ? 'Description is required'
                      : ContentModeration.validate(v),
                ),
                const SizedBox(height: AppSpacing.lg),
                _labelText(context, 'Type'),
                const SizedBox(height: AppSpacing.xs),
                _chips<DailyChallengeType>(
                  values: DailyChallengeType.values,
                  selected: _type,
                  labelOf: (DailyChallengeType t) => t.name,
                  onSelected: (DailyChallengeType t) => setState(() => _type = t),
                ),
                const SizedBox(height: AppSpacing.lg),
                _labelText(context, 'Difficulty'),
                const SizedBox(height: AppSpacing.xs),
                _chips<DifficultyLevel>(
                  values: DifficultyLevel.values,
                  selected: _difficulty,
                  labelOf: (DifficultyLevel d) => d.name,
                  onSelected: (DifficultyLevel d) =>
                      setState(() => _difficulty = d),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _field(
                        controller: _target,
                        label: 'Target',
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (String? v) =>
                            (int.tryParse(v?.trim() ?? '') ?? 0) <= 0
                                ? 'Enter a target'
                                : null,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _field(
                        controller: _reward,
                        label: 'Reward pts',
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _labelText(context, 'Unit'),
                const SizedBox(height: AppSpacing.xs),
                _chips<String>(
                  values: _units,
                  selected: _unit,
                  labelOf: (String u) => u,
                  onSelected: (String u) => setState(() => _unit = u),
                ),
                const SizedBox(height: AppSpacing.md),
                _field(
                  controller: _linkedId,
                  label: linksSession
                      ? 'Session ID (optional)'
                      : 'Exercise ID (optional)',
                ),
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
                        : Text(_isEditing ? 'Save changes' : 'Create challenge'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _labelText(BuildContext context, String text) => Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
      );

  Widget _chips<T>({
    required List<T> values,
    required T selected,
    required String Function(T) labelOf,
    required ValueChanged<T> onSelected,
  }) {
    return Wrap(
      spacing: AppSpacing.xs,
      children: values.map((T v) {
        final bool isSel = v == selected;
        return ChoiceChip(
          label: Text(labelOf(v)),
          selected: isSel,
          onSelected: (_) => onSelected(v),
          backgroundColor: AppColors.surface,
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(
            color: isSel ? Colors.white : AppColors.textSecondary,
          ),
        );
      }).toList(),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
