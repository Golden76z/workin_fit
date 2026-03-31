import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_chrome.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/app_opacity.dart';
import 'package:workin_fit/core/theme/colors.dart';
import 'package:workin_fit/features/workout/presentation/utils/exercise_ui_helpers.dart';
import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/exercise_localization.dart';
import 'package:workin_fit/models/exercise_localization_helper.dart';
import 'package:workin_fit/providers/workout_providers.dart';
import 'package:workin_fit/l10n/app_localizations_en.dart';
import 'package:workin_fit/l10n/app_localizations_fr.dart';

/// Full-screen exercise picker used by the session builder.
/// Pops with the chosen [Exercise], or null if the user cancelled.
class ExercisePickerScreen extends ConsumerStatefulWidget {
  /// IDs of exercises already added to the session (shown with a checkmark).
  final Set<String> alreadyAddedIds;

  const ExercisePickerScreen({
    required this.alreadyAddedIds,
    super.key,
  });

  static Route<Exercise> route({required Set<String> alreadyAddedIds}) {
    return MaterialPageRoute<Exercise>(
      fullscreenDialog: true,
      builder: (_) => ExercisePickerScreen(alreadyAddedIds: alreadyAddedIds),
    );
  }

  @override
  ConsumerState<ExercisePickerScreen> createState() =>
      _ExercisePickerScreenState();
}

class _ExercisePickerScreenState extends ConsumerState<ExercisePickerScreen> {
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
    final bool isFrench = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('fr');
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
                  _filtered(context: context, exercises: exercises);

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    elevation: 0,
                    toolbarHeight: 36,
                    flexibleSpace: Container(color: AppColors.navBarSurface),
                    leading: IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    title: Text(
                      isFrench ? 'Choisir un exercice' : 'Choose an exercise',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'AppFontMedium',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(116),
                      child: Container(
                        color: Colors.transparent,
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, AppSpacing.sm),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppLayout.pageMargin,
                              ),
                              child: TextField(
                                controller: _searchController,
                                textInputAction: TextInputAction.search,
                                onChanged: (_) => setState(() {}),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: isFrench
                                      ? 'Rechercher...'
                                      : 'Search exercise...',
                                  hintStyle: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.search_rounded,
                                    color: AppColors.textSecondary,
                                  ),
                                  suffixIcon: _searchController.text.trim().isEmpty
                                      ? null
                                      : IconButton(
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() {});
                                          },
                                          icon: const Icon(
                                            Icons.close_rounded,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                  filled: true,
                                  fillColor: AppColors.neutral300,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 5,
                                    horizontal: AppSpacing.sm,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppRadii.lg),
                                    borderSide: const BorderSide(
                                      color: AppColors.neutral400,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppRadii.lg),
                                    borderSide: BorderSide(
                                      color: AppColors.primaryPastel.withValues(
                                        alpha: AppOpacity.half,
                                      ),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppRadii.lg),
                                    borderSide: const BorderSide(
                                      color: AppColors.primary,
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
                                children: [
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
                                      backgroundColor: AppColors.neutral300,
                                      selectedColor: AppColors.primary,
                                      showCheckmark: false,
                                      side: BorderSide(
                                        color: _selectedMuscleGroup == null
                                            ? AppColors.primary
                                            : AppColors.primaryPastel.withValues(
                                                alpha: AppOpacity.half,
                                              ),
                                      ),
                                      labelStyle: TextStyle(
                                        color: _selectedMuscleGroup == null
                                            ? AppColors.background
                                            : AppColors.textPrimary,
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
                                        backgroundColor: AppColors.neutral300,
                                        selectedColor: AppColors.primary,
                                        showCheckmark: false,
                                        side: BorderSide(
                                          color: _selectedMuscleGroup == muscle
                                              ? AppColors.primary
                                              : AppColors.primaryPastel.withValues(
                                                  alpha: AppOpacity.half,
                                                ),
                                        ),
                                        labelStyle: TextStyle(
                                          color: _selectedMuscleGroup == muscle
                                              ? AppColors.background
                                              : AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        label: Text(
                                          muscleGroupLabel(muscle, isFrench),
                                        ),
                                        selected: _selectedMuscleGroup == muscle,
                                        onSelected: (_) => setState(
                                          () => _selectedMuscleGroup =
                                              _selectedMuscleGroup == muscle
                                                  ? null
                                                  : muscle,
                                        ),
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
                            textAlign: TextAlign.center,
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
                          final exercise = filtered[index];
                          final bool alreadyAdded =
                              widget.alreadyAddedIds.contains(exercise.id);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
                            child: _PickerExerciseCard(
                              exercise: exercise,
                              title: exercise.getLocalizedName(context),
                              muscleSummary: exercise.muscleGroups
                                  .map((m) => muscleGroupLabel(m, isFrench))
                                  .join(', '),
                              difficulty: exercise.difficulty,
                              isFrench: isFrench,
                              alreadyAdded: alreadyAdded,
                              onTap: () => Navigator.of(context).pop(exercise),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  'Failed to load exercises: $e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Exercise> _filtered({
    required BuildContext context,
    required List<Exercise> exercises,
  }) {
    final String query = _searchController.text.trim();

    final filtered = exercises.where((exercise) {
      if (_selectedMuscleGroup != null &&
          !exercise.muscleGroups.contains(_selectedMuscleGroup)) {
        return false;
      }
      if (query.isEmpty) return true;
      return _matchesSearch(context: context, exercise: exercise, query: query);
    }).toList(growable: false);

    filtered.sort((a, b) {
      final dc = difficultyRank(a.difficulty).compareTo(difficultyRank(b.difficulty));
      if (dc != 0) return dc;
      return a.getLocalizedName(context).toLowerCase()
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

    final Iterable<String> tokens = {
      exercise.getLocalizedName(context),
      exercise.getLocalizedDescription(context),
      exercise.name,
      exercise.description,
      ExerciseLocalizationHelper.getName(_en, exercise.id) ?? exercise.name,
      ExerciseLocalizationHelper.getName(_fr, exercise.id) ?? exercise.name,
      ...exercise.muscleGroups.expand(
        (m) => [
          muscleGroupLabel(m, false),
          muscleGroupLabel(m, true),
          ...muscleGroupAliases(m),
        ],
      ),
      ...exercise.equipment,
    };

    return tokens.map(exerciseNormalize).any((t) => t.contains(normalizedQuery));
  }

  String _emptyStateMessage({
    required bool isFrench,
    required bool hasActiveFilters,
    required bool hasAnyExercise,
  }) {
    if (!hasAnyExercise) {
      return isFrench
          ? 'Aucun exercice disponible pour le moment.'
          : 'No exercises available right now.';
    }
    if (hasActiveFilters) {
      return isFrench
          ? 'Aucun exercice ne correspond a ces filtres.'
          : 'No exercise matches those filters.';
    }
    return isFrench ? 'Aucun exercice trouve.' : 'No exercise found.';
  }
}

// ---------------------------------------------------------------------------
// Card widget
// ---------------------------------------------------------------------------

class _PickerExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final String title;
  final String muscleSummary;
  final DifficultyLevel difficulty;
  final bool isFrench;
  final bool alreadyAdded;
  final VoidCallback onTap;

  const _PickerExerciseCard({
    required this.exercise,
    required this.title,
    required this.muscleSummary,
    required this.difficulty,
    required this.isFrench,
    required this.alreadyAdded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardBackground =
        alreadyAdded ? AppColors.surfaceVariant : AppColors.surface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: cardBackground,
            border: Border.all(
              color: alreadyAdded
                  ? AppColors.success.withValues(alpha: AppOpacity.medium)
                  : AppColors.neutral300,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    border: Border.all(
                      color: AppColors.primaryPastel.withValues(
                        alpha: AppOpacity.soft,
                      ),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    child: SizedBox(
                      width: 72,
                      height: 72,
                      child: _ExerciseThumb(url: exercise.imageTutorialUrl),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
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
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        muscleSummary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      ExerciseDifficultyBadge(
                        difficulty: difficulty,
                        isFrench: isFrench,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 1,
                  height: 48,
                  color: AppColors.primaryPastel.withValues(
                    alpha: AppOpacity.soft,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: alreadyAdded
                        ? AppColors.success.withValues(alpha: AppOpacity.muted)
                        : AppColors.primary.withValues(alpha: AppOpacity.faint),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: alreadyAdded
                          ? AppColors.success.withValues(alpha: AppOpacity.half)
                          : AppColors.primary.withValues(alpha: AppOpacity.mild),
                    ),
                  ),
                  child: Icon(
                    alreadyAdded ? Icons.check_rounded : Icons.add_rounded,
                    color: alreadyAdded ? AppColors.success : AppColors.primary,
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

class _ExerciseThumb extends StatelessWidget {
  final String url;
  const _ExerciseThumb({required this.url});

  @override
  Widget build(BuildContext context) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return _placeholder();
    if (trimmed.startsWith('assets/')) {
      return Image.asset(
        trimmed,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return Image.network(
      trimmed,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              AppColors.surfaceVariant,
              AppColors.background,
            ],
          ),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.fitness_center_rounded,
          color: AppColors.primary,
          size: 24,
        ),
      );
}
