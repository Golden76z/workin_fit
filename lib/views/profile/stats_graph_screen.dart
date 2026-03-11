import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_chrome.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/features/auth/domain/auth_provider.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/exercise_localization.dart';
import 'package:workin_fit/providers/workout_providers.dart';
import 'package:workin_fit/services/firestore_service.dart';

class StatsGraphScreen extends ConsumerStatefulWidget {
  const StatsGraphScreen({super.key});

  @override
  ConsumerState<StatsGraphScreen> createState() => _StatsGraphScreenState();
}

class _StatsGraphScreenState extends ConsumerState<StatsGraphScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  DateTime _selectedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _monthlySummary;
  List<Map<String, dynamic>> _exerciseAggregates = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _loadMonthlyStats();
  }

  String _monthKey(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    return '${date.year}-$month';
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  String _formatDuration(int seconds) {
    final int hours = seconds ~/ 3600;
    final int minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  Future<void> _loadMonthlyStats() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'User not authenticated.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final Future<Map<String, dynamic>?> summaryFuture =
          _firestoreService.getMonthlyWorkoutSummary(
        userId: user.uid,
        monthKey: _monthKey(_selectedMonth),
      );
      final Future<List<Map<String, dynamic>>> aggregatesFuture =
          _firestoreService.getMonthlyExerciseAggregates(
        userId: user.uid,
        monthKey: _monthKey(_selectedMonth),
      );

      final List<dynamic> results = await Future.wait<dynamic>(<Future<dynamic>>[
        summaryFuture,
        aggregatesFuture,
      ]);
      if (!mounted) return;

      setState(() {
        _monthlySummary = results[0] as Map<String, dynamic>?;
        _exerciseAggregates = results[1] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + delta,
      );
    });
    _loadMonthlyStats();
  }

  @override
  Widget build(BuildContext context) {
    final bool isFrench = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('fr');
    final AsyncValue<List<Exercise>> exercisesAsync = ref.watch(
      exercisesProvider,
    );
    final Map<String, String> exerciseNameById = exercisesAsync.maybeWhen(
      data: (List<Exercise> exercises) => <String, String>{
        for (final Exercise exercise in exercises)
          exercise.id: exercise.getLocalizedName(context),
      },
      orElse: () => <String, String>{},
    );

    final List<Map<String, dynamic>> rankedExercises =
        List<Map<String, dynamic>>.from(_exerciseAggregates)
          ..sort((a, b) => _asInt(b['doneReps']).compareTo(_asInt(a['doneReps'])));
    const int maxVisibleRows = 100;
    final List<Map<String, dynamic>> visibleRows = rankedExercises
        .take(maxVisibleRows)
        .toList(growable: false);

    final int totalWorkouts = _asInt(_monthlySummary?['totalWorkouts']);
    final int totalDoneReps = _asInt(_monthlySummary?['totalDoneReps']);
    final int totalDoneWorkSeconds = _asInt(
      _monthlySummary?['totalDoneWorkSeconds'],
    );

    return AppSystemOverlayRegion(
      style: AppChrome.topAndBottomOverlay,
      child: Scaffold(
        backgroundColor: AppColors.surfaceVariant,
        appBar: AppBar(
          title: Text(
            isFrench ? 'Stats & Graphiques' : 'Stats & Graph',
          ),
          backgroundColor: AppChrome.topSurface,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        body: RefreshIndicator(
          onRefresh: _loadMonthlyStats,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.md),
            children: <Widget>[
              _MonthHeader(
                label: MaterialLocalizations.of(context).formatMonthYear(
                  _selectedMonth,
                ),
                onPrevious: () => _changeMonth(-1),
                onNext: () => _changeMonth(1),
              ),
              const SizedBox(height: AppSpacing.md),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.xxxl),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_errorMessage != null)
                _ErrorCard(message: _errorMessage!)
              else ...<Widget>[
                _SummaryGrid(
                  totalWorkouts: totalWorkouts,
                  totalDoneReps: totalDoneReps,
                  totalDoneWorkLabel: _formatDuration(totalDoneWorkSeconds),
                  isFrench: isFrench,
                ),
                const SizedBox(height: AppSpacing.md),
                _RepsGraphCard(
                  title: isFrench
                      ? 'Top exercices (répétitions)'
                      : 'Top exercises (reps)',
                  rows: rankedExercises.take(7).toList(growable: false),
                  nameById: exerciseNameById,
                  valueOf: (Map<String, dynamic> row) => _asInt(row['doneReps']),
                  fallbackName: isFrench ? 'Exercice' : 'Exercise',
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  isFrench
                      ? 'Détail des exercices du mois'
                      : 'Monthly exercise details',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'AppFontMedium',
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                if (visibleRows.isEmpty)
                  _EmptyCard(
                    label: isFrench
                        ? 'Aucune donnée pour ce mois.'
                        : 'No data for this month yet.',
                  )
                else
                  ...visibleRows.map((Map<String, dynamic> row) {
                    final String exerciseId =
                        (row['exerciseId'] as String? ?? '').trim();
                    final String title =
                        exerciseNameById[exerciseId] ??
                        '${isFrench ? 'Exercice' : 'Exercise'} $exerciseId';
                    return _ExerciseRow(
                      title: title,
                      reps: _asInt(row['doneReps']),
                      sets: _asInt(row['doneSets']),
                      workLabel: _formatDuration(_asInt(row['doneWorkSeconds'])),
                    );
                  }),
                if (rankedExercises.length > maxVisibleRows)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(
                      isFrench
                          ? 'Affichage des $maxVisibleRows premiers exercices sur ${rankedExercises.length}.'
                          : 'Showing top $maxVisibleRows exercises out of ${rankedExercises.length}.',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MonthHeader({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.babyBlueIce.withValues(alpha: 0.65)),
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'AppFontMedium',
              ),
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final int totalWorkouts;
  final int totalDoneReps;
  final String totalDoneWorkLabel;
  final bool isFrench;

  const _SummaryGrid({
    required this.totalWorkouts,
    required this.totalDoneReps,
    required this.totalDoneWorkLabel,
    required this.isFrench,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: <Widget>[
        _StatCard(
          label: isFrench ? 'Séances' : 'Workouts',
          value: '$totalWorkouts',
        ),
        _StatCard(
          label: isFrench ? 'Répétitions' : 'Reps',
          value: '$totalDoneReps',
        ),
        _StatCard(
          label: isFrench ? 'Travail actif' : 'Active work',
          value: totalDoneWorkLabel,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - (AppSpacing.md * 2) - AppSpacing.xs) / 2,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.babyBlueIce.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              fontFamily: 'AppFontMedium',
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RepsGraphCard extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> rows;
  final Map<String, String> nameById;
  final int Function(Map<String, dynamic>) valueOf;
  final String fallbackName;

  const _RepsGraphCard({
    required this.title,
    required this.rows,
    required this.nameById,
    required this.valueOf,
    required this.fallbackName,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> nonEmptyRows = rows
        .where((row) => valueOf(row) > 0)
        .toList(growable: false);
    final int maxValue = nonEmptyRows.isEmpty
        ? 0
        : nonEmptyRows
            .map(valueOf)
            .reduce(math.max);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.babyBlueIce.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontFamily: 'AppFontMedium',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (nonEmptyRows.isEmpty)
            const Text(
              'No rep-based activity yet.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            )
          else
            ...nonEmptyRows.map((Map<String, dynamic> row) {
              final String exerciseId =
                  (row['exerciseId'] as String? ?? '').trim();
              final String label =
                  nameById[exerciseId] ?? '$fallbackName $exerciseId';
              final int value = valueOf(row);
              final double fraction = maxValue <= 0
                  ? 0
                  : (value / maxValue).clamp(0, 1).toDouble();

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '$label · $value',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      child: LinearProgressIndicator(
                        value: fraction,
                        minHeight: 9,
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.12),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  final String title;
  final int reps;
  final int sets;
  final String workLabel;

  const _ExerciseRow({
    required this.title,
    required this.reps,
    required this.sets,
    required this.workLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.babyBlueIce.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '$reps reps',
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '$sets sets',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            workLabel,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.errorSoft.withValues(alpha: 0.5)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.error,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String label;

  const _EmptyCard({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.babyBlueIce.withValues(alpha: 0.6)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
