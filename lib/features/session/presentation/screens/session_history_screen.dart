import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_chrome.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/models/session_history_entry.dart';
import 'package:workin_fit/providers/session_history_provider.dart';
import 'package:workin_fit/widgets/app_dialog.dart';
import 'package:workin_fit/core/theme/app_opacity.dart';

class SessionHistoryScreen extends ConsumerWidget {
  const SessionHistoryScreen({super.key});

  static Route<void> route() {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (context, animation, secondaryAnimation) =>
          const SessionHistoryScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.15),
              end: Offset.zero,
            ).animate(curve),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isFrench = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('fr');

    final historyAsync = ref.watch(sessionHistoryProvider);

    return AppSystemOverlayRegion(
      style: AppChrome.topAndBottomOverlay,
      child: Scaffold(
        backgroundColor: AppColors.surfaceVariant,
        extendBody: true,
        bottomNavigationBar: const AppBottomInsetSurface(),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              systemOverlayStyle: AppChrome.topSurfaceOverlay,
              flexibleSpace: const AppTopBarBackground(),
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text(
                isFrench ? 'Historique' : 'History',
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'AppFontMedium',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              actions: [
                historyAsync.maybeWhen(
                  data: (entries) => entries.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(
                          icon: const Icon(
                            Icons.delete_sweep_rounded,
                            color: Colors.white,
                          ),
                          tooltip: isFrench ? 'Effacer' : 'Clear all',
                          onPressed: () =>
                              _confirmClear(context, ref, isFrench),
                        ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
            historyAsync.when(
              data: (entries) {
                if (entries.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(isFrench: isFrench),
                  );
                }

                // Group by date
                final grouped = _groupByDate(entries);
                final groups = grouped.entries.toList();

                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    MediaQuery.paddingOf(context).bottom + AppSpacing.xl,
                  ),
                  sliver: SliverList.builder(
                    itemCount: groups.fold<int>(
                      0,
                      (sum, g) => sum + 1 + g.value.length,
                    ),
                    itemBuilder: (context, index) {
                      // Flatten: header + entries for each group
                      int cursor = 0;
                      for (final group in groups) {
                        if (index == cursor) {
                          return _DateHeader(
                            label: _dateLabel(group.key, isFrench),
                          );
                        }
                        cursor++;
                        for (final entry in group.value) {
                          if (index == cursor) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.xs,
                              ),
                              child: _HistoryCard(
                                entry: entry,
                                isFrench: isFrench,
                              ),
                            );
                          }
                          cursor++;
                        }
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    isFrench
                        ? 'Impossible de charger l\'historique.'
                        : 'Could not load history.',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Group entries by calendar day (yyyy-MM-dd string key).
  Map<String, List<SessionHistoryEntry>> _groupByDate(
    List<SessionHistoryEntry> entries,
  ) {
    final map = <String, List<SessionHistoryEntry>>{};
    for (final entry in entries) {
      final key = _dayKey(entry.completedAt);
      map.putIfAbsent(key, () => []).add(entry);
    }
    return map;
  }

  String _dayKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  String _dateLabel(String dayKey, bool isFrench) {
    final today = DateTime.now();
    final todayKey = _dayKey(today);
    final yesterdayKey = _dayKey(today.subtract(const Duration(days: 1)));

    if (dayKey == todayKey) return isFrench ? "Aujourd'hui" : 'Today';
    if (dayKey == yesterdayKey) return isFrench ? 'Hier' : 'Yesterday';

    final parts = dayKey.split('-');
    final dt = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
    final months = isFrench
        ? [
            '',
            'jan.',
            'fév.',
            'mars',
            'avr.',
            'mai',
            'juin',
            'juil.',
            'août',
            'sept.',
            'oct.',
            'nov.',
            'déc.',
          ]
        : [
            '',
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
          ];

    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  Future<void> _confirmClear(
    BuildContext context,
    WidgetRef ref,
    bool isFrench,
  ) async {
    final confirmed = await AppDialog.showConfirm(
      context: context,
      title: isFrench ? 'Effacer l\'historique ?' : 'Clear history?',
      confirmLabel: isFrench ? 'Effacer' : 'Clear',
      cancelLabel: isFrench ? 'Annuler' : 'Cancel',
      message: isFrench
          ? 'Cette action est irréversible.'
          : 'This cannot be undone.',
      icon: Icons.delete_sweep_rounded,
      iconColor: AppColors.error,
      destructive: true,
    );
    if (confirmed != true) return;
    await ref.read(sessionHistoryActionsProvider).clearHistory();
  }
}

// ---------------------------------------------------------------------------
// Date header
// ---------------------------------------------------------------------------

class _DateHeader extends StatelessWidget {
  final String label;

  const _DateHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              fontFamily: 'AppFontMedium',
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// History card
// ---------------------------------------------------------------------------

class _HistoryCard extends StatelessWidget {
  final SessionHistoryEntry entry;
  final bool isFrench;

  const _HistoryCard({required this.entry, required this.isFrench});

  String _timeLabel(DateTime dt, bool isFrench) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: AppOpacity.medium),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withValues(alpha: AppOpacity.faint),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            // Check circle
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: AppOpacity.subtle),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.sessionName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'AppFontMedium',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 12,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        entry.durationDisplay,
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Time
            Text(
              _timeLabel(entry.completedAt, isFrench),
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  final bool isFrench;

  const _EmptyState({required this.isFrench});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            size: 56,
            color: AppColors.primaryLight.withValues(alpha: AppOpacity.visible),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isFrench ? 'Aucune session effectuée' : 'No sessions yet',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'AppFontMedium',
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            isFrench
                ? 'Vos sessions complétées apparaîtront ici.'
                : 'Your completed sessions will appear here.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Nav bar fill
// ---------------------------------------------------------------------------
