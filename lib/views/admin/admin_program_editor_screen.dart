import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/core/utils/content_moderation.dart';
import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/models/program.dart';
import 'package:workin_fit/providers/admin_providers.dart';
import 'package:workin_fit/views/admin/widgets/admin_guard.dart';

/// Minimal admin editor for preset programs. Writes to the top-level `programs`
/// collection. Session selection is entered as a comma-separated list of
/// session ids for now (a richer picker can build on this).
class AdminProgramEditorScreen extends ConsumerStatefulWidget {
  const AdminProgramEditorScreen({this.existing, super.key});

  /// When non-null the form edits this program; otherwise it creates a new one.
  final Program? existing;

  static Route<void> route({Program? existing}) => MaterialPageRoute<void>(
        builder: (_) => AdminProgramEditorScreen(existing: existing),
      );

  @override
  ConsumerState<AdminProgramEditorScreen> createState() =>
      _AdminProgramEditorScreenState();
}

class _AdminProgramEditorScreenState
    extends ConsumerState<AdminProgramEditorScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _goals;
  late final TextEditingController _sessionIds;
  late final TextEditingController _durationWeeks;
  late final TextEditingController _daysPerWeek;

  late DifficultyLevel _difficulty;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final Program? p = widget.existing;
    _name = TextEditingController(text: p?.name ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _goals = TextEditingController(text: (p?.goals ?? const <String>[]).join(', '));
    _sessionIds =
        TextEditingController(text: (p?.sessionIds ?? const <String>[]).join(', '));
    _durationWeeks =
        TextEditingController(text: '${p?.durationWeeks ?? 4}');
    _daysPerWeek = TextEditingController(text: '${p?.daysPerWeek ?? 3}');
    _difficulty = p?.difficulty ?? DifficultyLevel.beginner;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _goals.dispose();
    _sessionIds.dispose();
    _durationWeeks.dispose();
    _daysPerWeek.dispose();
    super.dispose();
  }

  List<String> _splitList(String raw) => raw
      .split(',')
      .map((String s) => s.trim())
      .where((String s) => s.isNotEmpty)
      .toList();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final Program? existing = widget.existing;
      final Program program = Program(
        id: existing?.id ??
            'custom_program_${const Uuid().v4().substring(0, 6)}',
        name: _name.text.trim(),
        description: _description.text.trim(),
        sessionIds: _splitList(_sessionIds.text),
        durationWeeks: int.tryParse(_durationWeeks.text.trim()) ?? 4,
        difficulty: _difficulty,
        goals: _splitList(_goals.text),
        daysPerWeek: int.tryParse(_daysPerWeek.text.trim()) ?? 3,
        imageUrl: existing?.imageUrl,
        isCustom: existing?.isCustom ?? false,
        userId: existing?.userId,
        createdAt: existing?.createdAt,
      );
      await ref.read(adminActionsProvider).savePresetProgram(program);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Program updated' : 'Program created'),
        ),
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
          title: Text(_isEditing ? 'Edit program' : 'New program'),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: <Widget>[
                _field(
                  controller: _name,
                  label: 'Name',
                  validator: (String? v) =>
                      (v == null || v.trim().isEmpty)
                          ? 'Name is required'
                          : ContentModeration.validate(v),
                ),
                const SizedBox(height: AppSpacing.md),
                _field(
                  controller: _description,
                  label: 'Description',
                  maxLines: 3,
                  validator: (String? v) =>
                      (v == null || v.trim().isEmpty)
                          ? 'Description is required'
                          : ContentModeration.validate(v),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _field(
                        controller: _durationWeeks,
                        label: 'Weeks',
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _field(
                        controller: _daysPerWeek,
                        label: 'Days / week',
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _field(
                  controller: _goals,
                  label: 'Goals (comma-separated)',
                ),
                const SizedBox(height: AppSpacing.md),
                _field(
                  controller: _sessionIds,
                  label: 'Session IDs (comma-separated, optional)',
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Difficulty',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  children: DifficultyLevel.values.map((DifficultyLevel d) {
                    final bool selected = d == _difficulty;
                    return ChoiceChip(
                      label: Text(d.name),
                      selected: selected,
                      onSelected: (_) => setState(() => _difficulty = d),
                      backgroundColor: AppColors.surface,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color:
                            selected ? Colors.white : AppColors.textSecondary,
                      ),
                    );
                  }).toList(),
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
                        : Text(_isEditing ? 'Save changes' : 'Create program'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
