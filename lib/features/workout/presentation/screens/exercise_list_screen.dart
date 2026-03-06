import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/features/workout/presentation/screens/exercise_detail_screen.dart';
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

class _ExerciseListScreenState extends ConsumerState<ExerciseListScreen> {
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
    final bool isFrench =
        Localizations.localeOf(context).languageCode.toLowerCase().startsWith(
              'fr',
            );
    final AsyncValue<List<Exercise>> exercisesAsync =
        ref.watch(exercisesProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      body: SafeArea(
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
                  backgroundColor: AppColors.surface,
                  surfaceTintColor: Colors.transparent,
                  automaticallyImplyLeading: false,
                  titleSpacing: AppSpacing.md,
                  title: Text(
                    isFrench ? 'Exercices' : 'Exercises',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'AppFontMedium',
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(116),
                    child: Container(
                      color: AppColors.surface,
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.xs,
                        AppSpacing.md,
                        AppSpacing.sm,
                      ),
                      child: Column(
                        children: <Widget>[
                          TextField(
                            controller: _searchController,
                            textInputAction: TextInputAction.search,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: isFrench
                                  ? 'Rechercher un exercice (ex: plank / planche)'
                                  : 'Search an exercise (e.g. plank / planche)',
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: _searchController.text.trim().isEmpty
                                  ? null
                                  : IconButton(
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {});
                                      },
                                      icon: const Icon(Icons.close_rounded),
                                    ),
                              filled: true,
                              fillColor:
                                  AppColors.lightCyan.withValues(alpha: 0.65),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.xs,
                                horizontal: AppSpacing.sm,
                              ),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadii.xl),
                                borderSide: BorderSide(
                                  color: AppColors.primaryLight
                                      .withValues(alpha: 0.35),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadii.xl),
                                borderSide: BorderSide(
                                  color: AppColors.primaryLight
                                      .withValues(alpha: 0.35),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadii.xl),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.4,
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
                                Padding(
                                  padding: const EdgeInsets.only(
                                    right: AppSpacing.xs,
                                  ),
                                  child: ChoiceChip(
                                    label: Text(
                                      isFrench ? 'Tout' : 'All muscles',
                                    ),
                                    selected: _selectedMuscleGroup == null,
                                    onSelected: (_) {
                                      setState(() {
                                        _selectedMuscleGroup = null;
                                      });
                                    },
                                  ),
                                ),
                                ...MuscleGroup.values.map(
                                  (MuscleGroup muscle) => Padding(
                                    padding: const EdgeInsets.only(
                                      right: AppSpacing.xs,
                                    ),
                                    child: ChoiceChip(
                                      label: Text(
                                        _muscleLabel(
                                          muscle: muscle,
                                          isFrench: isFrench,
                                        ),
                                      ),
                                      selected: _selectedMuscleGroup == muscle,
                                      onSelected: (_) {
                                        setState(() {
                                          _selectedMuscleGroup =
                                              _selectedMuscleGroup == muscle
                                                  ? null
                                                  : muscle;
                                        });
                                      },
                                    ),
                                  ),
                                ),
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
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.xl,
                    ),
                    sliver: SliverList.builder(
                      itemCount: filtered.length,
                      itemBuilder: (BuildContext context, int index) {
                        final Exercise exercise = filtered[index];
                        final String title = exercise.getLocalizedName(context);
                        final String description =
                            exercise.getLocalizedDescription(context);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _ExerciseCard(
                            exercise: exercise,
                            title: title,
                            description: description,
                            muscleSummary: exercise.muscleGroups
                                .map(
                                  (MuscleGroup muscle) => _muscleLabel(
                                    muscle: muscle,
                                    isFrench: isFrench,
                                  ),
                                )
                                .join(', '),
                            difficultyLabel: _difficultyLabel(
                              exercise.difficulty,
                              isFrench,
                            ),
                            difficultyColor:
                                _difficultyColor(exercise.difficulty),
                            shaderVelocity: velocity,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => ExerciseDetailScreen(
                                    exercise: exercise,
                                  ),
                                ),
                              );
                            },
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
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 14,
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

      if (query.isEmpty) {
        return true;
      }

      return _matchesSearch(context: context, exercise: exercise, query: query);
    }).toList(growable: false);

    filtered.sort(
      (Exercise a, Exercise b) =>
          a.getLocalizedName(context).toLowerCase().compareTo(
                b.getLocalizedName(context).toLowerCase(),
              ),
    );

    return filtered;
  }

  bool _matchesSearch({
    required BuildContext context,
    required Exercise exercise,
    required String query,
  }) {
    final String normalizedQuery = _normalize(query);

    final String localizedName = exercise.getLocalizedName(context);
    final String localizedDescription =
        exercise.getLocalizedDescription(context);

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

    final Iterable<String> muscleTokens = exercise.muscleGroups.expand(
      (MuscleGroup muscle) => <String>{
        _muscleLabel(muscle: muscle, isFrench: false),
        _muscleLabel(muscle: muscle, isFrench: true),
        ..._muscleSearchAliases(muscle),
      },
    );

    final Iterable<String> equipment = exercise.equipment;

    final Iterable<String> searchableTokens = <String>{
      localizedName,
      localizedDescription,
      exercise.name,
      exercise.description,
      enName,
      frName,
      enDescription,
      frDescription,
      ...muscleTokens,
      ...equipment,
    };

    return searchableTokens
        .map(_normalize)
        .any((String token) => token.contains(normalizedQuery));
  }

  Iterable<String> _muscleSearchAliases(MuscleGroup muscle) {
    switch (muscle) {
      case MuscleGroup.chest:
        return const <String>{'pecs', 'pectoraux'};
      case MuscleGroup.shoulders:
        return const <String>{'delts', 'epaules'};
      case MuscleGroup.triceps:
        return const <String>{'triceps'};
      case MuscleGroup.biceps:
        return const <String>{'biceps'};
      case MuscleGroup.back:
        return const <String>{'dorsaux', 'dos'};
      case MuscleGroup.forearms:
        return const <String>{'avant bras', 'forearm'};
      case MuscleGroup.quads:
        return const <String>{'quadriceps', 'cuisses'};
      case MuscleGroup.hamstrings:
        return const <String>{'ischio', 'hamstrings'};
      case MuscleGroup.calves:
        return const <String>{'mollets', 'calves'};
      case MuscleGroup.glutes:
        return const <String>{'fessiers', 'glutes'};
      case MuscleGroup.abs:
        return const <String>{'abdos', 'abdominals'};
      case MuscleGroup.obliques:
        return const <String>{'obliques'};
      case MuscleGroup.lowerBack:
        return const <String>{'lombaires', 'lower back'};
      case MuscleGroup.cardio:
        return const <String>{'cardio'};
    }
  }

  String _normalize(String value) {
    String normalized = value.toLowerCase();

    const Map<String, String> replacement = <String, String>{
      '\u00E0': 'a',
      '\u00E1': 'a',
      '\u00E2': 'a',
      '\u00E4': 'a',
      '\u00E7': 'c',
      '\u00E8': 'e',
      '\u00E9': 'e',
      '\u00EA': 'e',
      '\u00EB': 'e',
      '\u00EE': 'i',
      '\u00EF': 'i',
      '\u00F4': 'o',
      '\u00F6': 'o',
      '\u00F9': 'u',
      '\u00FB': 'u',
      '\u00FC': 'u',
      '\u0153': 'oe',
      "'": ' ',
      '-': ' ',
      '/': ' ',
    };

    replacement.forEach((String from, String to) {
      normalized = normalized.replaceAll(from, to);
    });

    return normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
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

  String _muscleLabel({
    required MuscleGroup muscle,
    required bool isFrench,
  }) {
    switch (muscle) {
      case MuscleGroup.chest:
        return isFrench ? 'Pectoraux' : 'Chest';
      case MuscleGroup.shoulders:
        return isFrench ? 'Epaules' : 'Shoulders';
      case MuscleGroup.triceps:
        return 'Triceps';
      case MuscleGroup.biceps:
        return 'Biceps';
      case MuscleGroup.back:
        return isFrench ? 'Dos' : 'Back';
      case MuscleGroup.forearms:
        return isFrench ? 'Avant-bras' : 'Forearms';
      case MuscleGroup.quads:
        return isFrench ? 'Quadriceps' : 'Quads';
      case MuscleGroup.hamstrings:
        return isFrench ? 'Ischio-jambiers' : 'Hamstrings';
      case MuscleGroup.calves:
        return isFrench ? 'Mollets' : 'Calves';
      case MuscleGroup.glutes:
        return isFrench ? 'Fessiers' : 'Glutes';
      case MuscleGroup.abs:
        return isFrench ? 'Abdos' : 'Abs';
      case MuscleGroup.obliques:
        return 'Obliques';
      case MuscleGroup.lowerBack:
        return isFrench ? 'Bas du dos' : 'Lower back';
      case MuscleGroup.cardio:
        return 'Cardio';
    }
  }

  String _difficultyLabel(DifficultyLevel difficulty, bool isFrench) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return isFrench ? 'Debutant' : 'Beginner';
      case DifficultyLevel.intermediate:
        return isFrench ? 'Intermediaire' : 'Intermediate';
      case DifficultyLevel.advanced:
        return isFrench ? 'Avance' : 'Advanced';
    }
  }

  Color _difficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return AppColors.success;
      case DifficultyLevel.intermediate:
        return AppColors.warning;
      case DifficultyLevel.advanced:
        return AppColors.error;
    }
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final String title;
  final String description;
  final String muscleSummary;
  final String difficultyLabel;
  final Color difficultyColor;
  final Offset shaderVelocity;
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.exercise,
    required this.title,
    required this.description,
    required this.muscleSummary,
    required this.difficultyLabel,
    required this.difficultyColor,
    required this.shaderVelocity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.xl),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Color(0xFFEFF6FF),
                Color(0xFFF7FBFF),
              ],
            ),
            border: Border.all(
              color: AppColors.primaryLight.withValues(alpha: 0.35),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.primaryLight.withValues(alpha: 0.15),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  child: SizedBox(
                    width: 118,
                    height: 118,
                    child: Hero(
                      tag: 'exercise-image-${exercise.id}',
                      child: _ExerciseWaveFilter(
                        velocity: shaderVelocity,
                        child: _ExerciseImage(
                          imageUrl: exercise.imageTutorialUrl,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'AppFontMedium',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: difficultyColor,
                              borderRadius: BorderRadius.circular(AppRadii.lg),
                            ),
                            child: Text(
                              difficultyLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        muscleSummary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xxs),
                const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.xs),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExerciseWaveFilter extends StatefulWidget {
  final Widget child;
  final Offset velocity;

  const _ExerciseWaveFilter({
    required this.child,
    required this.velocity,
  });

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
        if (!snap.hasData) {
          return widget.child;
        }

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

  const _ExerciseImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final String trimmed = imageUrl.trim();

    if (trimmed.isEmpty) {
      return const _MissingExerciseImage();
    }

    if (trimmed.startsWith('assets/')) {
      return Image.asset(
        trimmed,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _MissingExerciseImage(),
      );
    }

    return Image.network(
      trimmed,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const _MissingExerciseImage(),
    );
  }
}

class _MissingExerciseImage extends StatelessWidget {
  const _MissingExerciseImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryAbyss,
      alignment: Alignment.center,
      child: const Icon(
        Icons.fitness_center_rounded,
        color: AppColors.background,
        size: 34,
      ),
    );
  }
}
