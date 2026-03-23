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
import 'package:workin_fit/providers/workout_providers.dart';
import 'package:workin_fit/services/firestore_service.dart';
import 'package:workin_fit/views/auth/authentication_view.dart';
import 'package:workin_fit/views/profile/stats_graph_screen.dart';
import 'package:workin_fit/views/achievements/achievements_page.dart';
import 'package:workin_fit/views/social/friends_screen.dart';
import 'package:workin_fit/views/test/render_test_hub_page.dart';

// ─── Avatar size constants ────────────────────────────────────────────────────

const double _kAvatarRadius = 52.0;
const double _kRingWidth = 8.0;
const double _kAvatarTotalRadius = _kAvatarRadius + _kRingWidth; // 60
const double _kBannerHeight = 130.0;
const double _kProfileBlockRadius = AppRadii.lg;

// ─── Providers ───────────────────────────────────────────────────────────────

final _userProfileProvider =
    FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return FirestoreService().getUserProfile(user.uid);
});

// ─── Main tab ────────────────────────────────────────────────────────────────

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab>
    with AutomaticKeepAliveClientMixin<ProfileTab> {
  @override
  bool get wantKeepAlive => true;

  bool _uploadingImage = false;

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

  void _openFriends() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const FriendsScreen(),
      ),
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

  void _openTestHub() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const RenderTestHubPage(),
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
      child: Scaffold(
        backgroundColor: AppColors.surfaceVariant,
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(_userProfileProvider);
            ref.invalidate(streakDataProvider);
            await Future<void>.delayed(const Duration(milliseconds: 600));
          },
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              // ─── Banner + header info ─────────────────────────────
              _ProfileHeaderSliver(
                username: username,
                email: user?.email,
                photoUrl: user?.photoURL,
                uploadingImage: _uploadingImage,
                isFrench: isFrench,
                onEditAvatar: _pickAndUploadImage,
                onEditProfile: () => _showComingSoon(isFrench),
              ),

              // ─── Body sections ────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  0,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(<Widget>[
                    // ── Combined streak + account block ──────────────
                    _ProfileSection(
                      title: isFrench ? 'Série & Compte' : 'Streak & Account',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _SectionSubheader(
                            label: isFrench ? 'Série' : 'Streak',
                          ),
                          _StreakCalendar(isFrench: isFrench),
                          Divider(
                            height: 1,
                            color: AppColors.babyBlueIce.withValues(alpha: 0.6),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: _StatsGraphButton(
                              label: isFrench
                                  ? 'Statistiques & Graphiques'
                                  : 'Stats & Graph',
                              onTap: _openStatsGraph,
                            ),
                          ),
                          Divider(
                            height: 1,
                            color: AppColors.babyBlueIce.withValues(alpha: 0.6),
                          ),
                          _SectionSubheader(
                            label: isFrench ? 'Compte' : 'Account',
                          ),
                          _MenuList(
                            items: <_MenuItem>[
                              _MenuItem(
                                icon: Icons.emoji_events_rounded,
                                label: isFrench ? 'Trophées' : 'Trophies',
                                onTap: _openAchievements,
                              ),
                              _MenuItem(
                                icon: Icons.edit_rounded,
                                label: isFrench
                                    ? 'Modifier le profil'
                                    : 'Edit profile',
                                onTap: () => _showComingSoon(isFrench),
                              ),
                              _MenuItem(
                                icon: Icons.people_rounded,
                                label: isFrench ? 'Amis' : 'Friends',
                                onTap: _openFriends,
                              ),
                              _MenuItem(
                                icon: Icons.settings_rounded,
                                label: isFrench ? 'Paramètres' : 'Settings',
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

                    // ── Dev test hub ─────────────────────────────────
                    _TestHubButton(onTap: _openTestHub),

                    const SizedBox(height: AppSpacing.sm),

                    // ── Logout ───────────────────────────────────────
                    _LogoutButton(
                      label: isFrench ? 'Se déconnecter' : 'Log out',
                      onTap: _logout,
                    ),

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
          // ── Background: banner on top, white card below ──────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Top banner
              Container(
                height: _kBannerHeight + topPadding,
                color: AppColors.navBarSurface,
              ),

              // White info section
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  _kAvatarTotalRadius + AppSpacing.sm,
                  AppSpacing.xl,
                  AppSpacing.xl,
                ),
                child: Column(
                  children: <Widget>[
                    // Name
                    Text(
                      username,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontFamily: 'AppFontMedium',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),

                    const SizedBox(height: 5),

                    // Email badge
                    if (email != null && email!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.mail_outline_rounded,
                              size: 12,
                              color: AppColors.textSecondary
                                  .withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              email!,
                              style: TextStyle(
                                color: AppColors.textSecondary
                                    .withValues(alpha: 0.85),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: AppSpacing.xl),

                    // Inline stats row
                    _InlineStats(isFrench: isFrench),

                    const SizedBox(height: AppSpacing.xl),

                    // Edit profile button
                    _EditProfileButton(
                      label: isFrench ? 'Modifier le profil' : 'Edit Profile',
                      onTap: onEditProfile,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Avatar — overlaps banner / white boundary ─────────────────
          Positioned(
            top: _kBannerHeight + topPadding - _kAvatarTotalRadius,
            left: 0,
            right: 0,
            child: Center(
              child: _AvatarWidget(
                photoUrl: photoUrl,
                uploading: uploadingImage,
                onTap: onEditAvatar,
              ),
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
            color: AppColors.babyBlueIce.withValues(alpha: 0.8),
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
            color: AppColors.babyBlueIce.withValues(alpha: 0.8),
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
// Edit profile button — gradient, full-width
// ─────────────────────────────────────────────────────────────────────────────

class _EditProfileButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _EditProfileButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[AppColors.primaryDarker, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(AppRadii.md),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
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
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 4),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'AppFontMedium',
                ),
              ),
            ),
          ),
        ),
      ),
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
                    color: Colors.white.withValues(alpha: 0.7),
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
                color: Colors.black.withValues(alpha: 0.45),
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
          color: AppColors.babyBlueIce.withValues(alpha: 0.5),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
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
                color: AppColors.textSecondary.withValues(alpha: 0.7),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Divider(
            height: 1,
            color: AppColors.babyBlueIce.withValues(alpha: 0.6),
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
          color: AppColors.textSecondary.withValues(alpha: 0.6),
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
                  color: AppColors.babyBlueIce.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(AppRadii.lg),
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
                : AppColors.textSecondary.withValues(alpha: 0.5),
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
                : AppColors.babyBlueIce.withValues(alpha: 0.35),
            border: isToday
                ? Border.all(color: AppColors.primaryDark, width: 2)
                : null,
            boxShadow: worked
                ? <BoxShadow>[
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
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
                      color: AppColors.textSecondary.withValues(alpha: 0.3),
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
                        color: AppColors.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item.icon, color: AppColors.primary, size: 17),
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
                      color: AppColors.textSecondary.withValues(alpha: 0.4),
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
                color: AppColors.babyBlueIce.withValues(alpha: 0.6),
              ),
          ],
        );
      }).toList(),
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
        border: Border.all(color: AppColors.errorSoft.withValues(alpha: 0.4)),
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
                  color: AppColors.error.withValues(alpha: 0.08),
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

class _TestHubButton extends StatelessWidget {
  final VoidCallback onTap;

  const _TestHubButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: AppColors.primaryLight.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.science_rounded,
                color: AppColors.primary,
                size: 17,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Expanded(
              child: Text(
                'Dev — Test Hub',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

