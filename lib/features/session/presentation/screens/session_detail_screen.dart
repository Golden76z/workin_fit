import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_chrome.dart';
import 'package:workin_fit/core/theme/app_difficulty.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/features/workout/presentation/screens/exercise_detail_screen.dart';
import 'package:workin_fit/features/workout/presentation/screens/workout_execution_screen.dart';
import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/exercise_localization.dart';
import 'package:workin_fit/models/session.dart';
import 'package:workin_fit/models/workout_config.dart';
import 'package:workin_fit/models/session_history_entry.dart';
import 'package:workin_fit/providers/session_history_provider.dart';
import 'package:workin_fit/providers/workout_providers.dart';
import 'package:workin_fit/core/theme/app_opacity.dart';

class SessionDetailScreen extends ConsumerWidget {
  final Session session;

  const SessionDetailScreen({required this.session, super.key});

  static Route<void> route({required Session session}) {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (context, animation, secondaryAnimation) =>
          SessionDetailScreen(session: session),
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

    final exercisesAsync = ref.watch(exercisesProvider);
    final completedIds = ref.watch(completedTodaySessionIdsProvider);
    final isDone = completedIds.contains(session.id);
    final String description = (session.description ?? '').trim();

    return AppSystemOverlayRegion(
      style: AppChrome.topAndBottomOverlay,
      child: Scaffold(
        backgroundColor: AppColors.surfaceVariant,
        extendBody: true,
        bottomNavigationBar: const _NavBarFill(),
        body: exercisesAsync.when(
          data: (allExercises) {
            final exerciseMap = {for (final e in allExercises) e.id: e};
            return CustomScrollView(
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
                    title: session.name,
                    description: description,
                    difficulty: session.difficulty,
                    isFrench: isFrench,
                  ),
                  actions: const [SizedBox(width: 48)],
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
                        // Meta row
                        _MetaRow(session: session, isFrench: isFrench),
                        const SizedBox(height: AppSpacing.md),
                        // Done banner
                        if (isDone)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success
                                  .withValues(alpha: AppOpacity.subtle),
                              borderRadius: BorderRadius.circular(AppRadii.md),
                              border: Border.all(
                                color: AppColors.success
                                    .withValues(alpha: AppOpacity.firm),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.success,
                                  size: 20,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  isFrench
                                      ? 'Session effectuée aujourd\'hui !'
                                      : 'Session done today!',
                                  style: const TextStyle(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (isDone) const SizedBox(height: AppSpacing.md),
                        // Exercises section header
                        _SectionHeader(
                          icon: Icons.fitness_center_rounded,
                          title: isFrench ? 'Exercices' : 'Exercises',
                        ),
                      ],
                    ),
                  ),
                ),
                // Exercise list
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppLayout.pageMargin,
                    AppSpacing.xs,
                    AppLayout.pageMargin,
                    0,
                  ),
                  sliver: SliverList.builder(
                    itemCount: session.workouts.length,
                    itemBuilder: (context, index) {
                      final workout = session.workouts[index];
                      final exercise = exerciseMap[workout.exerciseId];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: _ExerciseRow(
                          workout: workout,
                          exercise: exercise,
                          isFrench: isFrench,
                          onTap: exercise == null
                              ? null
                              : () => Navigator.of(context).push(
                                    ExerciseDetailScreen.route(
                                      exercise: exercise,
                                    ),
                                  ),
                        ),
                      );
                    },
                  ),
                ),
                // Start button
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppLayout.pageMargin,
                      AppSpacing.lg,
                      AppLayout.pageMargin,
                      MediaQuery.paddingOf(context).bottom + AppSpacing.xl,
                    ),
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: isDone
                            ? null
                            : () => _startSession(
                                  context,
                                  ref,
                                  allExercises,
                                  exerciseMap,
                                ),
                        icon: Icon(
                          isDone
                              ? Icons.check_rounded
                              : Icons.play_arrow_rounded,
                        ),
                        label: Text(
                          isDone
                              ? (isFrench ? 'Déjà effectuée' : 'Already done')
                              : (isFrench
                                  ? 'Démarrer la session'
                                  : 'Start Session'),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'AppFontMedium',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor:
                              isDone ? AppColors.success : AppColors.primary,
                          disabledBackgroundColor: AppColors.success
                              .withValues(alpha: AppOpacity.prominent),
                          disabledForegroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadii.lg),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(
              isFrench
                  ? 'Impossible de charger les exercices.'
                  : 'Could not load exercises.',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }

  void _startSession(
    BuildContext context,
    WidgetRef ref,
    List<Exercise> allExercises,
    Map<String, Exercise> exerciseMap,
  ) {
    final seeded = session.workouts
        .map((w) => exerciseMap[w.exerciseId])
        .whereType<Exercise>()
        .toList();

    Navigator.of(context)
        .push(
      MaterialPageRoute<void>(
        builder: (_) => WorkoutExecutionScreen(
          session: session,
          seededExercises: seeded,
        ),
      ),
    )
        .then((_) {
      // Mark session as done for today
      ref
          .read(completedTodaySessionIdsProvider.notifier)
          .update((s) => {...s, session.id});
      // Persist to history
      ref.read(sessionHistoryActionsProvider).addEntry(
            SessionHistoryEntry(
              sessionId: session.id,
              sessionName: session.name,
              durationDisplay: session.durationDisplay,
              completedAt: DateTime.now(),
            ),
          );
    });
  }
}

// ---------------------------------------------------------------------------
// Meta row
// ---------------------------------------------------------------------------

class _MetaRow extends StatelessWidget {
  final Session session;
  final bool isFrench;

  const _MetaRow({required this.session, required this.isFrench});

  @override
  Widget build(BuildContext context) {
    return Row(
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
        if (session.restBetweenExercises != 120) ...[
          const SizedBox(width: AppSpacing.xs),
          _MetaChip(
            icon: Icons.pause_circle_outline_rounded,
            label:
                '${session.restBetweenExercises}s ${isFrench ? 'repos' : 'rest'}',
          ),
        ],
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
// Exercise row
// ---------------------------------------------------------------------------

class _ExerciseRow extends StatelessWidget {
  final WorkoutConfig workout;
  final Exercise? exercise;
  final bool isFrench;
  final VoidCallback? onTap;

  const _ExerciseRow({
    required this.workout,
    required this.exercise,
    required this.isFrench,
    required this.onTap,
  });

  String _configLabel(WorkoutConfig config, bool isFrench) {
    if (config is SetsConfig) {
      return '${config.sets} × ${config.reps} reps';
    } else if (config is TabataConfig) {
      return 'Tabata · ${config.rounds} rounds · ${config.workTime}s/${config.restTime}s';
    } else if (config is TimedConfig) {
      return '${config.duration}s';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final String name = exercise != null
        ? exercise!.getLocalizedName(context)
        : (isFrench ? 'Exercice inconnu' : 'Unknown exercise');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.md),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color:
                  AppColors.primaryLight.withValues(alpha: AppOpacity.medium),
            ),
            boxShadow: [
              BoxShadow(
                color:
                    AppColors.primaryLight.withValues(alpha: AppOpacity.faint),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                // Exercise icon / thumbnail
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPastel
                        .withValues(alpha: AppOpacity.firm),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'AppFontMedium',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _configLabel(workout, isFrench),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.primaryLight,
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
    return const AppBottomInsetSurface();
  }
}
