import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_chrome.dart';
import 'package:workin_fit/core/theme/app_difficulty.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/features/session/presentation/screens/program_builder_screen.dart';
import 'package:workin_fit/features/session/presentation/screens/program_detail_screen.dart';
import 'package:workin_fit/models/active_program_state.dart';
import 'package:workin_fit/features/session/presentation/screens/session_builder_screen.dart';
import 'package:workin_fit/features/session/presentation/screens/session_detail_screen.dart';
import 'package:workin_fit/features/session/presentation/screens/session_history_screen.dart';
import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/models/program.dart';
import 'package:workin_fit/models/session.dart';
import 'package:workin_fit/providers/workout_providers.dart';
import 'package:workin_fit/widgets/app_dialog.dart';
import 'package:workin_fit/core/theme/app_opacity.dart';

/// 3rd tab — sticky header (title + tabs) + Sessions / Programs sub-tabs.
/// Uses a plain Column so the inner lists are the only scroll views,
/// eliminating the NestedScrollView "phantom scroll" issue.
class SessionsTab extends ConsumerStatefulWidget {
  final ValueChanged<int>? onEdgeSwipe;

  const SessionsTab({
    this.onEdgeSwipe,
    super.key,
  });

  @override
  ConsumerState<SessionsTab> createState() => _SessionsTabState();
}

class _SessionsTabState extends ConsumerState<SessionsTab>
    with AutomaticKeepAliveClientMixin<SessionsTab>, TickerProviderStateMixin {
  late final TabController _tabController;
  bool _handledEdgeSwipe = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openSessionBuilder() async {
    await Navigator.of(context).push<void>(SessionBuilderScreen.route());
    if (mounted) ref.invalidate(userSessionsProvider);
  }

  Future<void> _openProgramBuilder() async {
    await Navigator.of(context).push<void>(ProgramBuilderScreen.route());
    if (mounted) ref.invalidate(programsProvider);
  }

  bool _handleTabViewEdgeSwipe(ScrollNotification notification) {
    if (widget.onEdgeSwipe == null ||
        notification.metrics.axis != Axis.horizontal) {
      return false;
    }

    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _handledEdgeSwipe = false;
      return false;
    }

    if (notification is ScrollEndNotification) {
      _handledEdgeSwipe = false;
      return false;
    }

    if (notification is OverscrollNotification &&
        notification.dragDetails != null &&
        !_handledEdgeSwipe) {
      final bool atFirstTab = _tabController.index == 0;
      final bool atLastTab = _tabController.index == _tabController.length - 1;

      if (notification.overscroll < 0 && atFirstTab) {
        _handledEdgeSwipe = true;
        widget.onEdgeSwipe?.call(-1);
        return true;
      }

      if (notification.overscroll > 0 && atLastTab) {
        _handledEdgeSwipe = true;
        widget.onEdgeSwipe?.call(1);
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bool isFrench = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('fr');

    final bool onProgramsTab = _tabController.index == 1;

    return AppSystemOverlayRegion(
      style: AppChrome.homeOverlay,
      child: Scaffold(
        backgroundColor: AppColors.surfaceVariant,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Padding(
          padding: EdgeInsets.only(
            // paddingOf.bottom is inflated by the outer scaffold's extendBody
            // to include the nav bar height (58) + system safe area inset.
            bottom: MediaQuery.paddingOf(context).bottom - 8,
          ),
          child: FloatingActionButton(
            heroTag: 'sessions_fab',
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 4,
            onPressed:
                onProgramsTab ? _openProgramBuilder : _openSessionBuilder,
            child: const Icon(Icons.add_rounded),
          ),
        ),
        body: Column(
          children: [
            // ── Top section: status bar + title bar + tabs ────────────────
            AppTopBarBackground(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: MediaQuery.paddingOf(context).top),
                  SizedBox(
                    height: kToolbarHeight + 8,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(width: 48),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isFrench ? 'Entraînements' : 'Workouts',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'AppFontMedium',
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                onProgramsTab
                                    ? (isFrench
                                        ? 'Programme hebdomadaire'
                                        : 'Weekly program planner')
                                    : (isFrench
                                        ? 'Sessions du jour'
                                        : 'Sessions for today'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(
                                    alpha: AppOpacity.over,
                                  ),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.xs),
                          child: Material(
                            color: Colors.white.withValues(
                              alpha: AppOpacity.soft,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                              side: BorderSide(
                                color: Colors.white.withValues(
                                  alpha: AppOpacity.light,
                                ),
                              ),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.history_rounded,
                                color: Colors.white,
                              ),
                              tooltip: isFrench ? 'Historique' : 'History',
                              onPressed: () => Navigator.of(context).push(
                                SessionHistoryScreen.route(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 1,
                    color: Colors.white.withValues(alpha: AppOpacity.subtle),
                  ),
                  TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor:
                        Colors.white.withValues(alpha: AppOpacity.over),
                    indicatorColor: Colors.white,
                    indicatorWeight: 2.5,
                    dividerColor: Colors.transparent,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      fontFamily: 'AppFontMedium',
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    tabs: [
                      Tab(
                        text: isFrench ? 'Sessions' : 'Sessions',
                        icon:
                            const Icon(Icons.fitness_center_rounded, size: 18),
                        iconMargin: const EdgeInsets.only(bottom: 2),
                      ),
                      Tab(
                        text: isFrench ? 'Programmes' : 'Programs',
                        icon:
                            const Icon(Icons.calendar_month_rounded, size: 18),
                        iconMargin: const EdgeInsets.only(bottom: 2),
                      ),
                    ],
                  ),
                  Container(
                    height: 1,
                    color: Colors.white.withValues(alpha: AppOpacity.subtle),
                  ),
                ],
              ),
            ),

            // ── Content ──────────────────────────────────────────────────
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: _handleTabViewEdgeSwipe,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _SessionsListView(
                      isFrench: isFrench,
                      onCreateTap: _openSessionBuilder,
                    ),
                    _ProgramsListView(isFrench: isFrench),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sessions list view (first tab)
// ---------------------------------------------------------------------------

class _SessionsListView extends ConsumerStatefulWidget {
  final bool isFrench;
  final VoidCallback onCreateTap;

  const _SessionsListView({
    required this.isFrench,
    required this.onCreateTap,
  });

  @override
  ConsumerState<_SessionsListView> createState() => _SessionsListViewState();
}

class _SessionsListViewState extends ConsumerState<_SessionsListView> {
  Future<void> _onRefresh() async {
    ref.invalidate(userSessionsProvider);
    await ref.read(userSessionsProvider.future);
  }

  String? _resolvePinnedSessionId({
    required List<Session> sessions,
    required Program program,
    required ActiveProgramState activeProgramState,
  }) {
    if (sessions.isEmpty || program.sessionIds.isEmpty) return null;

    final Set<String> visibleSessionIds =
        sessions.map((session) => session.id).toSet();
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final int elapsedDays =
        today.difference(activeProgramState.startDateOnly).inDays;

    int pinnedIndex = elapsedDays < 0 ? 0 : elapsedDays;
    if (pinnedIndex >= program.sessionIds.length) {
      pinnedIndex = program.sessionIds.length - 1;
    }
    if (pinnedIndex >= 0) {
      final String candidateId = program.sessionIds[pinnedIndex];
      if (visibleSessionIds.contains(candidateId)) {
        return candidateId;
      }
    }

    for (final String id in program.sessionIds) {
      if (visibleSessionIds.contains(id)) {
        return id;
      }
    }
    return null;
  }

  Future<void> _confirmDelete(Session session) async {
    final confirmed = await AppDialog.showConfirm(
      context: context,
      title: widget.isFrench ? 'Supprimer la session ?' : 'Delete session?',
      confirmLabel: widget.isFrench ? 'Supprimer' : 'Delete',
      cancelLabel: widget.isFrench ? 'Annuler' : 'Cancel',
      message: widget.isFrench
          ? 'Cette action est irréversible.'
          : 'This cannot be undone.',
      icon: Icons.delete_outline_rounded,
      iconColor: AppColors.error,
      destructive: true,
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(sessionActionsProvider).deleteSession(session.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(userSessionsProvider);
    final activeProgramState =
        ref.watch(activeProgramStateProvider).valueOrNull;
    final activeProgramAsync = activeProgramState == null
        ? const AsyncValue<Program?>.data(null)
        : ref.watch(programByIdProvider(activeProgramState.programId));

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.primary,
      child: sessionsAsync.when(
        data: (sessions) {
          if (sessions.isEmpty) {
            return _EmptyState(
              isFrench: widget.isFrench,
              onCreateTap: widget.onCreateTap,
            );
          }

          final Program? activeProgram = activeProgramAsync.valueOrNull;
          final String? pinnedSessionId =
              activeProgram == null || activeProgramState == null
                  ? null
                  : _resolvePinnedSessionId(
                      sessions: sessions,
                      program: activeProgram,
                      activeProgramState: activeProgramState,
                    );
          final List<Session> orderedSessions = List<Session>.of(sessions);
          if (pinnedSessionId != null) {
            final int currentIndex = orderedSessions.indexWhere(
              (session) => session.id == pinnedSessionId,
            );
            if (currentIndex > 0) {
              final Session pinned = orderedSessions.removeAt(currentIndex);
              orderedSessions.insert(0, pinned);
            }
          }

          return ListView.builder(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xs,
              AppSpacing.xs,
              AppSpacing.xs,
              104,
            ),
            itemCount: orderedSessions.length,
            itemBuilder: (context, index) {
              final session = orderedSessions[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: _SessionCard(
                  session: session,
                  isFrench: widget.isFrench,
                  isPinnedToProgram: pinnedSessionId == session.id,
                  onDelete: () => _confirmDelete(session),
                  onTap: () => Navigator.of(context).push(
                    SessionDetailScreen.route(session: session),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Text(
              widget.isFrench
                  ? 'Impossible de charger les sessions.'
                  : 'Could not load sessions.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Programs list view (second tab)
// ---------------------------------------------------------------------------

class _ProgramsListView extends ConsumerStatefulWidget {
  final bool isFrench;

  const _ProgramsListView({required this.isFrench});

  @override
  ConsumerState<_ProgramsListView> createState() => _ProgramsListViewState();
}

class _ProgramsListViewState extends ConsumerState<_ProgramsListView> {
  Future<void> _onRefresh() async {
    ref.invalidate(programsProvider);
    await ref.read(programsProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final programsAsync = ref.watch(programsProvider);
    final activeProgramId =
        ref.watch(activeProgramStateProvider).valueOrNull?.programId;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.primary,
      child: programsAsync.when(
        data: (programs) {
          if (programs.isEmpty) {
            return _EmptyProgramsState(isFrench: widget.isFrench);
          }
          final List<Program> orderedPrograms = List<Program>.of(programs);
          if (activeProgramId != null) {
            final int activeIndex = orderedPrograms.indexWhere(
              (program) => program.id == activeProgramId,
            );
            if (activeIndex > 0) {
              final Program activeProgram =
                  orderedPrograms.removeAt(activeIndex);
              orderedPrograms.insert(0, activeProgram);
            }
          }
          return ListView.builder(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xs,
              AppSpacing.xs,
              AppSpacing.xs,
              104,
            ),
            itemCount: orderedPrograms.length,
            itemBuilder: (context, index) {
              final program = orderedPrograms[index];
              final isActive = activeProgramId == program.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: _ProgramCard(
                  program: program,
                  isActive: isActive,
                  isFrench: widget.isFrench,
                  onTap: () => Navigator.of(context).push(
                    ProgramDetailScreen.route(program: program),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Text(
              widget.isFrench
                  ? 'Impossible de charger les programmes.'
                  : 'Could not load programs.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Session card
// ---------------------------------------------------------------------------

class _SessionCard extends StatelessWidget {
  final Session session;
  final bool isFrench;
  final bool isPinnedToProgram;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _SessionCard({
    required this.session,
    required this.isFrench,
    required this.isPinnedToProgram,
    required this.onDelete,
    required this.onTap,
  });

  Color _difficultyColor(DifficultyLevel d) {
    return AppDifficultyTheme.paletteFor(d).accentColor;
  }

  @override
  Widget build(BuildContext context) {
    final color = _difficultyColor(session.difficulty);

    return Dismissible(
      key: Key(session.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: AppOpacity.subtle),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: onTap,
          onLongPress: onDelete,
          child: Ink(
            decoration: BoxDecoration(
              color: isPinnedToProgram
                  ? AppColors.primary.withValues(alpha: AppOpacity.whisper)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isPinnedToProgram
                    ? AppColors.primary.withValues(alpha: AppOpacity.prominent)
                    : AppColors.neutral300,
              ),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left accent bar
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        bottomLeft: Radius.circular(4),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Icon block
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.neutral300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.fitness_center_rounded,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          // Text block
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    if (isPinnedToProgram) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(
                                            alpha: AppOpacity.firm,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          isFrench ? 'PROGRAMME' : 'PROGRAM',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                    ],
                                    Expanded(
                                      child: Text(
                                        session.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'AppFontMedium',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    _MetaChip(
                                      icon: Icons.fitness_center_rounded,
                                      label:
                                          '${session.exerciseCount} ${isFrench ? 'ex.' : 'ex.'}',
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    _MetaChip(
                                      icon: Icons.timer_outlined,
                                      label: session.durationDisplay,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          // Difficulty badge + chevron aligned together
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              AppDifficultyBadge(
                                difficulty: session.difficulty,
                                isFrench: isFrench,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDifficultyTheme
                                      .compactHorizontalPadding,
                                  vertical:
                                      AppDifficultyTheme.compactVerticalPadding,
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(
                                    AppDifficultyTheme.compactRadius,
                                  ),
                                ),
                                fontSize: AppDifficultyTheme.compactFontSize,
                                backgroundAlpha: AppOpacity.subtle,
                                borderAlpha: AppOpacity.half,
                              ),
                              const SizedBox(height: 4),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.textTertiary,
                                size: 18,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Program card
// ---------------------------------------------------------------------------

class _ProgramCard extends StatelessWidget {
  final Program program;
  final bool isActive;
  final bool isFrench;
  final VoidCallback onTap;

  const _ProgramCard({
    required this.program,
    required this.isActive,
    required this.isFrench,
    required this.onTap,
  });

  Color _difficultyColor(DifficultyLevel d) {
    return AppDifficultyTheme.paletteFor(d).accentColor;
  }

  @override
  Widget build(BuildContext context) {
    final color = _difficultyColor(program.difficulty);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withValues(alpha: AppOpacity.whisper)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.neutral300,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left accent bar — primary for active, difficulty color otherwise
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Icon block
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary
                                    .withValues(alpha: AppOpacity.mild)
                                : AppColors.neutral300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.calendar_month_rounded,
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        // Text block
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  if (isActive) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        isFrench ? 'ACTIF' : 'ACTIVE',
                                        style: const TextStyle(
                                          color: AppColors.neutral0,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                  ],
                                  Expanded(
                                    child: Text(
                                      program.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'AppFontMedium',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  _MetaChip(
                                    icon: Icons.list_alt_rounded,
                                    label:
                                        '${program.totalSessions} ${isFrench ? 'sessions' : 'sessions'}',
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  _MetaChip(
                                    icon: Icons.calendar_today_rounded,
                                    label:
                                        '${program.durationWeeks} ${isFrench ? 'sem.' : 'wks'}',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        // Difficulty badge + chevron aligned together
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AppDifficultyBadge(
                              difficulty: program.difficulty,
                              isFrench: isFrench,
                              padding: const EdgeInsets.symmetric(
                                horizontal:
                                    AppDifficultyTheme.compactHorizontalPadding,
                                vertical:
                                    AppDifficultyTheme.compactVerticalPadding,
                              ),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(
                                  AppDifficultyTheme.compactRadius,
                                ),
                              ),
                              fontSize: AppDifficultyTheme.compactFontSize,
                              backgroundAlpha: AppOpacity.subtle,
                              borderAlpha: AppOpacity.half,
                            ),
                            const SizedBox(height: 4),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textTertiary,
                              size: 18,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
// Meta chip
// ---------------------------------------------------------------------------

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    const color = AppColors.textTertiary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Empty states
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  final bool isFrench;
  final VoidCallback onCreateTap;

  const _EmptyState({required this.isFrench, required this.onCreateTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: constraints.maxHeight,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.playlist_add_rounded,
                  size: 56,
                  color: AppColors.primaryLight
                      .withValues(alpha: AppOpacity.prominent),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  isFrench
                      ? 'Aucune session personnalisée'
                      : 'No custom sessions yet',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'AppFontMedium',
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  isFrench
                      ? 'Créez votre première session pour commencer.'
                      : 'Create your first session to get started.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                FilledButton.icon(
                  onPressed: onCreateTap,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(
                    isFrench ? 'Créer une session' : 'Create a session',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyProgramsState extends StatelessWidget {
  final bool isFrench;

  const _EmptyProgramsState({required this.isFrench});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: constraints.maxHeight,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  size: 56,
                  color: AppColors.primaryLight
                      .withValues(alpha: AppOpacity.prominent),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  isFrench ? 'Aucun programme' : 'No programs yet',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'AppFontMedium',
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  isFrench
                      ? 'Les programmes vous permettent d\'organiser vos sessions sur plusieurs semaines.'
                      : 'Programs let you organize your sessions across multiple weeks.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
