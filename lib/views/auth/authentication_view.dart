import 'package:flutter/material.dart';
import 'package:sport_app/views/auth/login_view.dart';
import 'package:sport_app/views/auth/register_view.dart';

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
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Center(
            child: Text(
              'Workin Fit',
              style: theme.textTheme.displayLarge?.copyWith(
                color: colors.onPrimary,
              ),
            ),
          ),
        ),
        backgroundColor: colors.primary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            color: colors.primary,
            child: TabBar(
              controller: _tabController,
              labelColor: colors.onPrimary,
              unselectedLabelColor: colors.onPrimary.withOpacity(0.7),
              indicatorColor: colors.onPrimary,
              indicatorWeight: 3,
              labelStyle: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: theme.textTheme.titleLarge,
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
          RegisterView(),
          LoginView(),
        ],
      ),
    );
  }
}