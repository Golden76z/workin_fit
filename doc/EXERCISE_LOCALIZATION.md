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
- `lib/l10n/app_fr.arb` (French - translated for current exercise set)

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

**Note**: The extension uses a generated helper map (`ExerciseLocalizationHelper`) and is safe for production use.

### Option 3: Generated Helper Class

Use `ExerciseLocalizationHelper` for key-based lookup:

```dart
ExerciseLocalizationHelper.getName(localizations, exerciseId);
ExerciseLocalizationHelper.getDescription(localizations, exerciseId);
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
4. **Add/adjust French translations** in `lib/l10n/app_fr.arb` if needed

## Current Status

- ✅ 100 exercises with localization keys
- ✅ English ARB entries generated (300 entries)
- ✅ French exercise names/descriptions/tips available for current 100-exercise set
- ✅ Runtime helper generated for key-based lookup with English fallback

## Next Steps

1. Keep translating any newly added exercise entries
2. Test localization in the app
3. Continue replacing direct text usage with localized exercise helpers in new UI screens
