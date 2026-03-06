import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/l10n/app_localizations.dart';
import 'package:workin_fit/providers/auth_provider.dart';
import 'package:workin_fit/views/auth/authentication_view.dart';
import 'package:workin_fit/views/test/render_test_hub_page.dart';
import 'package:workin_fit/views/test/test_page_002.dart';
import 'package:workin_fit/widgets/button.dart';

const SystemUiOverlayStyle _homeSystemOverlayStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
  systemNavigationBarColor: Colors.transparent,
  systemNavigationBarDividerColor: Colors.transparent,
  systemNavigationBarIconBrightness: Brightness.light,
  systemNavigationBarContrastEnforced: false,
);

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
    final List<Widget> tabs = <Widget>[
      const _HomeDashboardTab(),
      const SessionsListScreen(),
      const RenderTestHubPage(),
      _PlaceholderTab(
        title: localizations.home_tab_programs,
        subtitle: localizations.home_placeholder_coming_soon,
      ),
      _PlaceholderTab(
        title: localizations.home_tab_profile,
        subtitle: localizations.home_placeholder_coming_soon,
      ),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _homeSystemOverlayStyle,
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
            child: Container(
              height: navContentHeight + bottomInset,
              padding: EdgeInsets.only(
                left: AppSpacing.sm,
                right: AppSpacing.sm,
                top: AppSpacing.xxs,
                bottom: AppSpacing.xxs + bottomInset,
              ),
              decoration: BoxDecoration(
                color: AppColors.navigationBarBackground,
                border: Border(
                  top: BorderSide(
                    color: AppColors.background.withValues(alpha: 0.28),
                  ),
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
                      label: localizations.home_tab_sessions,
                      isSelected: selectedIndex == 1,
                      onTap: () => onTabSelected(1),
                    ),
                  ),
                  const SizedBox(width: centerButtonSize),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.calendar_month_rounded,
                      label: localizations.home_tab_programs,
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
              message: localizations.home_tab_lab,
              child: GestureDetector(
                onTap: () => onTabSelected(2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 170),
                  width: centerButtonSize,
                  height: centerButtonSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selectedIndex == 2
                        ? AppColors.raspberry
                        : AppColors.bubblegumPink.withValues(alpha: 0.92),
                    border: Border.all(
                      color: AppColors.background.withValues(alpha: 0.48),
                      width: centerButtonBorderWidth,
                    ),
                  ),
                  child: Icon(
                    Icons.science_rounded,
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
        ? AppColors.bubblegumPink
        : AppColors.lightCyan.withValues(alpha: 0.72);
    final Color textColor = isSelected
        ? AppColors.pinkMist
        : AppColors.lightCyan.withValues(alpha: 0.75);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xxs,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 19,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  color: textColor,
                  fontSize: 9,
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

class _HomeDashboardTab extends ConsumerWidget {
  const _HomeDashboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final localizations = AppLocalizations.of(context)!;
    final String userEmail = user?.email ?? localizations.home_user_fallback;

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          localizations.welcome_page_app_title,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'AppFont',
            fontSize: 28,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              Text(
                localizations.home_welcome_title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'AppFontMedium',
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                userEmail,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              Text(
                localizations.home_preview_front,
                style: const TextStyle(
                  fontFamily: 'AppFont',
                  fontSize: 24,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                localizations.home_preview_back,
                style: const TextStyle(
                  fontFamily: 'AppFont',
                  fontSize: 24,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.lg),
                child: Image.asset(
                  'assets/images/test.png',
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 80,
                        color: AppColors.accent.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        localizations.home_placeholder_title,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        localizations.home_placeholder_subtitle,
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AppButton(
                label: localizations.home_logout,
                onPressed: () async {
                  try {
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              const AuthenticationView(
                            initialTabIndex: 1,
                          ),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    }
                    await ref.read(authActionsProvider).signOut();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            localizations.email_verification_error_signout(
                              e.toString(),
                            ),
                          ),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
