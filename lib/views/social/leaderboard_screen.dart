import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/models/leaderboard_entry.dart';
import 'package:workin_fit/providers/leaderboard_providers.dart';
import 'package:workin_fit/core/theme/app_opacity.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Leaderboard',
          style: TextStyle(
            fontFamily: 'AppFontMedium',
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
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
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LeaderboardTab(
            type: LeaderboardType.streak,
            onRefresh: _refresh,
          ),
          _LeaderboardTab(
            type: LeaderboardType.workouts,
            onRefresh: _refresh,
          ),
        ],
      ),
    );
  }
}

// ─── Tab ──────────────────────────────────────────────────────────────────────

class _LeaderboardTab extends ConsumerWidget {
  final LeaderboardType type;
  final Future<void> Function() onRefresh;

  const _LeaderboardTab({required this.type, required this.onRefresh});

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
              TextButton(
                onPressed: onRefresh,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (entries) {
        if (entries.isEmpty) {
          return _EmptyLeaderboard(type: type);
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
                itemBuilder: (context, i) =>
                    _LeaderboardTile(entry: entries[i]),
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
    final isTop3 = entry.rank <= 3;

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
            _RankBadge(rank: entry.rank, isTop3: isTop3),
            const SizedBox(width: AppSpacing.sm),
            _Avatar(photoUrl: entry.photoUrl, username: entry.username),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                entry.isCurrentUser ? '${entry.username} (you)' : entry.username,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight:
                      entry.isCurrentUser ? FontWeight.w700 : FontWeight.w600,
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

// ─── Rank badge ───────────────────────────────────────────────────────────────

class _RankBadge extends StatelessWidget {
  final int rank;
  final bool isTop3;

  const _RankBadge({required this.rank, required this.isTop3});

  @override
  Widget build(BuildContext context) {
    if (isTop3) {
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

// ─── Value chip ───────────────────────────────────────────────────────────────

class _ValueChip extends StatelessWidget {
  final LeaderboardEntry entry;

  const _ValueChip({required this.entry});

  @override
  Widget build(BuildContext context) {
    // Determined by which tab this tile is rendered in — we don't have
    // the type here, but we can infer from the LeaderboardEntry's value
    // label via the provider. Instead we just show the numeric value
    // and rely on the tab title (Streaks 🔥 / Workouts 💪) for context.
    final label = '${entry.value}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: entry.isCurrentUser
            ? AppColors.primary.withValues(alpha: AppOpacity.light)
            : AppColors.babyBlueIce.withValues(alpha: AppOpacity.medium),
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      child: Text(
        label,
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

// ─── Sticky "my rank" bar ─────────────────────────────────────────────────────

class _StickyMyRankBar extends StatelessWidget {
  final LeaderboardEntry entry;
  final LeaderboardType type;

  const _StickyMyRankBar({required this.entry, required this.type});

  @override
  Widget build(BuildContext context) {
    final medal = entry.rank <= 3
        ? ['🥇', '🥈', '🥉'][entry.rank - 1]
        : '#${entry.rank}';
    final suffix = type == LeaderboardType.streak ? 'day streak' : 'workouts';
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
          Text(
            medal,
            style: const TextStyle(fontSize: 20),
          ),
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
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryDarker,
      backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
          ? CachedNetworkImageProvider(photoUrl!) as ImageProvider
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
        child: avatar,
      );
    }

    return avatar;
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyLeaderboard extends StatelessWidget {
  final LeaderboardType type;

  const _EmptyLeaderboard({required this.type});

  @override
  Widget build(BuildContext context) {
    final isStreak = type == LeaderboardType.streak;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isStreak ? '🔥' : '💪',
              style: const TextStyle(fontSize: 56),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Add friends to see\nhow you compare!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: AppOpacity.bold),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
