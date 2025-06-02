import 'package:flutter/material.dart';
import 'package:sport_app/app_theme.dart';

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Good Morning! 👋",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AthleticEnergyTheme.textGray,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            "Ready to move your body today?",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AthleticEnergyTheme.textGray,
                ),
          ),
        ],
      ),
    );
  }
}
