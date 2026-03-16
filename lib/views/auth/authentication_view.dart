import 'package:flutter/material.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/l10n/app_localizations.dart';
import 'package:workin_fit/views/auth/login_view.dart';
import 'package:workin_fit/views/auth/register_view.dart';

class AuthenticationView extends StatefulWidget {
  final int initialTabIndex;

  const AuthenticationView({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<AuthenticationView> createState() => _AuthenticationViewState();
}

class _AuthenticationViewState extends State<AuthenticationView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        // To hide the arrow back button on the screen (only keep the phone one)
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm + 3),
          child: Center(
            child: Text(
              localizations.welcome_page_app_title,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'AppFont',
                fontSize: 30,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ),
        backgroundColor: AppColors.primary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            color: AppColors.primary,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withValues(alpha: 0.65),
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'AppFontMedium',
              ),
              unselectedLabelStyle: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontFamily: 'AppFontMedium',
              ),
              tabs: [
                Tab(text: localizations.auth_tab_register),
                Tab(text: localizations.auth_tab_login),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          RegisterScreen(),
          LoginView(),
        ],
      ),
    );
  }
}
