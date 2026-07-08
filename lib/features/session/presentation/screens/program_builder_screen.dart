import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:workin_fit/core/theme/app_chrome.dart';
import 'package:workin_fit/core/theme/app_difficulty.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/models/program.dart';
import 'package:workin_fit/models/session.dart';
import 'package:workin_fit/providers/workout_providers.dart';
import 'package:workin_fit/core/theme/app_opacity.dart';

/// Maximum custom programs a user can have.
const int kMaxCustomPrograms = 10;

/// Sentinel value stored in a slot to mark it as an explicit rest day.
const String kRestDaySlot = '__rest__';

class ProgramBuilderScreen extends ConsumerStatefulWidget {
  /// If non-null the builder opens in edit mode for this program.
  final Program? editProgram;

  const ProgramBuilderScreen({this.editProgram, super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => const ProgramBuilderScreen(),
    );
  }

  static Route<void> editRoute({required Program program}) {
    return MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => ProgramBuilderScreen(editProgram: program),
    );
  }

  @override
  ConsumerState<ProgramBuilderScreen> createState() =>
      _ProgramBuilderScreenState();
}

class _ProgramBuilderScreenState extends ConsumerState<ProgramBuilderScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();

  DifficultyLevel _difficulty = DifficultyLevel.intermediate;
  int _durationWeeks = 4;

  /// Which days of the week are designated training days (0=Mon … 6=Sun).
  /// Default: Mon, Wed, Fri.
  Set<int> _trainingDays = {0, 2, 4};

  /// Slot grid: [week * 7 + dayOfWeek] → sessionId or null.
  /// Always 7 slots per week (full week). Rest days can also hold sessions.
  List<String?> _slots = List.filled(4 * 7, null);
  final List<String> _goals = [];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.editProgram;
    if (p != null) {
      _nameController.text = p.name;
      _descController.text = p.description;
      _difficulty = p.difficulty;
      _durationWeeks = p.durationWeeks;
      _goals.addAll(p.goals);
      // Reconstruct training days: use first daysPerWeek weekdays (Mon=0…)
      _trainingDays = {for (var i = 0; i < p.daysPerWeek; i++) i};
      _slots = List.filled(p.durationWeeks * 7, null);
      // Fill sessions sequentially into training day slots
      final sortedDays = _trainingDays.toList()..sort();
      int sessionIdx = 0;
      for (int w = 0; w < p.durationWeeks; w++) {
        for (final day in sortedDays) {
          if (sessionIdx < p.sessionIds.length) {
            _slots[w * 7 + day] = p.sessionIds[sessionIdx];
            sessionIdx++;
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  int get _assignedCount =>
      _slots.where((s) => s != null && s != kRestDaySlot).length;

  // ---------------------------------------------------------------------------
  // Slot management
  // ---------------------------------------------------------------------------

  void _onDurationWeeksChanged(int weeks) {
    final newSize = weeks * 7;
    setState(() {
      _durationWeeks = weeks;
      if (newSize > _slots.length) {
        _slots = [
          ..._slots,
          ...List.filled(newSize - _slots.length, null),
        ];
      } else {
        _slots = _slots.sublist(0, newSize);
      }
    });
  }

  void _toggleTrainingDay(int dayOfWeek) {
    setState(() {
      if (_trainingDays.contains(dayOfWeek)) {
        _trainingDays = {..._trainingDays}..remove(dayOfWeek);
        // Clear sessions assigned to this day across all weeks
        for (int w = 0; w < _durationWeeks; w++) {
          _slots[w * 7 + dayOfWeek] = null;
        }
      } else {
        _trainingDays = {..._trainingDays, dayOfWeek};
      }
    });
  }

  Future<void> _pickSessionForSlot(
    int slotIndex,
    bool isFrench,
    List<Session> allSessions,
  ) async {
    // Dismiss keyboard and clear focus so it doesn't restore on sheet close
    FocusManager.instance.primaryFocus?.unfocus();

    final picked = await showModalBottomSheet<Object>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SessionPickerSheet(
        sessions: allSessions,
        isFrench: isFrench,
        currentSessionId: _slots[slotIndex],
      ),
    );
    // Prevent focus restoration to any text field after sheet close
    FocusManager.instance.primaryFocus?.unfocus();
    if (picked == null || !mounted) return;
    HapticFeedback.selectionClick();
    if (picked == kRestDaySlot) {
      setState(() => _slots[slotIndex] = kRestDaySlot);
    } else if (picked is Session) {
      setState(() => _slots[slotIndex] = picked.id);
    }
  }

  void _clearSlot(int slotIndex) {
    HapticFeedback.lightImpact();
    setState(() => _slots[slotIndex] = null);
  }

  // ---------------------------------------------------------------------------
  // Goals
  // ---------------------------------------------------------------------------

  void _addGoal() {
    final goal = _goalController.text.trim();
    if (goal.isEmpty || _goals.length >= 10) return;
    setState(() {
      _goals.add(goal);
      _goalController.clear();
    });
  }

  void _removeGoal(int index) {
    setState(() => _goals.removeAt(index));
  }

  // ---------------------------------------------------------------------------
  // Save
  // ---------------------------------------------------------------------------

  Future<void> _save(bool isFrench) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFrench
                ? 'Donnez un nom à votre programme.'
                : 'Please give your program a name.',
          ),
        ),
      );
      return;
    }
    if (_assignedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFrench
                ? 'Ajoutez au moins une session.'
                : 'Assign at least one session.',
          ),
        ),
      );
      return;
    }

    // Only check custom program limit when creating a new program
    if (widget.editProgram == null) {
      final existing = await ref.read(programsProvider.future);
      if (!mounted) return;
      final customCount = existing.where((p) => p.isCustom).length;
      if (customCount >= kMaxCustomPrograms) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFrench
                  ? 'Limite de $kMaxCustomPrograms programmes atteinte.'
                  : 'You have reached the limit of $kMaxCustomPrograms custom programs.',
            ),
          ),
        );
        return;
      }
    }

    setState(() => _isSaving = true);
    try {
      final userId = ref.read(currentUserIdProvider);
      final sessionIds =
          _slots.whereType<String>().where((s) => s != kRestDaySlot).toList();
      final program = Program(
        id: widget.editProgram?.id ?? const Uuid().v4(),
        name: name,
        description: _descController.text.trim(),
        sessionIds: sessionIds,
        durationWeeks: _durationWeeks,
        difficulty: _difficulty,
        goals: List.unmodifiable(_goals),
        daysPerWeek: _trainingDays.length,
        isCustom: true,
        userId: userId,
        createdAt: widget.editProgram?.createdAt,
      );
      if (widget.editProgram != null) {
        await ref.read(programActionsProvider).updateProgram(program);
      } else {
        await ref.read(programActionsProvider).createProgram(program);
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFrench
                ? 'Erreur lors de la sauvegarde : $e'
                : 'Failed to save program: $e',
          ),
        ),
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

    final sessionsAsync = ref.watch(userSessionsProvider);
    final allSessions = sessionsAsync.valueOrNull ?? [];
    final sessionMap = {for (final s in allSessions) s.id: s};

    return AppSystemOverlayRegion(
      style: AppChrome.topAndBottomOverlay,
      child: Scaffold(
        backgroundColor: AppColors.surfaceVariant,
        extendBody: true,
        bottomNavigationBar: const AppBottomInsetSurface(),
        body: CustomScrollView(
          slivers: [
            // ── App bar ──────────────────────────────────────────────────────
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
                widget.editProgram != null
                    ? (isFrench ? 'Modifier le programme' : 'Edit Program')
                    : (isFrench ? 'Nouveau programme' : 'New Program'),
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
                    onPressed: () => _save(isFrench),
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

            // ── Form fields ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xs,
                  AppSpacing.sm,
                  AppSpacing.xs,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card 1: Name & Description
                    _BuilderSectionCard(
                      icon: Icons.edit_rounded,
                      title: isFrench ? 'Informations' : 'Program Info',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionLabel(
                            text:
                                isFrench ? 'Nom du programme' : 'Program name',
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          _InputField(
                            controller: _nameController,
                            hint: isFrench
                                ? 'Ex: Prise de masse, Cardio…'
                                : 'e.g. Strength Builder, Cardio…',
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
                            maxLength: 300,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Card 2: Configuration
                    _BuilderSectionCard(
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
                                                      alpha: AppOpacity.half),
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
                          _StepperField(
                            label: isFrench
                                ? 'Durée (semaines)'
                                : 'Duration (weeks)',
                            value: _durationWeeks,
                            min: 1,
                            max: 12,
                            onChanged: _onDurationWeeksChanged,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _SectionLabel(
                            text: isFrench
                                ? 'Jours d\'entraînement'
                                : 'Training days',
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          _WeekdaySelector(
                            selectedDays: _trainingDays,
                            isFrench: isFrench,
                            onToggle: _toggleTrainingDay,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Card 3: Goals
                    _BuilderSectionCard(
                      icon: Icons.flag_rounded,
                      title: isFrench
                          ? 'Objectifs (optionnel)'
                          : 'Goals (optional)',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _InputField(
                                  controller: _goalController,
                                  hint: isFrench
                                      ? 'Ex: Perdre du poids…'
                                      : 'e.g. Lose weight…',
                                  maxLength: 60,
                                  onSubmitted: (_) => _addGoal(),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              _AddButton(onTap: _addGoal),
                            ],
                          ),
                          if (_goals.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: AppColors.primaryPastel
                                  .withValues(alpha: AppOpacity.firm),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Wrap(
                              spacing: AppSpacing.xs,
                              runSpacing: AppSpacing.xs,
                              children: _goals
                                  .asMap()
                                  .entries
                                  .map(
                                    (e) => _GoalChip(
                                      label: e.value,
                                      onRemove: () => _removeGoal(e.key),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Schedule header
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
                            isFrench ? 'Planning' : 'Schedule',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'AppFontMedium',
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        Text(
                          '$_assignedCount / ${_durationWeeks * _trainingDays.length}',
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

            // ── Week/day grid ─────────────────────────────────────────────
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xs,
                0,
                AppSpacing.xs,
                MediaQuery.paddingOf(context).bottom + 96,
              ),
              sliver: SliverList.builder(
                itemCount: _durationWeeks,
                itemBuilder: (context, weekIndex) {
                  final weekAssigned = List.generate(7, (d) {
                    final s = _slots[weekIndex * 7 + d];
                    return s != null && s != kRestDaySlot;
                  }).where((v) => v).length;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: _WeekCard(
                      key: ValueKey(weekIndex),
                      weekIndex: weekIndex,
                      trainingDays: _trainingDays,
                      slots: _slots,
                      sessionMap: sessionMap,
                      isFrench: isFrench,
                      assignedCount: weekAssigned,
                      onPickSession: (dayOfWeek) => _pickSessionForSlot(
                        weekIndex * 7 + dayOfWeek,
                        isFrench,
                        allSessions,
                      ),
                      onClearSlot: (dayOfWeek) =>
                          _clearSlot(weekIndex * 7 + dayOfWeek),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: _assignedCount > 0
            ? FloatingActionButton.extended(
                onPressed: _isSaving ? null : () => _save(isFrench),
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
                  isFrench
                      ? 'Enregistrer ($_assignedCount)'
                      : 'Save ($_assignedCount)',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              )
            : null,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Builder section card (matches exercise_detail _SectionCard style)
// ---------------------------------------------------------------------------

class _BuilderSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _BuilderSectionCard({
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
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            color: AppChrome.topSurface,
            child: Row(
              children: [
                Icon(icon, size: 16, color: Colors.white),
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
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.sm,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Week card
// ---------------------------------------------------------------------------

class _WeekCard extends StatefulWidget {
  final int weekIndex;
  final Set<int> trainingDays;
  final List<String?> slots;
  final Map<String, Session> sessionMap;
  final bool isFrench;
  final int assignedCount;
  final void Function(int dayOfWeek) onPickSession;
  final void Function(int dayOfWeek) onClearSlot;

  const _WeekCard({
    required this.weekIndex,
    required this.trainingDays,
    required this.slots,
    required this.sessionMap,
    required this.isFrench,
    required this.assignedCount,
    required this.onPickSession,
    required this.onClearSlot,
    super.key,
  });

  @override
  State<_WeekCard> createState() => _WeekCardState();
}

class _WeekCardState extends State<_WeekCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 2,
      shadowColor: AppColors.primary.withValues(alpha: AppOpacity.faint),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Week header — tappable to expand/collapse
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              color: AppChrome.topSurface,
              child: Row(
                children: [
                  Text(
                    widget.isFrench
                        ? 'Semaine ${widget.weekIndex + 1}'
                        : 'Week ${widget.weekIndex + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'AppFontMedium',
                      letterSpacing: 0.2,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: AppOpacity.soft),
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                    child: Text(
                      '${widget.assignedCount} / ${widget.trainingDays.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  AnimatedRotation(
                    turns: _expanded ? 0 : -0.25,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.expand_more_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Day rows — collapsible
          AnimatedSize(
            alignment: Alignment.topCenter,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: _expanded
                ? Column(
                    children: List.generate(7, (dayOfWeek) {
                      final slotIndex = widget.weekIndex * 7 + dayOfWeek;
                      final sessionId = widget.slots[slotIndex];
                      final session = sessionId != null
                          ? widget.sessionMap[sessionId]
                          : null;
                      final isTraining =
                          widget.trainingDays.contains(dayOfWeek);

                      return _DaySlotRow(
                        dayOfWeek: dayOfWeek,
                        session: session,
                        sessionId: sessionId,
                        isTrainingDay: isTraining,
                        isFrench: widget.isFrench,
                        isLast: dayOfWeek == 6,
                        onTap: () => widget.onPickSession(dayOfWeek),
                        onClear: sessionId != null
                            ? () => widget.onClearSlot(dayOfWeek)
                            : null,
                      );
                    }),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Day slot row
// ---------------------------------------------------------------------------

class _DaySlotRow extends StatelessWidget {
  final int dayOfWeek; // 0 = Mon … 6 = Sun
  final Session? session;
  final String? sessionId;
  final bool isTrainingDay;
  final bool isFrench;
  final bool isLast;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _DaySlotRow({
    required this.dayOfWeek,
    required this.session,
    required this.sessionId,
    required this.isTrainingDay,
    required this.isFrench,
    required this.isLast,
    required this.onTap,
    this.onClear,
  });

  static const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _dayNamesFr = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

  @override
  Widget build(BuildContext context) {
    final dayLabel = isFrench ? _dayNamesFr[dayOfWeek] : _dayNames[dayOfWeek];
    final isExplicitRest = sessionId == kRestDaySlot;
    final assigned = sessionId != null && !isExplicitRest;
    final isRest = !isTrainingDay && !assigned && !isExplicitRest;
    final isRestDisplay = isRest || isExplicitRest;

    // Colors based on state
    final Color badgeBg = assigned
        ? AppColors.primary.withValues(alpha: AppOpacity.subtle)
        : (isTrainingDay && !isExplicitRest)
            ? AppColors.primary.withValues(alpha: AppOpacity.trace)
            : AppColors.surfaceVariant;
    final Color badgeBorder = assigned
        ? AppColors.primary.withValues(alpha: AppOpacity.mild)
        : (isTrainingDay && !isExplicitRest)
            ? AppColors.primary.withValues(alpha: AppOpacity.muted)
            : AppColors.primaryPastel.withValues(alpha: AppOpacity.soft);
    final Color badgeText = assigned
        ? AppColors.primary
        : (isTrainingDay && !isExplicitRest)
            ? AppColors.primaryLight
            : AppColors.textSecondary.withValues(alpha: AppOpacity.half);

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            // Uniform height for all rows — no special-casing for rest days
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                // Day badge
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    border: Border.all(color: badgeBorder),
                  ),
                  child: Center(
                    child: Text(
                      dayLabel,
                      style: TextStyle(
                        color: badgeText,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),

                // Content
                Expanded(
                  child: isRestDisplay
                      ? Text(
                          isFrench ? 'Repos' : 'Rest',
                          style: TextStyle(
                            color: AppColors.textSecondary
                                .withValues(alpha: AppOpacity.dim),
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      : assigned
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        session?.name ?? sessionId!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    if (!isTrainingDay)
                                      Container(
                                        margin: const EdgeInsets.only(
                                          left: AppSpacing.xs,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.warning.withValues(
                                              alpha: AppOpacity.light),
                                          borderRadius: BorderRadius.circular(
                                              AppRadii.sm),
                                        ),
                                        child: const Text(
                                          'Extra',
                                          style: TextStyle(
                                            color: AppColors.warning,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                if (session != null)
                                  Text(
                                    session!.durationDisplay,
                                    style: const TextStyle(
                                      color: AppColors.textTertiary,
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            )
                          : Text(
                              isFrench
                                  ? 'Assigner une session'
                                  : 'Assign session',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                ),

                // Action icon
                if (onClear != null)
                  GestureDetector(
                    onTap: onClear,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color:
                            AppColors.error.withValues(alpha: AppOpacity.faint),
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: AppColors.error,
                        size: 16,
                      ),
                    ),
                  )
                else if (!isRestDisplay)
                  const Icon(
                    Icons.add_rounded,
                    color: AppColors.primary,
                    size: 20,
                  )
                else
                  const Icon(
                    Icons.add_rounded,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            indent: AppSpacing.sm,
            endIndent: AppSpacing.sm,
            color: isRestDisplay
                ? AppColors.primaryPastel.withValues(alpha: AppOpacity.subtle)
                : AppColors.primaryPastel.withValues(alpha: AppOpacity.mild),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Weekday selector
// ---------------------------------------------------------------------------

class _WeekdaySelector extends StatelessWidget {
  final Set<int> selectedDays;
  final bool isFrench;
  final void Function(int dayOfWeek) onToggle;

  const _WeekdaySelector({
    required this.selectedDays,
    required this.isFrench,
    required this.onToggle,
  });

  static const _dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _dayNamesFr = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
  static const _dayFull = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _dayFullFr = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

  @override
  Widget build(BuildContext context) {
    final labels = isFrench ? _dayNamesFr : _dayNames;
    final fullLabels = isFrench ? _dayFullFr : _dayFull;

    return Row(
      children: List.generate(7, (i) {
        final selected = selectedDays.contains(i);
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 6 ? 4 : 0),
            child: Tooltip(
              message: fullLabels[i],
              child: GestureDetector(
                onTap: () => onToggle(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: 36,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.13)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                              .withValues(alpha: AppOpacity.visible)
                          : AppColors.primaryPastel
                              .withValues(alpha: AppOpacity.half),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      labels[i],
                      style: TextStyle(
                        color: selected
                            ? AppColors.primaryDark
                            : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Session picker bottom sheet
// ---------------------------------------------------------------------------

class _SessionPickerSheet extends StatefulWidget {
  final List<Session> sessions;
  final bool isFrench;
  final String? currentSessionId;

  const _SessionPickerSheet({
    required this.sessions,
    required this.isFrench,
    this.currentSessionId,
  });

  @override
  State<_SessionPickerSheet> createState() => _SessionPickerSheetState();
}

class _SessionPickerSheetState extends State<_SessionPickerSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Default to "My sessions" tab if the user has sessions, otherwise "Popular"
    final initialTab = widget.sessions.isNotEmpty ? 0 : 1;
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: initialTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _query.trim().isEmpty
        ? widget.sessions
        : widget.sessions
            .where(
              (s) => s.name.toLowerCase().contains(_query.trim().toLowerCase()),
            )
            .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadii.lg),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 4),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary
                        .withValues(alpha: AppOpacity.firm),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title + tab bar
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xxs,
                  AppSpacing.md,
                  AppSpacing.xxs,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.isFrench ? 'Choisir une session' : 'Pick a session',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'AppFontMedium',
                    ),
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorWeight: 2,
                dividerColor:
                    AppColors.primaryPastel.withValues(alpha: AppOpacity.mild),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  fontFamily: 'AppFontMedium',
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                tabs: [
                  Tab(
                    text: widget.isFrench ? 'Mes sessions' : 'My sessions',
                  ),
                  Tab(
                    text: widget.isFrench ? 'Populaires' : 'Popular',
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xs),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // ── Tab 0: My sessions ──────────────────────────────
                    Column(
                      children: [
                        // Rest day option
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.sm,
                            0,
                            AppSpacing.sm,
                            AppSpacing.xxs,
                          ),
                          child: Material(
                            color: widget.currentSessionId == kRestDaySlot
                                ? AppColors.success
                                    .withValues(alpha: AppOpacity.faint)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(AppRadii.sm),
                              onTap: () =>
                                  Navigator.of(context).pop(kRestDaySlot),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xs,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withValues(
                                            alpha: AppOpacity.subtle),
                                        borderRadius:
                                            BorderRadius.circular(AppRadii.sm),
                                      ),
                                      child: const Icon(
                                        Icons.bedtime_outlined,
                                        color: AppColors.success,
                                        size: 17,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Expanded(
                                      child: Text(
                                        widget.isFrench ? 'Repos' : 'Rest day',
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      widget.currentSessionId == kRestDaySlot
                                          ? Icons.check_circle_rounded
                                          : Icons.bedtime_outlined,
                                      color: AppColors.success,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (widget.sessions.isNotEmpty)
                          Divider(
                            height: 1,
                            thickness: 1,
                            indent: AppSpacing.sm,
                            endIndent: AppSpacing.sm,
                            color: AppColors.primaryPastel
                                .withValues(alpha: AppOpacity.medium),
                          ),
                        if (widget.sessions.isNotEmpty)
                          const SizedBox(height: AppSpacing.xs),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          child: TextField(
                            autofocus: false,
                            onChanged: (v) => setState(() => _query = v),
                            decoration: InputDecoration(
                              hintText:
                                  widget.isFrench ? 'Rechercher…' : 'Search…',
                              hintStyle: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: AppColors.textSecondary,
                                size: 18,
                              ),
                              filled: true,
                              fillColor: AppColors.surface,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadii.sm),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Expanded(
                          child: filtered.isEmpty
                              ? Center(
                                  child: Text(
                                    widget.isFrench
                                        ? widget.sessions.isEmpty
                                            ? 'Aucune session créée.'
                                            : 'Aucun résultat.'
                                        : widget.sessions.isEmpty
                                            ? 'No sessions created yet.'
                                            : 'No results.',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  controller: controller,
                                  padding: EdgeInsets.fromLTRB(
                                    AppSpacing.sm,
                                    0,
                                    AppSpacing.sm,
                                    MediaQuery.paddingOf(context).bottom +
                                        AppSpacing.md,
                                  ),
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) =>
                                      _SessionPickerTile(
                                    session: filtered[index],
                                    isCurrent: filtered[index].id ==
                                        widget.currentSessionId,
                                    onTap: () => Navigator.of(context)
                                        .pop(filtered[index]),
                                  ),
                                ),
                        ),
                      ],
                    ),

                    // ── Tab 1: Popular sessions ──────────────────────────
                    _PopularSessionsTab(
                      isFrench: widget.isFrench,
                      scrollController: controller,
                      currentSessionId: widget.currentSessionId,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Session picker tile (shared between tabs)
// ---------------------------------------------------------------------------

class _SessionPickerTile extends StatelessWidget {
  final Session session;
  final bool isCurrent;
  final VoidCallback onTap;

  const _SessionPickerTile({
    required this.session,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      child: Material(
        color: isCurrent
            ? AppColors.primary.withValues(alpha: AppOpacity.faint)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color:
                        AppColors.primary.withValues(alpha: AppOpacity.whisper),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    color: AppColors.primary,
                    size: 17,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        session.durationDisplay,
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isCurrent ? Icons.check_circle_rounded : Icons.add_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Popular sessions tab placeholder
// ---------------------------------------------------------------------------

class _PopularSessionsTab extends StatelessWidget {
  final bool isFrench;
  final ScrollController scrollController;
  final String? currentSessionId;

  const _PopularSessionsTab({
    required this.isFrench,
    required this.scrollController,
    this.currentSessionId,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.explore_rounded,
              size: 48,
              color: AppColors.primaryLight.withValues(alpha: AppOpacity.half),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isFrench ? 'Sessions populaires' : 'Popular sessions',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'AppFontMedium',
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              isFrench
                  ? 'Bientôt disponible — parcourez des sessions\ncréées par la communauté.'
                  : 'Coming soon — browse sessions\ncreated by the community.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stepper field
// ---------------------------------------------------------------------------

class _StepperField extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _StepperField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(
          color: AppColors.primaryPastel.withValues(alpha: AppOpacity.half),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _StepButton(
                icon: Icons.remove_rounded,
                onTap: value > min ? () => onChanged(value - 1) : null,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '$value',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'AppFontMedium',
                    ),
                  ),
                ),
              ),
              _StepButton(
                icon: Icons.add_rounded,
                onTap: value < max ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary.withValues(alpha: AppOpacity.subtle)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? AppColors.primary : AppColors.textTertiary,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Goal chip
// ---------------------------------------------------------------------------

class _GoalChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _GoalChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: AppOpacity.whisper),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: AppOpacity.mild)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              size: 14,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add button
// ---------------------------------------------------------------------------

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section label & input field
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
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
    );
  }
}

class _InputField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLength;
  final int maxLines;
  final ValueChanged<String>? onSubmitted;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.maxLength,
    this.maxLines = 1,
    this.onSubmitted,
  });

  @override
  State<_InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<_InputField> {
  int _length = 0;

  @override
  void initState() {
    super.initState();
    _length = widget.controller.text.length;
    widget.controller.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() => _length = widget.controller.text.length);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMultiline = widget.maxLines > 1;
    final counterColor = _length >= widget.maxLength
        ? AppColors.error
        : AppColors.textSecondary.withValues(alpha: AppOpacity.over);

    final field = TextField(
      controller: widget.controller,
      maxLength: widget.maxLength,
      maxLines: widget.maxLines,
      onSubmitted: widget.onSubmitted,
      textInputAction: widget.onSubmitted != null
          ? TextInputAction.done
          : TextInputAction.newline,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle:
            const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        counterText: '',
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: EdgeInsets.fromLTRB(
          AppSpacing.sm,
          AppSpacing.xs,
          isMultiline ? AppSpacing.sm : AppSpacing.xxs,
          isMultiline ? 22 : AppSpacing.xs,
        ),
        suffix: isMultiline
            ? null
            : Text(
                '$_length/${widget.maxLength}',
                style: TextStyle(
                  color: counterColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: BorderSide(
              color:
                  AppColors.primaryPastel.withValues(alpha: AppOpacity.half)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: BorderSide(
              color:
                  AppColors.primaryPastel.withValues(alpha: AppOpacity.half)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );

    if (!isMultiline) return field;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        field,
        Positioned(
          bottom: 6,
          right: AppSpacing.sm,
          child: IgnorePointer(
            child: Text(
              '$_length/${widget.maxLength}',
              style: TextStyle(
                color: counterColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Nav bar fill
// ---------------------------------------------------------------------------
