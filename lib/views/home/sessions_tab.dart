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

/// 3rd tab — sticky header (title + optional active program) + Sessions /
/// Programs sub-tabs. Uses a plain Column so the inner lists are the only
/// scroll views, eliminating the NestedScrollView "phantom scroll" issue.
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
    final activeProgramState =
        ref.watch(activeProgramStateProvider).valueOrNull;

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
            // ── Top section: status bar + title bar + active program ──────
            AppTopBarBackground(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: MediaQuery.paddingOf(context).top),
                  SizedBox(
                    height: kToolbarHeight,
                    child: Row(
                      children: [
                        const SizedBox(width: 48),
                        Expanded(
                          child: Text(
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
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.history_rounded,
                            color: Colors.white,
                          ),
                          tooltip: isFrench ? 'Historique' : 'History',
                          onPressed: () => Navigator.of(context).push(
                            SessionHistoryScreen.route(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (activeProgramState != null) ...[
                    Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: AppOpacity.whisper),
                    ),
                    _ActiveProgramInline(
                      activeProgramState: activeProgramState,
                      isFrench: isFrench,
                    ),
                  ],
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
// Active program inline banner (embedded in the top section)
// ---------------------------------------------------------------------------

class _ActiveProgramInline extends ConsumerWidget {
  final ActiveProgramState activeProgramState;
  final bool isFrench;

  const _ActiveProgramInline({
    required this.activeProgramState,
    required this.isFrench,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programAsync =
        ref.watch(programByIdProvider(activeProgramState.programId));
    final startDate = activeProgramState.startDateOnly;

    return programAsync.maybeWhen(
      data: (program) {
        if (program == null) return const SizedBox.shrink();

        // Compute progress
        int? currentDay;
        int? currentWeek;
        double? progress;
        int? daysUntilStart;
        final totalDays = program.totalDays;

        if (totalDays > 0) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final elapsed = today.difference(startDate).inDays;
          if (elapsed >= 0) {
            currentDay = (elapsed + 1).clamp(1, totalDays);
            currentWeek =
                ((elapsed / 7).floor() + 1).clamp(1, program.durationWeeks);
            progress = (currentDay / totalDays).clamp(0.0, 1.0);
          } else {
            daysUntilStart = -elapsed;
          }
        }

        final hasProgress = currentDay != null;

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            10,
            AppSpacing.xs,
            10,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bolt icon — aligned with the label row
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.bolt_rounded,
                  color: Colors.white.withValues(alpha: AppOpacity.prominent),
                  size: 15,
                ),
              ),
              const SizedBox(width: 7),
              // Info column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Row 1: label + action buttons
                    Row(
                      children: [
                        Text(
                          isFrench ? 'Programme actif' : 'Active program',
                          style: TextStyle(
                            color:
                                Colors.white.withValues(alpha: AppOpacity.half),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const Spacer(),
                        // Navigate to detail
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            ProgramDetailScreen.route(program: program),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 2,
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white
                                  .withValues(alpha: AppOpacity.half),
                              size: 12,
                            ),
                          ),
                        ),
                        // Stop button
                        GestureDetector(
                          onTap: () async {
                            final confirmed = await AppDialog.showConfirm(
                              context: context,
                              title: isFrench
                                  ? 'Arrêter le programme ?'
                                  : 'Stop program?',
                              confirmLabel: isFrench ? 'Arrêter' : 'Stop',
                              cancelLabel: isFrench ? 'Annuler' : 'Cancel',
                              message: isFrench
                                  ? 'Voulez-vous arrêter ce programme ?'
                                  : 'Do you want to stop this program?',
                              icon: Icons.stop_circle_outlined,
                              iconColor: AppColors.error,
                              destructive: true,
                            );
                            if (confirmed == true) {
                              try {
                                await ref
                                    .read(activeProgramActionsProvider)
                                    .unsubscribe();
                              } catch (e) {
                                if (!context.mounted) return;
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
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 2,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              color: Colors.white
                                  .withValues(alpha: AppOpacity.over),
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Row 2: program name
                    Text(
                      program.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'AppFontMedium',
                      ),
                    ),
                    if (hasProgress) ...[
                      const SizedBox(height: 6),
                      // Row 3: week/day label + percent
                      Row(
                        children: [
                          Icon(
                            Icons.flag_rounded,
                            size: 11,
                            color:
                                Colors.white.withValues(alpha: AppOpacity.over),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isFrench
                                ? 'Semaine $currentWeek/${program.durationWeeks}  •  Jour $currentDay/$totalDays'
                                : 'Week $currentWeek/${program.durationWeeks}  •  Day $currentDay/$totalDays',
                            style: TextStyle(
                              color: Colors.white
                                  .withValues(alpha: AppOpacity.visible),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${(progress! * 100).round()}%',
                            style: TextStyle(
                              color: Colors.white
                                  .withValues(alpha: AppOpacity.prominent),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      // Row 4: progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 3,
                          backgroundColor:
                              Colors.white.withValues(alpha: AppOpacity.light),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 3),
                      // Show static stats when no start date
                      Text(
                        daysUntilStart != null
                            ? (isFrench
                                ? 'Commence dans $daysUntilStart jour${daysUntilStart > 1 ? 's' : ''}'
                                : 'Starts in $daysUntilStart day${daysUntilStart > 1 ? 's' : ''}')
                            : (isFrench
                                ? '${program.durationWeeks} semaines  •  ${program.daysPerWeek} j/sem'
                                : '${program.durationWeeks} weeks  •  ${program.daysPerWeek} days/wk'),
                        style: TextStyle(
                          color:
                              Colors.white.withValues(alpha: AppOpacity.half),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
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
          return ListView.builder(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xs,
              AppSpacing.xs,
              AppSpacing.xs,
              104,
            ),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: _SessionCard(
                  session: session,
                  isFrench: widget.isFrench,
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
          return ListView.builder(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xs,
              AppSpacing.xs,
              AppSpacing.xs,
              104,
            ),
            itemCount: programs.length,
            itemBuilder: (context, index) {
              final program = programs[index];
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
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _SessionCard({
    required this.session,
    required this.isFrench,
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
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: AppColors.neutral300,
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
                                Text(
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
