# Exercise Data Files

This directory contains exercise data organized by difficulty level for easy management and scalability.

## Structure

- `beginner.json` - Beginner-level exercises (44 exercises)
- `intermediate.json` - Intermediate-level exercises (46 exercises)
- `advanced.json` - Advanced-level exercises (10 exercises)
- `all.json` - Combined file with all exercises (100 exercises)

## Localization

Exercises use **localization keys** that reference ARB files for translations:

- Each exercise has:
  - `nameKey`: e.g., `"exercise_push_001_name"`
  - `descriptionKey`: e.g., `"exercise_push_001_description"`
  - `beginnerTipsKey`: e.g., `"exercise_push_001_beginner_tips"` (if tips exist)

- The actual text is stored in:
  - `lib/l10n/app_en.arb` (English)
  - `lib/l10n/app_fr.arb` (French - needs translation)

- The JSON files also contain the English text as fallback (`name`, `description`, `beginnerTips`)

## Using Localized Exercises in Code

```dart
import 'package:workin_fit/models/exercise_localization.dart';

// In your widget:
Text(exercise.getLocalizedName(context))
Text(exercise.getLocalizedDescription(context))
Text(exercise.getLocalizedBeginnerTips(context) ?? '')
```

The extension methods automatically:
1. Look up the localization key in ARB files
2. Fall back to stored English text if key not found
3. Handle null cases gracefully

## Adding New Exercises

1. **Add to appropriate difficulty file**: Open the relevant `{difficulty}.json` file and add your new exercise following the same structure.

2. **Generate localization keys**: Run:
   ```bash
   python3 data/exercises/generate_localization_keys.py
   ```
   This will:
   - Add localization keys to the exercise JSON
   - Generate ARB entries in `app_en.arb` and `app_fr.arb`
   - Update all difficulty files

3. **Translate to French**: Edit `lib/l10n/app_fr.arb` and add French translations for the new exercise keys.

4. **Regenerate ARB code**: Run:
   ```bash
   flutter gen-l10n
   ```

5. **Update all.json** (optional): Run `combine_exercises.py` to regenerate the combined file.

## Exercise Schema

Each exercise follows this structure:

```json
{
  "id": "unique_id",
  "name": "Exercise Name (English fallback)",
  "description": "Description (English fallback)",
  "nameKey": "exercise_unique_id_name",
  "descriptionKey": "exercise_unique_id_description",
  "beginnerTipsKey": "exercise_unique_id_beginner_tips",
  "imageMuscleUrl": "",
  "imageTutorialUrl": "",
  "muscleGroups": ["chest", "shoulders", "triceps"],
  "difficulty": "beginner|intermediate|advanced",
  "beginnerTips": "Optional tips (English fallback)",
  "equipment": [] // Empty for bodyweight, ["chair"] for minimal equipment
}
```

## Valid Muscle Groups

- `chest`, `shoulders`, `triceps`, `biceps`, `back`, `forearms`
- `quads`, `hamstrings`, `calves`, `glutes`
- `abs`, `obliques`, `lowerBack`
- `cardio`

## Uploading to Firestore

Use the `upload_exercises.dart` script to bulk upload exercises to Firestore.

## Scripts

- `generate_localization_keys.py` - Generate ARB entries and add keys to JSON files
- `combine_exercises.py` - Combine all difficulty files into `all.json`
- `upload_exercises.dart` - Upload exercises to Firestore
