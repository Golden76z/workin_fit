import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/models/achievement.dart';
import 'package:workin_fit/providers/achievement_providers.dart';

class AchievementsPage extends ConsumerWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(achievementsProvider);
    final statsAsync = ref.watch(achievementStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Trophies',
          style: TextStyle(
            fontFamily: 'AppFontMedium',
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () {
              ref.invalidate(achievementsProvider);
              ref.invalidate(achievementStatsProvider);
            },
          ),
        ],
      ),
      body: achievementsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  size: 48,
                  color: AppColors.babyBlueIce.withValues(alpha: 0.6),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Could not load achievements',
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () => ref.invalidate(achievementsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (achievements) {
          final stats = statsAsync.valueOrNull ?? {};
          final unlockedCount = achievements.where((a) => a.isUnlocked).length;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _SummaryBanner(
                  unlocked: unlockedCount,
                  total: achievements.length,
                ),
              ),
              for (final category in AchievementCategory.values)
                _CategorySection(
                  category: category,
                  achievements: achievements
                      .where((a) => a.definition.category == category)
                      .toList(),
                  currentValue: stats[category] ?? 0,
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 104)),
            ],
          );
        },
      ),
    );
  }
}

// ─── Summary banner ───────────────────────────────────────────────────────────

class _SummaryBanner extends StatelessWidget {
  final int unlocked;
  final int total;

  const _SummaryBanner({required this.unlocked, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? unlocked / total : 0.0;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadii.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 44)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$unlocked / $total Trophies',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${(pct * 100).round()}% complete',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Category section ─────────────────────────────────────────────────────────

class _CategorySection extends StatelessWidget {
  final AchievementCategory category;
  final List<Achievement> achievements;
  final int currentValue;

  const _CategorySection({
    required this.category,
    required this.achievements,
    required this.currentValue,
  });

  String get _categoryTitle {
    switch (category) {
      case AchievementCategory.totalWorkouts:
        return 'Total Workouts';
      case AchievementCategory.streakMilestone:
        return 'Streak Milestones';
      case AchievementCategory.exerciseMastery:
        return 'Exercise Mastery';
      case AchievementCategory.programsCompleted:
        return 'Programs Completed';
    }
  }

  String get _categorySubtitle {
    switch (category) {
      case AchievementCategory.totalWorkouts:
        return '$currentValue workouts completed';
      case AchievementCategory.streakMilestone:
        return 'Best streak: $currentValue days';
      case AchievementCategory.exerciseMastery:
        return '$currentValue total reps';
      case AchievementCategory.programsCompleted:
        return '$currentValue programs completed';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sort: bronze → silver → gold
    final sorted = List<Achievement>.from(achievements)
      ..sort((a, b) => a.definition.rank.index.compareTo(b.definition.rank.index));

    // Find the next locked achievement to highlight progress
    final nextLocked = sorted.where((a) => !a.isUnlocked).firstOrNull;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.xxs,
                bottom: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Text(
                    sorted.isNotEmpty ? sorted.first.definition.icon : '',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    _categoryTitle,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _categorySubtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (nextLocked != null)
              _ProgressBar(
                current: currentValue,
                target: nextLocked.definition.targetValue,
              ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: sorted
                  .map((a) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xxs,
                          ),
                          child: _TrophyCard(achievement: a),
                        ),
                      ),)
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Progress bar ─────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  final int current;
  final int target;

  const _ProgressBar({required this.current, required this.target});

  @override
  Widget build(BuildContext context) {
    final pct = (current / target).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.sm),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 5,
              backgroundColor: AppColors.babyBlueIce.withValues(alpha: 0.3),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$current / $target',
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.6),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Trophy card ──────────────────────────────────────────────────────────────

class _TrophyCard extends StatelessWidget {
  final Achievement achievement;

  const _TrophyCard({required this.achievement});

  Color get _rankColor {
    switch (achievement.definition.rank) {
      case AchievementRank.bronze:
        return const Color(0xFFCD7F32);
      case AchievementRank.silver:
        return const Color(0xFFA8A9AD);
      case AchievementRank.gold:
        return const Color(0xFFFFD700);
    }
  }

  String get _rankLabel {
    switch (achievement.definition.rank) {
      case AchievementRank.bronze:
        return 'Bronze';
      case AchievementRank.silver:
        return 'Silver';
      case AchievementRank.gold:
        return 'Gold';
    }
  }

  String get _trophyEmoji {
    switch (achievement.definition.rank) {
      case AchievementRank.bronze:
        return '🥉';
      case AchievementRank.silver:
        return '🥈';
      case AchievementRank.gold:
        return '🥇';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool unlocked = achievement.isUnlocked;
    final Color rankColor = _rankColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: unlocked ? AppColors.surface : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: unlocked
              ? rankColor.withValues(alpha: 0.6)
              : AppColors.babyBlueIce.withValues(alpha: 0.3),
          width: unlocked ? 2 : 1,
        ),
        boxShadow: unlocked
            ? [
                BoxShadow(
                  color: rankColor.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Trophy emoji or locked icon
            Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  unlocked ? _trophyEmoji : '🔒',
                  style: TextStyle(
                    fontSize: 32,
                    color: unlocked ? null : Colors.black,
                  ),
                ),
                if (!unlocked)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.babyBlueIce.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            // Rank label chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: unlocked
                    ? rankColor.withValues(alpha: 0.15)
                    : AppColors.babyBlueIce.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Text(
                _rankLabel,
                style: TextStyle(
                  color: unlocked
                      ? rankColor
                      : AppColors.textSecondary.withValues(alpha: 0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            // Title
            Text(
              achievement.definition.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: unlocked
                    ? AppColors.textPrimary
                    : AppColors.textSecondary.withValues(alpha: 0.5),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            // Description
            Text(
              achievement.definition.description,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textSecondary.withValues(
                  alpha: unlocked ? 0.7 : 0.4,
                ),
                fontSize: 10,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
