# App logo setup (Workin Fit)

This app uses **flutter_launcher_icons** for the app icon and **flutter_native_splash** for the splash screen. Both expect image files under `assets/`.

## 1. App icon (home screen icon)

- **Source image:** `assets/icons/app_icon.png`
- **Recommended size:** 1024×1024 px (PNG, no transparency for best results on Android adaptive icon).
- **Usage:** Launcher icon on Android, iOS, and other platforms.

**Steps:**

1. Create the folder if needed: `assets/icons/`
2. Add your logo as `assets/icons/app_icon.png` (1024×1024 recommended).
3. Generate platform icons (from the project root). Use Flutter’s runner so the SDK is available:
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```
   Or run: `make icons`

## 2. Splash screen logo

- **Source image:** `assets/images/splash_logo.png`
- **Recommended:** Same or similar to app icon; often 288×288 px or larger, centered on splash.
- **Usage:** Shown in the middle of the native splash screen.

**Steps:**

1. Create the folder if needed: `assets/images/`
2. Add your logo as `assets/images/splash_logo.png`.
3. Regenerate splash screens:
   ```bash
   flutter pub get
   flutter pub run flutter_native_splash:create
   ```
   Or run: `make splash`

## 3. In-app logo (e.g. login, header)

- Use the same file via Flutter’s asset system, e.g. `Image.asset('assets/images/splash_logo.png')` or from `assets/icons/app_icon.png`.
- Ensure the path is listed under `flutter.assets` in `pubspec.yaml` (e.g. `assets/images/` and `assets/icons/`).

## 4. Asset paths in pubspec.yaml

The following are already configured in `pubspec.yaml` (uncommented when you add logo files):

- `assets/icons/` — app icon source
- `assets/images/` — splash logo and other images

After adding your PNG files, run (from the project root):

```bash
flutter pub get
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create
```

Or use the Makefile: `make icons` then `make splash`. Then rebuild and run the app to see the new icon and splash screen.

---

## App name on home screen

The label under the app icon (e.g. "Workin Fit") is set per platform:

- **Android:** `android/app/src/main/AndroidManifest.xml` → `android:label` on the `<application>` tag.
- **iOS:** `ios/Runner/Info.plist` → `CFBundleDisplayName` (user-visible name). `CFBundleName` is the short/internal name.

Change those strings and rebuild to update the name on the home screen.

**Note:** Use `flutter pub run`, not `dart run`, so the Flutter SDK is available (otherwise you may see “flutter_test from sdk which doesn’t exist”).
