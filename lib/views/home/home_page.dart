import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_chrome.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/features/workout/presentation/screens/exercise_list_screen.dart';
import 'package:workin_fit/l10n/app_localizations.dart';
import 'package:workin_fit/providers/auth_provider.dart';
import 'package:workin_fit/views/home/home_dashboard_tab.dart';
import 'package:workin_fit/views/test/render_test_hub_page.dart';
import 'package:workin_fit/widgets/button.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedTabIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final bool isFrench = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('fr');
    final List<Widget> tabs = <Widget>[
      const HomeDashboardTab(),
      const ExerciseListScreen(),
      _PlaceholderTab(
        title: localizations.home_tab_programs,
        subtitle: localizations.home_placeholder_coming_soon,
      ),
      _PlaceholderTab(
        title: isFrench ? 'Social' : 'Social',
        subtitle: localizations.home_placeholder_coming_soon,
      ),
      _ProfileTab(
        title: localizations.home_tab_profile,
        subtitle: localizations.home_placeholder_coming_soon,
      ),
    ];

    return AppSystemOverlayRegion(
      style: AppChrome.homeOverlay,
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: _selectedTabIndex,
          children: tabs,
        ),
        bottomNavigationBar: _FloatingBottomBar(
          selectedIndex: _selectedTabIndex,
          onTabSelected: _onTabSelected,
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
    const double centerButtonSize = 58;
    const double centerButtonLift = 10;
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
                  color: AppColors.background.withValues(alpha: 0.28),
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
                      label: isFrench ? 'Social' : 'Social',
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
                        ? AppColors.cornflowerBlue
                        : AppColors.babyBlueIce,
                    border: Border.all(
                      color: AppColors.background.withValues(alpha: 0.48),
                      width: centerButtonBorderWidth,
                    ),
                  ),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    size: 30,
                    color: selectedIndex == 2
                        ? Colors.white
                        : AppColors.primaryAbyss,
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
        : AppColors.frostedCyan.withValues(alpha: 0.75);

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
                    ? Colors.white.withValues(alpha: 0.15)
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

class _PlaceholderTab extends StatelessWidget {
  final String title;
  final String subtitle;

  const _PlaceholderTab({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.construction_rounded,
                  size: 42,
                  color: AppColors.primaryLight.withValues(alpha: 0.8),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'AppFontMedium',
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileTab extends ConsumerWidget {
  final String title;
  final String subtitle;

  const _ProfileTab({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final bool isFrench = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('fr');

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                user?.email ?? title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'AppFontMedium',
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label:
                    isFrench ? 'Ouvrir le hub de test' : 'Open Render Test Hub',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const RenderTestHubPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

