# Evaluation Rubric: Workout Execution Screen Design

## Scoring (0–10 per category, weighted)

### Design Quality (weight: 0.35)
Does the screen feel cohesive and polished within the app's dark purple theme?
- 10: All surfaces use neutral/brand palette correctly; no amber/orange bleed; every color reads as intentional
- 7: Minor color inconsistencies remain but overall feel improved
- 4: Several off-theme colors still present
- 0: Colors unchanged or made worse

### Theme Compliance (weight: 0.30)
Are ALL `Colors.white`, `Colors.black`, raw hex literals, and raw alpha floats eliminated?
- 10: Zero hardcoded colors; all alpha values use `AppOpacity.*`
- 7: 1–2 minor raw values remain
- 4: Half of violations fixed
- 0: No change

### Craft (weight: 0.25)
Is the code clean? No regressions, no duplicate const declarations, no unused imports?
- 10: Clean diff, `dart analyze` passes with zero new warnings
- 7: Minor lint warnings
- 4: Functional but messy
- 0: Broken

### Functionality (weight: 0.10)
Does the app still compile and the timer/phase logic remain intact?
- 10: Compiles, tests pass
- 0: Broken

## Pass Threshold: 7.5

## Key Questions
1. Does `_buildCurrentExerciseCard` now use a neutral surface instead of amber `accentLight`?
2. Does `_buildNextExercisePreview` use neutral instead of amber `darkAccentLight`?
3. Does `_buildLowerGlassSection` use neutral tint instead of amber?
4. Are all `FilledButton.styleFrom` calls using `AppColors.textPrimary` or `AppColors.background` instead of `Colors.white`?
5. Are raw alpha floats replaced with `AppOpacity.*` constants?
