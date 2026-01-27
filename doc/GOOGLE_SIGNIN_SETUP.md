# Google Sign-In Setup Guide

This guide will help you configure Google Sign-In for the Workin Fit app on both Android and iOS platforms.

## ✅ Already Completed

- [x] `google_sign_in` package added to `pubspec.yaml`
- [x] Google sign-in implementation in `AuthRepository`
- [x] Google sign-in button connected in login and register views
- [x] Account linking error handling
- [x] Firestore profile creation for Google users

## 📋 Setup Steps

### ✅ Essential Steps (Required for Google Sign-In to Work)

#### 1. Enable Google Provider in Firebase Console ⚠️ REQUIRED

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **workinfit**
3. Navigate to **Authentication** → **Sign-in method**
4. Click on **Google** provider
5. Enable the provider by toggling it ON
6. Enter your **Support email** (your email address)
7. Click **Save**

**This step is absolutely required** - without it, Google Sign-In won't work.

#### 2. Android: Add SHA-1 Fingerprint ⚠️ REQUIRED for Android

**For Debug Keystore:**
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**For Release Keystore:**
```bash
keytool -list -v -keystore /path/to/your/release.keystore -alias your-key-alias
```

Then add SHA-1 to Firebase:
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **workinfit**
3. Go to **Project Settings** (gear icon)
4. Scroll down to **Your apps** section
5. Click on your Android app
6. Click **Add fingerprint**
7. Paste your SHA-1 fingerprint
8. Click **Save**
9. Download updated `google-services.json` and replace `android/app/google-services.json`

**Important:** Add both debug and release SHA-1 fingerprints!

#### 3. iOS: Configure URL Scheme ⚠️ REQUIRED for iOS

If you have `GoogleService-Info.plist`, add the reversed client ID to `Info.plist`:

1. Open `ios/Runner/GoogleService-Info.plist`
2. Find the `REVERSED_CLIENT_ID` value
3. Open `ios/Runner/Info.plist`
4. Add it to `CFBundleURLSchemes` array (see full guide below for details)

**Note:** If you don't have `GoogleService-Info.plist`, you may need to add the iOS app to Firebase first.

---

### 🔧 Optional/Recommended Steps (For Production & Better UX)

#### 4. Configure OAuth Consent Screen (Optional for Testing, Required for Production)

**You can skip this for initial testing** - Firebase often handles it automatically. However, you'll need it for:
- Production releases
- Adding test users
- Customizing the consent screen appearance

If you want to configure it:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project: **workinfit**
3. Navigate to **APIs & Services** → **OAuth consent screen**
4. Choose **External** (unless you have a Google Workspace account)
5. Fill in the required information:
   - **App name**: Workin Fit
   - **User support email**: Your email
   - **Developer contact information**: Your email
6. Click **Save and Continue**
7. Add scopes (if needed):
   - `email`
   - `profile`
   - `openid`
8. Click **Save and Continue**
9. Add test users (for testing before publishing):
   - Add your email address
10. Click **Save and Continue**
11. Review and go back to dashboard

---

### 📱 Detailed Configuration Steps

#### Android: Verify Configuration

The Android app is already configured with:
- ✅ Package name: `com.workinfit.workin_fit`
- ✅ Google Services plugin in `build.gradle.kts`
- ✅ `google-services.json` file in place

#### iOS: Add iOS App to Firebase (if not already added)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **workinfit**
3. Go to **Project Settings**
4. Scroll to **Your apps** section
5. If iOS app is not listed, click **Add app** → **iOS**
6. Enter bundle ID: `com.workinfit.workinFit`
7. Download `GoogleService-Info.plist`
8. Add it to: `ios/Runner/GoogleService-Info.plist`

#### iOS: Configure URL Scheme in Info.plist

The iOS `Info.plist` already has a URL scheme configured. However, for Google Sign-In, you may need to add the reversed client ID.

1. Open `ios/Runner/Info.plist`
2. Find the `CFBundleURLTypes` array
3. Add a new URL scheme entry with the reversed client ID from `GoogleService-Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <!-- Existing entry -->
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>workinfit.app</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>workinfit</string>
        </array>
    </dict>
    <!-- Add Google Sign-In reversed client ID -->
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>REVERSED_CLIENT_ID_FROM_GoogleService-Info.plist</string>
        </array>
    </dict>
</array>
```

**To find the reversed client ID:**
1. Open `ios/Runner/GoogleService-Info.plist`
2. Find the `REVERSED_CLIENT_ID` key
3. Copy its value
4. Add it to `Info.plist` as shown above

**Example:**
If `REVERSED_CLIENT_ID` is `com.googleusercontent.apps.123456789-abcdefg`, add:
```xml
<string>com.googleusercontent.apps.123456789-abcdefg</string>
```

---

### 🧪 Testing

#### 5.1 Test on Android

1. Run the app on an Android device or emulator with Google Play Services:
   ```bash
   flutter run
   ```

2. Navigate to the login or register screen
3. Tap "Continue with Google"
4. Select a Google account
5. Verify that you're signed in and redirected to the home page

**Common Issues:**
- **PlatformException(sign_in_failed)**: Missing SHA-1 fingerprint → Add SHA-1 to Firebase Console
- **DEVELOPER_ERROR**: OAuth client not configured → Check OAuth consent screen setup

#### 5.2 Test on iOS

1. Run the app on an iOS device or simulator:
   ```bash
   flutter run
   ```

2. Navigate to the login or register screen
3. Tap "Continue with Google"
4. Complete the Google sign-in flow
5. Verify that you're signed in and redirected to the home page

**Common Issues:**
- **Invalid client ID**: Missing URL scheme in Info.plist → Add reversed client ID
- **Sign-in cancelled**: User cancelled the flow (this is expected behavior)

---

### 🔗 Account Linking

The app handles account linking scenarios:

- **If email already exists with password auth**: User will see an error message asking them to sign in with password first
- **If email already exists with Google auth**: User will be automatically signed in
- **New Google account**: New account will be created and profile saved to Firestore

---

### 🚀 Production Checklist

Before releasing to production:

- [ ] OAuth consent screen published (not in testing mode)
- [ ] Release SHA-1 fingerprint added to Firebase
- [ ] iOS app added to Firebase with correct bundle ID
- [ ] `GoogleService-Info.plist` added to iOS project
- [ ] Reversed client ID added to iOS `Info.plist`
- [ ] Tested on real Android device
- [ ] Tested on real iOS device
- [ ] Error handling tested (cancelled sign-in, network errors)

## 🔧 Troubleshooting

### Android: "PlatformException(sign_in_failed)"

**Solution:**
1. Verify SHA-1 fingerprint is added to Firebase Console
2. Download updated `google-services.json`
3. Clean and rebuild:
   ```bash
   flutter clean
   flutter pub get
   cd android && ./gradlew clean && cd ..
   flutter run
   ```

### iOS: "Invalid client ID"

**Solution:**
1. Verify `GoogleService-Info.plist` is in `ios/Runner/`
2. Check that reversed client ID is in `Info.plist`
3. Clean and rebuild:
   ```bash
   flutter clean
   flutter pub get
   cd ios && pod install && cd ..
   flutter run
   ```

### Both: "DEVELOPER_ERROR"

**Solution:**
1. Check OAuth consent screen is configured
2. Verify Google provider is enabled in Firebase Console
3. Ensure test users are added (for testing mode)

## 📚 Additional Resources

- [Google Sign-In Package](https://pub.dev/packages/google_sign_in)
- [Firebase Google Auth Guide](https://firebase.flutter.dev/docs/auth/social#google)
- [SHA-1 Setup Guide](https://stackoverflow.com/questions/51845559/how-to-generate-sha-1-for-flutter-react-native-android-native-app)
- [Firebase Authentication Docs](https://firebase.google.com/docs/auth)

---

## 🎯 Quick Start (Minimum Steps)

To get Google Sign-In working quickly:

1. ✅ **Enable Google Provider in Firebase Console** (Step 1)
2. ✅ **Add SHA-1 fingerprint for Android** (Step 2) - if testing on Android
3. ✅ **Configure iOS URL scheme** (Step 3) - if testing on iOS
4. ✅ **Test the app**

You can skip the OAuth consent screen configuration for initial testing - Firebase will handle it automatically. Configure it later when you're ready for production.

---

## 🎯 Full Summary

Once you complete the essential steps:
1. ✅ Google Sign-In will work on both Android and iOS
2. ✅ Users can sign in with their Google accounts
3. ✅ Accounts are automatically linked to Firebase Auth
4. ✅ User profiles are saved to Firestore
5. ✅ Error handling is in place for common scenarios

If you encounter any issues, refer to the troubleshooting section above or check the Firebase Console logs for more details.
