import 'package:flutter/material.dart';
import 'package:sport_app/core/theme/app_theme.dart';

class QuickStartSection extends StatelessWidget {
  const QuickStartSection({super.key});

  @override
  Widget build(BuildContext context) {
    Widget buildQuickStartCard(
        String duration, String title, IconData icon, Color color) {
      return GestureDetector(
        onTap: () {
          // Navigate to specific workout
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                duration,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            "Warm-up Routine",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AthleticEnergyTheme.textGray,
                ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: buildQuickStartCard(
                "2 Min",
                "Warm Up",
                Icons.accessibility_new,
                AthleticEnergyTheme.brightYellow,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: buildQuickStartCard(
                "5 Min",
                "Gentle Move",
                Icons.favorite,
                AthleticEnergyTheme.deepOrange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: buildQuickStartCard(
                "10 Min",
                "Full Body",
                Icons.fitness_center,
                AthleticEnergyTheme.primaryRed,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
