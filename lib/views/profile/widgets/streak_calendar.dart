import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/app_opacity.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/providers/workout_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Streak calendar — shows last 7 days
// ─────────────────────────────────────────────────────────────────────────────

class StreakCalendar extends ConsumerWidget {
  final bool isFrench;

  const StreakCalendar({required this.isFrench, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(streakDataProvider);

    return streakAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (data) {
        final int currentStreak = (data['currentStreak'] as int?) ?? 0;
        final int bestStreak = (data['bestStreak'] as int?) ?? 0;
        final List<bool> lastSevenDays =
            (data['lastSevenDays'] as List?)?.cast<bool>() ??
                List<bool>.filled(7, false);

        final DateTime today = DateTime.now();
        final List<DateTime> days = List<DateTime>.generate(
          7,
          (int i) => today.subtract(Duration(days: 6 - i)),
        );
        final List<String> letters = isFrench
            ? <String>['L', 'M', 'M', 'J', 'V', 'S', 'D']
            : <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'];

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: AppOpacity.faint),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  border: Border.all(
                    color: AppColors.primary.withValues(
                      alpha: AppOpacity.medium,
                    ),
                  ),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: _StreakSummaryStat(
                          icon: Icons.local_fire_department_rounded,
                          iconColor: AppColors.warning,
                          value: '$currentStreak',
                          unit: isFrench ? 'jours' : 'days',
                          label: isFrench ? 'Actuelle' : 'Current',
                        ),
                      ),
                      VerticalDivider(
                        color: AppColors.babyBlueIce
                            .withValues(alpha: AppOpacity.visible),
                        thickness: 1,
                        width: AppSpacing.md,
                      ),
                      Expanded(
                        child: _StreakSummaryStat(
                          icon: Icons.emoji_events_rounded,
                          iconColor: AppColors.cornflowerBlue,
                          value: '$bestStreak',
                          unit: isFrench ? 'jours' : 'days',
                          label: isFrench ? 'Record' : 'Best',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xs,
                  AppSpacing.xs,
                  AppSpacing.xs,
                  AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant
                      .withValues(alpha: AppOpacity.moderate),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  border: Border.all(
                    color: AppColors.babyBlueIce.withValues(
                      alpha: AppOpacity.mild,
                    ),
                  ),
                ),
                child: _StreakDayTrack(
                  days: days,
                  lastSevenDays: lastSevenDays,
                  letters: letters,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StreakSummaryStat extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String unit;
  final String label;

  const _StreakSummaryStat({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.unit,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary.withValues(
                  alpha: AppOpacity.prominent,
                ),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'AppFontMedium',
                fontSize: 24,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: Text(
                unit,
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(
                    alpha: AppOpacity.bold,
                  ),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StreakDayTrack extends StatelessWidget {
  final List<DateTime> days;
  final List<bool> lastSevenDays;
  final List<String> letters;

  const _StreakDayTrack({
    required this.days,
    required this.lastSevenDays,
    required this.letters,
  });

  @override
  Widget build(BuildContext context) {
    const double maxNodeSize = 34;
    const double minNodeSize = 24;
    const double minGap = 4;
    const double maxGap = 14;
    const double connectorHeight = 10;
    const double labelHeight = 14;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double availableWidth = constraints.maxWidth;
        final double estimatedGap = (availableWidth - (maxNodeSize * 7)) / 6;
        final double gap = estimatedGap.clamp(minGap, maxGap).toDouble();
        final double nodeSize = ((availableWidth - (gap * 6)) / 7)
            .clamp(minNodeSize, maxNodeSize)
            .toDouble();
        final double topOffset =
            labelHeight + AppSpacing.xs + ((nodeSize - connectorHeight) / 2);
        final double totalHeight = labelHeight + AppSpacing.xs + nodeSize;

        return SizedBox(
          height: totalHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              for (int i = 0; i < 6; i++)
                Positioned(
                  left: ((nodeSize + gap) * i) + nodeSize,
                  top: topOffset,
                  width: gap,
                  height: connectorHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: lastSevenDays[i] && lastSevenDays[i + 1]
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              for (int i = 0; i < 7; i++)
                Positioned(
                  left: (nodeSize + gap) * i,
                  top: 0,
                  width: nodeSize,
                  child: _DaySquare(
                    letter: letters[(days[i].weekday - 1) % 7],
                    worked: lastSevenDays[i],
                    isToday: i == 6,
                    size: nodeSize,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DaySquare extends StatelessWidget {
  final String letter;
  final bool worked;
  final bool isToday;
  final double size;

  const _DaySquare({
    required this.letter,
    required this.worked,
    required this.isToday,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          letter,
          style: TextStyle(
            color: isToday
                ? AppColors.primaryDark
                : AppColors.textSecondary.withValues(alpha: AppOpacity.half),
            fontSize: 10,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: worked
                ? AppColors.primary
                : AppColors.babyBlueIce.withValues(alpha: AppOpacity.moderate),
            border: Border.all(
              color: isToday
                  ? AppColors.primaryLight
                  : worked
                      ? AppColors.primary
                      : AppColors.babyBlueIce.withValues(
                          alpha: AppOpacity.visible,
                        ),
              width: isToday ? 2 : 1,
            ),
            boxShadow: worked
                ? <BoxShadow>[
                    BoxShadow(
                      color:
                          AppColors.primary.withValues(alpha: AppOpacity.mild),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: worked
                ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                : Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1.5),
                      color: AppColors.textSecondary
                          .withValues(alpha: AppOpacity.mild),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
