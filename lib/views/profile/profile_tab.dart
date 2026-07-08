import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:workin_fit/core/theme/app_chrome.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/features/auth/domain/auth_provider.dart';
import 'package:workin_fit/providers/workout_providers.dart'
    hide firestoreServiceProvider;
import 'package:workin_fit/views/auth/authentication_view.dart';
import 'package:workin_fit/providers/admin_providers.dart';
import 'package:workin_fit/views/admin/admin_dashboard_screen.dart';
import 'package:workin_fit/views/achievements/achievements_page.dart';
import 'package:workin_fit/views/profile/stats_graph_screen.dart';
import 'package:workin_fit/views/profile/widgets/friends_tab.dart';
import 'package:workin_fit/views/profile/widgets/streak_calendar.dart';
import 'package:workin_fit/core/theme/app_opacity.dart';
import 'package:workin_fit/widgets/app_dialog.dart';
import 'package:workin_fit/providers/locale_provider.dart';

// ─── Avatar size constants ────────────────────────────────────────────────────

const double _kAvatarRadius = 52.0;
const double _kRingWidth = 8.0;
const double _kAvatarTotalRadius = _kAvatarRadius + _kRingWidth; // 60
// Banner ends at the avatar's vertical centre (avatar straddles the boundary).
const double _kBannerHeight = 100.0;
const double _kProfileBlockRadius = AppRadii.sm;

// ─── Providers ───────────────────────────────────────────────────────────────

final _userProfileProvider =
    FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.read(firestoreServiceProvider).getUserProfile(user.uid);
});

final _profileStatsProvider =
    FutureProvider.autoDispose<({int sessions, int programs, int totalHours})>(
        (ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return (sessions: 0, programs: 0, totalHours: 0);
  final svc = ref.read(firestoreServiceProvider);
  final results = await Future.wait([
    svc.getWorkoutHistory(userId: user.uid),
    svc.getProgramsCompleted(user.uid),
  ]);
  final history = results[0] as List<Map<String, dynamic>>;
  final programs = results[1] as int;
  int totalSeconds = 0;
  for (final entry in history) {
    totalSeconds += (entry['duration'] as num?)?.toInt() ?? 0;
  }
  return (
    sessions: history.length,
    programs: programs,
    totalHours: (totalSeconds / 3600).round(),
  );
});

// ─── Main tab ────────────────────────────────────────────────────────────────

class ProfileTab extends ConsumerStatefulWidget {
  final ValueChanged<int>? onEdgeSwipe;

  const ProfileTab({
    this.onEdgeSwipe,
    super.key,
  });

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab>
    with AutomaticKeepAliveClientMixin<ProfileTab> {
  @override
  bool get wantKeepAlive => true;

  bool _uploadingImage = false;
  bool _handledEdgeSwipe = false;

  Future<void> _pickAndUploadImage() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 512,
    );
    if (picked == null) return;

    setState(() => _uploadingImage = true);
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images/${user.uid}.jpg');
      await storageRef.putFile(File(picked.path));
      final url = await storageRef.getDownloadURL();
      await user.updatePhotoURL(url);
      ref.invalidate(_userProfileProvider); // ignore: unused_result
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image.')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  Future<void> _logout() async {
    try {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (_) => const AuthenticationView(initialTabIndex: 1),
          ),
          (Route<dynamic> route) => false,
        );
      }
      await ref.read(authActionsProvider).signOut();
    } catch (_) {}
  }

  Future<void> _confirmLogout(bool isFrench) async {
    final confirmed = await AppDialog.showConfirm(
      context: context,
      title: isFrench ? 'Se déconnecter ?' : 'Log out?',
      message: isFrench
          ? 'Êtes-vous sûr de vouloir vous déconnecter ?'
          : 'Are you sure you want to log out?',
      confirmLabel: isFrench ? 'Déconnecter' : 'Log out',
      cancelLabel: isFrench ? 'Annuler' : 'Cancel',
      icon: Icons.logout_rounded,
      iconColor: AppColors.error,
      destructive: true,
    );
    if (confirmed == true) {
      await _logout();
    }
  }

  Future<void> _openEditProfile(String username) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(
        currentUsername: username,
        userId: user.uid,
        email: user.email,
      ),
    );
    // Refresh in case username was updated
    ref.invalidate(_userProfileProvider);
  }

  void _showComingSoon(bool isFrench) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isFrench ? 'Bientôt disponible !' : 'Coming soon!'),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openLanguage() {
    showDialog<void>(
      context: context,
      builder: (_) => const _LanguagePickerDialog(),
    );
  }

  void _openAchievements() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AchievementsPage(),
      ),
    );
  }

  void _openAdmin() {
    Navigator.of(context).push(AdminDashboardScreen.route());
  }

  void _openStatsGraph() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const StatsGraphScreen(),
      ),
    );
  }

  String _emailToName(String? email) {
    if (email == null || email.isEmpty) return 'Athlete';
    final local = email.split('@').first;
    final part = local
        .replaceAll(RegExp(r'[._]'), ' ')
        .split(' ')
        .where((s) => s.isNotEmpty)
        .first;
    return part[0].toUpperCase() + part.substring(1);
  }

  bool _handleTabViewEdgeSwipe(
    ScrollNotification notification,
    TabController tabController,
  ) {
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
      final bool atFirstTab = tabController.index == 0;
      final bool atLastTab = tabController.index == tabController.length - 1;

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
    final user = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(_userProfileProvider);
    final bool isAdmin = ref.watch(isAdminProvider);
    final bool isFrench = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('fr');

    final String username = profileAsync.when(
      data: (d) =>
          d?['username'] as String? ??
          user?.displayName ??
          _emailToName(user?.email),
      loading: () => user?.displayName ?? _emailToName(user?.email),
      error: (_, __) => _emailToName(user?.email),
    );

    return AppSystemOverlayRegion(
      style: AppChrome.homeOverlay,
      child: DefaultTabController(
        length: 2,
        child: Builder(
          builder: (BuildContext tabContext) {
            final TabController tabController =
                DefaultTabController.of(tabContext);
            return Scaffold(
              backgroundColor: AppColors.surfaceVariant,
              body: NestedScrollView(
                headerSliverBuilder:
                    (BuildContext ctx, bool innerBoxIsScrolled) {
                  return <Widget>[
                    // ─── Banner + header info ──────────────────────────
                    SliverOverlapAbsorber(
                      handle:
                          NestedScrollView.sliverOverlapAbsorberHandleFor(ctx),
                      sliver: _ProfileHeaderSliver(
                        username: username,
                        email: user?.email,
                        photoUrl: user?.photoURL,
                        uploadingImage: _uploadingImage,
                        isFrench: isFrench,
                        onEditAvatar: _pickAndUploadImage,
                        onEditProfile: () => _openEditProfile(username),
                      ),
                    ),
                    // ─── Sticky tab bar ────────────────────────────────
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _ProfileTabBarDelegate(isFrench: isFrench),
                    ),
                  ];
                },
                body: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification notification) {
                    return _handleTabViewEdgeSwipe(
                      notification,
                      tabController,
                    );
                  },
                  child: TabBarView(
                    controller: tabController,
                    children: <Widget>[
                      // ─── Tab 0: Profile ────────────────────────────────
                      Builder(
                        builder: (BuildContext innerContext) =>
                            RefreshIndicator(
                          onRefresh: () async {
                            ref.invalidate(_userProfileProvider);
                            ref.invalidate(streakDataProvider);
                            await Future<void>.delayed(
                              const Duration(milliseconds: 600),
                            );
                          },
                          color: AppColors.primary,
                          backgroundColor: AppColors.surface,
                          child: CustomScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: <Widget>[
                              SliverOverlapInjector(
                                handle:
                                    NestedScrollView.sliverOverlapAbsorberHandleFor(
                                        innerContext,
                                    ),
                              ),
                              SliverPadding(
                                padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.xs,
                                  AppSpacing.sm,
                                  AppSpacing.xs,
                                  0,
                                ),
                                sliver: SliverToBoxAdapter(
                                  child: _ProfileSection(
                                    title: isFrench
                                        ? 'Série & Compte'
                                        : 'Streak & Account',
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        StreakCalendar(isFrench: isFrench),
                                        Divider(
                                          height: 1,
                                          color: AppColors.babyBlueIce
                                              .withValues(
                                            alpha: AppOpacity.visible,
                                          ),
                                        ),
                                        _SectionSubheader(
                                          label:
                                              isFrench ? 'Compte' : 'Account',
                                        ),
                                        _MenuList(
                                          items: <_MenuItem>[
                                            if (isAdmin)
                                              _MenuItem(
                                                icon: Icons
                                                    .admin_panel_settings_rounded,
                                                label: isFrench
                                                    ? 'Administration'
                                                    : 'Admin',
                                                onTap: _openAdmin,
                                              ),
                                            _MenuItem(
                                              icon: Icons.insights_rounded,
                                              label: isFrench
                                                  ? 'Statistiques & Graphiques'
                                                  : 'Stats & Graph',
                                              onTap: _openStatsGraph,
                                            ),
                                            _MenuItem(
                                              icon:
                                                  Icons.emoji_events_rounded,
                                              label: isFrench
                                                  ? 'Trophées'
                                                  : 'Trophies',
                                              onTap: _openAchievements,
                                            ),
                                            _MenuItem(
                                              icon: Icons.language_rounded,
                                              label: isFrench
                                                  ? 'Langue'
                                                  : 'Language',
                                              onTap: _openLanguage,
                                            ),
                                            _MenuItem(
                                              icon: Icons.settings_rounded,
                                              label: isFrench
                                                  ? 'Paramètres'
                                                  : 'Settings',
                                              onTap: () =>
                                                  _showComingSoon(isFrench),
                                            ),
                                            _MenuItem(
                                              icon:
                                                  Icons.lock_outline_rounded,
                                              label: isFrench
                                                  ? 'Confidentialité'
                                                  : 'Privacy',
                                              onTap: () =>
                                                  _showComingSoon(isFrench),
                                              isLast: true,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SliverPadding(
                                padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.xs,
                                  AppSpacing.sm,
                                  AppSpacing.xs,
                                  AppSpacing.sm,
                                ),
                                sliver: SliverToBoxAdapter(
                                  child: _LogoutButton(
                                    label: isFrench
                                        ? 'Se déconnecter'
                                        : 'Log out',
                                    onTap: () => _confirmLogout(isFrench),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ─── Tab 1: Friends ────────────────────────────────
                      FriendsTabContent(isFrench: isFrench),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile header — gradient banner + overlapping avatar + info + stats + button
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileHeaderSliver extends StatelessWidget {
  final String username;
  final String? email;
  final String? photoUrl;
  final bool uploadingImage;
  final bool isFrench;
  final VoidCallback onEditAvatar;
  final VoidCallback onEditProfile;

  const _ProfileHeaderSliver({
    required this.username,
    required this.email,
    required this.photoUrl,
    required this.uploadingImage,
    required this.isFrench,
    required this.onEditAvatar,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    return SliverToBoxAdapter(
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          // ── Banner + white section ────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Top banner — gradient bg + username/email + edit FAB
              SizedBox(
                height: _kBannerHeight + topPadding,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    const Positioned.fill(child: AppTopBarBackground()),

                    // Username — right of avatar space, inside banner
                    Positioned(
                      top: topPadding +
                          _kBannerHeight -
                          _kAvatarTotalRadius +
                          AppSpacing.lg,
                      left: AppSpacing.lg +
                          _kAvatarTotalRadius * 2 +
                          AppSpacing.md,
                      right: 60,
                      child: Text(
                        username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'AppFontMedium',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),

                    // Edit FAB — bottom-right of banner
                    Positioned(
                      bottom: AppSpacing.sm,
                      right: AppSpacing.md,
                      child: _BannerEditButton(
                        label: isFrench ? 'Modifier' : 'Edit',
                        onTap: onEditProfile,
                      ),
                    ),
                  ],
                ),
              ),

              // White section — top padding accommodates avatar overlap
              Container(
                color: AppColors.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(
                      height: _kAvatarTotalRadius + AppSpacing.xl,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.babyBlueIce
                            .withValues(alpha: AppOpacity.visible),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.md,
                      ),
                      child: _InlineStats(isFrench: isFrench),
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.babyBlueIce
                          .withValues(alpha: AppOpacity.visible),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Email badge — below banner line, right of avatar ────────
          if (email != null && email!.isNotEmpty)
            Positioned(
              top: topPadding + _kBannerHeight + AppSpacing.xs,
              left: AppSpacing.lg + _kAvatarTotalRadius * 2 + AppSpacing.md,
              right: AppSpacing.md,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: AppOpacity.faint),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  border: Border.all(
                    color:
                        AppColors.primary.withValues(alpha: AppOpacity.muted),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.mail_outline_rounded,
                      size: 11,
                      color: AppColors.textSecondary
                          .withValues(alpha: AppOpacity.prominent),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        email!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textSecondary
                              .withValues(alpha: AppOpacity.bold),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Avatar — left-aligned, centre at banner/white boundary ────
          Positioned(
            top: topPadding + _kBannerHeight - _kAvatarTotalRadius,
            left: AppSpacing.lg,
            child: _AvatarWidget(
              photoUrl: photoUrl,
              uploading: uploadingImage,
              onTap: onEditAvatar,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Inline stats — Posts / Followers / Following style
// ─────────────────────────────────────────────────────────────────────────────

class _InlineStats extends ConsumerWidget {
  final bool isFrench;

  const _InlineStats({required this.isFrench});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(_profileStatsProvider);
    final stats = statsAsync.valueOrNull;

    final String sessions = stats != null ? '${stats.sessions}' : '—';
    final String programs = stats != null ? '${stats.programs}' : '—';
    final String totalTime = stats != null ? '${stats.totalHours}h' : '—';

    return IntrinsicHeight(
      child: Row(
        children: <Widget>[
          Expanded(
            child: _InlineStatItem(
              value: sessions,
              label: isFrench ? 'Séances' : 'Sessions',
            ),
          ),
          VerticalDivider(
            color: AppColors.babyBlueIce.withValues(alpha: AppOpacity.bold),
            thickness: 1,
            width: 1,
          ),
          Expanded(
            child: _InlineStatItem(
              value: programs,
              label: isFrench ? 'Programmes' : 'Programs',
            ),
          ),
          VerticalDivider(
            color: AppColors.babyBlueIce.withValues(alpha: AppOpacity.bold),
            thickness: 1,
            width: 1,
          ),
          Expanded(
            child: _InlineStatItem(
              value: totalTime,
              label: isFrench ? 'Temps total' : 'Total time',
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineStatItem extends StatelessWidget {
  final String value;
  final String label;

  const _InlineStatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontFamily: 'AppFontMedium',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Avatar widget
// ─────────────────────────────────────────────────────────────────────────────

class _AvatarWidget extends StatelessWidget {
  final String? photoUrl;
  final bool uploading;
  final VoidCallback onTap;

  const _AvatarWidget({
    required this.photoUrl,
    required this.uploading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: uploading ? null : onTap,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // White ring
          Container(
            width: _kAvatarTotalRadius * 2,
            height: _kAvatarTotalRadius * 2,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          // Avatar image
          CircleAvatar(
            radius: _kAvatarRadius,
            backgroundColor: AppColors.primaryDarker,
            backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
                ? CachedNetworkImageProvider(photoUrl!) as ImageProvider
                : null,
            child: photoUrl == null || photoUrl!.isEmpty
                ? Icon(
                    Icons.person_rounded,
                    size: _kAvatarRadius * 0.85,
                    color: Colors.white.withValues(alpha: AppOpacity.prominent),
                  )
                : null,
          ),
          // Upload overlay
          if (uploading)
            Container(
              width: _kAvatarRadius * 2,
              height: _kAvatarRadius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: AppOpacity.dim),
              ),
              child: const Center(
                child: SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          // Camera badge
          if (!uploading)
            Positioned(
              bottom: _kRingWidth + 2,
              right: _kRingWidth + 2,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 13,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile section card — title centered, content below
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _ProfileSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_kProfileBlockRadius),
        border: Border.all(
          color: AppColors.babyBlueIce.withValues(alpha: AppOpacity.half),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withValues(alpha: AppOpacity.hairline),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                color: AppColors.textSecondary
                    .withValues(alpha: AppOpacity.prominent),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Divider(
            height: 1,
            color: AppColors.babyBlueIce.withValues(alpha: AppOpacity.visible),
          ),
          child,
        ],
      ),
    );
  }
}

class _SectionSubheader extends StatelessWidget {
  final String label;

  const _SectionSubheader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xxs,
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: AppOpacity.visible),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Menu list
// ─────────────────────────────────────────────────────────────────────────────

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLast;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLast = false,
  });
}

class _MenuList extends StatelessWidget {
  final List<_MenuItem> items;

  const _MenuList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((_MenuItem item) {
        return Column(
          children: <Widget>[
            InkWell(
              onTap: item.onTap,
              borderRadius: item.isLast
                  ? const BorderRadius.only(
                      bottomLeft: Radius.circular(_kProfileBlockRadius),
                      bottomRight: Radius.circular(_kProfileBlockRadius),
                    )
                  : BorderRadius.zero,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm + 2,
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary
                            .withValues(alpha: AppOpacity.faint),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.primary
                              .withValues(alpha: AppOpacity.muted),
                        ),
                      ),
                      child: Icon(
                        item.icon,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      width: 1,
                      height: 24,
                      color: AppColors.babyBlueIce
                          .withValues(alpha: AppOpacity.visible),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        item.label,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary
                          .withValues(alpha: AppOpacity.firm),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            if (!item.isLast)
              Divider(
                height: 1,
                indent: AppSpacing.md,
                endIndent: AppSpacing.md,
                color:
                    AppColors.babyBlueIce.withValues(alpha: AppOpacity.visible),
              ),
          ],
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile tab bar delegate — pinned below the header
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileTabBarDelegate extends SliverPersistentHeaderDelegate {
  final bool isFrench;

  const _ProfileTabBarDelegate({required this.isFrench});

  @override
  double get minExtent => 56;

  @override
  double get maxExtent => 56;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.surface,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.babyBlueIce.withValues(alpha: AppOpacity.subtle),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xs,
            AppSpacing.xs,
            AppSpacing.xs,
            AppSpacing.sm,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppRadii.sm),
              border: Border.all(
                color: AppColors.babyBlueIce.withValues(alpha: AppOpacity.soft),
              ),
            ),
            child: TabBar(
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              labelColor: AppColors.textPrimary,
              unselectedLabelColor: AppColors.textSecondary.withValues(
                alpha: AppOpacity.prominent,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppColors.primary.withValues(alpha: AppOpacity.light),
                borderRadius: BorderRadius.circular(6),
              ),
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                fontFamily: 'AppFontMedium',
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              tabs: <Tab>[
                Tab(text: isFrench ? 'Profil' : 'Profile'),
                Tab(text: isFrench ? 'Amis' : 'Friends'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_ProfileTabBarDelegate oldDelegate) =>
      oldDelegate.isFrench != isFrench;
}

// ─────────────────────────────────────────────────────────────────────────────
// Banner edit button — small glass-style pill at bottom-right of banner
// ─────────────────────────────────────────────────────────────────────────────

class _BannerEditButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _BannerEditButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs + 2,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: AppOpacity.light),
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color: Colors.white.withValues(alpha: AppOpacity.mild),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.edit_rounded, size: 14, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
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
// Edit profile bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _EditProfileSheet extends ConsumerStatefulWidget {
  final String currentUsername;
  final String userId;
  final String? email;

  const _EditProfileSheet({
    required this.currentUsername,
    required this.userId,
    this.email,
  });

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late final TextEditingController _controller;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentUsername);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final String newName = _controller.text.trim();
    if (newName.isEmpty || newName == widget.currentUsername) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(firestoreServiceProvider).createOrUpdateUserProfile(
        userId: widget.userId,
        username: newName,
        email: widget.email ?? '',
      );
      final user = ref.read(currentUserProvider);
      await user?.updateDisplayName(newName);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isFrench = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('fr');
    final double bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg + bottomPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color:
                    AppColors.textTertiary.withValues(alpha: AppOpacity.half),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            isFrench ? 'Modifier le profil' : 'Edit Profile',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontFamily: 'AppFontMedium',
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            isFrench ? 'Nom d\'utilisateur' : 'Username',
            style: TextStyle(
              color: AppColors.textSecondary
                  .withValues(alpha: AppOpacity.prominent),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surfaceVariant,
              hintText: isFrench ? 'Votre nom' : 'Your name',
              hintStyle: TextStyle(
                color:
                    AppColors.textSecondary.withValues(alpha: AppOpacity.half),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
                borderSide: BorderSide(
                  color: AppColors.primary.withValues(alpha: AppOpacity.muted),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
                borderSide: BorderSide(
                  color:
                      AppColors.babyBlueIce.withValues(alpha: AppOpacity.half),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: _saving ? null : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: BorderSide(
                      color: AppColors.babyBlueIce
                          .withValues(alpha: AppOpacity.half),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm + 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                  ),
                  child: Text(isFrench ? 'Annuler' : 'Cancel'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm + 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isFrench ? 'Sauvegarder' : 'Save',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
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
// Language picker dialog
// ─────────────────────────────────────────────────────────────────────────────

class _LanguagePickerDialog extends ConsumerWidget {
  const _LanguagePickerDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isFrench = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('fr');

    return AppDialog(
      title: isFrench ? 'Langue' : 'Language',
      icon: Icons.language_rounded,
      iconColor: AppColors.primary,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _LanguageOption(
              flag: '🇬🇧',
              label: 'English',
              isSelected: !isFrench,
              onTap: () {
                ref.read(localeProvider.notifier).setLocale('en');
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            _LanguageOption(
              flag: '🇫🇷',
              label: 'Français',
              isSelected: isFrench,
              onTap: () {
                ref.read(localeProvider.notifier).setLocale('fr');
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
      actions: <AppDialogAction<dynamic>>[
        AppDialogAction<bool>(
          label: isFrench ? 'Fermer' : 'Close',
          returnValue: false,
        ),
      ],
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String flag;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.flag,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: AppOpacity.faint)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: AppOpacity.muted)
                : AppColors.babyBlueIce.withValues(alpha: AppOpacity.half),
          ),
        ),
        child: Row(
          children: <Widget>[
            Text(flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 20,
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
  final String label;
  final VoidCallback onTap;

  const _LogoutButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_kProfileBlockRadius),
        border: Border.all(
          color: AppColors.errorSoft.withValues(alpha: AppOpacity.firm),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.error.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_kProfileBlockRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: AppOpacity.faint),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.error,
                  size: 17,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 15,
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
