import 'package:flutter/material.dart';
import 'package:sport_app/app_theme.dart';

class BeginnerProgramsSection extends StatelessWidget {
  const BeginnerProgramsSection({super.key});

  @override
  Widget build(BuildContext context) {
    Widget buildProgramCard(
        String title, String subtitle, String description, IconData icon,
        {bool isRecommended = false}) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: isRecommended
              ? Border.all(color: AthleticEnergyTheme.brightYellow, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isRecommended
                    ? AthleticEnergyTheme.brightYellow.withValues(alpha: 0.1)
                    : AthleticEnergyTheme.primaryRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isRecommended
                    ? AthleticEnergyTheme.brightYellow
                    : AthleticEnergyTheme.primaryRed,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AthleticEnergyTheme.textGray,
                                ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AthleticEnergyTheme.brightYellow,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "RECOMMENDED",
                            style: TextStyle(
                              color: AthleticEnergyTheme.darkCharcoalLight,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AthleticEnergyTheme.deepOrange,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AthleticEnergyTheme.textGray,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AthleticEnergyTheme.textGray,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              " Workout Programs",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AthleticEnergyTheme.textGray,
                  ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to all programs
              },
              child: const Text("See All"),
            ),
          ],
        ),
        const SizedBox(height: 4),
        buildProgramCard(
          "First Week Journey",
          "7 days • 5-10 min daily",
          "Build confidence with gentle movements",
          Icons.star,
          isRecommended: true,
        ),
        const SizedBox(height: 12),
        buildProgramCard(
          "No Experience Needed",
          "Easy pace • Step by step",
          "Learn the basics at your own speed",
          Icons.school,
        ),
        const SizedBox(height: 12),
        buildProgramCard(
          "Living Room Friendly",
          "Small space • Quiet movements",
          "Perfect for home workouts",
          Icons.home,
        ),
        const SizedBox(height: 12),
        buildProgramCard(
          "Create your own !",
          "Fully customisable",
          "",
          Icons.dashboard_customize,
        ),
      ],
    );
  }
}
