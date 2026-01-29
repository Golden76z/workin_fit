# Exercise Localization Guide

## Overview

Exercises are now localized using ARB files. Each exercise has localization keys that reference entries in `app_en.arb` and `app_fr.arb`.

## Structure

### JSON Files
Exercises in `data/exercises/*.json` contain:
- **Localization keys**: `nameKey`, `descriptionKey`, `beginnerTipsKey`
- **Fallback text**: `name`, `description`, `beginnerTips` (English)

### ARB Files
Localization entries are in:
- `lib/l10n/app_en.arb` (English - complete)
- `lib/l10n/app_fr.arb` (French - needs translation)

Each exercise has 3 ARB entries:
- `exercise_{id}_name`
- `exercise_{id}_description`
- `exercise_{id}_beginner_tips` (if tips exist)

## Usage

### Option 1: Direct ARB Access (Recommended)

Access the localized strings directly using the generated getters:

```dart
import 'package:workin_fit/l10n/app_localizations.dart';

// In your widget:
final localizations = AppLocalizations.of(context)!;
Text(localizations.exercise_push_001_name)
Text(localizations.exercise_push_001_description)
```

### Option 2: Using Extension (Fallback)

The `ExerciseLocalization` extension provides helper methods that fall back to stored text:

```dart
import 'package:workin_fit/models/exercise_localization.dart';

Text(exercise.getLocalizedName(context))
Text(exercise.getLocalizedDescription(context))
```

**Note**: The extension uses reflection which may not work in all cases. Option 1 is more reliable.

### Option 3: Helper Function

Create a helper function that maps exercise IDs to getters:

```dart
String getExerciseName(BuildContext context, String exerciseId) {
  final localizations = AppLocalizations.of(context)!;
  final key = 'exercise_${exerciseId}_name';
  // Use a switch statement or Map to map to the getter
  // For now, access directly:
  return (localizations as dynamic)[Symbol(key)] ?? '';
}
```

## Adding New Exercises

1. **Add exercise to JSON file** (e.g., `data/exercises/beginner.json`)
2. **Run localization generator**:
   ```bash
   python3 data/exercises/generate_localization_keys.py
   ```
3. **Regenerate ARB code**:
   ```bash
   flutter gen-l10n
   ```
4. **Add French translations** to `lib/l10n/app_fr.arb`

## Current Status

- ✅ 100 exercises with localization keys
- ✅ English ARB entries generated (300 entries)
- ⚠️  French ARB entries need translation (currently same as English)

## Next Steps

1. Translate French ARB entries
2. Test localization in the app
3. Update UI to use localized strings
