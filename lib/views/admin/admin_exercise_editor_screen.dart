import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/core/utils/content_moderation.dart';
import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/providers/admin_providers.dart';
import 'package:workin_fit/views/admin/widgets/admin_guard.dart';

/// Create or edit a single exercise. On save it uploads any newly picked images
/// to Firebase Storage and writes the exercise to the shared `exercises`
/// collection via [AdminActions]. All free-text is run through
/// [ContentModeration] before writing.
class AdminExerciseEditorScreen extends ConsumerStatefulWidget {
  const AdminExerciseEditorScreen({this.existing, super.key});

  /// When non-null the form edits this exercise; otherwise it creates a new one.
  final Exercise? existing;

  static Route<void> route({Exercise? existing}) => MaterialPageRoute<void>(
        builder: (_) => AdminExerciseEditorScreen(existing: existing),
      );

  @override
  ConsumerState<AdminExerciseEditorScreen> createState() =>
      _AdminExerciseEditorScreenState();
}

class _AdminExerciseEditorScreenState
    extends ConsumerState<AdminExerciseEditorScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _tipsController;
  late final TextEditingController _equipmentController;

  late DifficultyLevel _difficulty;
  final Set<MuscleGroup> _muscleGroups = <MuscleGroup>{};

  // Existing remote URLs (kept when no new image is picked).
  String _muscleImageUrl = '';
  String _tutorialImageUrl = '';
  // Newly picked local files pending upload on save.
  File? _muscleImageFile;
  File? _tutorialImageFile;

  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final Exercise? e = widget.existing;
    _nameController = TextEditingController(text: e?.name ?? '');
    _descriptionController = TextEditingController(text: e?.description ?? '');
    _tipsController = TextEditingController(text: e?.beginnerTips ?? '');
    _equipmentController =
        TextEditingController(text: (e?.equipment ?? const <String>[]).join(', '));
    _difficulty = e?.difficulty ?? DifficultyLevel.beginner;
    if (e != null) _muscleGroups.addAll(e.muscleGroups);
    _muscleImageUrl = e?.imageMuscleUrl ?? '';
    _tutorialImageUrl = e?.imageTutorialUrl ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _tipsController.dispose();
    _equipmentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage({required bool muscle}) async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1080,
    );
    if (picked == null) return;
    setState(() {
      if (muscle) {
        _muscleImageFile = File(picked.path);
      } else {
        _tutorialImageFile = File(picked.path);
      }
    });
  }

  String _generateId() {
    final String slug = _nameController.text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    final String suffix = const Uuid().v4().substring(0, 6);
    final String base = slug.isEmpty ? 'exercise' : slug;
    return 'custom_${base}_$suffix';
  }

  List<String> _parseEquipment() {
    return _equipmentController.text
        .split(',')
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_muscleGroups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one muscle group.')),
      );
      return;
    }

    setState(() => _saving = true);
    final AdminActions actions = ref.read(adminActionsProvider);
    final String id = widget.existing?.id ?? _generateId();

    try {
      String muscleUrl = _muscleImageUrl;
      String tutorialUrl = _tutorialImageUrl;

      if (_muscleImageFile != null) {
        muscleUrl = await actions.uploadExerciseImage(
          file: _muscleImageFile!,
          exerciseId: id,
          kind: 'muscle',
        );
      }
      if (_tutorialImageFile != null) {
        tutorialUrl = await actions.uploadExerciseImage(
          file: _tutorialImageFile!,
          exerciseId: id,
          kind: 'tutorial',
        );
      }

      final String tips = _tipsController.text.trim();
      final Exercise exercise = Exercise(
        id: id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        imageMuscleUrl: muscleUrl,
        imageTutorialUrl: tutorialUrl,
        muscleGroups: _muscleGroups.toList(),
        difficulty: _difficulty,
        beginnerTips: tips.isEmpty ? null : tips,
        equipment: _parseEquipment(),
      );

      await actions.saveExercise(exercise);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Exercise updated' : 'Exercise created'),
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
          title: Text(_isEditing ? 'Edit exercise' : 'New exercise'),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: <Widget>[
                _field(
                  controller: _nameController,
                  label: 'Name',
                  validator: (String? v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return ContentModeration.validate(v);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _field(
                  controller: _descriptionController,
                  label: 'Description',
                  maxLines: 3,
                  validator: (String? v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Description is required';
                    }
                    return ContentModeration.validate(v);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _field(
                  controller: _tipsController,
                  label: 'Beginner tips (optional)',
                  maxLines: 2,
                  validator: ContentModeration.validate,
                ),
                const SizedBox(height: AppSpacing.md),
                _field(
                  controller: _equipmentController,
                  label: 'Equipment (comma-separated, empty = bodyweight)',
                ),
                const SizedBox(height: AppSpacing.lg),
                _label(context, 'Difficulty'),
                const SizedBox(height: AppSpacing.xs),
                _DifficultySelector(
                  value: _difficulty,
                  onChanged: (DifficultyLevel d) =>
                      setState(() => _difficulty = d),
                ),
                const SizedBox(height: AppSpacing.lg),
                _label(context, 'Muscle groups'),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: MuscleGroup.values.map((MuscleGroup g) {
                    final bool selected = _muscleGroups.contains(g);
                    return FilterChip(
                      label: Text(g.name),
                      selected: selected,
                      onSelected: (bool value) => setState(() {
                        if (value) {
                          _muscleGroups.add(g);
                        } else {
                          _muscleGroups.remove(g);
                        }
                      }),
                      backgroundColor: AppColors.surface,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: selected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                      checkmarkColor: Colors.white,
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
                _label(context, 'Images'),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _ImagePickerTile(
                        title: 'Muscle diagram',
                        file: _muscleImageFile,
                        remoteUrl: _muscleImageUrl,
                        onTap: () => _pickImage(muscle: true),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _ImagePickerTile(
                        title: 'Tutorial',
                        file: _tutorialImageFile,
                        remoteUrl: _tutorialImageUrl,
                        onTap: () => _pickImage(muscle: false),
                      ),
                    ),
                  ],
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
                        : Text(_isEditing ? 'Save changes' : 'Create exercise'),
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

  Widget _field({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
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

class _DifficultySelector extends StatelessWidget {
  const _DifficultySelector({required this.value, required this.onChanged});

  final DifficultyLevel value;
  final ValueChanged<DifficultyLevel> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      children: DifficultyLevel.values.map((DifficultyLevel d) {
        final bool selected = d == value;
        return ChoiceChip(
          label: Text(d.name),
          selected: selected,
          onSelected: (_) => onChanged(d),
          backgroundColor: AppColors.surface,
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        );
      }).toList(),
    );
  }
}

class _ImagePickerTile extends StatelessWidget {
  const _ImagePickerTile({
    required this.title,
    required this.file,
    required this.remoteUrl,
    required this.onTap,
  });

  final String title;
  final File? file;
  final String remoteUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Widget preview;
    if (file != null) {
      preview = Image.file(file!, fit: BoxFit.cover);
    } else if (remoteUrl.isNotEmpty) {
      preview = CachedNetworkImage(
        imageUrl: remoteUrl,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => _placeholder(),
      );
    } else {
      preview = _placeholder();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.md),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  preview,
                  Positioned(
                    right: 6,
                    bottom: 6,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholder() => Container(
        color: AppColors.surfaceVariant,
        child: const Center(
          child: Icon(
            Icons.add_photo_alternate_outlined,
            color: AppColors.textTertiary,
          ),
        ),
      );
}
