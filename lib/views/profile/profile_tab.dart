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
import 'package:workin_fit/services/firestore_service.dart';
import 'package:workin_fit/views/auth/authentication_view.dart';
import 'package:workin_fit/models/friend.dart';
import 'package:workin_fit/models/friend_request.dart';
import 'package:workin_fit/providers/friend_providers.dart';
import 'package:workin_fit/views/achievements/achievements_page.dart';
import 'package:workin_fit/views/profile/stats_graph_screen.dart';
import 'package:workin_fit/views/social/friend_search_screen.dart';
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
  return FirestoreService().getUserProfile(user.uid);
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
                    _ProfileHeaderSliver(
                      username: username,
                      email: user?.email,
                      photoUrl: user?.photoURL,
                      uploadingImage: _uploadingImage,
                      isFrench: isFrench,
                      onEditAvatar: _pickAndUploadImage,
                      onEditProfile: () => _openEditProfile(username),
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
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.xs,
                            AppSpacing.sm,
                            AppSpacing.xs,
                            0,
                          ),
                          children: <Widget>[
                            _ProfileSection(
                              title: isFrench
                                  ? 'Série & Compte'
                                  : 'Streak & Account',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  _SectionSubheader(
                                    label: isFrench ? 'Série' : 'Streak',
                                  ),
                                  _StreakCalendar(isFrench: isFrench),
                                  Divider(
                                    height: 1,
                                    color: AppColors.babyBlueIce
                                        .withValues(alpha: AppOpacity.visible),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.all(AppSpacing.md),
                                    child: _StatsGraphButton(
                                      label: isFrench
                                          ? 'Statistiques & Graphiques'
                                          : 'Stats & Graph',
                                      onTap: _openStatsGraph,
                                    ),
                                  ),
                                  Divider(
                                    height: 1,
                                    color: AppColors.babyBlueIce
                                        .withValues(alpha: AppOpacity.visible),
                                  ),
                                  _SectionSubheader(
                                    label: isFrench ? 'Compte' : 'Account',
                                  ),
                                  _MenuList(
                                    items: <_MenuItem>[
                                      _MenuItem(
                                        icon: Icons.emoji_events_rounded,
                                        label:
                                            isFrench ? 'Trophées' : 'Trophies',
                                        onTap: _openAchievements,
                                      ),
                                      _MenuItem(
                                        icon: Icons.language_rounded,
                                        label: isFrench ? 'Langue' : 'Language',
                                        onTap: _openLanguage,
                                      ),
                                      _MenuItem(
                                        icon: Icons.settings_rounded,
                                        label: isFrench
                                            ? 'Paramètres'
                                            : 'Settings',
                                        onTap: () => _showComingSoon(isFrench),
                                      ),
                                      _MenuItem(
                                        icon: Icons.lock_outline_rounded,
                                        label: isFrench
                                            ? 'Confidentialité'
                                            : 'Privacy',
                                        onTap: () => _showComingSoon(isFrench),
                                        isLast: true,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _LogoutButton(
                              label: isFrench ? 'Se déconnecter' : 'Log out',
                              onTap: () => _confirmLogout(isFrench),
                            ),
                            const SizedBox(height: 104),
                          ],
                        ),
                      ),

                      // ─── Tab 1: Friends ────────────────────────────────
                      _FriendsTabContent(isFrench: isFrench),
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        _kAvatarTotalRadius + AppSpacing.lg,
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
                    color: AppColors.primary.withValues(alpha: AppOpacity.muted),
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

class _InlineStats extends StatelessWidget {
  final bool isFrench;

  const _InlineStats({required this.isFrench});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: <Widget>[
          Expanded(
            child: _InlineStatItem(
              value: '48',
              label: isFrench ? 'Séances' : 'Workouts',
            ),
          ),
          VerticalDivider(
            color: AppColors.babyBlueIce.withValues(alpha: AppOpacity.bold),
            thickness: 1,
            width: 1,
          ),
          Expanded(
            child: _InlineStatItem(
              value: '3',
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
              value: '72h',
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

class _StatsGraphButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _StatsGraphButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[AppColors.primaryDarker, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(AppRadii.md),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 2,
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.insights_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'AppFontMedium',
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
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

// ─────────────────────────────────────────────────────────────────────────────
// Streak calendar — shows last 7 days
// ─────────────────────────────────────────────────────────────────────────────

class _StreakCalendar extends ConsumerWidget {
  final bool isFrench;

  const _StreakCalendar({required this.isFrench});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(streakDataProvider);

    return streakAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (data) {
        final int currentStreak = (data['currentStreak'] as int?) ?? 0;
        final int bestStreak = (data['bestStreak'] as int?) ?? 0;
        final List<bool> lastSevenDays =
            (data['lastSevenDays'] as List?)?.cast<bool>() ??
                List<bool>.filled(7, false);

        final DateTime today = DateTime.now();
        final List<DateTime> days = List<DateTime>.generate(
          7,
          (int i) => today.subtract(Duration(days: 6 - i)),
        );
        final List<String> letters = isFrench
            ? <String>['L', 'M', 'M', 'J', 'V', 'S', 'D']
            : <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'];

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: <Widget>[
              // Big streak number
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: AppColors.warning,
                    size: 32,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$currentStreak',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontFamily: 'AppFontMedium',
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isFrench ? 'jours' : 'days',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Day bubbles
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List<Widget>.generate(7, (int i) {
                  return _DayBubble(
                    letter: letters[(days[i].weekday - 1) % 7],
                    worked: lastSevenDays[i],
                    isToday: i == 6,
                  );
                }),
              ),

              const SizedBox(height: AppSpacing.md),

              // Best streak badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xxs + 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.babyBlueIce
                      .withValues(alpha: AppOpacity.medium),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(
                      Icons.emoji_events_rounded,
                      color: AppColors.cornflowerBlue,
                      size: 14,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isFrench
                          ? 'Meilleur : $bestStreak jours'
                          : 'Best: $bestStreak days',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DayBubble extends StatelessWidget {
  final String letter;
  final bool worked;
  final bool isToday;

  const _DayBubble({
    required this.letter,
    required this.worked,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          letter,
          style: TextStyle(
            color: isToday
                ? AppColors.primaryDark
                : AppColors.textSecondary.withValues(alpha: AppOpacity.half),
            fontSize: 10,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: worked
                ? AppColors.primary
                : AppColors.babyBlueIce.withValues(alpha: AppOpacity.moderate),
            border: isToday
                ? Border.all(color: AppColors.primaryDark, width: 2)
                : null,
            boxShadow: worked
                ? <BoxShadow>[
                    BoxShadow(
                      color:
                          AppColors.primary.withValues(alpha: AppOpacity.mild),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: worked
                ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                : Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.textSecondary
                          .withValues(alpha: AppOpacity.mild),
                    ),
                  ),
          ),
        ),
      ],
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
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.primary
                            .withValues(alpha: AppOpacity.faint),
                        shape: BoxShape.circle,
                      ),
                      child:
                          Icon(item.icon, color: AppColors.primary, size: 17),
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
                indent: AppSpacing.md + 34 + AppSpacing.sm,
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
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return AppTopBarBackground(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: AppOpacity.trace),
            ),
            bottom: BorderSide(
              color: Colors.white.withValues(alpha: AppOpacity.subtle),
            ),
          ),
        ),
        child: TabBar(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: AppOpacity.over),
          indicatorColor: Colors.white,
          indicatorWeight: 2,
          dividerColor: Colors.transparent,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            fontFamily: 'AppFontMedium',
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          tabs: <Tab>[
            Tab(text: isFrench ? 'Profil' : 'Profile'),
            Tab(text: isFrench ? 'Amis' : 'Friends'),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_ProfileTabBarDelegate oldDelegate) =>
      oldDelegate.isFrench != isFrench;
}

// ─────────────────────────────────────────────────────────────────────────────
// Friends tab content — add button + requests + friends list
// ─────────────────────────────────────────────────────────────────────────────

class _FriendsTabContent extends ConsumerWidget {
  final bool isFrench;

  const _FriendsTabContent({required this.isFrench});

  void _openSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const FriendSearchScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsAsync = ref.watch(friendsStreamProvider);
    final requestsAsync = ref.watch(incomingRequestsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(friendsStreamProvider);
        ref.invalidate(incomingRequestsProvider);
        await Future<void>.delayed(const Duration(milliseconds: 600));
      },
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          104,
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          // ── Add friends button ──────────────────────────────────
          _AddFriendsButton(
            label: isFrench ? 'Trouver des amis' : 'Find Friends',
            onTap: () => _openSearch(context),
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Requests section (shown only when pending > 0) ──────
          requestsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (requests) {
              if (requests.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _FriendsSectionHeader(
                    label: isFrench
                        ? 'Demandes (${requests.length})'
                        : 'Requests (${requests.length})',
                  ),
                  _FriendsSectionCard(
                    children: requests.map((r) {
                      return _RequestRow(
                        request: r,
                        onAccept: () => _accept(context, ref, r),
                        onReject: () => _reject(context, ref, r),
                        isLast: r == requests.last,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              );
            },
          ),

          // ── Friends list ────────────────────────────────────────
          friendsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            error: (_, __) => Center(
              child: Text(
                isFrench
                    ? 'Impossible de charger les amis'
                    : 'Failed to load friends',
                style: TextStyle(
                  color: AppColors.textSecondary
                      .withValues(alpha: AppOpacity.prominent),
                ),
              ),
            ),
            data: (friends) {
              if (friends.isEmpty) {
                return _FriendsEmptyState(
                  isFrench: isFrench,
                  onSearch: () => _openSearch(context),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _FriendsSectionHeader(
                    label: isFrench
                        ? 'Amis (${friends.length})'
                        : 'Friends (${friends.length})',
                  ),
                  _FriendsSectionCard(
                    children: friends.map((f) {
                      return _FriendRow(
                        friend: f,
                        onRemove: () => _confirmRemove(context, ref, f),
                        isLast: f == friends.last,
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _accept(
    BuildContext context,
    WidgetRef ref,
    FriendRequest request,
  ) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    try {
      final profile =
          await ref.read(firestoreServiceProvider).getUserProfile(user.uid);
      final myUsername = profile?['username'] as String? ??
          user.displayName ??
          user.email?.split('@').first ??
          'User';
      await ref.read(friendServiceProvider).acceptFriendRequest(
            requestId: request.id,
            fromUserId: request.fromUserId,
            fromUsername: request.fromUsername,
            toUserId: request.toUserId,
            toUsername: myUsername,
            fromPhotoUrl: request.fromPhotoUrl,
            toPhotoUrl: user.photoURL,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You and ${request.fromUsername} are now friends!',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to accept request.')),
        );
      }
    }
  }

  Future<void> _reject(
    BuildContext context,
    WidgetRef ref,
    FriendRequest request,
  ) async {
    try {
      await ref
          .read(friendServiceProvider)
          .rejectFriendRequest(requestId: request.id);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to decline request.')),
        );
      }
    }
  }

  void _confirmRemove(BuildContext context, WidgetRef ref, Friend friend) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isFrench ? 'Retirer un ami' : 'Remove friend'),
        content: Text(
          isFrench
              ? 'Retirer ${friend.username} de vos amis ?'
              : 'Remove ${friend.username} from your friends?',
        ),
        actions: <TextButton>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isFrench ? 'Annuler' : 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final user = ref.read(currentUserProvider);
              if (user == null) return;
              try {
                await ref.read(friendServiceProvider).removeFriend(
                      userId: user.uid,
                      friendId: friend.userId,
                    );
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to remove friend.'),
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(isFrench ? 'Retirer' : 'Remove'),
          ),
        ],
      ),
    );
  }
}

// ─── Friends tab helper widgets ───────────────────────────────────────────────

class _AddFriendsButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AddFriendsButton({required this.label, required this.onTap});

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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: AppOpacity.muted),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.primary.withValues(alpha: AppOpacity.hairline),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: AppOpacity.faint),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_add_rounded,
                color: AppColors.primary,
                size: 17,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary.withValues(alpha: AppOpacity.firm),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendsSectionHeader extends StatelessWidget {
  final String label;

  const _FriendsSectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        bottom: AppSpacing.xs,
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

class _FriendsSectionCard extends StatelessWidget {
  final List<Widget> children;

  const _FriendsSectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.sm),
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
      child: Column(children: children),
    );
  }
}

class _FriendRow extends StatelessWidget {
  final Friend friend;
  final VoidCallback onRemove;
  final bool isLast;

  const _FriendRow({
    required this.friend,
    required this.onRemove,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xxs,
          ),
          leading: _FriendAvatar(
            photoUrl: friend.photoUrl,
            username: friend.username,
          ),
          title: Text(
            friend.username,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.person_remove_rounded,
              color: AppColors.textSecondary.withValues(alpha: AppOpacity.firm),
              size: 20,
            ),
            onPressed: onRemove,
            tooltip: 'Remove friend',
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: AppSpacing.md + 44 + AppSpacing.sm,
            color: AppColors.babyBlueIce.withValues(alpha: AppOpacity.half),
          ),
      ],
    );
  }
}

class _RequestRow extends StatelessWidget {
  final FriendRequest request;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final bool isLast;

  const _RequestRow({
    required this.request,
    required this.onAccept,
    required this.onReject,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: <Widget>[
              _FriendAvatar(
                photoUrl: request.fromPhotoUrl,
                username: request.fromUsername,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      request.fromUsername,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'wants to be your friend',
                      style: TextStyle(
                        color: AppColors.textSecondary
                            .withValues(alpha: AppOpacity.prominent),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              _FriendActionButton(
                icon: Icons.check_rounded,
                color: AppColors.success,
                onTap: onAccept,
              ),
              const SizedBox(width: AppSpacing.xs),
              _FriendActionButton(
                icon: Icons.close_rounded,
                color: AppColors.error,
                onTap: onReject,
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: AppSpacing.md + 44 + AppSpacing.sm,
            color: AppColors.babyBlueIce.withValues(alpha: AppOpacity.half),
          ),
      ],
    );
  }
}

class _FriendAvatar extends StatelessWidget {
  final String? photoUrl;
  final String username;

  const _FriendAvatar({required this.username, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.primaryDarker,
      backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
          ? CachedNetworkImageProvider(photoUrl!) as ImageProvider
          : null,
      child: photoUrl == null || photoUrl!.isEmpty
          ? Text(
              username.isNotEmpty ? username[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            )
          : null,
    );
  }
}

class _FriendActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FriendActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: AppOpacity.whisper),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

class _FriendsEmptyState extends StatelessWidget {
  final bool isFrench;
  final VoidCallback onSearch;

  const _FriendsEmptyState({required this.isFrench, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.group_rounded,
              size: 64,
              color:
                  AppColors.babyBlueIce.withValues(alpha: AppOpacity.visible),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              isFrench ? 'Pas encore d\'amis' : 'No friends yet',
              style: TextStyle(
                color: AppColors.textSecondary
                    .withValues(alpha: AppOpacity.prominent),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            TextButton.icon(
              onPressed: onSearch,
              icon: const Icon(Icons.person_add_rounded),
              label: Text(isFrench ? 'Trouver des amis' : 'Find Friends'),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.sm,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
      await FirestoreService().createOrUpdateUserProfile(
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
                color: AppColors.textTertiary
                    .withValues(alpha: AppOpacity.half),
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
                color: AppColors.textSecondary
                    .withValues(alpha: AppOpacity.half),
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
                  onPressed:
                      _saving ? null : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: BorderSide(
                      color:
                          AppColors.babyBlueIce.withValues(alpha: AppOpacity.half),
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
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
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
