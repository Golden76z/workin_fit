import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:workin_fit/core/theme/app_chrome.dart';
import 'package:workin_fit/core/theme/app_difficulty.dart';
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

// ---------------------------------------------------------------------------
// Builder entry — either a single exercise or a circuit block
// ---------------------------------------------------------------------------

sealed class _BuilderEntry {}

class _ExerciseEntry extends _BuilderEntry {
  final Exercise exercise;
  WorkoutConfig config;
  _ExerciseEntry({required this.exercise, required this.config});
}

/// Mutable circuit held in the builder list.
class _CircuitEntry extends _BuilderEntry {
  String name;
  int rounds;
  int restBetweenExercises; // seconds
  int restBetweenRounds; // seconds
  /// Each item: (exercise, config)
  List<(Exercise, WorkoutConfig)> exercises;

  _CircuitEntry({
    required this.name,
    required this.rounds,
    required this.restBetweenExercises,
    required this.restBetweenRounds,
    required this.exercises,
  });

  CircuitConfig toCircuitConfig() => CircuitConfig(
        name: name,
        exercises: exercises.map((e) => e.$2).toList(),
        rounds: rounds,
        restBetweenExercises: restBetweenExercises,
        restBetweenRounds: restBetweenRounds,
      );
}

// ---------------------------------------------------------------------------
// Main screen
// ---------------------------------------------------------------------------

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
  int _restBetweenExercises = 120;

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
    if (cfg is SetsConfig) return '${cfg.sets} × ${cfg.reps} reps';
    if (cfg is TabataConfig)
      return '${cfg.rounds} rounds · ${cfg.workTime}s/${cfg.restTime}s';
    if (cfg is TimedConfig) return _formatSeconds(cfg.duration);
    return '';
  }

  String _configTypeLabel(WorkoutConfig cfg) {
    if (cfg is SetsConfig) return 'Sets';
    if (cfg is TabataConfig) return 'Tabata';
    if (cfg is TimedConfig) return 'Timed';
    return '';
  }

  int get _estimatedSeconds {
    int total = 0;
    for (final e in _entries) {
      if (e is _ExerciseEntry) {
        final cfg = e.config;
        if (cfg is SetsConfig)
          total += cfg.estimatedTotalTime;
        else if (cfg is TabataConfig)
          total += cfg.totalDuration;
        else if (cfg is TimedConfig) total += cfg.totalDuration;
      } else if (e is _CircuitEntry) {
        total += e.toCircuitConfig().totalDuration;
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
    final alreadyAdded =
        _entries.whereType<_ExerciseEntry>().map((e) => e.exercise.id).toSet();
    final exercise = await Navigator.of(context).push<Exercise>(
      ExercisePickerScreen.route(alreadyAddedIds: alreadyAdded),
    );
    if (exercise == null || !mounted) return;

    final defaultConfig =
        SetsConfig(exerciseId: exercise.id, sets: 3, reps: 10);
    final config = await ExerciseConfigBottomSheet.show(
      context,
      exercise: exercise,
      initialConfig: defaultConfig,
    );
    if (!mounted || config == null) return;

    setState(
        () => _entries.add(_ExerciseEntry(exercise: exercise, config: config)));
  }

  Future<void> _addCircuit() async {
    final result = await Navigator.of(context).push<_CircuitEntry>(
      _CircuitEditorScreen.route(initial: null),
    );
    if (result == null || !mounted) return;
    setState(() => _entries.add(result));
  }

  Future<void> _editExerciseConfig(int index) async {
    final entry = _entries[index] as _ExerciseEntry;
    final config = await ExerciseConfigBottomSheet.show(
      context,
      exercise: entry.exercise,
      initialConfig: entry.config,
    );
    if (!mounted || config == null) return;
    setState(() => (entry).config = config);
  }

  Future<void> _editCircuit(int index) async {
    final entry = _entries[index] as _CircuitEntry;
    final result = await Navigator.of(context).push<_CircuitEntry>(
      _CircuitEditorScreen.route(initial: entry),
    );
    if (result == null || !mounted) return;
    setState(() => _entries[index] = result);
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
      final workouts = _entries.map((e) {
        if (e is _ExerciseEntry) return e.config;
        return (e as _CircuitEntry).toCircuitConfig();
      }).toList();

      final session = Session(
        id: const Uuid().v4(),
        name: name,
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        workouts: workouts,
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
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              systemOverlayStyle: AppChrome.topSurfaceOverlay,
              flexibleSpace: const AppTopBarBackground(),
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
                            text:
                                isFrench ? 'Nom de la session' : 'Session name',
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
                              final AppDifficultyPalette palette =
                                  AppDifficultyTheme.paletteFor(d);
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: AppSpacing.xs),
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _difficulty = d),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 160),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? palette.backgroundColor(
                                                alpha: AppDifficultyTheme
                                                    .selectedSurfaceOpacity,
                                              )
                                            : AppColors.surfaceVariant,
                                        borderRadius:
                                            BorderRadius.circular(AppRadii.sm),
                                        border: Border.all(
                                          color: selected
                                              ? palette.accentColor
                                              : AppColors.primaryPastel
                                                  .withValues(
                                                  alpha: AppOpacity.half,
                                                ),
                                          width: selected
                                              ? AppDifficultyTheme
                                                  .selectedBorderWidth
                                              : AppDifficultyTheme
                                                  .unselectedBorderWidth,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          AppDifficultyTheme.label(
                                            d,
                                            isFrench: isFrench,
                                          ),
                                          style: TextStyle(
                                            color: selected
                                                ? palette.foregroundColor
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
                                      ? 'Repos entre blocs'
                                      : 'Rest between blocks',
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
                                  AppColors.primaryPastel.withValues(
                                alpha: AppOpacity.firm,
                              ),
                              thumbColor: AppColors.primary,
                              overlayColor: AppColors.primary.withValues(
                                alpha: AppOpacity.light,
                              ),
                              trackHeight: 3,
                            ),
                            child: Slider(
                              value: _restBetweenExercises.toDouble(),
                              min: 15,
                              max: 300,
                              divisions: (300 - 15) ~/ 15,
                              onChanged: (v) => setState(
                                  () => _restBetweenExercises = v.round()),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Section header
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
                                ? 'Contenu (${_entries.length})'
                                : 'Content (${_entries.length})',
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

            // Entry list (reorderable)
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
                          ? 'Aucun contenu ajouté.\nAjoutez un exercice ou un circuit.'
                          : 'Nothing added yet.\nAdd an exercise or a circuit.',
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
                  final entry = _entries[index];
                  if (entry is _ExerciseEntry) {
                    return _ExerciseEntryTile(
                      key: ValueKey('ex_${entry.exercise.id}_$index'),
                      entry: entry,
                      index: index,
                      configSummary: _configSummary(entry.config),
                      configTypeLabel: _configTypeLabel(entry.config),
                      onEdit: () => _editExerciseConfig(index),
                      onRemove: () => _removeEntry(index),
                    );
                  } else {
                    final circuit = entry as _CircuitEntry;
                    return _CircuitEntryTile(
                      key: ValueKey('circuit_${circuit.name}_$index'),
                      entry: circuit,
                      index: index,
                      isFrench: isFrench,
                      formatSeconds: _formatSeconds,
                      onEdit: () => _editCircuit(index),
                      onRemove: () => _removeEntry(index),
                    );
                  }
                },
              ),

            // Add buttons + bottom padding
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  120,
                ),
                child: Column(
                  children: [
                    OutlinedButton.icon(
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
                    const SizedBox(height: AppSpacing.xs),
                    OutlinedButton.icon(
                      onPressed: _addCircuit,
                      icon: const Icon(Icons.loop_rounded),
                      label: Text(
                        isFrench ? 'Ajouter un circuit' : 'Add circuit',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.warning,
                        side: const BorderSide(color: AppColors.warning),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                        ),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
}

// ---------------------------------------------------------------------------
// Circuit editor screen
// ---------------------------------------------------------------------------

class _CircuitEditorScreen extends StatefulWidget {
  final _CircuitEntry? initial;

  const _CircuitEditorScreen({required this.initial});

  static Route<_CircuitEntry> route({required _CircuitEntry? initial}) {
    return MaterialPageRoute<_CircuitEntry>(
      fullscreenDialog: true,
      builder: (_) => _CircuitEditorScreen(initial: initial),
    );
  }

  @override
  State<_CircuitEditorScreen> createState() => _CircuitEditorScreenState();
}

class _CircuitEditorScreenState extends State<_CircuitEditorScreen> {
  late final TextEditingController _nameCtrl;
  late int _rounds;
  late int _restBetweenExercises;
  late int _restBetweenRounds;
  late List<(Exercise, WorkoutConfig)> _exercises;

  @override
  void initState() {
    super.initState();
    final init = widget.initial;
    _nameCtrl = TextEditingController(text: init?.name ?? '');
    _rounds = init?.rounds ?? 3;
    _restBetweenExercises = init?.restBetweenExercises ?? 0;
    _restBetweenRounds = init?.restBetweenRounds ?? 60;
    _exercises = List.from(init?.exercises ?? []);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  String _fmt(int s) {
    if (s == 0) return 'None';
    if (s < 60) return '${s}s';
    final m = s ~/ 60;
    final rem = s % 60;
    return rem == 0 ? '${m}m' : '${m}m ${rem}s';
  }

  String _configSummary(WorkoutConfig cfg) {
    if (cfg is SetsConfig) return '${cfg.sets} × ${cfg.reps} reps';
    if (cfg is TabataConfig)
      return '${cfg.rounds} rounds · ${cfg.workTime}s/${cfg.restTime}s';
    if (cfg is TimedConfig) return _fmt(cfg.duration);
    return '';
  }

  String _configTypeLabel(WorkoutConfig cfg) {
    if (cfg is SetsConfig) return 'Sets';
    if (cfg is TabataConfig) return 'Tabata';
    if (cfg is TimedConfig) return 'Timed';
    return '';
  }

  Future<void> _addExercise() async {
    final alreadyAdded = _exercises.map((e) => e.$1.id).toSet();
    final exercise = await Navigator.of(context).push<Exercise>(
      ExercisePickerScreen.route(alreadyAddedIds: alreadyAdded),
    );
    if (exercise == null || !mounted) return;

    final defaultConfig =
        SetsConfig(exerciseId: exercise.id, sets: 1, reps: 10);
    final config = await ExerciseConfigBottomSheet.show(
      context,
      exercise: exercise,
      initialConfig: defaultConfig,
      isCircuitExercise: true,
    );
    if (!mounted || config == null) return;
    setState(() => _exercises.add((exercise, config)));
  }

  Future<void> _editExercise(int index) async {
    final (exercise, config) = _exercises[index];
    final updated = await ExerciseConfigBottomSheet.show(
      context,
      exercise: exercise,
      initialConfig: config,
      isCircuitExercise: true,
    );
    if (!mounted || updated == null) return;
    setState(() => _exercises[index] = (exercise, updated));
  }

  void _confirm() {
    final name = _nameCtrl.text.trim();
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Add at least one exercise to the circuit.')),
      );
      return;
    }
    Navigator.of(context).pop(
      _CircuitEntry(
        name: name.isEmpty ? 'Circuit' : name,
        rounds: _rounds,
        restBetweenExercises: _restBetweenExercises,
        restBetweenRounds: _restBetweenRounds,
        exercises: List.from(_exercises),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isFrench = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('fr');

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: AppChrome.topSurfaceOverlay,
        flexibleSpace: const AppTopBarBackground(),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isFrench ? 'Circuit' : 'Circuit',
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'AppFontMedium',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _confirm,
            child: Text(
              isFrench ? 'OK' : 'Done',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Circuit name ──────────────────────────────────
                  _SectionLabel(
                    text: isFrench ? 'Nom du circuit' : 'Circuit name',
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _InputField(
                    controller: _nameCtrl,
                    hint: isFrench ? 'Ex: Cardio Blast…' : 'e.g. Cardio Blast…',
                    maxLength: 40,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── Rounds ────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _SectionLabel(
                          text: isFrench ? 'Nombre de rounds' : 'Rounds',
                        ),
                      ),
                      _StepperCompact(
                        value: _rounds,
                        min: 1,
                        max: 20,
                        onChanged: (v) => setState(() => _rounds = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── Rest between exercises ─────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionLabel(
                              text: isFrench
                                  ? 'Repos entre exercices'
                                  : 'Rest between exercises',
                            ),
                            Text(
                              _fmt(_restBetweenExercises),
                              style: const TextStyle(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.warning,
                      inactiveTrackColor:
                          AppColors.warning.withValues(alpha: AppOpacity.firm),
                      thumbColor: AppColors.warning,
                      overlayColor:
                          AppColors.warning.withValues(alpha: AppOpacity.light),
                      trackHeight: 3,
                    ),
                    child: Slider(
                      value: _restBetweenExercises.toDouble(),
                      min: 0,
                      max: 120,
                      divisions: 24,
                      onChanged: (v) =>
                          setState(() => _restBetweenExercises = v.round()),
                    ),
                  ),

                  // ── Rest between rounds ────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionLabel(
                              text: isFrench
                                  ? 'Repos entre rounds'
                                  : 'Rest between rounds',
                            ),
                            Text(
                              _fmt(_restBetweenRounds),
                              style: const TextStyle(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.warning,
                      inactiveTrackColor:
                          AppColors.warning.withValues(alpha: AppOpacity.firm),
                      thumbColor: AppColors.warning,
                      overlayColor:
                          AppColors.warning.withValues(alpha: AppOpacity.light),
                      trackHeight: 3,
                    ),
                    child: Slider(
                      value: _restBetweenRounds.toDouble(),
                      min: 0,
                      max: 300,
                      divisions: 20,
                      onChanged: (v) =>
                          setState(() => _restBetweenRounds = v.round()),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // ── Exercise list header ───────────────────────────
                  Row(
                    children: [
                      Container(
                        width: 3,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        isFrench
                            ? 'Exercices dans le circuit (${_exercises.length})'
                            : 'Exercises in circuit (${_exercises.length})',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'AppFontMedium',
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // ── Info pill ──────────────────────────────────────
                  if (_rounds > 1 && _exercises.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning
                            .withValues(alpha: AppOpacity.faint),
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                        border: Border.all(
                          color: AppColors.warning
                              .withValues(alpha: AppOpacity.light),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.loop_rounded,
                              color: AppColors.warning, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            isFrench
                                ? '$_rounds rounds · ${_exercises.length} exercices par round'
                                : '$_rounds rounds · ${_exercises.length} exercises per round',
                            style: const TextStyle(
                              color: AppColors.warning,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Reorderable exercise list
          if (_exercises.isNotEmpty)
            SliverReorderableList(
              itemCount: _exercises.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _exercises.removeAt(oldIndex);
                  _exercises.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final (exercise, config) = _exercises[index];
                return _ExerciseEntryTile(
                  key: ValueKey('circuit_ex_${exercise.id}_$index'),
                  entry: _ExerciseEntry(exercise: exercise, config: config),
                  index: index,
                  configSummary: _configSummary(config),
                  configTypeLabel: _configTypeLabel(config),
                  accentColor: AppColors.warning,
                  onEdit: () => _editExercise(index),
                  onRemove: () => setState(() => _exercises.removeAt(index)),
                );
              },
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.lg,
                ),
                child: Center(
                  child: Text(
                    isFrench
                        ? 'Aucun exercice dans ce circuit.'
                        : 'No exercises in this circuit yet.',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                40,
              ),
              child: OutlinedButton.icon(
                onPressed: _addExercise,
                icon: const Icon(Icons.add_rounded),
                label: Text(
                  isFrench ? 'Ajouter au circuit' : 'Add to circuit',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warning,
                  side: const BorderSide(color: AppColors.warning),
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
    );
  }
}

// ---------------------------------------------------------------------------
// Circuit entry tile (shown in the session builder list)
// ---------------------------------------------------------------------------

class _CircuitEntryTile extends StatelessWidget {
  final _CircuitEntry entry;
  final int index;
  final bool isFrench;
  final String Function(int) formatSeconds;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const _CircuitEntryTile({
    super.key,
    required this.entry,
    required this.index,
    required this.isFrench,
    required this.formatSeconds,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final count = entry.exercises.length;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: AppOpacity.faint),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadii.sm),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: [
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
                    const Icon(Icons.loop_rounded,
                        color: AppColors.warning, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        entry.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'AppFontMedium',
                        ),
                      ),
                    ),
                    // Rounds badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning
                            .withValues(alpha: AppOpacity.light),
                        borderRadius: BorderRadius.circular(AppRadii.xl),
                      ),
                      child: Text(
                        '× ${entry.rounds}',
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline_rounded),
                      color: AppColors.error
                          .withValues(alpha: AppOpacity.prominent),
                      iconSize: 20,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      constraints: const BoxConstraints(),
                      onPressed: onRemove,
                    ),
                  ],
                ),
              ),

              // ── Exercise list preview ──────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  AppSpacing.xs,
                  AppSpacing.sm,
                  AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...entry.exercises.take(3).map((pair) {
                      final (exercise, config) = pair;
                      final name = exercise.getLocalizedName(context);
                      String typeLabel = '';
                      if (config is SetsConfig)
                        typeLabel = 'Sets';
                      else if (config is TabataConfig)
                        typeLabel = 'Tabata';
                      else if (config is TimedConfig) typeLabel = 'Timed';
                      String summary = '';
                      if (config is SetsConfig) {
                        summary = '${config.sets} × ${config.reps} reps';
                      } else if (config is TabataConfig) {
                        summary =
                            '${config.rounds}r · ${config.workTime}s/${config.restTime}s';
                      } else if (config is TimedConfig) {
                        summary = formatSeconds(config.duration);
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 4,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: const BoxDecoration(
                                color: AppColors.warning,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            _TypeBadge(
                              label: typeLabel,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              summary,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    if (count > 3)
                      Text(
                        isFrench
                            ? '+ ${count - 3} exercice(s) de plus'
                            : '+ ${count - 3} more exercise(s)',
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: AppColors.textSecondary, fontSize: 14),
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
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _ExerciseEntryTile extends StatelessWidget {
  final _ExerciseEntry entry;
  final int index;
  final String configSummary;
  final String configTypeLabel;
  final Color accentColor;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const _ExerciseEntryTile({
    super.key,
    required this.entry,
    required this.index,
    required this.configSummary,
    required this.configTypeLabel,
    this.accentColor = AppColors.primary,
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  child: SizedBox(
                    width: 52,
                    height: 52,
                    child: _EntryThumb(url: entry.exercise.imageTutorialUrl),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
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
                          _TypeBadge(
                              label: configTypeLabel, color: accentColor),
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
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                  color:
                      AppColors.error.withValues(alpha: AppOpacity.prominent),
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
  final Color color;

  const _TypeBadge({
    required this.label,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppOpacity.faint),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: AppOpacity.light)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
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
          fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder());
    }
    return Image.network(trimmed,
        fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder());
  }

  Widget _placeholder() => Container(
        color: AppColors.primaryAbyss,
        alignment: Alignment.center,
        child: const Icon(Icons.fitness_center_rounded,
            color: AppColors.background, size: 22),
      );
}

// ── Compact stepper (used in circuit editor) ────────────────────────────────

class _StepperCompact extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _StepperCompact({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Btn(
          icon: Icons.remove_rounded,
          enabled: value > min,
          onTap: () => onChanged(value - 1),
          color: AppColors.warning,
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
        _Btn(
          icon: Icons.add_rounded,
          enabled: value < max,
          onTap: () => onChanged(value + 1),
          color: AppColors.warning,
        ),
      ],
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final Color color;

  const _Btn({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.color,
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
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? color : color.withValues(alpha: AppOpacity.light),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Icon(icon,
            size: 18, color: enabled ? Colors.white : AppColors.textSecondary),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section card
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
    return const AppBottomInsetSurface();
  }
}
