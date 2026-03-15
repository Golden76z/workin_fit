import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_chrome.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/features/session/presentation/screens/session_detail_screen.dart';
import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/models/program.dart';
import 'package:workin_fit/models/session.dart';
import 'package:workin_fit/providers/workout_providers.dart';

class ProgramDetailScreen extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isFrench = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('fr');

    final sessionsAsync = ref.watch(userSessionsProvider);
    final activeProgramId = ref.watch(activeProgramIdProvider);
    final completedIds = ref.watch(completedTodaySessionIdsProvider);
    final isActive = activeProgramId == program.id;

    return AppSystemOverlayRegion(
      style: AppChrome.topAndBottomOverlay,
      child: Scaffold(
        backgroundColor: AppColors.surfaceVariant,
        extendBody: true,
        bottomNavigationBar: const _NavBarFill(),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: AppChrome.topSurface,
              surfaceTintColor: Colors.transparent,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text(
                program.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'AppFontMedium',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: Center(
                    child: _DifficultyBadge(difficulty: program.difficulty),
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Meta chips
                    _MetaRow(program: program, isFrench: isFrench),
                    const SizedBox(height: AppSpacing.sm),
                    // Description
                    if (program.description.isNotEmpty)
                      Text(
                        program.description,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    // Goals
                    if (program.goals.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      _SectionHeader(
                        icon: Icons.flag_rounded,
                        title: isFrench ? 'Objectifs' : 'Goals',
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      ...program.goals.map(
                        (g) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  g,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    // Sessions section header
                    _SectionHeader(
                      icon: Icons.list_alt_rounded,
                      title: isFrench ? 'Sessions' : 'Sessions',
                    ),
                  ],
                ),
              ),
            ),
            // Sessions list
            sessionsAsync.when(
              data: (allSessions) {
                final sessionMap = {for (final s in allSessions) s.id: s};
                final sessions = program.sessionIds
                    .map((id) => sessionMap[id])
                    .whereType<Session>()
                    .toList();

                if (sessions.isEmpty) {
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

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xs,
                    AppSpacing.md,
                    0,
                  ),
                  sliver: SliverList.builder(
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      final isDone = completedIds.contains(session.id);
                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: _SessionRow(
                          session: session,
                          isFrench: isFrench,
                          isDone: isDone,
                          index: index,
                          onTap: () => Navigator.of(context).push(
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
            // Start / Active button
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.md,
                  MediaQuery.paddingOf(context).bottom + AppSpacing.xl,
                ),
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: isActive
                        ? () => ref
                            .read(activeProgramIdProvider.notifier)
                            .state = null
                        : () => ref
                            .read(activeProgramIdProvider.notifier)
                            .state = program.id,
                    icon: Icon(
                      isActive
                          ? Icons.stop_circle_outlined
                          : Icons.play_arrow_rounded,
                    ),
                    label: Text(
                      isActive
                          ? (isFrench ? 'Arrêter le programme' : 'Stop Program')
                          : (isFrench
                              ? 'Démarrer le programme'
                              : 'Start Program'),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'AppFontMedium',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor:
                          isActive ? AppColors.warning : AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                      ),
                    ),
                  ),
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
          label:
              '${program.durationWeeks} ${isFrench ? 'semaines' : 'weeks'}',
        ),
        _MetaChip(
          icon: Icons.repeat_rounded,
          label:
              '${program.daysPerWeek}×/${isFrench ? 'sem.' : 'week'}',
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppChrome.topSurface,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: AppSpacing.xs),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFamily: 'AppFontMedium',
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Session row
// ---------------------------------------------------------------------------

class _SessionRow extends StatelessWidget {
  final Session session;
  final bool isFrench;
  final bool isDone;
  final int index;
  final VoidCallback onTap;

  const _SessionRow({
    required this.session,
    required this.isFrench,
    required this.isDone,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDone ? 0.6 : 1.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.md),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              gradient: isDone
                  ? null
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFD7E5FF), Color(0xFFE4EEFF)],
                    ),
              color: isDone ? AppColors.surface : null,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(
                color: isDone
                    ? AppColors.textTertiary.withValues(alpha: 0.3)
                    : AppColors.primaryLight.withValues(alpha: 0.45),
              ),
              boxShadow: isDone
                  ? null
                  : [
                      BoxShadow(
                        color:
                            AppColors.primaryLight.withValues(alpha: 0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  // Index badge
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isDone
                          ? AppColors.success.withValues(alpha: 0.15)
                          : AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: isDone
                        ? const Icon(
                            Icons.check_rounded,
                            color: AppColors.success,
                            size: 18,
                          )
                        : Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
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
                          style: TextStyle(
                            color: isDone
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'AppFontMedium',
                          ),
                        ),
                        const SizedBox(height: 2),
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
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDone
                        ? AppColors.textTertiary
                        : AppColors.primary,
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
// Difficulty badge
// ---------------------------------------------------------------------------

class _DifficultyBadge extends StatelessWidget {
  final DifficultyLevel difficulty;

  const _DifficultyBadge({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final bool isFrench = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('fr');
    final (String label, Color color) = switch (difficulty) {
      DifficultyLevel.beginner => (
          isFrench ? 'Débutant' : 'Beginner',
          AppColors.success
        ),
      DifficultyLevel.intermediate => (
          isFrench ? 'Intermédiaire' : 'Intermediate',
          AppColors.warning
        ),
      DifficultyLevel.advanced => (
          isFrench ? 'Avancé' : 'Advanced',
          AppColors.error
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
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
