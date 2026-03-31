import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_chrome.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/app_opacity.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/features/workout/presentation/screens/exercise_detail_screen.dart';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bool isFrench = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('fr');
    const Color selectedFilterCheckColor = AppColors.primaryDarkest;
    final AsyncValue<List<Exercise>> exercisesAsync =
        ref.watch(exercisesProvider);

    return AppSystemOverlayRegion(
      style: AppChrome.homeOverlay,
      child: Scaffold(
        backgroundColor: AppColors.surfaceVariant,
        body: SafeArea(
          top: false,
          bottom: false,
          child: exercisesAsync.when(
            data: (List<Exercise> exercises) {
              final List<Exercise> filtered =
                  _filteredExercises(context: context, exercises: exercises);
              const Offset velocity = Offset(42, 12);

              return CustomScrollView(
                slivers: <Widget>[
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
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(116),
                      child: Container(
                        color: Colors.transparent,
                        padding:
                            const EdgeInsets.fromLTRB(0, 0, 0, AppSpacing.sm),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppLayout.pageMargin,
                              ),
                              child: TextField(
                                controller: _searchController,
                                textInputAction: TextInputAction.search,
                                onChanged: (_) => setState(() {}),
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
                                            setState(() {});
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
                                  const SizedBox(width: AppLayout.pageMargin),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      right: AppSpacing.xs,
                                    ),
                                    child: ChoiceChip(
                                      label: Text(
                                        isFrench ? 'Tout' : 'All muscles',
                                      ),
                                      selected: _selectedMuscleGroup == null,
                                      checkmarkColor: selectedFilterCheckColor,
                                      backgroundColor:
                                          Colors.white.withValues(alpha: 0.84),
                                      selectedColor: AppColors.primaryPastel
                                          .withValues(alpha: 0.96),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppRadii.sm,
                                        ),
                                      ),
                                      side: BorderSide(
                                        color: _selectedMuscleGroup == null
                                            ? AppColors.primaryLight.withValues(
                                                alpha: 0.9,
                                              )
                                            : Colors.white.withValues(
                                                alpha: 0.5,
                                              ),
                                      ),
                                      labelStyle: TextStyle(
                                        color: _selectedMuscleGroup == null
                                            ? AppColors.primaryDarkest
                                            : AppColors.neutral0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      onSelected: (_) => setState(
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
                                        selectedColor: AppColors.primaryPastel
                                            .withValues(alpha: 0.96),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppRadii.sm,
                                          ),
                                        ),
                                        side: BorderSide(
                                          color: _selectedMuscleGroup == muscle
                                              ? AppColors.primaryLight
                                                  .withValues(alpha: 0.9)
                                              : Colors.white.withValues(
                                                  alpha: 0.5,
                                                ),
                                        ),
                                        labelStyle: TextStyle(
                                          color: _selectedMuscleGroup == muscle
                                              ? AppColors.primaryDarkest
                                              : AppColors.neutral0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        label: Text(
                                          muscleGroupLabel(muscle, isFrench),
                                        ),
                                        selected:
                                            _selectedMuscleGroup == muscle,
                                        onSelected: (_) => setState(() {
                                          _selectedMuscleGroup =
                                              _selectedMuscleGroup == muscle
                                                  ? null
                                                  : muscle;
                                        }),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppLayout.pageMargin),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (filtered.isEmpty)
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
                    )
                  else
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
                              shaderVelocity: velocity,
                              onTap: () => Navigator.of(context).push(
                                ExerciseDetailScreen.route(exercise: exercise),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object error, StackTrace stackTrace) => Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  isFrench
                      ? 'Impossible de charger les exercices: $error'
                      : 'Failed to load exercises: $error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error, fontSize: 14),
                ),
              ),
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
    final List<Exercise> filtered = exercises.where((Exercise exercise) {
      if (_selectedMuscleGroup != null &&
          !exercise.muscleGroups.contains(_selectedMuscleGroup)) {
        return false;
      }
      if (query.isEmpty) return true;
      return _matchesSearch(context: context, exercise: exercise, query: query);
    }).toList(growable: false);

    filtered.sort((Exercise a, Exercise b) {
      final int dc =
          difficultyRank(a.difficulty).compareTo(difficultyRank(b.difficulty));
      if (dc != 0) return dc;
      return a
          .getLocalizedName(context)
          .toLowerCase()
          .compareTo(b.getLocalizedName(context).toLowerCase());
    });

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

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final String title;
  final String description;
  final String muscleSummary;
  final DifficultyLevel difficulty;
  final bool isFrench;
  final Offset shaderVelocity;
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.exercise,
    required this.title,
    required this.description,
    required this.muscleSummary,
    required this.difficulty,
    required this.isFrench,
    required this.shaderVelocity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: AppColors.surface,
            border: Border.all(color: AppColors.neutral300),
          ),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double cardWidth = constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : MediaQuery.sizeOf(context).width;
              final double mediaWidth = (cardWidth * 0.36).clamp(118.0, 156.0);
              final double mediaHeight = mediaWidth * 0.64;

              return Padding(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'AppFontMedium',
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        ExerciseDifficultyBadge(
                          difficulty: difficulty,
                          isFrench: isFrench,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Container(
                      height: 1,
                      color: AppColors.primaryLight.withValues(
                        alpha: AppOpacity.moderate,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    SizedBox(
                      height: mediaHeight,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                            child: SizedBox(
                              width: mediaWidth,
                              height: mediaHeight,
                              child: _ExerciseImage(
                                imageUrl: exercise.imageTutorialUrl,
                                shaderVelocity: shaderVelocity,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            width: 1,
                            height: mediaHeight,
                            color: AppColors.primaryLight.withValues(
                              alpha: AppOpacity.moderate,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                if (muscleSummary.trim().isNotEmpty) ...[
                                  Text(
                                    muscleSummary,
                                    maxLines: 2,
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
                                  const SizedBox(height: AppSpacing.xxs),
                                ],
                                Expanded(
                                  child: Text(
                                    description,
                                    maxLines: 5,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      height: 1.28,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Image + shader
// ---------------------------------------------------------------------------

class _ExerciseWaveFilter extends StatefulWidget {
  final Widget child;
  final Offset velocity;

  const _ExerciseWaveFilter({required this.child, required this.velocity});

  @override
  State<_ExerciseWaveFilter> createState() => _ExerciseWaveFilterState();
}

class _ExerciseWaveFilterState extends State<_ExerciseWaveFilter> {
  static final Future<ui.FragmentProgram> _programFuture =
      ui.FragmentProgram.fromAsset('assets/shaders/exercise_wave.frag');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.FragmentProgram>(
      future: _programFuture,
      builder: (BuildContext context, AsyncSnapshot<ui.FragmentProgram> snap) {
        if (!snap.hasData) return widget.child;
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double width =
                constraints.maxWidth.isFinite ? constraints.maxWidth : 1;
            final double height =
                constraints.maxHeight.isFinite ? constraints.maxHeight : 1;
            final ui.FragmentShader shader = snap.data!.fragmentShader();
            shader.setFloat(0, width.clamp(1, 2000).toDouble());
            shader.setFloat(1, height.clamp(1, 2000).toDouble());
            shader.setFloat(2, widget.velocity.dx);
            shader.setFloat(3, widget.velocity.dy);
            return ImageFiltered(
              imageFilter: ui.ImageFilter.shader(shader),
              child: widget.child,
            );
          },
        );
      },
    );
  }
}

class _ExerciseImage extends StatelessWidget {
  final String imageUrl;
  final Offset shaderVelocity;

  const _ExerciseImage({required this.imageUrl, required this.shaderVelocity});

  @override
  Widget build(BuildContext context) {
    final String trimmed = imageUrl.trim();
    if (trimmed.isEmpty) return const _MissingExerciseImage();

    final Widget image = trimmed.startsWith('assets/')
        ? Image.asset(
            trimmed,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          )
        : Image.network(
            trimmed,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          );

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        const _MissingExerciseImage(),
        _ExerciseWaveFilter(velocity: shaderVelocity, child: image),
      ],
    );
  }
}

class _MissingExerciseImage extends StatelessWidget {
  const _MissingExerciseImage();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.surface.withValues(alpha: 0.96),
            AppColors.background.withValues(alpha: 0.92),
          ],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.neutral300,
          ),
        ),
      ),
    );
  }
}
