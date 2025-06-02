import 'package:flutter/material.dart';

class ProgressSection extends StatelessWidget {
  const ProgressSection({super.key});

  Widget _buildMotivationStat(String number, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFFE53E3E),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF718096),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFD23F).withOpacity(0.1), // brightYellow
            const Color(0xFFFF6B35).withOpacity(0.1), // deepOrange
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD23F).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_events,
                color: Color(0xFFFFD23F),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                "Your Journey Starts Here",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D3748),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Every expert was once a beginner. Take the first step today and celebrate every small victory along the way!",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF2D3748),
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMotivationStat("0", "Days Active"),
              const SizedBox(width: 24),
              _buildMotivationStat("0", "Workouts Done"),
              const SizedBox(width: 24),
              _buildMotivationStat("0", "Minutes Moved"),
            ],
          ),
        ],
      ),
    );
  }
}