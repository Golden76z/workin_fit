import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sport_app/app_theme.dart';
import '../widgets/index.dart';
import 'package:sport_app/services/auth/bloc/auth_bloc.dart';
import 'package:sport_app/services/auth/bloc/auth_event.dart';
import 'package:sport_app/utilities/dialogs/logout_dialog.dart';

class HomePageAuth extends StatefulWidget {
  const HomePageAuth({super.key});

  @override
  State<HomePageAuth> createState() => _HomePageState();
}

class _HomePageState extends State<HomePageAuth> {
  int _currentIndex = 0;
  final List<Widget> _pages = [const HomeContent()];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 10),
        child: Container(
          decoration: BoxDecoration(
            color: AthleticEnergyTheme.primaryRed,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
          ),
          child: AppBar(
            title: Transform.translate(
              offset: const Offset(0, 5),
              child: Text(
                'Workin Fit',
                style: theme.textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 2,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.logout,
                    color: Colors.white.withValues(alpha: 0.9)),
                onPressed: () async {
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout && mounted) {
                    // ignore: use_build_context_synchronously
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        height: kBottomNavigationBarHeight + 8,
        decoration: BoxDecoration(
          color: AthleticEnergyTheme.primaryRed,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              spreadRadius: 0.5,
              offset: const Offset(0, -1),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1.0,
            ),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home,
                    color: Colors.white.withValues(alpha: 0.9)),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center,
                    color: Colors.white.withValues(alpha: 0.9)),
                label: 'Exercises',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person,
                    color: Colors.white.withValues(alpha: 0.9)),
                label: 'Profile',
              ),
            ],
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white.withValues(alpha: 0.6),
            showUnselectedLabels: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WelcomeHeader(),
            const SizedBox(height: 24),
            const DailyChallengeCard(),
            const SizedBox(height: 24),
            const QuickStartSection(),
            const SizedBox(height: 24),
            const BeginnerProgramsSection(),
            const SizedBox(height: 24),
            const ProgressSection(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
