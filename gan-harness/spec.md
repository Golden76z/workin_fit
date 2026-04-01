# Design Brief: Workout Execution Screen

## Goal
Improve `lib/features/workout/presentation/screens/workout_execution_screen.dart` for visual consistency and theme compliance.

## App Theme
- **Background**: `AppColors.background` = `neutral0` (#111111)
- **Surface**: `AppColors.surface` = `neutral100` (#1C1C1C)
- **Surface variant**: `AppColors.surfaceVariant` = `neutral200` (#242424)
- **Primary brand**: `AppColors.primary` = `brand200` (#AF99FF) — purple
- **Text primary**: `AppColors.textPrimary` = `neutral600` (#F0F0F0)
- **Text secondary**: `AppColors.textSecondary` = `neutral500` (#AAAAAA)
- Semantic: `success` (#4CAF50), `warning` (#FF9800), `error` (#F44336)
- Opacity system: `AppOpacity.*` constants (never raw alpha literals)

## Current Problems

### 1. Hardcoded `Colors.white` (CRITICAL)
Must replace with `AppColors.textPrimary` or `AppColors.background` depending on context:
- `foregroundColor: Colors.white` in 4 `FilledButton.styleFrom(...)` calls
- `Colors.white.withValues(alpha: AppOpacity.dim)` in achievement banner chip

### 2. Raw opacity literals (HIGH)
Replace with `AppOpacity.*` constants:
- `alpha: 0.74` → `AppOpacity.prominent`
- `alpha: 0.48` → `AppOpacity.firm` (closest to 0.45–0.50)
- `alpha: 0.16` → `AppOpacity.muted` (closest)
- `alpha: 0.34` → `AppOpacity.moderate` (closest)
- `alpha: 0.32` → `AppOpacity.mild` (closest)

### 3. Off-theme surface colors (HIGH)
- `AppColors.accentLight` (`#FFCC80` amber) as current exercise card background → replace with `AppColors.surface`
- `AppColors.darkAccentLight` (`#FFCC80` amber) in glass panel and next preview → replace with `AppColors.surface`
- `AppColors.darkPrimaryDarker` used for text in next preview → replace with `AppColors.textPrimary`

## Constraints
- **Do NOT** change any business logic, state management, or timer behavior
- **Do NOT** add new dependencies
- **Do NOT** change layout structure or widget hierarchy beyond color/style
- All changes must be in `workout_execution_screen.dart` only
- Colors MUST come from `AppColors.*` and opacity from `AppOpacity.*`
- Functionality must remain identical after changes
