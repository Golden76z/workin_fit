import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_chrome.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/features/warmup/presentation/screens/warmup_category_screen.dart';
import 'package:workin_fit/features/workout/presentation/screens/exercise_list_screen.dart';
import 'package:workin_fit/features/workout/presentation/screens/workout_execution_screen.dart';
import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/providers/auth_provider.dart';
import 'package:workin_fit/providers/warmup_providers.dart';
import 'package:workin_fit/providers/workout_providers.dart';
import 'package:workin_fit/views/auth/authentication_view.dart';
import 'package:workin_fit/core/theme/app_opacity.dart';

class HomeDashboardTab extends ConsumerStatefulWidget {
  const HomeDashboardTab({super.key});

  @override
  ConsumerState<HomeDashboardTab> createState() => _HomeDashboardTabState();
}

class _HomeDashboardTabState extends ConsumerState<HomeDashboardTab>
    with AutomaticKeepAliveClientMixin<HomeDashboardTab> {
  @override
  bool get wantKeepAlive => true;

  Future<void> _onRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final user = ref.watch(currentUserProvider);
    final bool isFrench = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('fr');

    final String displayName = _resolveDisplayName(
      email: user?.email,
      isFrench: isFrench,
    );
    final String greeting = _greeting(isFrench: isFrench);

    return AppSystemOverlayRegion(
      style: AppChrome.homeOverlay,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              // ─── Banner ───────────────────────────────────────────
              _HomeBannerSliver(
                greeting: greeting,
                displayName: displayName,
                isFrench: isFrench,
              ),

              // ─── Body sections ────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.md,
                  0,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(<Widget>[
                    // Session of the Day
                    _SessionOfTheDayCard(isFrench: isFrench),
                    const SizedBox(height: AppSpacing.md),

                    // Daily Challenge
                    _DailyChallengeCard(isFrench: isFrench),
                    const SizedBox(height: AppSpacing.lg),

                    // Warmup Selector
                    _SectionTitle(
                      title: isFrench ? 'Échauffement' : 'Warmup',
                      subtitle: isFrench ? 'Commencez doucement' : 'Start easy',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _WarmupSelector(isFrench: isFrench),
                    const SizedBox(height: AppSpacing.lg),

                    // Programs Carousel
                    _SectionTitle(
                      title: isFrench ? 'Programmes' : 'Programs',
                      subtitle: isFrench
                          ? 'Suivez un plan structuré'
                          : 'Follow a structured plan',
                      actionLabel: isFrench ? 'Voir tout' : 'See all',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const _ProgramsCarousel(),
                    const SizedBox(height: AppSpacing.lg),

                    // Sessions Carousel
                    _SectionTitle(
                      title: isFrench ? 'Séances' : 'Sessions',
                      subtitle: isFrench
                          ? 'Entraînements disponibles'
                          : 'Available workouts',
                      actionLabel: isFrench ? 'Voir tout' : 'See all',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _SessionsCarousel(isFrench: isFrench),
                    const SizedBox(height: AppSpacing.lg),

                    // Quick Access: Exercises
                    _QuickAccessRow(
                      isFrench: isFrench,
                      onExercisesTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ExerciseListScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Logout
                    _LogoutButton(
                      isFrench: isFrench,
                      onLogout: () async {
                        try {
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute<void>(
                                builder: (_) => const AuthenticationView(
                                  initialTabIndex: 1,
                                ),
                              ),
                              (Route<dynamic> route) => false,
                            );
                          }
                          await ref.read(authActionsProvider).signOut();
                        } catch (_) {}
                      },
                    ),

                    // Bottom padding — floating nav bar clearance
                    const SizedBox(height: 104),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _resolveDisplayName({
    required String? email,
    required bool isFrench,
  }) {
    if (email == null || email.isEmpty) {
      return isFrench ? 'athlète' : 'athlete';
    }
    final String local = email.split('@').first;
    // Capitalise first letter, replace dots/underscores with spaces
    final String readable = local
        .replaceAll(RegExp(r'[._]'), ' ')
        .split(' ')
        .where((String s) => s.isNotEmpty)
        .first;
    return readable[0].toUpperCase() + readable.substring(1);
  }

  String _greeting({required bool isFrench}) {
    final int hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return isFrench ? 'Bonjour' : 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      return isFrench ? 'Bon après-midi' : 'Good afternoon';
    } else if (hour >= 17 && hour < 21) {
      return isFrench ? 'Bonsoir' : 'Good evening';
    } else {
      return isFrench ? 'Bonne nuit' : 'Good night';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Banner
// ─────────────────────────────────────────────────────────────────────────────

class _HomeBannerSliver extends StatelessWidget {
  final String greeting;
  final String displayName;
  final bool isFrench;

  const _HomeBannerSliver({
    required this.greeting,
    required this.displayName,
    required this.isFrench,
  });

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    return SliverToBoxAdapter(
      child: ClipPath(
        clipper: _ArchClipper(),
        child: AppTopBarBackground(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              topPadding + AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg + AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Greeting
                Text(
                  '$greeting,',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: AppOpacity.bold),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'AppFontMedium',
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Stats row
                _BannerStatsRow(isFrench: isFrench),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BannerStatsRow extends ConsumerWidget {
  final bool isFrench;
  const _BannerStatsRow({required this.isFrench});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(streakDataProvider);
    final int currentStreak = streakAsync.when(
      data: (d) => (d['currentStreak'] as int?) ?? 0,
      loading: () => 0,
      error: (_, __) => 0,
    );

    return Row(
      children: <Widget>[
        _StatPill(
          icon: Icons.local_fire_department_rounded,
          value: '$currentStreak',
          label: isFrench ? 'jours' : 'day streak',
          color: AppColors.warning,
        ),
        const SizedBox(width: AppSpacing.xs),
        _StatPill(
          icon: Icons.fitness_center_rounded,
          value: '—',
          label: isFrench ? 'cette semaine' : 'this week',
          color: AppColors.frostedCyan,
        ),
        const SizedBox(width: AppSpacing.xs),
        _StatPill(
          icon: Icons.emoji_events_rounded,
          value: '—',
          label: isFrench ? 'succès' : 'trophies',
          color: AppColors.babyBlueIce,
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatPill({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: AppOpacity.light),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(
          color: Colors.white.withValues(alpha: AppOpacity.soft),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: AppOpacity.moderate),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: AppSpacing.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: AppOpacity.strong),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Wave clipper
// ─────────────────────────────────────────────────────────────────────────────

class _ArchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(0, size.height - 28);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height + 28,
      size.width,
      size.height - 28,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Section title
// ─────────────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? actionLabel;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        // Left accent bar
        Container(
          width: 3,
          height: 22,
          margin: const EdgeInsets.only(right: AppSpacing.xs),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[AppColors.primary, AppColors.primaryLight],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'AppFontMedium',
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '· $subtitle',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xxs,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: AppColors.primary,
              backgroundColor:
                  AppColors.primary.withValues(alpha: AppOpacity.whisper),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
            ),
            child: Text(
              actionLabel!,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Session of the Day
// ─────────────────────────────────────────────────────────────────────────────

class _SessionOfTheDayCard extends StatelessWidget {
  final bool isFrench;
  const _SessionOfTheDayCard({required this.isFrench});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              AppColors.primaryDark,
              AppColors.primary,
              AppColors.cornflowerBlue,
            ],
            stops: <double>[0.0, 0.45, 1.0],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.primary.withValues(alpha: AppOpacity.moderate),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: Stack(
            children: <Widget>[
              // Decorative ring — top-right
              Positioned(
                right: -36,
                top: -36,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: AppOpacity.soft),
                      width: 28,
                    ),
                  ),
                ),
              ),
              // Decorative ring — bottom-left
              Positioned(
                left: -20,
                bottom: -44,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: AppOpacity.subtle),
                      width: 20,
                    ),
                  ),
                ),
              ),
              // Card content
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                Colors.white.withValues(alpha: AppOpacity.soft),
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                            border: Border.all(
                              color: Colors.white
                                  .withValues(alpha: AppOpacity.medium),
                            ),
                          ),
                          child: Text(
                            isFrench ? 'SÉANCE DU JOUR' : 'SESSION OF THE DAY',
                            style: TextStyle(
                              color: Colors.white
                                  .withValues(alpha: AppOpacity.high),
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                Colors.white.withValues(alpha: AppOpacity.soft),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'Full Body Power',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'AppFontMedium',
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      isFrench
                          ? 'Circuit complet — force et cardio combinés'
                          : 'Full circuit — strength and cardio combined',
                      style: TextStyle(
                        color:
                            Colors.white.withValues(alpha: AppOpacity.strong),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: <Widget>[
                        const _SessionMetaChip(
                          icon: Icons.timer_outlined,
                          label: '45 min',
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        _SessionMetaChip(
                          icon: Icons.bolt_rounded,
                          label: isFrench ? '8 exercices' : '8 exercises',
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        _SessionMetaChip(
                          icon: Icons.bar_chart_rounded,
                          label: isFrench ? 'Intermédiaire' : 'Intermediate',
                        ),
                      ],
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

class _SessionMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SessionMetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: AppOpacity.light),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border:
            Border.all(color: Colors.white.withValues(alpha: AppOpacity.soft)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Daily Challenge
// ─────────────────────────────────────────────────────────────────────────────

class _DailyChallengeCard extends StatelessWidget {
  final bool isFrench;
  const _DailyChallengeCard({required this.isFrench});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(
            color: AppColors.warning.withValues(alpha: AppOpacity.mild),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.warning.withValues(alpha: AppOpacity.faint),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          AppColors.warning,
                          AppColors.warningSoft,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          isFrench ? 'DÉFI DU JOUR' : 'DAILY CHALLENGE',
                          style: const TextStyle(
                            color: AppColors.warning,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isFrench
                              ? '100 pompes en moins de 10 min'
                              : '100 push-ups in under 10 min',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'AppFontMedium',
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: <Widget>[
                            const Icon(
                              Icons.people_outline_rounded,
                              size: 11,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              isFrench
                                  ? '247 participants aujourd\'hui'
                                  : '247 participants today',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.warning,
                    size: 22,
                  ),
                ],
              ),
            ),
            // Progress bar strip
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(AppRadii.sm),
              ),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.xs,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          isFrench ? 'Progression' : 'Progress',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Text(
                          '42 / 100',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 4,
                    color:
                        AppColors.warning.withValues(alpha: AppOpacity.whisper),
                    child: FractionallySizedBox(
                      widthFactor: 0.42,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[
                              AppColors.warning,
                              AppColors.warningSoft,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Warmup Selector
// ─────────────────────────────────────────────────────────────────────────────

class _WarmupSelector extends ConsumerStatefulWidget {
  final bool isFrench;
  const _WarmupSelector({required this.isFrench});

  @override
  ConsumerState<_WarmupSelector> createState() => _WarmupSelectorState();
}

class _WarmupSelectorState extends ConsumerState<_WarmupSelector> {
  static const List<int> _durations = <int>[2, 5, 10];

  static const _categoryLabels = {
    WarmupCategory.fullBody:  ('Full Body',   'Corps entier'),
    WarmupCategory.upperBody: ('Upper Body',  'Haut du corps'),
    WarmupCategory.lowerBody: ('Lower Body',  'Bas du corps'),
    WarmupCategory.core:      ('Core',        'Abdominaux'),
    WarmupCategory.cardio:    ('Cardio',      'Cardio'),
  };

  @override
  Widget build(BuildContext context) {
    final category = ref.watch(warmupCategoryProvider);
    final duration = ref.watch(warmupDurationProvider);
    final selectedIndex = _durations.indexOf(duration);

    final labels = _categoryLabels[category]!;
    final categoryLabel = widget.isFrench ? labels.$2 : labels.$1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Category chip
        GestureDetector(
          onTap: () => Navigator.of(context).push(WarmupCategoryScreen.route()),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: AppOpacity.light),
              borderRadius: BorderRadius.circular(AppRadii.xl),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: AppOpacity.moderate),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.tune_rounded, size: 14, color: AppColors.primary),
                const SizedBox(width: AppSpacing.xxs),
                Text(
                  categoryLabel,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: AppSpacing.xxs),
                const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.primary),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Duration buttons
        Row(
          children: List<Widget>.generate(
            _durations.length,
            (int i) {
              final int minutes = _durations[i];
              final bool isSelected = selectedIndex == i;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: i < _durations.length - 1 ? AppSpacing.xs : 0,
                  ),
                  child: _WarmupDurationButton(
                    minutes: minutes,
                    isSelected: isSelected,
                    label: 'min',
                    onTap: () {
                      ref.read(warmupDurationProvider.notifier).state = minutes;
                    },
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Start button
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              final routine = ref.read(warmupRoutineProvider);
              final exercises = ref.read(warmupExercisesProvider);
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => WorkoutExecutionScreen(
                    session: routine.toSession(),
                    seededExercises: exercises,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.play_arrow_rounded, size: 20),
            label: Text(
              widget.isFrench
                  ? 'Démarrer $duration min d\'échauffement'
                  : 'Start $duration min warmup',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WarmupDurationButton extends StatelessWidget {
  final int minutes;
  final bool isSelected;
  final String label;
  final VoidCallback onTap;

  const _WarmupDurationButton({
    required this.minutes,
    required this.isSelected,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.primaryLight.withValues(alpha: AppOpacity.moderate),
          ),
          boxShadow: isSelected
              ? <BoxShadow>[
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: AppOpacity.mild),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: <Widget>[
            Text(
              '$minutes',
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                fontFamily: 'AppFontMedium',
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white.withValues(alpha: AppOpacity.bold)
                    : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Programs Carousel
// ─────────────────────────────────────────────────────────────────────────────

class _ProgramsCarousel extends StatelessWidget {
  const _ProgramsCarousel();

  static const List<_ProgramData> _programs = <_ProgramData>[
    _ProgramData(
      title: 'Full Body Blast',
      weeks: 6,
      sessions: 18,
      level: 'Beginner',
      levelFr: 'Débutant',
      icon: Icons.accessibility_new_rounded,
      color: AppColors.electricSapphire,
    ),
    _ProgramData(
      title: 'Upper Body\nFocus',
      weeks: 4,
      sessions: 12,
      level: 'Intermediate',
      levelFr: 'Intermédiaire',
      icon: Icons.sports_gymnastics_rounded,
      color: AppColors.cornflowerBlue,
    ),
    _ProgramData(
      title: 'Core & Cardio',
      weeks: 8,
      sessions: 24,
      level: 'Advanced',
      levelFr: 'Avancé',
      icon: Icons.directions_run_rounded,
      color: AppColors.primaryDark,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isFrench = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('fr');

    return SizedBox(
      height: 178,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        itemCount: _programs.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (BuildContext context, int index) {
          return _ProgramCard(
            data: _programs[index],
            isFrench: isFrench,
          );
        },
      ),
    );
  }
}

class _ProgramData {
  final String title;
  final int weeks;
  final int sessions;
  final String level;
  final String levelFr;
  final IconData icon;
  final Color color;

  const _ProgramData({
    required this.title,
    required this.weeks,
    required this.sessions,
    required this.level,
    required this.levelFr,
    required this.icon,
    required this.color,
  });
}

class _ProgramCard extends StatelessWidget {
  final _ProgramData data;
  final bool isFrench;

  const _ProgramCard({required this.data, required this.isFrench});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              data.color,
              data.color.withValues(alpha: AppOpacity.prominent),
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadii.sm),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: data.color.withValues(alpha: AppOpacity.mild),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: AppOpacity.soft),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Icon(data.icon, color: Colors.white, size: 22),
              ),
              const Spacer(),
              Text(
                data.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'AppFontMedium',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                isFrench
                    ? '${data.weeks} sem · ${data.sessions} séances'
                    : '${data.weeks}wk · ${data.sessions} sessions',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: AppOpacity.strong),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: AppOpacity.muted),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Text(
                  isFrench ? data.levelFr : data.level,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
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

// ─────────────────────────────────────────────────────────────────────────────
// Sessions Carousel
// ─────────────────────────────────────────────────────────────────────────────

class _SessionsCarousel extends StatelessWidget {
  final bool isFrench;
  const _SessionsCarousel({required this.isFrench});

  static const List<_SessionData> _sessions = <_SessionData>[
    _SessionData(
      title: 'Push Day',
      titleFr: 'Jour Push',
      duration: '45 min',
      exercises: 6,
      level: 'Intermediate',
      levelFr: 'Intermédiaire',
      levelColor: AppColors.warning,
      icon: Icons.fitness_center_rounded,
    ),
    _SessionData(
      title: 'Leg Day',
      titleFr: 'Jour Jambes',
      duration: '60 min',
      exercises: 8,
      level: 'Beginner',
      levelFr: 'Débutant',
      levelColor: AppColors.success,
      icon: Icons.directions_walk_rounded,
    ),
    _SessionData(
      title: 'HIIT Circuit',
      titleFr: 'Circuit HIIT',
      duration: '30 min',
      exercises: 10,
      level: 'Advanced',
      levelFr: 'Avancé',
      levelColor: AppColors.error,
      icon: Icons.bolt_rounded,
    ),
    _SessionData(
      title: 'Pull Day',
      titleFr: 'Jour Pull',
      duration: '50 min',
      exercises: 7,
      level: 'Intermediate',
      levelFr: 'Intermédiaire',
      levelColor: AppColors.warning,
      icon: Icons.open_with_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        itemCount: _sessions.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (BuildContext context, int index) {
          return _SessionCard(data: _sessions[index], isFrench: isFrench);
        },
      ),
    );
  }
}

class _SessionData {
  final String title;
  final String titleFr;
  final String duration;
  final int exercises;
  final String level;
  final String levelFr;
  final Color levelColor;
  final IconData icon;

  const _SessionData({
    required this.title,
    required this.titleFr,
    required this.duration,
    required this.exercises,
    required this.level,
    required this.levelFr,
    required this.levelColor,
    required this.icon,
  });
}

class _SessionCard extends StatelessWidget {
  final _SessionData data;
  final bool isFrench;

  const _SessionCard({required this.data, required this.isFrench});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(
            color: AppColors.primaryLight.withValues(alpha: AppOpacity.mild),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight
                          .withValues(alpha: AppOpacity.light),
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                    child: Icon(
                      data.icon,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color:
                          data.levelColor.withValues(alpha: AppOpacity.subtle),
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      border: Border.all(
                        color:
                            data.levelColor.withValues(alpha: AppOpacity.mild),
                      ),
                    ),
                    child: Text(
                      isFrench ? data.levelFr : data.level,
                      style: TextStyle(
                        color: data.levelColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                isFrench ? data.titleFr : data.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'AppFontMedium',
                ),
              ),
              const SizedBox(height: 3),
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.timer_outlined,
                    size: 11,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    data.duration,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(
                    Icons.fitness_center_rounded,
                    size: 11,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    isFrench
                        ? '${data.exercises} ex.'
                        : '${data.exercises} ex.',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick Access Row
// ─────────────────────────────────────────────────────────────────────────────

class _QuickAccessRow extends StatelessWidget {
  final bool isFrench;
  final VoidCallback onExercisesTap;

  const _QuickAccessRow({
    required this.isFrench,
    required this.onExercisesTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _QuickAccessCard(
            icon: Icons.fitness_center_rounded,
            label: isFrench ? 'Exercices' : 'Exercises',
            color: AppColors.electricSapphire,
            onTap: onExercisesTap,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _QuickAccessCard(
            icon: Icons.bar_chart_rounded,
            label: isFrench ? 'Statistiques' : 'Statistics',
            color: AppColors.success,
            onTap: () {},
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _QuickAccessCard(
            icon: Icons.people_rounded,
            label: isFrench ? 'Communauté' : 'Community',
            color: AppColors.warning,
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: AppOpacity.whisper),
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(color: color.withValues(alpha: AppOpacity.medium)),
        ),
        child: Column(
          children: <Widget>[
            Icon(icon, color: color, size: 26),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Logout button
// ─────────────────────────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  final bool isFrench;
  final VoidCallback onLogout;

  const _LogoutButton({required this.isFrench, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onLogout,
      icon: const Icon(Icons.logout_rounded, size: 18),
      label: Text(isFrench ? 'Se déconnecter' : 'Sign out'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        side: BorderSide(
            color: AppColors.primaryLight.withValues(alpha: AppOpacity.firm)),
        minimumSize: const Size(double.infinity, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
      ),
    );
  }
}
