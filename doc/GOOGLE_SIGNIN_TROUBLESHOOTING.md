# Google Sign-In Troubleshooting

If you're seeing "Google Sign-In failed. Please try again.", follow these steps:

## 🔍 Step 1: Check Console Logs

The app now logs detailed error information. When the error occurs, check your console/logs for:
- `Google Sign-In Error: ...`
- `FirebaseAuthException: ...`
- `Original exception: ...`

This will tell you the exact cause.

## 🐛 Common Issues & Solutions

### Issue 1: Android - "sign_in_failed" or "PlatformException"

**Symptoms:**
- Error message mentions SHA-1 or configuration
- Works on iOS but not Android

**Solution:**
1. Get your SHA-1 fingerprint:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
2. Copy the SHA-1 value (look for "SHA1:")
3. Go to Firebase Console → Project Settings → Your Android app
4. Click "Add fingerprint" and paste the SHA-1
5. Download the updated `google-services.json` and replace `android/app/google-services.json`
6. Clean and rebuild:
   ```bash
   flutter clean
   flutter pub get
   cd android && ./gradlew clean && cd ..
   flutter run
   ```

### Issue 2: "operation-not-allowed" or "DEVELOPER_ERROR"

**Symptoms:**
- Error mentions "sign-in method is not enabled"

**Solution:**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Authentication** → **Sign-in method**
4. Click on **Google** provider
5. Make sure it's **Enabled** (toggle should be ON)
6. Enter a support email if prompted
7. Click **Save**

### Issue 3: iOS - "Invalid client ID"

**Symptoms:**
- Works on Android but not iOS
- Error mentions client ID or URL scheme

**Solution:**
1. Make sure `GoogleService-Info.plist` exists in `ios/Runner/`
2. Open `ios/Runner/GoogleService-Info.plist`
3. Find the `REVERSED_CLIENT_ID` value
4. Open `ios/Runner/Info.plist`
5. Add the reversed client ID to `CFBundleURLSchemes` (see main setup guide)
6. Clean and rebuild:
   ```bash
   flutter clean
   flutter pub get
   cd ios && pod install && cd ..
   flutter run
   ```

### Issue 4: Network Errors

**Symptoms:**
- Error mentions network or connection

**Solution:**
1. Check your internet connection
2. If using Android emulator, make sure it has internet access
3. Try on a real device
4. Check if Google Play Services is available (Android)

### Issue 5: Android Emulator Without Google Play Services

**Symptoms:**
- Works on real device but not emulator
- Error on emulator only

**Solution:**
1. Use an emulator with Google Play Services (Google APIs system image)
2. Or test on a real Android device
3. Google Sign-In requires Google Play Services

## 🧪 Quick Debug Checklist

Run through this checklist:

- [ ] **Google provider enabled in Firebase Console?**
  - Firebase Console → Authentication → Sign-in method → Google → Enabled

- [ ] **SHA-1 fingerprint added?** (Android only)
  - Firebase Console → Project Settings → Android app → SHA-1 fingerprints
  - Both debug and release SHA-1 should be added

- [ ] **google-services.json up to date?** (Android)
  - File should be in `android/app/google-services.json`
  - Should be downloaded AFTER adding SHA-1

- [ ] **GoogleService-Info.plist exists?** (iOS)
  - File should be in `ios/Runner/GoogleService-Info.plist`

- [ ] **URL scheme configured?** (iOS)
  - `Info.plist` should have reversed client ID in `CFBundleURLSchemes`

- [ ] **Testing on real device or emulator with Google Play Services?** (Android)
  - Google Sign-In requires Google Play Services

- [ ] **OAuth consent screen configured?** (Optional for testing, required for production)
  - Can skip for initial testing

## 🔧 Debug Mode

The app now logs detailed errors. To see them:

1. Run the app with verbose logging:
   ```bash
   flutter run -v
   ```

2. Or check your IDE's debug console when the error occurs

3. Look for lines starting with:
   - `Google Sign-In Error:`
   - `FirebaseAuthException:`
   - `Original exception:`

## 📱 Platform-Specific Notes

### Android
- **Must have SHA-1 fingerprint** in Firebase Console
- Requires Google Play Services (use emulator with Google APIs or real device)
- `google-services.json` must be up to date

### iOS
- **Must have URL scheme** (reversed client ID) in Info.plist
- `GoogleService-Info.plist` must be present
- Works on both simulator and real device

## 🆘 Still Not Working?

If you've checked everything above:

1. **Check the console logs** - The actual error will be printed there
2. **Verify Firebase project** - Make sure you're using the correct Firebase project
3. **Check package name/bundle ID** - Must match Firebase configuration
4. **Try a clean build**:
   ```bash
   flutter clean
   flutter pub get
   # Android
   cd android && ./gradlew clean && cd ..
   # iOS
   cd ios && pod install && cd ..
   flutter run
   ```

5. **Check Firebase Console logs**:
   - Firebase Console → Authentication → Users
   - See if any sign-in attempts are logged

## 💡 Pro Tip

The most common issue is **missing SHA-1 fingerprint on Android**. Always check that first!
