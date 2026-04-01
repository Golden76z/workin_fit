import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/providers/warmup_providers.dart';

class WarmupCategoryScreen extends ConsumerWidget {
  const WarmupCategoryScreen({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => const WarmupCategoryScreen(),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(warmupCategoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        title: const Text('Choose focus area'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          for (final entry in _categories)
            _CategoryCard(
              category: entry.$1,
              icon: entry.$2,
              name: entry.$3,
              description: entry.$4,
              isSelected: selected == entry.$1,
              onTap: () {
                ref.read(warmupCategoryProvider.notifier).state = entry.$1;
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }
}

const _categories = [
  (WarmupCategory.fullBody,   Icons.accessibility_new_rounded,  'Full Body',  'Whole body activation'),
  (WarmupCategory.upperBody,  Icons.fitness_center_rounded,     'Upper Body', 'Arms, shoulders & chest'),
  (WarmupCategory.lowerBody,  Icons.directions_run_rounded,     'Lower Body', 'Legs, hips & glutes'),
  (WarmupCategory.core,       Icons.sports_gymnastics_rounded,  'Core',       'Abs & lower back'),
  (WarmupCategory.cardio,     Icons.favorite_rounded,           'Cardio',     'Get your heart rate up'),
];

class _CategoryCard extends StatelessWidget {
  final WarmupCategory category;
  final IconData icon;
  final String name;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.icon,
    required this.name,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceVariant : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}
