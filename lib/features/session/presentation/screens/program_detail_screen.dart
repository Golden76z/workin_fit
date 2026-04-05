import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_chrome.dart';
import 'package:workin_fit/core/theme/app_difficulty.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/features/session/presentation/screens/program_builder_screen.dart';
import 'package:workin_fit/features/session/presentation/screens/session_detail_screen.dart';
import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/models/program.dart';
import 'package:workin_fit/models/session.dart';
import 'package:workin_fit/providers/workout_providers.dart';
import 'package:workin_fit/widgets/app_dialog.dart';
import 'package:workin_fit/core/theme/app_opacity.dart';

class ProgramDetailScreen extends ConsumerStatefulWidget {
  final Program program;

  const ProgramDetailScreen({required this.program, super.key});

  static Route<void> route({required Program program}) {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (context, animation, secondaryAnimation) =>
          ProgramDetailScreen(program: program),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.18),
              end: Offset.zero,
            ).animate(curve),
            child: child,
          ),
        );
      },
    );
  }

  @override
  ConsumerState<ProgramDetailScreen> createState() =>
      _ProgramDetailScreenState();
}

class _ProgramDetailScreenState extends ConsumerState<ProgramDetailScreen> {
  Program get program => widget.program;

  // ---------------------------------------------------------------------------
  // Start-date chooser
  // ---------------------------------------------------------------------------

  Future<DateTime?> _chooseStartDate(bool isFrench) async {
    final now = DateTime.now();
    if (now.weekday == DateTime.monday) {
      final ok = await AppDialog.showConfirm(
        context: context,
        title: isFrench ? 'Démarrer le programme ?' : 'Start program?',
        confirmLabel: isFrench ? 'Démarrer' : 'Start',
        cancelLabel: isFrench ? 'Annuler' : 'Cancel',
        message: isFrench
            ? 'Démarrer « ${program.name} » aujourd\'hui ?'
            : 'Start "${program.name}" today?',
        icon: Icons.play_arrow_rounded,
        iconColor: AppColors.primary,
      );
      return ok == true ? now : null;
    }
    // Offer today vs next Monday
    return showDialog<DateTime>(
      context: context,
      builder: (ctx) => _StartDateDialog(
        programName: program.name,
        isFrench: isFrench,
        now: now,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Toggle active/stop
  // ---------------------------------------------------------------------------

  Future<void> _handleToggle(
    bool isActive,
    String? activeProgramId,
    bool isFrench,
  ) async {
    if (isActive) {
      final ok = await AppDialog.showConfirm(
        context: context,
        title: isFrench ? 'Arrêter le programme ?' : 'Stop program?',
        confirmLabel: isFrench ? 'Arrêter' : 'Stop',
        cancelLabel: isFrench ? 'Annuler' : 'Cancel',
        message: isFrench
            ? 'Voulez-vous arrêter ce programme ?'
            : 'Do you want to stop this program?',
        icon: Icons.stop_circle_outlined,
        iconColor: AppColors.error,
        destructive: true,
      );
      if (ok == true && mounted) {
        try {
          await ref.read(activeProgramActionsProvider).unsubscribe();
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isFrench
                    ? 'Impossible d\'arrêter le programme : $e'
                    : 'Failed to stop program: $e',
              ),
            ),
          );
        }
      }
    } else if (activeProgramId != null) {
      // Confirm replace then choose start date
      final ok = await AppDialog.showConfirm(
        context: context,
        title: isFrench ? 'Changer de programme ?' : 'Switch program?',
        confirmLabel: isFrench ? 'Remplacer' : 'Replace',
        cancelLabel: isFrench ? 'Annuler' : 'Cancel',
        message: isFrench
            ? 'Vous avez déjà un programme actif. Le remplacer par « ${program.name} » ?'
            : 'Replace your current program with "${program.name}"?',
        icon: Icons.swap_horiz_rounded,
        iconColor: AppColors.primary,
      );
      if (ok != true || !mounted) return;
      final startDate = await _chooseStartDate(isFrench);
      if (startDate != null && mounted) {
        try {
          await ref.read(activeProgramActionsProvider).subscribe(
                programId: program.id,
                startDate: startDate,
              );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isFrench
                    ? 'Impossible de démarrer le programme : $e'
                    : 'Failed to start program: $e',
              ),
            ),
          );
        }
      }
    } else {
      final startDate = await _chooseStartDate(isFrench);
      if (startDate != null && mounted) {
        try {
          await ref.read(activeProgramActionsProvider).subscribe(
                programId: program.id,
                startDate: startDate,
              );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isFrench
                    ? 'Impossible de démarrer le programme : $e'
                    : 'Failed to start program: $e',
              ),
            ),
          );
        }
      }
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

    final sessionsAsync = ref.watch(programSessionsProvider);
    final activeProgramState =
        ref.watch(activeProgramStateProvider).valueOrNull;
    final activeProgramId = activeProgramState?.programId;
    final startDate = activeProgramState?.startDateOnly;
    final completedIds = ref.watch(completedTodaySessionIdsProvider);
    final isActive = activeProgramId == program.id;
    final String description = program.description.trim();

    // Compute current week/day in program
    int? activeWeekIndex;
    int? activeDayInWeek;
    if (isActive && startDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final elapsed = today.difference(startDate).inDays;
      if (elapsed >= 0) {
        activeWeekIndex = (elapsed ~/ 7).clamp(0, program.durationWeeks - 1);
        activeDayInWeek = elapsed % 7;
      }
    }

    return AppSystemOverlayRegion(
      style: AppChrome.topAndBottomOverlay,
      child: Scaffold(
        backgroundColor: AppColors.surfaceVariant,
        bottomNavigationBar: _ProgramStickyActionBar(
          isActive: isActive,
          isFrench: isFrench,
          onPressed: () => _handleToggle(
            isActive,
            activeProgramId,
            isFrench,
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              centerTitle: true,
              toolbarHeight: description.isEmpty ? 92 : 148,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              systemOverlayStyle: AppChrome.topSurfaceOverlay,
              flexibleSpace: const AppTopBarBackground(),
              iconTheme: const IconThemeData(color: Colors.white),
              title: _DetailAppBarTitle(
                title: program.name,
                description: description,
                difficulty: program.difficulty,
                isFrench: isFrench,
              ),
              actions: [
                if (program.isCustom)
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: Colors.white),
                    tooltip: isFrench ? 'Modifier' : 'Edit',
                    onPressed: () async {
                      await Navigator.of(context).push<void>(
                        ProgramBuilderScreen.editRoute(program: program),
                      );
                      if (mounted) {
                        ref.invalidate(programByIdProvider(program.id));
                        ref.invalidate(programsProvider);
                      }
                    },
                  )
                else
                  const SizedBox(width: 48),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppLayout.pageMargin,
                  AppSpacing.md,
                  AppLayout.pageMargin,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _MetaRow(program: program, isFrench: isFrench),
                    if (program.goals.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      _GoalsDetailCard(
                        goals: program.goals,
                        isFrench: isFrench,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
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
                          '${program.totalSessions} ${isFrench ? 'sessions' : 'sessions'}',
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
            // Week / day grid
            sessionsAsync.when(
              data: (allSessions) {
                final sessionMap = {for (final s in allSessions) s.id: s};
                final sessions =
                    program.sessionIds.map((id) => sessionMap[id]).toList();

                if (program.sessionIds.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Center(
                        child: Text(
                          isFrench
                              ? 'Aucune session dans ce programme.'
                              : 'No sessions in this program.',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                // Distribute sessions into week × day grid
                final weeks = <List<Session?>>[];
                int cursor = 0;
                final int trainingDaysPerWeek = program.daysPerWeek.clamp(0, 7);
                for (int w = 0; w < program.durationWeeks; w++) {
                  final week = <Session?>[];
                  for (int d = 0; d < 7; d++) {
                    if (d < trainingDaysPerWeek) {
                      week.add(
                        cursor < sessions.length ? sessions[cursor] : null,
                      );
                      cursor++;
                    } else {
                      week.add(null);
                    }
                  }
                  weeks.add(week);
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppLayout.pageMargin,
                    0,
                    AppLayout.pageMargin,
                    0,
                  ),
                  sliver: SliverList.builder(
                    itemCount: weeks.length,
                    itemBuilder: (context, weekIndex) {
                      final week = weeks[weekIndex];
                      final assigned = week.where((s) => s != null).length;
                      final isCurrentWeek = activeWeekIndex == weekIndex;
                      final isPastWeek = activeWeekIndex != null &&
                          weekIndex < activeWeekIndex;
                      // Expand only the current week when active
                      final initialExpanded =
                          activeWeekIndex == null || isCurrentWeek;
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.md,
                        ),
                        child: _WeekDetailCard(
                          key: ValueKey(weekIndex),
                          weekIndex: weekIndex,
                          sessions: week,
                          completedIds: completedIds,
                          assignedCount: assigned,
                          isFrench: isFrench,
                          initialExpanded: initialExpanded,
                          isCurrentWeek: isCurrentWeek,
                          isPastWeek: isPastWeek,
                          currentDayInWeek:
                              isCurrentWeek ? activeDayInWeek : null,
                          onTapSession: (session) => Navigator.of(context).push(
                            SessionDetailScreen.route(session: session),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Center(
                    child: Text(
                      isFrench
                          ? 'Impossible de charger les sessions.'
                          : 'Could not load sessions.',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height:
                    MediaQuery.viewPaddingOf(context).bottom + AppSpacing.sm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Start date dialog (shown when today is not Monday)
// ---------------------------------------------------------------------------

class _StartDateDialog extends StatelessWidget {
  final String programName;
  final bool isFrench;
  final DateTime now;

  const _StartDateDialog({
    required this.programName,
    required this.isFrench,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final daysUntilMonday = (DateTime.monday - now.weekday + 7) % 7;
    final nextMonday =
        now.add(Duration(days: daysUntilMonday == 0 ? 7 : daysUntilMonday));

    final months = isFrench
        ? [
            '',
            'jan.',
            'fév.',
            'mars',
            'avr.',
            'mai',
            'juin',
            'juil.',
            'août',
            'sept.',
            'oct.',
            'nov.',
            'déc.',
          ]
        : [
            '',
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
          ];
    final mondayLabel = '${nextMonday.day} ${months[nextMonday.month]}';

    return AppDialog(
      title: isFrench ? 'Quand commencer ?' : 'When to start?',
      message: isFrench ? '« $programName »' : '"$programName"',
      icon: Icons.play_arrow_rounded,
      iconColor: AppColors.primary,
      actions: [
        AppDialogAction<DateTime>(
          label: isFrench ? "Aujourd'hui" : 'Today',
          returnValue: now,
          style: AppDialogActionStyle.primary,
        ),
        AppDialogAction<DateTime>(
          label: isFrench
              ? 'Lundi prochain ($mondayLabel)'
              : 'Next Monday ($mondayLabel)',
          returnValue: nextMonday,
          style: AppDialogActionStyle.outlined,
        ),
        AppDialogAction<DateTime?>(
          label: isFrench ? 'Annuler' : 'Cancel',
          returnValue: null,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Meta row
// ---------------------------------------------------------------------------

class _MetaRow extends StatelessWidget {
  final Program program;
  final bool isFrench;

  const _MetaRow({required this.program, required this.isFrench});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        _MetaChip(
          icon: Icons.list_alt_rounded,
          label:
              '${program.totalSessions} ${isFrench ? 'sessions' : 'sessions'}',
        ),
        _MetaChip(
          icon: Icons.calendar_today_rounded,
          label: '${program.durationWeeks} ${isFrench ? 'semaines' : 'weeks'}',
        ),
        _MetaChip(
          icon: Icons.repeat_rounded,
          label: '${program.daysPerWeek}×/${isFrench ? 'sem.' : 'week'}',
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Detail app bar content
// ---------------------------------------------------------------------------

class _DetailAppBarTitle extends StatelessWidget {
  final String title;
  final String description;
  final DifficultyLevel difficulty;
  final bool isFrench;

  const _DetailAppBarTitle({
    required this.title,
    required this.description,
    required this.difficulty,
    required this.isFrench,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'AppFontMedium',
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        if (description.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: AppOpacity.over),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ],
        const SizedBox(height: 4),
        AppDifficultyBadge(
          difficulty: difficulty,
          isFrench: isFrench,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDifficultyTheme.compactHorizontalPadding,
            vertical: AppDifficultyTheme.compactVerticalPadding,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(AppDifficultyTheme.compactRadius),
          ),
          fontSize: AppDifficultyTheme.compactFontSize,
          backgroundAlpha: AppOpacity.subtle,
          borderAlpha: AppOpacity.half,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Goals detail card
// ---------------------------------------------------------------------------

class _GoalsDetailCard extends StatefulWidget {
  final List<String> goals;
  final bool isFrench;

  const _GoalsDetailCard({
    required this.goals,
    required this.isFrench,
  });

  @override
  State<_GoalsDetailCard> createState() => _GoalsDetailCardState();
}

class _GoalsDetailCardState extends State<_GoalsDetailCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 2,
      shadowColor: AppColors.primary.withValues(alpha: AppOpacity.faint),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadii.sm)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                  const Icon(Icons.flag_rounded, size: 16, color: Colors.white),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    widget.isFrench ? 'Objectifs' : 'Goals',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'AppFontMedium',
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
                      '${widget.goals.length}',
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
          AnimatedSize(
            alignment: Alignment.topCenter,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Column(
                      children: [
                        for (int index = 0;
                            index < widget.goals.length;
                            index++)
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: index == widget.goals.length - 1
                                  ? 0
                                  : AppSpacing.xs,
                            ),
                            child: _GoalTile(goal: widget.goals[index]),
                          ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  final String goal;

  const _GoalTile({
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: AppOpacity.hairline),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: AppOpacity.moderate),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: AppOpacity.light),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(
              Icons.flag_rounded,
              size: 12,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              goal,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Week detail card
// ---------------------------------------------------------------------------

class _WeekDetailCard extends StatefulWidget {
  final int weekIndex;
  final List<Session?> sessions;
  final Set<String> completedIds;
  final int assignedCount;
  final bool isFrench;
  final bool initialExpanded;
  final bool isCurrentWeek;
  final bool isPastWeek;
  final int? currentDayInWeek;
  final void Function(Session session) onTapSession;

  const _WeekDetailCard({
    required this.weekIndex,
    required this.sessions,
    required this.completedIds,
    required this.assignedCount,
    required this.isFrench,
    required this.initialExpanded,
    required this.isCurrentWeek,
    required this.isPastWeek,
    required this.currentDayInWeek,
    required this.onTapSession,
    super.key,
  });

  @override
  State<_WeekDetailCard> createState() => _WeekDetailCardState();
}

class _WeekDetailCardState extends State<_WeekDetailCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initialExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 2,
      shadowColor: AppColors.primary.withValues(alpha: AppOpacity.faint),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadii.sm)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Week header
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              color: widget.isPastWeek
                  ? AppColors.primaryDarker.withValues(alpha: AppOpacity.over)
                  : AppChrome.topSurface,
              child: Row(
                children: [
                  Text(
                    widget.isFrench
                        ? 'Semaine ${widget.weekIndex + 1}'
                        : 'Week ${widget.weekIndex + 1}',
                    style: TextStyle(
                      color: widget.isPastWeek
                          ? Colors.white.withValues(alpha: 0.65)
                          : Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'AppFontMedium',
                      letterSpacing: 0.2,
                    ),
                  ),
                  // "Current week" badge
                  if (widget.isCurrentWeek) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white
                              .withValues(alpha: AppOpacity.moderate),
                        ),
                      ),
                      child: Text(
                        widget.isFrench ? 'En cours' : 'Current',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                  // "Done" badge for past weeks
                  if (widget.isPastWeek) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: Colors.white.withValues(alpha: AppOpacity.over),
                    ),
                  ],
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
                      '${widget.assignedCount} / ${widget.sessions.length}',
                      style: TextStyle(
                        color: widget.isPastWeek
                            ? Colors.white.withValues(alpha: 0.65)
                            : Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  AnimatedRotation(
                    turns: _expanded ? 0 : -0.25,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: widget.isPastWeek
                          ? Colors.white.withValues(alpha: AppOpacity.over)
                          : Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Day rows
          AnimatedSize(
            alignment: Alignment.topCenter,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: _expanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: List.generate(widget.sessions.length, (dayIndex) {
                      final session = widget.sessions[dayIndex];
                      final isDone = session != null &&
                          widget.completedIds.contains(session.id);
                      final isPastDay = widget.isPastWeek ||
                          (widget.isCurrentWeek &&
                              widget.currentDayInWeek != null &&
                              dayIndex < widget.currentDayInWeek!);
                      final isToday = widget.isCurrentWeek &&
                          widget.currentDayInWeek == dayIndex;
                      return _DayDetailRow(
                        dayIndex: dayIndex,
                        session: session,
                        isDone: isDone,
                        isFrench: widget.isFrench,
                        isLast: dayIndex == widget.sessions.length - 1,
                        isPastDay: isPastDay,
                        isToday: isToday,
                        onTap: session != null
                            ? () => widget.onTapSession(session)
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
// Day detail row
// ---------------------------------------------------------------------------

class _DayDetailRow extends StatelessWidget {
  final int dayIndex;
  final Session? session;
  final bool isDone;
  final bool isFrench;
  final bool isLast;
  final bool isPastDay;
  final bool isToday;
  final VoidCallback? onTap;

  const _DayDetailRow({
    required this.dayIndex,
    required this.session,
    required this.isDone,
    required this.isFrench,
    required this.isLast,
    required this.isPastDay,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasSession = session != null;

    // ── Row background ───────────────────────────────────────────────────────
    Color rowBg;
    Color badgeBg;
    Color badgeBorder;
    Color nameColor;

    if (isToday && isDone) {
      rowBg = AppColors.success.withValues(alpha: 0.07);
      badgeBg = AppColors.success.withValues(alpha: AppOpacity.light);
      badgeBorder = AppColors.success.withValues(alpha: AppOpacity.firm);
      nameColor = AppColors.textPrimary;
    } else if (isToday) {
      rowBg = AppColors.primary.withValues(alpha: AppOpacity.hairline);
      badgeBg = AppColors.primary.withValues(alpha: AppOpacity.subtle);
      badgeBorder = AppColors.primary.withValues(alpha: AppOpacity.half);
      nameColor = AppColors.textPrimary;
    } else if (isDone) {
      rowBg = AppColors.success.withValues(alpha: 0.04);
      badgeBg = AppColors.success.withValues(alpha: AppOpacity.subtle);
      badgeBorder = AppColors.success.withValues(alpha: AppOpacity.moderate);
      nameColor = AppColors.textSecondary;
    } else if (isPastDay) {
      rowBg = AppColors.surfaceVariant.withValues(alpha: AppOpacity.visible);
      badgeBg = AppColors.primaryPastel.withValues(alpha: AppOpacity.light);
      badgeBorder =
          AppColors.primaryPastel.withValues(alpha: AppOpacity.subtle);
      nameColor = AppColors.textSecondary.withValues(alpha: AppOpacity.half);
    } else {
      rowBg = Colors.transparent;
      badgeBg = hasSession
          ? AppColors.primary.withValues(alpha: AppOpacity.whisper)
          : AppColors.surfaceVariant;
      badgeBorder = hasSession
          ? AppColors.primary.withValues(alpha: AppOpacity.medium)
          : AppColors.primaryPastel.withValues(alpha: AppOpacity.soft);
      nameColor = AppColors.textPrimary;
    }

    return Column(
      children: [
        Ink(
          color: rowBg,
          child: InkWell(
            onTap: onTap,
            child: Padding(
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
                      child: isDone
                          ? const Icon(
                              Icons.check_rounded,
                              color: AppColors.success,
                              size: 16,
                            )
                          : isPastDay && !hasSession
                              ? Icon(
                                  Icons.remove_rounded,
                                  color: AppColors.textTertiary
                                      .withValues(alpha: AppOpacity.mild),
                                  size: 14,
                                )
                              : Text(
                                  isFrench
                                      ? 'J${dayIndex + 1}'
                                      : 'D${dayIndex + 1}',
                                  style: TextStyle(
                                    color: isPastDay
                                        ? AppColors.textSecondary
                                            .withValues(alpha: AppOpacity.firm)
                                        : hasSession
                                            ? AppColors.primary
                                            : AppColors.textSecondary
                                                .withValues(
                                                alpha: AppOpacity.firm,
                                              ),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),

                  // Content
                  Expanded(
                    child: hasSession
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      session!.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: nameColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        decoration: isPastDay && !isDone
                                            ? TextDecoration.none
                                            : null,
                                      ),
                                    ),
                                  ),
                                  // Today chip
                                  if (isToday) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDone
                                            ? AppColors.success
                                            : AppColors.primary,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isDone
                                            ? (isFrench ? 'Auj. ✓' : 'Today ✓')
                                            : (isFrench
                                                ? "Aujourd'hui"
                                                : 'Today'),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.fitness_center_rounded,
                                    size: 11,
                                    color: isPastDay && !isDone
                                        ? AppColors.textTertiary
                                            .withValues(alpha: AppOpacity.firm)
                                        : AppColors.textTertiary,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${session!.exerciseCount} ${isFrench ? 'ex.' : 'ex.'}',
                                    style: TextStyle(
                                      color: isPastDay && !isDone
                                          ? AppColors.textTertiary.withValues(
                                              alpha: AppOpacity.firm,
                                            )
                                          : AppColors.textTertiary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Icon(
                                    Icons.timer_outlined,
                                    size: 11,
                                    color: isPastDay && !isDone
                                        ? AppColors.textTertiary
                                            .withValues(alpha: AppOpacity.firm)
                                        : AppColors.textTertiary,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    session!.durationDisplay,
                                    style: TextStyle(
                                      color: isPastDay && !isDone
                                          ? AppColors.textTertiary.withValues(
                                              alpha: AppOpacity.firm,
                                            )
                                          : AppColors.textTertiary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (isDone) ...[
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      isFrench ? '✓ Effectuée' : '✓ Done',
                                      style: const TextStyle(
                                        color: AppColors.success,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          )
                        : Text(
                            isFrench ? 'Repos' : 'Rest',
                            style: TextStyle(
                              color: AppColors.textSecondary
                                  .withValues(alpha: isPastDay ? 0.30 : 0.45),
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                  ),

                  if (hasSession && !isPastDay)
                    Icon(
                      Icons.chevron_right_rounded,
                      color:
                          isDone ? AppColors.textTertiary : AppColors.primary,
                      size: 18,
                    ),
                ],
              ),
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            indent: AppSpacing.sm,
            endIndent: AppSpacing.sm,
            color: AppColors.primaryPastel.withValues(
              alpha: isPastDay ? 0.12 : 0.25,
            ),
          ),
      ],
    );
  }
}

// Meta chip
// ---------------------------------------------------------------------------

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textTertiary),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Sticky action bar
// ---------------------------------------------------------------------------

class _ProgramStickyActionBar extends StatelessWidget {
  final bool isActive;
  final bool isFrench;
  final VoidCallback onPressed;

  const _ProgramStickyActionBar({
    required this.isActive,
    required this.isFrench,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    const double buttonHeight = 54;
    final double barHeight = buttonHeight + AppSpacing.sm * 2 + bottomInset;

    return AppBottomBarSurface(
      height: barHeight,
      padding: EdgeInsets.fromLTRB(
        AppLayout.pageMargin,
        AppSpacing.sm,
        AppLayout.pageMargin,
        AppSpacing.sm + bottomInset,
      ),
      border: Border(
        top: BorderSide(
          color: AppColors.background.withValues(alpha: AppOpacity.thin),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: SizedBox(
            height: buttonHeight,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(
                isActive
                    ? Icons.stop_circle_outlined
                    : Icons.play_arrow_rounded,
              ),
              label: Text(
                isActive
                    ? (isFrench ? 'Arrêter le programme' : 'Stop Program')
                    : (isFrench ? 'Démarrer le programme' : 'Start Program'),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'AppFontMedium',
                ),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor:
                    isActive ? AppColors.primaryDarkest : AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
