import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_chrome.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/features/workout/presentation/screens/exercise_list_screen.dart';
import 'package:workin_fit/l10n/app_localizations.dart';
import 'package:workin_fit/providers/workout_providers.dart';
import 'package:workin_fit/views/home/home_dashboard_tab.dart';
import 'package:workin_fit/views/home/sessions_tab.dart';
import 'package:workin_fit/views/profile/profile_tab.dart';
import 'package:workin_fit/views/chat/chat_tab.dart';
import 'package:workin_fit/core/theme/app_opacity.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final ValueNotifier<int> _tabIndex;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _tabIndex = ValueNotifier<int>(0);
    _pageController = PageController();
    // Pre-warm the exercises data so the first swipe to that tab is lag-free
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(exercisesProvider);
      // Drain any writes that were queued while offline
      _runPendingSync();
    });
  }

  @override
  void dispose() {
    _tabIndex.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _runPendingSync() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    await ref.read(syncServiceProvider).syncPendingChanges(userId);
  }

  void _onTabSelected(int index) {
    if (index == _tabIndex.value) return;
    final int distance = (index - _tabIndex.value).abs();
    _tabIndex.value = index;
    if (distance == 1) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _pageController.jumpToPage(index);
    }
  }

  void _onPageChanged(int index) {
    if (index != _tabIndex.value) {
      _tabIndex.value = index;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = <Widget>[
      const HomeDashboardTab(),
      const ExerciseListScreen(),
      const SessionsTab(),
      const ChatTab(),
      const ProfileTab(),
    ];

    return AppSystemOverlayRegion(
      style: AppChrome.homeOverlay,
      child: Scaffold(
        extendBody: true,
        body: Stack(
          children: <Widget>[
            PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: const ClampingScrollPhysics(),
              children: tabs,
            ),
            // ── Page-seam indicator ──────────────────────────────────────
            // A thin vertical line rendered at the exact boundary between
            // two adjacent pages while a swipe is in progress. It fades in
            // as the drag begins, peaks at mid-swipe, and fades out on
            // landing — giving a clear visual split without cluttering the
            // resting state.
            AnimatedBuilder(
              animation: _pageController,
              builder: (BuildContext context, Widget? _) {
                if (!_pageController.hasClients) {
                  return const SizedBox.shrink();
                }
                double page;
                try {
                  page = _pageController.page ??
                      _tabIndex.value.toDouble();
                } catch (_) {
                  return const SizedBox.shrink();
                }
                final double frac =
                    page - page.truncateToDouble();
                if (frac == 0.0) return const SizedBox.shrink();

                final double screenWidth =
                    MediaQuery.sizeOf(context).width;
                final double seamX = (1.0 - frac) * screenWidth;
                // Opacity peaks at 0.5 (halfway between pages)
                final double opacity =
                    (frac < 0.5 ? frac * 2 : (1.0 - frac) * 2) *
                        0.45;

                return Positioned(
                  left: seamX - 1,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          AppColors.primary
                              .withValues(alpha: 0),
                          AppColors.primary
                              .withValues(alpha: opacity),
                          AppColors.primary
                              .withValues(alpha: opacity),
                          AppColors.primary
                              .withValues(alpha: 0),
                        ],
                        stops: const <double>[
                          0.0,
                          0.12,
                          0.88,
                          1.0,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        bottomNavigationBar: ValueListenableBuilder<int>(
          valueListenable: _tabIndex,
          builder: (BuildContext context, int index, Widget? _) {
            return _FloatingBottomBar(
              selectedIndex: index,
              onTabSelected: _onTabSelected,
            );
          },
        ),
      ),
    );
  }
}

class _FloatingBottomBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const _FloatingBottomBar({
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final bool isFrench = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('fr');
    final double bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    const double navContentHeight = 58;
    const double centerButtonSize = 72;
    const double centerButtonLift = 6;
    const double centerButtonBorderWidth = 3.6;

    return SizedBox(
      height: navContentHeight + bottomInset,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomBarSurface(
              height: navContentHeight + bottomInset,
              padding: EdgeInsets.only(
                left: AppSpacing.xxs,
                right: AppSpacing.xxs,
                top: AppSpacing.xxs,
                bottom: AppSpacing.xxs + bottomInset,
              ),
              border: Border(
                top: BorderSide(
                  color: AppColors.background.withValues(alpha: AppOpacity.thin),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _NavItem(
                      icon: Icons.home_rounded,
                      label: localizations.home_tab_home,
                      isSelected: selectedIndex == 0,
                      onTap: () => onTabSelected(0),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.fitness_center_rounded,
                      label: isFrench ? 'Exercices' : 'Exercises',
                      isSelected: selectedIndex == 1,
                      onTap: () => onTabSelected(1),
                    ),
                  ),
                  const SizedBox(width: centerButtonSize),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Chat',
                      isSelected: selectedIndex == 3,
                      onTap: () => onTabSelected(3),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.person_rounded,
                      label: localizations.home_tab_profile,
                      isSelected: selectedIndex == 4,
                      onTap: () => onTabSelected(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: bottomInset + centerButtonLift,
            child: Tooltip(
              message: localizations.home_tab_programs,
              child: GestureDetector(
                onTap: () => onTabSelected(2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 170),
                  width: centerButtonSize,
                  height: centerButtonSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selectedIndex == 2
                        ? AppColors.primary
                        : AppColors.neutral300,
                    border: Border.all(
                      color: AppColors.neutral0,
                      width: centerButtonBorderWidth.roundToDouble(),
                    ),
                  ),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    size: 32,
                    color: selectedIndex == 2
                        ? AppColors.neutral0
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor = isSelected
        ? Colors.white
        : AppColors.frostedCyan.withValues(alpha: 0.72);
    final Color textColor = isSelected
        ? Colors.white
        : AppColors.frostedCyan.withValues(alpha: AppOpacity.strong);

    // GestureDetector covers the full Expanded width for a large tap area,
    // while Material + InkWell clip the ripple to the pill bounds.
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 170),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: AppOpacity.light)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: iconColor, size: 23),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textScaler: TextScaler.noScaling,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
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


