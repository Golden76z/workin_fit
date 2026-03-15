import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/core/theme/app_chrome.dart';
import 'package:workin_fit/core/theme/app_dimensions.dart';
import 'package:workin_fit/core/theme/colors.dart';
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

    final Color searchFieldColor = Colors.white.withValues(alpha: 0.15);
    final Color chipBg = Colors.white.withValues(alpha: 0.15);
    final Color chipSelected = Colors.white.withValues(alpha: 0.92);

    return AppSystemOverlayRegion(
      style: AppChrome.homeOverlay,
      child: Scaffold(
        backgroundColor: AppColors.surfaceVariant,
        body: SafeArea(
          top: false,
          bottom: false,
          child: exercisesAsync.when(
            data: (List<Exercise> exercises) {
              final List<Exercise> filtered = _filtered(
                context: context,
                exercises: exercises,
              );

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    elevation: 0,
                    toolbarHeight: 36,
                    flexibleSpace: Container(
                      color: AppColors.navBarSurface,
                    ),
                    leading: IconButton(
                      icon:
                          const Icon(Icons.close_rounded, color: Colors.white),
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
                        padding:
                            const EdgeInsets.fromLTRB(0, 0, 0, AppSpacing.sm),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,),
                              child: TextField(
                                controller: _searchController,
                                textInputAction: TextInputAction.search,
                                onChanged: (_) => setState(() {}),
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: isFrench
                                      ? 'Rechercher...'
                                      : 'Search exercise...',
                                  hintStyle: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.55),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search_rounded,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                  suffixIcon:
                                      _searchController.text.trim().isEmpty
                                          ? null
                                          : IconButton(
                                              onPressed: () {
                                                _searchController.clear();
                                                setState(() {});
                                              },
                                              icon: Icon(
                                                Icons.close_rounded,
                                                color: Colors.white
                                                    .withValues(alpha: 0.8),
                                              ),
                                            ),
                                  filled: true,
                                  fillColor: searchFieldColor,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 5,
                                    horizontal: AppSpacing.sm,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadii.lg),
                                    borderSide: BorderSide(
                                      color:
                                          Colors.white.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadii.lg),
                                    borderSide: BorderSide(
                                      color:
                                          Colors.white.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadii.lg),
                                    borderSide: BorderSide(
                                      color:
                                          Colors.white.withValues(alpha: 0.75),
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
                                  const SizedBox(width: AppSpacing.md),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: AppSpacing.xs,),
                                    child: ChoiceChip(
                                      label: Text(
                                          isFrench ? 'Tout' : 'All muscles',),
                                      selected: _selectedMuscleGroup == null,
                                      backgroundColor: chipBg,
                                      selectedColor: chipSelected,
                                      side: BorderSide(
                                        color:
                                            Colors.white.withValues(alpha: 0.3),
                                      ),
                                      labelStyle: const TextStyle(
                                        color: AppColors.primaryAbyss,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      onSelected: (_) => setState(
                                          () => _selectedMuscleGroup = null,),
                                    ),
                                  ),
                                  ...MuscleGroup.values.map(
                                    (MuscleGroup muscle) => Padding(
                                      padding: const EdgeInsets.only(
                                          right: AppSpacing.xs,),
                                      child: ChoiceChip(
                                        backgroundColor: chipBg,
                                        selectedColor: chipSelected,
                                        side: BorderSide(
                                          color: AppColors.background
                                              .withValues(alpha: 0.28),
                                        ),
                                        labelStyle: const TextStyle(
                                          color: AppColors.primaryAbyss,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        label: Text(
                                            _muscleLabel(muscle, isFrench),),
                                        selected:
                                            _selectedMuscleGroup == muscle,
                                        onSelected: (_) => setState(
                                          () => _selectedMuscleGroup =
                                              _selectedMuscleGroup == muscle
                                                  ? null
                                                  : muscle,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
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
                        child: Text(
                          isFrench
                              ? 'Aucun exercice trouvé.'
                              : 'No exercise found.',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xs, AppSpacing.md, AppSpacing.xs, 104,),
                      sliver: SliverList.builder(
                        itemCount: filtered.length,
                        itemBuilder: (BuildContext context, int index) {
                          final exercise = filtered[index];
                          final bool alreadyAdded =
                              widget.alreadyAddedIds.contains(exercise.id);

                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.xs),
                            child: _PickerExerciseCard(
                              exercise: exercise,
                              title: exercise.getLocalizedName(context),
                              muscleSummary: exercise.muscleGroups
                                  .map((m) => _muscleLabel(m, isFrench))
                                  .join(', '),
                              difficultyColor:
                                  _difficultyColor(exercise.difficulty),
                              difficultyLabel: _difficultyLabel(
                                  exercise.difficulty, isFrench,),
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
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text(
                'Failed to load exercises: $e',
                style: const TextStyle(color: AppColors.error),
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
      final dc = _difficultyRank(a.difficulty)
          .compareTo(_difficultyRank(b.difficulty));
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
    final String normalizedQuery = _normalize(query);

    final Iterable<String> tokens = {
      exercise.getLocalizedName(context),
      exercise.getLocalizedDescription(context),
      exercise.name,
      exercise.description,
      ExerciseLocalizationHelper.getName(_en, exercise.id) ?? exercise.name,
      ExerciseLocalizationHelper.getName(_fr, exercise.id) ?? exercise.name,
      ...exercise.muscleGroups.expand((m) => [
            _muscleLabel(m, false),
            _muscleLabel(m, true),
          ],),
      ...exercise.equipment,
    };

    return tokens.map(_normalize).any((t) => t.contains(normalizedQuery));
  }

  String _normalize(String v) {
    String s = v.toLowerCase();
    const Map<String, String> rep = {
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
    rep.forEach((from, to) => s = s.replaceAll(from, to));
    return s.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _muscleLabel(MuscleGroup muscle, bool isFrench) {
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

  String _difficultyLabel(DifficultyLevel d, bool isFrench) {
    switch (d) {
      case DifficultyLevel.beginner:
        return isFrench ? 'Débutant' : 'Beginner';
      case DifficultyLevel.intermediate:
        return isFrench ? 'Intermédiaire' : 'Intermediate';
      case DifficultyLevel.advanced:
        return isFrench ? 'Avancé' : 'Advanced';
    }
  }

  Color _difficultyColor(DifficultyLevel d) {
    switch (d) {
      case DifficultyLevel.beginner:
        return AppColors.success;
      case DifficultyLevel.intermediate:
        return AppColors.warning;
      case DifficultyLevel.advanced:
        return AppColors.error;
    }
  }

  int _difficultyRank(DifficultyLevel d) {
    switch (d) {
      case DifficultyLevel.beginner:
        return 0;
      case DifficultyLevel.intermediate:
        return 1;
      case DifficultyLevel.advanced:
        return 2;
    }
  }
}

// ---------------------------------------------------------------------------
// Card widget
// ---------------------------------------------------------------------------

class _PickerExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final String title;
  final String muscleSummary;
  final String difficultyLabel;
  final Color difficultyColor;
  final bool alreadyAdded;
  final VoidCallback onTap;

  const _PickerExerciseCard({
    required this.exercise,
    required this.title,
    required this.muscleSummary,
    required this.difficultyLabel,
    required this.difficultyColor,
    required this.alreadyAdded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.md),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFD7E5FF), Color(0xFFE4EEFF)],
            ),
            border: Border.all(
              color: AppColors.primaryLight.withValues(alpha: 0.45),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryLight.withValues(alpha: 0.2),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: _ExerciseThumb(url: exercise.imageTutorialUrl),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'AppFontMedium',
                        ),
                      ),
                      const SizedBox(height: 2),
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
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2,),
                        decoration: BoxDecoration(
                          color: difficultyColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: difficultyColor.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          difficultyLabel,
                          style: TextStyle(
                            color: difficultyColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                // Trailing icon
                if (alreadyAdded)
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.success, size: 24,)
                else
                  const Icon(Icons.add_circle_outline_rounded,
                      color: AppColors.primary, size: 24,),
                const SizedBox(width: AppSpacing.xs),
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
      return Image.asset(trimmed,
          fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder(),);
    }
    return Image.network(trimmed,
        fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder(),);
  }

  Widget _placeholder() => Container(
        color: AppColors.primaryAbyss,
        alignment: Alignment.center,
        child: const Icon(Icons.fitness_center_rounded,
            color: AppColors.background, size: 28,),
      );
}
