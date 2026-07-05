import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_chrome.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/app_opacity.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/features/workout/presentation/screens/exercise_detail_screen.dart';
import 'package:workin_fit/core/constants/exercise_assets.dart';
import 'package:workin_fit/features/workout/presentation/widgets/exercise_movement_thumbnail.dart';
import 'package:workin_fit/features/workout/presentation/utils/exercise_ui_helpers.dart';
import 'package:workin_fit/l10n/app_localizations_en.dart';
import 'package:workin_fit/l10n/app_localizations_fr.dart';
import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/exercise_localization.dart';
import 'package:workin_fit/models/exercise_localization_helper.dart';
import 'package:workin_fit/providers/workout_providers.dart';

class ExerciseListScreen extends ConsumerStatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  ConsumerState<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends ConsumerState<ExerciseListScreen>
    with AutomaticKeepAliveClientMixin<ExerciseListScreen> {
  @override
  bool get wantKeepAlive => true;

  static final AppLocalizationsEn _en = AppLocalizationsEn();
  static final AppLocalizationsFr _fr = AppLocalizationsFr();

  final TextEditingController _searchController = TextEditingController();
  MuscleGroup? _selectedMuscleGroup;
  bool _compactMode = false;

  List<Exercise>? _filteredCache;
  List<Exercise>? _filteredSource;
  String _filteredQuery = '';
  MuscleGroup? _filteredMuscle;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetFilters(VoidCallback update) {
    setState(() {
      update();
      _invalidateFilteredCache();
    });
  }

  void _invalidateFilteredCache() {
    _filteredCache = null;
    _filteredSource = null;
  }

  List<Widget> _buildHeaderSlivers({
    required bool isFrench,
    required Color selectedFilterColor,
    required Color selectedFilterBorderColor,
    required Color unselectedFilterBorderColor,
  }) {

    const Color selectedFilterLabelColor = AppColors.primary;
    const Color unselectedFilterLabelColor = AppColors.neutral0;
    const Color selectedFilterCheckColor = AppColors.primary;

    return <Widget>[
      SliverAppBar(
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    systemOverlayStyle: AppChrome.topSurfaceOverlay,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    toolbarHeight: 36,
                    flexibleSpace: const AppTopBarBackground(),
                    title: Text(
                      isFrench ? 'Liste des exercices' : 'Exercise list',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'AppFontMedium',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    actions: <Widget>[
                      IconButton(
                        onPressed: () => setState(() => _compactMode = !_compactMode),
                        tooltip: _compactMode
                            ? (isFrench ? 'Vue normale' : 'Normal view')
                            : (isFrench ? 'Vue compacte' : 'Compact view'),
                        icon: Icon(
                          _compactMode
                              ? Icons.view_agenda_rounded
                              : Icons.view_headline_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ],
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(116),
                      child: AppTopBarBackground(
                        child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(0, 0, 0, AppSpacing.sm),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppLayout.pageMarginNarrow,
                              ),
                              child: TextField(
                                controller: _searchController,
                                textInputAction: TextInputAction.search,
                                onChanged: (_) => _resetFilters(() {}),
                                style: const TextStyle(
                                  color: AppColors.neutral0,
                                ),
                                decoration: InputDecoration(
                                  hintText: isFrench
                                      ? 'Rechercher un exercice...'
                                      : 'Search an exercise...',
                                  hintStyle: const TextStyle(
                                    color: AppColors.neutral400,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.search_rounded,
                                    color: AppColors.neutral400,
                                  ),
                                  suffixIcon: _searchController.text
                                          .trim()
                                          .isEmpty
                                      ? null
                                      : IconButton(
                                          onPressed: () {
                                            _searchController.clear();
                                            _resetFilters(() {});
                                          },
                                          icon: Icon(
                                            Icons.close_rounded,
                                            color:
                                                AppColors.neutral0.withValues(
                                              alpha: AppOpacity.bold,
                                            ),
                                          ),
                                        ),
                                  filled: true,
                                  fillColor:
                                      Colors.white.withValues(alpha: 0.9),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 5,
                                    horizontal: AppSpacing.sm,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadii.sm),
                                    borderSide: BorderSide(
                                      color: Colors.white
                                          .withValues(alpha: AppOpacity.mild),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadii.sm),
                                    borderSide: BorderSide(
                                      color:
                                          Colors.white.withValues(alpha: 0.55),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadii.sm),
                                    borderSide: BorderSide(
                                      color: AppColors.primaryLight.withValues(
                                        alpha: 0.95,
                                      ),
                                      width: 1.4,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            SizedBox(
                              height: 36,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: <Widget>[
                                  const SizedBox(width: AppLayout.pageMarginNarrow),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      right: AppSpacing.xs,
                                    ),
                                    child: ChoiceChip(
                                      label: Text(
                                        isFrench ? 'Tous' : 'All muscles',
                                      ),
                                      selected: _selectedMuscleGroup == null,
                                      checkmarkColor: selectedFilterCheckColor,
                                      backgroundColor:
                                          Colors.white.withValues(alpha: 0.84),
                                      selectedColor: selectedFilterColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppRadii.sm,
                                        ),
                                      ),
                                      side: BorderSide(
                                        color: _selectedMuscleGroup == null
                                            ? selectedFilterBorderColor
                                            : unselectedFilterBorderColor,
                                      ),
                                      labelStyle: TextStyle(
                                        color: _selectedMuscleGroup == null
                                            ? selectedFilterLabelColor
                                            : unselectedFilterLabelColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      onSelected: (_) => _resetFilters(
                                        () => _selectedMuscleGroup = null,
                                      ),
                                    ),
                                  ),
                                  ...MuscleGroup.values.map(
                                    (MuscleGroup muscle) => Padding(
                                      padding: const EdgeInsets.only(
                                        right: AppSpacing.xs,
                                      ),
                                      child: ChoiceChip(
                                        checkmarkColor:
                                            selectedFilterCheckColor,
                                        backgroundColor: Colors.white
                                            .withValues(alpha: 0.84),
                                        selectedColor: selectedFilterColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppRadii.sm,
                                          ),
                                        ),
                                        side: BorderSide(
                                          color: _selectedMuscleGroup == muscle
                                              ? selectedFilterBorderColor
                                              : unselectedFilterBorderColor,
                                        ),
                                        labelStyle: TextStyle(
                                          color: _selectedMuscleGroup == muscle
                                              ? selectedFilterLabelColor
                                              : unselectedFilterLabelColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        label: Text(
                                          muscleGroupLabel(muscle, isFrench),
                                        ),
                                        selected:
                                            _selectedMuscleGroup == muscle,
                                        onSelected: (_) => _resetFilters(() {
                                          _selectedMuscleGroup =
                                              _selectedMuscleGroup == muscle
                                                  ? null
                                                  : muscle;
                                        }),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppLayout.pageMarginNarrow),
                                ],
                              ),
                            ),
                          ],
                        ),
                        ),
                      ),
                    ),
                  ),
    ];
  }

  List<Widget> _buildSkeletonSlivers() {
    return <Widget>[
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppLayout.pageMargin,
          AppSpacing.md,
          AppLayout.pageMargin,
          104,
        ),
        sliver: SliverList.builder(
          itemCount: 6,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
              child: _ExerciseCardSkeleton(),
            );
          },
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bool isFrench = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('fr');
    final Color selectedFilterColor = Colors.white.withValues(alpha: 0.98);
    final Color selectedFilterBorderColor = AppColors.primary.withValues(
      alpha: 0.92,
    );
    final Color unselectedFilterBorderColor = Colors.white.withValues(
      alpha: 0.5,
    );
    final AsyncValue<List<Exercise>> exercisesAsync =
        ref.watch(exercisesProvider);
    ref.listen<AsyncValue<List<Exercise>>>(exercisesProvider, (
      AsyncValue<List<Exercise>>? previous,
      AsyncValue<List<Exercise>> next,
    ) {
      if (next.hasValue && previous?.valueOrNull != next.valueOrNull) {
        setState(_invalidateFilteredCache);
      }
    });

    return AppSystemOverlayRegion(
      style: AppChrome.homeOverlay,
      child: Scaffold(
        backgroundColor: AppColors.surfaceVariant,
        body: SafeArea(
          top: false,
          bottom: false,
          child: RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            onRefresh: () async {
              await ref.read(syncServiceProvider).refreshExercises();
              ExerciseAssets.clearMovementAssetIndexCache();
              await ExerciseAssets.warmMovementAssetIndex();
              ref.invalidate(exercisesProvider);
              await ref.read(exercisesProvider.future);
            },
            child: CustomScrollView(
              slivers: <Widget>[
                ..._buildHeaderSlivers(
                  isFrench: isFrench,
                  selectedFilterColor: selectedFilterColor,
                  selectedFilterBorderColor: selectedFilterBorderColor,
                  unselectedFilterBorderColor: unselectedFilterBorderColor,
                ),
                ...exercisesAsync.when(
                  data: (List<Exercise> exercises) {
                    final List<Exercise> filtered = _filteredExercises(
                      context: context,
                      exercises: exercises,
                    );

                    if (filtered.isEmpty) {
                      return <Widget>[
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              child: Text(
                                _emptyStateMessage(
                                  isFrench: isFrench,
                                  hasActiveFilters: _selectedMuscleGroup != null ||
                                      _searchController.text.trim().isNotEmpty,
                                  hasAnyExercise: exercises.isNotEmpty,
                                ),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ];
                    }

                    return <Widget>[
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          AppLayout.pageMargin,
                          AppSpacing.md,
                          AppLayout.pageMargin,
                          104,
                        ),
                        sliver: SliverList.builder(
                          itemCount: filtered.length,
                          itemBuilder: (BuildContext context, int index) {
                            final Exercise exercise = filtered[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.xxs),
                              child: _ExerciseCard(
                                exercise: exercise,
                                title: exercise.getLocalizedName(context),
                                description:
                                    exercise.getLocalizedDescription(context),
                                muscleSummary: exercise.muscleGroups
                                    .map((m) => muscleGroupLabel(m, isFrench))
                                    .join(', '),
                                difficulty: exercise.difficulty,
                                isFrench: isFrench,
                                compact: _compactMode,
                                onTap: () => Navigator.of(context).push(
                                  ExerciseDetailScreen.route(exercise: exercise),
                                ),
                              )
                                  .animate(
                                    delay: Duration(
                                      milliseconds:
                                          min(index, AppAnimations.staggerMaxItems) *
                                              AppAnimations.staggerMs,
                                    ),
                                  )
                                  .fadeIn(duration: AppAnimations.fast)
                                  .slideY(
                                    begin: 0.06,
                                    end: 0,
                                    duration: AppAnimations.fast,
                                    curve: AppAnimations.defaultIn,
                                  ),
                            );
                          },
                        ),
                      ),
                    ];
                  },
                  loading: () => _buildSkeletonSlivers(),
                  error: (Object error, StackTrace stackTrace) => <Widget>[
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Text(
                            isFrench
                                ? 'Impossible de charger les exercices: $error'
                                : 'Failed to load exercises: $error',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Exercise> _filteredExercises({
    required BuildContext context,
    required List<Exercise> exercises,
  }) {
    final String query = _searchController.text.trim();
    if (_filteredCache != null &&
        identical(_filteredSource, exercises) &&
        _filteredQuery == query &&
        _filteredMuscle == _selectedMuscleGroup) {
      return _filteredCache!;
    }

    final List<Exercise> filtered = exercises.where((Exercise exercise) {
      if (_selectedMuscleGroup != null &&
          !exercise.muscleGroups.contains(_selectedMuscleGroup)) {
        return false;
      }
      if (query.isEmpty) return true;
      return _matchesSearch(context: context, exercise: exercise, query: query);
    }).toList(growable: false);

    filtered.sort(
      (Exercise a, Exercise b) => a
          .getLocalizedName(context)
          .toLowerCase()
          .compareTo(b.getLocalizedName(context).toLowerCase()),
    );

    _filteredSource = exercises;
    _filteredQuery = query;
    _filteredMuscle = _selectedMuscleGroup;
    _filteredCache = filtered;
    return filtered;
  }

  bool _matchesSearch({
    required BuildContext context,
    required Exercise exercise,
    required String query,
  }) {
    final String normalizedQuery = exerciseNormalize(query);
    final String enName =
        ExerciseLocalizationHelper.getName(_en, exercise.id) ?? exercise.name;
    final String frName =
        ExerciseLocalizationHelper.getName(_fr, exercise.id) ?? exercise.name;
    final String enDescription =
        ExerciseLocalizationHelper.getDescription(_en, exercise.id) ??
            exercise.description;
    final String frDescription =
        ExerciseLocalizationHelper.getDescription(_fr, exercise.id) ??
            exercise.description;

    final Iterable<String> tokens = <String>{
      exercise.getLocalizedName(context),
      exercise.getLocalizedDescription(context),
      exercise.name,
      exercise.description,
      enName,
      frName,
      enDescription,
      frDescription,
      ...exercise.muscleGroups.expand(
        (m) => <String>{
          muscleGroupLabel(m, false),
          muscleGroupLabel(m, true),
          ...muscleGroupAliases(m),
        },
      ),
      ...exercise.equipment,
    };

    return tokens
        .map(exerciseNormalize)
        .any((t) => t.contains(normalizedQuery));
  }

  String _emptyStateMessage({
    required bool isFrench,
    required bool hasActiveFilters,
    required bool hasAnyExercise,
  }) {
    if (!hasAnyExercise) {
      return isFrench
          ? 'Aucun exercice disponible. La collection Firebase "exercises" semble vide pour le moment.'
          : 'No exercises available. The Firebase "exercises" collection appears empty right now.';
    }
    if (hasActiveFilters) {
      return isFrench
          ? 'Aucun exercice trouve avec ces filtres.'
          : 'No exercise found with those filters.';
    }
    return isFrench ? 'Aucun exercice trouve.' : 'No exercise found.';
  }
}

// ---------------------------------------------------------------------------
// Card widget
// ---------------------------------------------------------------------------

class _ExerciseCardSkeleton extends StatelessWidget {
  const _ExerciseCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: AppColors.surface,
        border: Border.all(color: AppColors.neutral300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 16,
              width: 180,
              decoration: BoxDecoration(
                color: AppColors.neutral300.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.neutral300.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final String title;
  final String description;
  final String muscleSummary;
  final DifficultyLevel difficulty;
  final bool isFrench;
  final bool compact;
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.exercise,
    required this.title,
    required this.description,
    required this.muscleSummary,
    required this.difficulty,
    required this.isFrench,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.surface,
            border: Border.all(color: AppColors.neutral300),
          ),
          child: compact ? _buildCompactContent() : _buildFullContent(context),
        ),
      ),
    );
  }

  Widget _buildCompactContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'AppFontMedium',
                  ),
                ),
                if (muscleSummary.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    muscleSummary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.primaryLight.withValues(
                        alpha: AppOpacity.bold,
                      ),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          ExerciseDifficultyBadge(difficulty: difficulty, isFrench: isFrench),
        ],
      ),
    );
  }

  Widget _buildFullContent(BuildContext context) {
    final String categoryLabel = getExerciseCategoryLabel(exercise, isFrench);
    const double mediaWidth = 120.0;
    const double mediaHeight = 84.0;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Thumbnail Image on the left
          Hero(
            tag: exercise.imageTutorialUrl.isNotEmpty
                ? 'exercise-img-${exercise.imageTutorialUrl}'
                : 'exercise-img-${exercise.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: mediaWidth,
                height: mediaHeight,
                child: _ExerciseImage(
                  exerciseId: exercise.id,
                  imageUrl: exercise.imageTutorialUrl,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Content on the right
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Row with Title & Difficulty Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'AppFontMedium',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ExerciseDifficultyBadge(difficulty: difficulty, isFrench: isFrench),
                  ],
                ),
                const SizedBox(height: 6),
                // Description
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF8F8DA8), // Muted grayish-purple
                    fontSize: 12,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                // Category Tag
                _CategoryBadge(label: categoryLabel),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String label;

  const _CategoryBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1B36),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF8D8AA6),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

String getExerciseCategoryLabel(Exercise exercise, bool isFrench) {
  bool targetsUpper = exercise.muscleGroups.any((m) => 
    m == MuscleGroup.chest || 
    m == MuscleGroup.shoulders || 
    m == MuscleGroup.triceps || 
    m == MuscleGroup.biceps || 
    m == MuscleGroup.back || 
    m == MuscleGroup.forearms
  );
  bool targetsLower = exercise.muscleGroups.any((m) => 
    m == MuscleGroup.quads || 
    m == MuscleGroup.hamstrings || 
    m == MuscleGroup.calves || 
    m == MuscleGroup.glutes
  );
  bool targetsCore = exercise.muscleGroups.any((m) => 
    m == MuscleGroup.abs || 
    m == MuscleGroup.obliques || 
    m == MuscleGroup.lowerBack
  );

  if (targetsUpper && targetsLower && targetsCore) {
    return isFrench ? 'Corps entier' : 'Full body';
  }
  
  if (targetsCore && !targetsUpper && !targetsLower) {
    return isFrench ? 'Tronc' : 'Core';
  }
  
  if (exercise.muscleGroups.isNotEmpty) {
    final primary = exercise.muscleGroups.first;
    if (primary == MuscleGroup.abs || primary == MuscleGroup.obliques || primary == MuscleGroup.lowerBack) {
      return isFrench ? 'Tronc' : 'Core';
    }
    return muscleGroupLabel(primary, isFrench);
  }
  
  return isFrench ? 'Autre' : 'Other';
}

class _ExerciseImage extends StatelessWidget {
  final String exerciseId;
  final String imageUrl;

  const _ExerciseImage({
    required this.exerciseId,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final int cacheHeight =
        (100 * MediaQuery.devicePixelRatioOf(context)).round();

    return ExerciseMovementThumbnail(
      exerciseId: exerciseId,
      imageUrl: imageUrl,
      cacheHeight: cacheHeight,
      placeholder: const _ListThumbnailPlaceholder(),
    );
  }
}

class _ListThumbnailPlaceholder extends StatelessWidget {
  const _ListThumbnailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: Color(0xFF1E1B30),
      ),
    );
  }
}
