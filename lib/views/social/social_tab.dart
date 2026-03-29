import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/models/leaderboard_entry.dart';
import 'package:workin_fit/providers/leaderboard_providers.dart';
import 'package:workin_fit/views/social/leaderboard_screen.dart';
import 'package:workin_fit/core/theme/app_opacity.dart';

class SocialTab extends ConsumerStatefulWidget {
  const SocialTab({super.key});

  @override
  ConsumerState<SocialTab> createState() => _SocialTabState();
}

class _SocialTabState extends ConsumerState<SocialTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  LeaderboardType _activeType = LeaderboardType.streak;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _activeType = LeaderboardType.values[_tabController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(friendLeaderboardProvider(_activeType));
  }

  void _openFullLeaderboard() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const LeaderboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            floating: true,
            snap: true,
            pinned: false,
            title: const Text(
              'Social',
              style: TextStyle(
                fontFamily: 'AppFontMedium',
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: _LeaderboardTabBar(controller: _tabController),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _EmbeddedLeaderboardTab(
              type: LeaderboardType.streak,
              onRefresh: _refresh,
              onExpand: _openFullLeaderboard,
            ),
            _EmbeddedLeaderboardTab(
              type: LeaderboardType.workouts,
              onRefresh: _refresh,
              onExpand: _openFullLeaderboard,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tab bar ──────────────────────────────────────────────────────────────────

class _LeaderboardTabBar extends StatelessWidget {
  final TabController controller;

  const _LeaderboardTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white60,
      indicatorColor: Colors.white,
      indicatorWeight: 3,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 14,
        fontFamily: 'AppFontMedium',
      ),
      tabs: const [
        Tab(text: 'Streaks 🔥'),
        Tab(text: 'Workouts 💪'),
      ],
    );
  }
}

// ─── Embedded leaderboard content ─────────────────────────────────────────────

class _EmbeddedLeaderboardTab extends ConsumerWidget {
  final LeaderboardType type;
  final Future<void> Function() onRefresh;
  final VoidCallback onExpand;

  const _EmbeddedLeaderboardTab({
    required this.type,
    required this.onRefresh,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(friendLeaderboardProvider(type));

    return async.when(
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
                color: AppColors.babyBlueIce.withValues(alpha: AppOpacity.visible),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Could not load leaderboard',
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: AppOpacity.bold),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(onPressed: onRefresh, child: const Text('Retry')),
            ],
          ),
        ),
      ),
      data: (entries) {
        if (entries.isEmpty) {
          return _EmptyState(onFindFriends: onExpand);
        }

        final currentUserEntry =
            entries.where((e) => e.isCurrentUser).firstOrNull;

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: onRefresh,
          child: Stack(
            children: [
              ListView.builder(
                padding: EdgeInsets.only(
                  top: AppSpacing.sm,
                  bottom: currentUserEntry != null ? 80 : AppSpacing.sm,
                ),
                itemCount: entries.length,
                itemBuilder: (_, i) => _LeaderboardTile(entry: entries[i]),
              ),
              if (currentUserEntry != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _StickyMyRankBar(
                    entry: currentUserEntry,
                    type: type,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Tile ─────────────────────────────────────────────────────────────────────

class _LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;

  const _LeaderboardTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: entry.isCurrentUser
            ? AppColors.primary.withValues(alpha: AppOpacity.faint)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: entry.isCurrentUser
            ? Border.all(color: AppColors.primary.withValues(alpha: AppOpacity.moderate))
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDarker.withValues(alpha: AppOpacity.trace),
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
            _RankBadge(rank: entry.rank),
            const SizedBox(width: AppSpacing.sm),
            _Avatar(photoUrl: entry.photoUrl, username: entry.username),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                entry.isCurrentUser
                    ? '${entry.username} (you)'
                    : entry.username,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: entry.isCurrentUser
                      ? FontWeight.w700
                      : FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _ValueChip(entry: entry),
          ],
        ),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;

  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    if (rank <= 3) {
      final medals = ['🥇', '🥈', '🥉'];
      return SizedBox(
        width: 32,
        child: Text(
          medals[rank - 1],
          style: const TextStyle(fontSize: 22),
          textAlign: TextAlign.center,
        ),
      );
    }
    return SizedBox(
      width: 32,
      child: Text(
        '#$rank',
        style: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: AppOpacity.prominent),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _ValueChip extends StatelessWidget {
  final LeaderboardEntry entry;

  const _ValueChip({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: entry.isCurrentUser
            ? AppColors.primary.withValues(alpha: AppOpacity.light)
            : AppColors.babyBlueIce.withValues(alpha: AppOpacity.medium),
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      child: Text(
        '${entry.value}',
        style: TextStyle(
          color: entry.isCurrentUser
              ? AppColors.primaryDarker
              : AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─── Sticky rank bar ──────────────────────────────────────────────────────────

class _StickyMyRankBar extends StatelessWidget {
  final LeaderboardEntry entry;
  final LeaderboardType type;

  const _StickyMyRankBar({required this.entry, required this.type});

  @override
  Widget build(BuildContext context) {
    final medal = entry.rank <= 3
        ? ['🥇', '🥈', '🥉'][entry.rank - 1]
        : '#${entry.rank}';
    final suffix =
        type == LeaderboardType.streak ? 'day streak' : 'workouts';
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.sm,
        bottom: AppSpacing.sm + bottomInset,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDarker.withValues(alpha: AppOpacity.medium),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(medal, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: AppSpacing.sm),
          _Avatar(
            photoUrl: entry.photoUrl,
            username: entry.username,
            radius: 18,
            borderColor: Colors.white,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Your rank',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${entry.username} · ${entry.value} $suffix',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Avatar ───────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String? photoUrl;
  final String username;
  final double radius;
  final Color? borderColor;

  const _Avatar({
    required this.username,
    this.photoUrl,
    this.radius = 22,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final inner = CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryDarker,
      backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
          ? NetworkImage(photoUrl!) as ImageProvider
          : null,
      child: photoUrl == null || photoUrl!.isEmpty
          ? Text(
              username.isNotEmpty ? username[0].toUpperCase() : '?',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: radius * 0.7,
              ),
            )
          : null,
    );

    if (borderColor != null) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor!, width: 2),
        ),
        child: inner,
      );
    }

    return inner;
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onFindFriends;

  const _EmptyState({required this.onFindFriends});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_events_rounded,
              size: 64,
              color: AppColors.babyBlueIce.withValues(alpha: AppOpacity.visible),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No one to compete with yet!',
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: AppOpacity.bold),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Add friends to see how you\nstack up on the leaderboard.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: AppOpacity.visible),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            TextButton.icon(
              onPressed: onFindFriends,
              icon: const Icon(Icons.person_add_rounded),
              label: const Text('Find Friends'),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.sm,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
