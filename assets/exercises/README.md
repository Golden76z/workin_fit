# Exercise media assets

The app reads movement media via `imageTutorialUrl` using
`assets/exercises/movements/{exercise_id}/tutorial.*` (see `ExerciseAssets.movementPath`).

## Current tutorial images: generated vector illustrations

Every `tutorial.png` (1080 × 608) is **generated** from a pose script in
`tools/exercise_illustrations/` — a gray silhouette in the muscle-atlas style with the
worked muscle zones highlighted in brand purple (`#5E2BFF`), no embedded text.

To tweak or regenerate an image:

```bash
cd tools/exercise_illustrations
# edit poses/<exercise_id>.py (see POSE_GUIDE.md for the API)
python3 poses/<exercise_id>.py           # renders out/<exercise_id>.png (needs rsvg-convert)
cp out/<id>.png ../../assets/exercises/movements/<id>/tutorial.png
```

`python3 build_all.py` re-renders all 141 images.

## Display dimensions (UI)

| Area | On-screen size (logical px) | Background color |
|------|------------------------------|------------------|
| **Movement** (how-to GIF) | Full card width × **200** height | `AppColors.mediaCanvas` (`#111111`) |
| **Muscle atlas** (front + back) | Full card width × **320** height (each half ~50% width) | `AppColors.mediaCanvas` |

Horizontal inset on the detail screen: **16 px** per side (`AppSpacing.md`), so on a **390 px** wide phone the media width is about **358 px**.

Constants live in `lib/core/theme/app_dimensions.dart` (`AppSizes`).

## Recommended export size (source files)

Create GIFs at **1080 × 608 px** (16∶9). That scales cleanly to the 200 px-tall slot with `BoxFit.cover`.

- Format: **GIF** (or WebP/APNG if you later add a dedicated player)
- Filename per exercise: **`tutorial.gif`**
- Background in the file: **black** (`#000000` or `#111111`) to match `AppColors.mediaCanvas`

## Folder layout

```
assets/exercises/movements/
  push_001/
    tutorial.gif
  push_002/
    tutorial.gif
  …
```

One folder per exercise `id` from `data/exercises/all.json`.

After adding files, set in Firestore or JSON:

```json
"imageTutorialUrl": "assets/exercises/movements/push_001/tutorial.gif"
```

Then run `flutter pub get` (assets are declared in `pubspec.yaml`).
