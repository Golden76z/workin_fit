import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_chrome.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/features/session/presentation/screens/program_builder_screen.dart';
import 'package:workin_fit/features/session/presentation/screens/program_detail_screen.dart';
import 'package:workin_fit/features/session/presentation/screens/session_builder_screen.dart';
import 'package:workin_fit/features/session/presentation/screens/session_detail_screen.dart';
import 'package:workin_fit/features/session/presentation/screens/session_history_screen.dart';
import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/models/program.dart';
import 'package:workin_fit/models/session.dart';
import 'package:workin_fit/providers/workout_providers.dart';

/// 3rd tab: current program banner + Sessions / Programs sub-tabs.
class SessionsTab extends ConsumerStatefulWidget {
  const SessionsTab({super.key});

  @override
  ConsumerState<SessionsTab> createState() => _SessionsTabState();
}

class _SessionsTabState extends ConsumerState<SessionsTab>
    with AutomaticKeepAliveClientMixin<SessionsTab>, TickerProviderStateMixin {
  late final TabController _tabController;

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
        body: SafeArea(
          top: false,
          bottom: false,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              // ── App bar ──
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                toolbarHeight: 36,
                flexibleSpace: Container(color: AppColors.navBarSurface),
                title: Text(
                  isFrench ? 'Entraînements' : 'Workouts',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'AppFontMedium',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                actions: [
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
                  IconButton(
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    tooltip: onProgramsTab
                        ? (isFrench ? 'Créer un programme' : 'New program')
                        : (isFrench ? 'Créer une session' : 'New session'),
                    onPressed: onProgramsTab
                        ? _openProgramBuilder
                        : _openSessionBuilder,
                  ),
                ],
              ),
              // ── Active program banner (if any) ──
              _ActiveProgramBannerSliver(isFrench: isFrench),
              // ── Pinned tab bar ──
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor:
                        Colors.white.withValues(alpha: 0.55),
                    indicatorColor: Colors.white,
                    indicatorWeight: 2.5,
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
                        icon: const Icon(
                          Icons.fitness_center_rounded,
                          size: 18,
                        ),
                        iconMargin: const EdgeInsets.only(bottom: 2),
                      ),
                      Tab(
                        text: isFrench ? 'Programmes' : 'Programs',
                        icon: const Icon(
                          Icons.calendar_month_rounded,
                          size: 18,
                        ),
                        iconMargin: const EdgeInsets.only(bottom: 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            body: TabBarView(
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
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Active program banner (sliver wrapper)
// ---------------------------------------------------------------------------

class _ActiveProgramBannerSliver extends ConsumerWidget {
  final bool isFrench;

  const _ActiveProgramBannerSliver({required this.isFrench});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProgramId = ref.watch(activeProgramIdProvider);
    if (activeProgramId == null) return const SliverToBoxAdapter(child: SizedBox.shrink());

    final programAsync = ref.watch(programByIdProvider(activeProgramId));

    return programAsync.when(
      data: (program) {
        if (program == null) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        return SliverToBoxAdapter(
          child: _ActiveProgramCard(program: program, isFrench: isFrench),
        );
      },
      loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
      error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }
}

class _ActiveProgramCard extends ConsumerWidget {
  final Program program;
  final bool isFrench;

  const _ActiveProgramCard({required this.program, required this.isFrench});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(userSessionsProvider);
    final completedIds = ref.watch(completedTodaySessionIdsProvider);

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.xs,
        AppSpacing.xs,
        0,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3340B8), Color(0xFF5465FF)],
        ),
        borderRadius: BorderRadius.circular(AppRadii.md),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              const Icon(
                Icons.bolt_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                isFrench ? 'Programme actif' : 'Active Program',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => ref
                    .read(activeProgramIdProvider.notifier)
                    .state = null,
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            program.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontFamily: 'AppFontMedium',
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Sessions progress row
          sessionsAsync.when(
            data: (allSessions) {
              final sessionMap = {for (final s in allSessions) s.id: s};
              final sessions = program.sessionIds
                  .map((id) => sessionMap[id])
                  .whereType<Session>()
                  .toList();

              if (sessions.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isFrench ? 'Sessions' : 'Sessions',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: sessions.asMap().entries.map((entry) {
                        final isDone =
                            completedIds.contains(entry.value.id);
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: _SessionChip(
                            session: entry.value,
                            index: entry.key,
                            isDone: isDone,
                            isFrench: isFrench,
                            onTap: () => Navigator.of(context).push(
                              SessionDetailScreen.route(
                                session: entry.value,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _SessionChip extends StatelessWidget {
  final Session session;
  final int index;
  final bool isDone;
  final bool isFrench;
  final VoidCallback onTap;

  const _SessionChip({
    required this.session,
    required this.index,
    required this.isDone,
    required this.isFrench,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDone
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(
            color: isDone
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.45),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isDone)
              const Icon(Icons.check_rounded, color: Colors.white, size: 12)
            else
              Text(
                '${index + 1}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: isDone ? 0.6 : 1.0),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            const SizedBox(width: 4),
            Text(
              session.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: isDone ? 0.5 : 0.9),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                decoration: isDone ? TextDecoration.lineThrough : null,
                decorationColor: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab bar delegate (pins the TabBar)
// ---------------------------------------------------------------------------

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: AppColors.navBarSurface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) =>
      tabBar != oldDelegate.tabBar;
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          widget.isFrench ? 'Supprimer la session ?' : 'Delete session?',
        ),
        content: Text(
          widget.isFrench
              ? 'Cette action est irréversible.'
              : 'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(widget.isFrench ? 'Annuler' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              widget.isFrench ? 'Supprimer' : 'Delete',
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
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
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.xs,
              104,
            ),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
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
        loading: () =>
            const Center(child: CircularProgressIndicator()),
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
    final activeProgramId = ref.watch(activeProgramIdProvider);

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.primary,
      child: programsAsync.when(
        data: (programs) {
          if (programs.isEmpty) {
            return _EmptyProgramsState(isFrench: widget.isFrench);
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.xs,
              104,
            ),
            itemCount: programs.length,
            itemBuilder: (context, index) {
              final program = programs[index];
              final isActive = activeProgramId == program.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
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
        loading: () =>
            const Center(child: CircularProgressIndicator()),
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
    switch (d) {
      case DifficultyLevel.beginner:
        return AppColors.success;
      case DifficultyLevel.intermediate:
        return AppColors.warning;
      case DifficultyLevel.advanced:
        return AppColors.error;
    }
  }

  String _difficultyLabel(DifficultyLevel d) {
    switch (d) {
      case DifficultyLevel.beginner:
        return isFrench ? 'Débutant' : 'Beginner';
      case DifficultyLevel.intermediate:
        return isFrench ? 'Intermédiaire' : 'Intermediate';
      case DifficultyLevel.advanced:
        return isFrench ? 'Avancé' : 'Advanced';
    }
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
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child:
            const Icon(Icons.delete_outline_rounded, color: AppColors.error),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.md),
          onTap: onTap,
          onLongPress: onDelete,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.md),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFD7E5FF), Color(0xFFE4EEFF)],
              ),
              border: Border.all(
                color: AppColors.primaryLight.withValues(alpha: 0.45),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryLight.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPastel.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: const Icon(
                      Icons.fitness_center_rounded,
                      color: AppColors.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
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
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'AppFontMedium',
                          ),
                        ),
                        if (session.description != null &&
                            session.description!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            session.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _MetaChip(
                              icon: Icons.fitness_center_rounded,
                              label:
                                  '${session.exerciseCount} ${isFrench ? 'exercices' : 'exercises'}',
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            _MetaChip(
                              icon: Icons.timer_outlined,
                              label: session.durationDisplay,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: color.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                _difficultyLabel(session.difficulty),
                                style: TextStyle(
                                  color: color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.primary,
                    size: 20,
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
    switch (d) {
      case DifficultyLevel.beginner:
        return AppColors.success;
      case DifficultyLevel.intermediate:
        return AppColors.warning;
      case DifficultyLevel.advanced:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _difficultyColor(program.difficulty);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.md),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            gradient: isActive
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3340B8), Color(0xFF5465FF)],
                  )
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFD7E5FF), Color(0xFFE4EEFF)],
                  ),
            border: Border.all(
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.6)
                  : AppColors.primaryLight.withValues(alpha: 0.45),
            ),
            boxShadow: [
              BoxShadow(
                color: (isActive ? AppColors.primary : AppColors.primaryLight)
                    .withValues(alpha: isActive ? 0.3 : 0.18),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white.withValues(alpha: 0.18)
                        : AppColors.primaryPastel.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    color: isActive ? Colors.white : AppColors.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isFrench ? 'Actif' : 'Active',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
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
                              style: TextStyle(
                                color: isActive
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'AppFontMedium',
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (program.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          program.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isActive
                                ? Colors.white.withValues(alpha: 0.75)
                                : AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _MetaChip(
                            icon: Icons.list_alt_rounded,
                            label:
                                '${program.totalSessions} ${isFrench ? 'sessions' : 'sessions'}',
                            light: isActive,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          _MetaChip(
                            icon: Icons.calendar_today_rounded,
                            label:
                                '${program.durationWeeks} ${isFrench ? 'sem.' : 'wks'}',
                            light: isActive,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          if (!isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: color.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                _difficultyLabel(program.difficulty, isFrench),
                                style: TextStyle(
                                  color: color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isActive ? Colors.white : AppColors.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
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
// Meta chip
// ---------------------------------------------------------------------------

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool light;

  const _MetaChip({
    required this.icon,
    required this.label,
    this.light = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = light
        ? Colors.white.withValues(alpha: 0.7)
        : AppColors.textTertiary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
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
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.6,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.playlist_add_rounded,
                size: 56,
                color: AppColors.primaryLight.withValues(alpha: 0.7),
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
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                  ),
                ),
              ),
            ],
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
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.6,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_month_rounded,
                size: 56,
                color: AppColors.primaryLight.withValues(alpha: 0.7),
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
    );
  }
}
