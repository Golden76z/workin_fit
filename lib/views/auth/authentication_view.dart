
import 'package:flutter/material.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/views/auth/login_view.dart';
import 'package:workin_fit/views/auth/register_view.dart';
// import 'package:workin_fit/views/auth/old_register_view.dart';
// import 'package:workin_fit/views/auth/register_view.dart';

class AuthenticationView extends StatefulWidget {
  const AuthenticationView({super.key});

  @override
  State<AuthenticationView> createState() => _AuthenticationViewState();
}

class _AuthenticationViewState extends State<AuthenticationView> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        // To hide the arrow back button on the screen (only keep the phone one)
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.only(top: 15.0),
          child: Center(
            child: Text(
          'Workin Fit',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontFamily:
                'AppFont',
            fontSize: 44,
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
              labelColor: AppColors.textPrimary,
              unselectedLabelColor: AppColors.textPrimary.withValues(alpha: 0.7),
              indicatorColor: AppColors.textPrimary,
              indicatorWeight: 3,
              labelStyle: theme.textTheme.titleLarge?.copyWith(
                // fontWeight: FontWeight.bold,
                fontFamily: 'AppFontNormal',
              ),
              unselectedLabelStyle: theme.textTheme.titleLarge?.copyWith(
                fontFamily: 'AppFontNormal',
              ),
              tabs: const [
                Tab(text: 'Register'),
                Tab(text: 'Login'),
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