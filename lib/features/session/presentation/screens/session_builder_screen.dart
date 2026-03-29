import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:workin_fit/core/theme/app_chrome.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/features/session/presentation/screens/exercise_picker_screen.dart';
import 'package:workin_fit/features/session/presentation/widgets/exercise_config_bottom_sheet.dart';
import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/exercise_localization.dart';
import 'package:workin_fit/models/session.dart';
import 'package:workin_fit/models/workout_config.dart';
import 'package:workin_fit/providers/workout_providers.dart';
import 'package:workin_fit/core/theme/app_opacity.dart';

/// Maximum custom sessions a user can have (free tier limit).
const int kMaxCustomSessions = 30;

/// Entry in the builder list: an [exercise] paired with its [config].
class _BuilderEntry {
  final Exercise exercise;
  WorkoutConfig config;

  _BuilderEntry({required this.exercise, required this.config});
}

class SessionBuilderScreen extends ConsumerStatefulWidget {
  const SessionBuilderScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => const SessionBuilderScreen(),
    );
  }

  @override
  ConsumerState<SessionBuilderScreen> createState() =>
      _SessionBuilderScreenState();
}

class _SessionBuilderScreenState extends ConsumerState<SessionBuilderScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  DifficultyLevel _difficulty = DifficultyLevel.intermediate;
  int _restBetweenExercises = 120; // seconds

  final List<_BuilderEntry> _entries = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _formatSeconds(int s) {
    if (s < 60) return '${s}s';
    final m = s ~/ 60;
    final rem = s % 60;
    return rem == 0 ? '${m}m' : '${m}m ${rem}s';
  }

  String _configSummary(WorkoutConfig cfg) {
    if (cfg is SetsConfig) {
      return '${cfg.sets} × ${cfg.reps} reps';
    } else if (cfg is TabataConfig) {
      return '${cfg.rounds} rounds · ${cfg.workTime}s/${cfg.restTime}s';
    } else if (cfg is TimedConfig) {
      return _formatSeconds(cfg.duration);
    }
    return '';
  }

  String _configTypeLabel(WorkoutConfig cfg) {
    if (cfg is SetsConfig) return 'Sets';
    if (cfg is TabataConfig) return 'Tabata';
    return 'Timed';
  }

  Color _difficultyColor(DifficultyLevel d) {
    switch (d) {
      case DifficultyLevel.beginner:
        return AppColors.success;
      case DifficultyLevel.intermediate:
        return AppColors.warning;
      case DifficultyLevel.advanced:
        return AppColors.error;
    }
  }

  // Estimated session duration in seconds
  int get _estimatedSeconds {
    int total = 0;
    for (final e in _entries) {
      final cfg = e.config;
      if (cfg is SetsConfig) {
        total += cfg.estimatedTotalTime;
      } else if (cfg is TabataConfig) {
        total += cfg.totalDuration;
      } else if (cfg is TimedConfig) {
        total += cfg.totalDuration;
      }
    }
    if (_entries.length > 1) {
      total += (_entries.length - 1) * _restBetweenExercises;
    }
    return total;
  }

  String get _durationDisplay {
    final mins = (_estimatedSeconds / 60).ceil();
    if (mins < 1) return '< 1 min';
    return '$mins min';
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _addExercise() async {
    final alreadyAdded = _entries.map((e) => e.exercise.id).toSet();
    final exercise = await Navigator.of(context).push<Exercise>(
      ExercisePickerScreen.route(alreadyAddedIds: alreadyAdded),
    );
    if (exercise == null || !mounted) return;

    // Default config: sets
    final defaultConfig = SetsConfig(
      exerciseId: exercise.id,
      sets: 3,
      reps: 10,
    );

    // Open config sheet immediately
    final config = await ExerciseConfigBottomSheet.show(
      context,
      exercise: exercise,
      initialConfig: defaultConfig,
    );
    if (!mounted) return;
    if (config == null) return;

    setState(() {
      _entries.add(_BuilderEntry(exercise: exercise, config: config));
    });
  }

  Future<void> _editConfig(int index) async {
    final entry = _entries[index];
    final config = await ExerciseConfigBottomSheet.show(
      context,
      exercise: entry.exercise,
      initialConfig: entry.config,
    );
    if (!mounted || config == null) return;
    setState(() {
      _entries[index].config = config;
    });
  }

  void _removeEntry(int index) {
    HapticFeedback.lightImpact();
    setState(() => _entries.removeAt(index));
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please give your session a name.')),
      );
      return;
    }
    if (_entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one exercise.')),
      );
      return;
    }

    // Check session limit
    final existingSessions = await ref.read(userSessionsProvider.future);
    if (!mounted) return;
    if (existingSessions.length >= kMaxCustomSessions) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You have reached the limit of $kMaxCustomSessions custom sessions.',
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final userId = ref.read(currentUserIdProvider);
      final session = Session(
        id: const Uuid().v4(),
        name: name,
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        workouts: _entries.map((e) => e.config).toList(),
        difficulty: _difficulty,
        restBetweenExercises: _restBetweenExercises,
        isCustom: true,
        userId: userId,
      );

      await ref.read(sessionActionsProvider).createSession(session);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save session: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final bool isFrench = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('fr');

    return AppSystemOverlayRegion(
      style: AppChrome.topAndBottomOverlay,
      child: Scaffold(
        backgroundColor: AppColors.surfaceVariant,
        extendBody: true,
        bottomNavigationBar: const _NavBarFill(),
        body: CustomScrollView(
          slivers: [
              // App bar
              SliverAppBar(
                pinned: true,
                backgroundColor: AppChrome.topSurface,
                surfaceTintColor: Colors.transparent,
                iconTheme: const IconThemeData(color: Colors.white),
                leading: IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text(
                  isFrench ? 'Nouvelle session' : 'New Session',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'AppFontMedium',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                actions: [
                  if (_isSaving)
                    const Padding(
                      padding: EdgeInsets.only(right: AppSpacing.md),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else
                    TextButton(
                      onPressed: _save,
                      child: Text(
                        isFrench ? 'Enregistrer' : 'Save',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card 1: Session Info
                      _SectionCard(
                        icon: Icons.edit_rounded,
                        title: isFrench ? 'Informations' : 'Session Info',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionLabel(
                              text: isFrench
                                  ? 'Nom de la session'
                                  : 'Session name',
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            _InputField(
                              controller: _nameController,
                              hint: isFrench
                                  ? 'Ex: Push Day, Full Body…'
                                  : 'e.g. Push Day, Full Body…',
                              maxLength: 60,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _SectionLabel(
                              text: isFrench
                                  ? 'Description (optionnel)'
                                  : 'Description (optional)',
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            _InputField(
                              controller: _descController,
                              hint: isFrench
                                  ? 'Brève description…'
                                  : 'Short description…',
                              maxLength: 200,
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Card 2: Configuration
                      _SectionCard(
                        icon: Icons.tune_rounded,
                        title: isFrench ? 'Configuration' : 'Configuration',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionLabel(
                              text: isFrench ? 'Difficulté' : 'Difficulty',
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Row(
                              children: DifficultyLevel.values.map((d) {
                                final selected = _difficulty == d;
                                final color = _difficultyColor(d);
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      right: AppSpacing.xs,
                                    ),
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => _difficulty = d),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 160),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: selected
                                              ? color.withValues(alpha: AppOpacity.muted)
                                              : AppColors.surfaceVariant,
                                          borderRadius: BorderRadius.circular(
                                            AppRadii.sm,
                                          ),
                                          border: Border.all(
                                            color: selected
                                                ? color
                                                : AppColors.primaryPastel
                                                    .withValues(alpha: AppOpacity.half),
                                            width: selected ? 1.6 : 1,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            _difficultyLabel(d, isFrench),
                                            style: TextStyle(
                                              color: selected
                                                  ? color
                                                  : AppColors.textSecondary,
                                              fontSize: 12,
                                              fontWeight: selected
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: _SectionLabel(
                                    text: isFrench
                                        ? 'Repos entre exercices'
                                        : 'Rest between exercises',
                                  ),
                                ),
                                Text(
                                  _formatSeconds(_restBetweenExercises),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
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
                                overlayColor:
                                    AppColors.primary.withValues(alpha: AppOpacity.light),
                                trackHeight: 3,
                              ),
                              child: Slider(
                                value: _restBetweenExercises.toDouble(),
                                min: 15,
                                max: 300,
                                divisions: (300 - 15) ~/ 15,
                                onChanged: (v) => setState(
                                  () => _restBetweenExercises = v.round(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Exercises section header
                      Row(
                        children: [
                          Container(
                            width: 3,
                            height: 16,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              isFrench
                                  ? 'Exercices (${_entries.length})'
                                  : 'Exercises (${_entries.length})',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'AppFontMedium',
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          if (_entries.isNotEmpty)
                            Text(
                              _durationDisplay,
                              style: const TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ),
                ),
              ),

              // Exercise list (reorderable)
              if (_entries.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xl,
                    ),
                    child: Center(
                      child: Text(
                        isFrench
                            ? 'Aucun exercice ajouté.\nAppuyez sur + pour commencer.'
                            : 'No exercises added yet.\nTap + to get started.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverReorderableList(
                  itemCount: _entries.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex--;
                      final entry = _entries.removeAt(oldIndex);
                      _entries.insert(newIndex, entry);
                    });
                  },
                  itemBuilder: (context, index) {
                    return _ExerciseEntryTile(
                      key: ValueKey(
                          _entries[index].exercise.id + index.toString(),),
                      entry: _entries[index],
                      index: index,
                      configSummary: _configSummary(_entries[index].config),
                      configTypeLabel:
                          _configTypeLabel(_entries[index].config),
                      onEdit: () => _editConfig(index),
                      onRemove: () => _removeEntry(index),
                    );
                  },
                ),

              // Add exercise button + bottom padding
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    120,
                  ),
                  child: OutlinedButton.icon(
                    onPressed: _addExercise,
                    icon: const Icon(Icons.add_rounded),
                    label: Text(
                      isFrench ? 'Ajouter un exercice' : 'Add exercise',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ),
              ),
            ],
          ),
        // Floating save button
        floatingActionButton: _entries.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: _isSaving ? null : _save,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(
                  isFrench ? 'Enregistrer' : 'Save session',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              )
            : null,
      ),
    );
  }

  String _difficultyLabel(DifficultyLevel d, bool isFrench) {
    switch (d) {
      case DifficultyLevel.beginner:
        return isFrench ? 'Débutant' : 'Beginner';
      case DifficultyLevel.intermediate:
        return isFrench ? 'Intermédiaire' : 'Intermediate';
      case DifficultyLevel.advanced:
        return isFrench ? 'Avancé' : 'Advanced';
    }
  }
}

// ---------------------------------------------------------------------------
// Internal widgets
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLength;
  final int maxLines;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.maxLength,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLines,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        counterStyle:
            const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: BorderSide(
            color: AppColors.primaryPastel.withValues(alpha: AppOpacity.half),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: BorderSide(
            color: AppColors.primaryPastel.withValues(alpha: AppOpacity.half),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _ExerciseEntryTile extends StatelessWidget {
  final _BuilderEntry entry;
  final int index;
  final String configSummary;
  final String configTypeLabel;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const _ExerciseEntryTile({
    super.key,
    required this.entry,
    required this.index,
    required this.configSummary,
    required this.configTypeLabel,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final exerciseName = entry.exercise.getLocalizedName(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                // Drag handle – instant drag on press, no delay
                ReorderableDragStartListener(
                  index: index,
                  child: const Padding(
                    padding: EdgeInsets.only(right: AppSpacing.xs),
                    child: Icon(
                      Icons.drag_handle_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ),
                // Exercise thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  child: SizedBox(
                    width: 52,
                    height: 52,
                    child: _EntryThumb(url: entry.exercise.imageTutorialUrl),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exerciseName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          _TypeBadge(label: configTypeLabel),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              configSummary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Remove
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                  color: AppColors.error.withValues(alpha: AppOpacity.prominent),
                  iconSize: 22,
                  onPressed: onRemove,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String label;
  const _TypeBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryPastel.withValues(alpha: AppOpacity.half),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: AppOpacity.firm),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EntryThumb extends StatelessWidget {
  final String url;
  const _EntryThumb({required this.url});

  @override
  Widget build(BuildContext context) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return _placeholder();
    if (trimmed.startsWith('assets/')) {
      return Image.asset(trimmed,
          fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder(),);
    }
    return Image.network(trimmed,
        fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder(),);
  }

  Widget _placeholder() => Container(
        color: AppColors.primaryAbyss,
        alignment: Alignment.center,
        child: const Icon(Icons.fitness_center_rounded,
            color: AppColors.background, size: 22,),
      );
}

// ---------------------------------------------------------------------------
// Section card (matches program_builder / exercise_detail style)
// ---------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 2,
      shadowColor: AppColors.primary.withValues(alpha: AppOpacity.whisper),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadii.md)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            color: AppChrome.topSurface,
            child: Row(
              children: [
                Icon(icon, size: 17, color: Colors.white),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'AppFontMedium',
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Nav bar fill
// ---------------------------------------------------------------------------

class _NavBarFill extends StatelessWidget {
  const _NavBarFill();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.viewPaddingOf(context).bottom,
      child: const ColoredBox(color: AppChrome.topSurface),
    );
  }
}
