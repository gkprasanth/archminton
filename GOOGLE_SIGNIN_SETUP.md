# Google Sign-In Setup Guide for Archminton

## ✅ What's Already Done
- ✅ Google Sign-In code uncommented and ready
- ✅ Apple Sign-In remains commented out
- ✅ Dependencies added (`google_sign_in: ^6.2.1`)
- ✅ Android Gradle configuration updated
- ✅ iOS Info.plist configured with URL schemes
- ✅ **Configuration files created and installed:**
  - ✅ `android/app/google-services.json` - Android configuration
  - ✅ `ios/Runner/GoogleService-Info.plist` - iOS configuration
  - ✅ iOS URL scheme configured: `com.googleusercontent.apps.525472168794-9rkf053o6cu2jl5tu2vu6dg5fr07vfjj`

## 🔧 Remaining Steps to Complete Setup

### Step 1: Complete Google Cloud Console Setup
Your project: `vigilant-design-464014-k4`

**IMPORTANT:** You need to add the Android OAuth client in Google Cloud Console:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select project `vigilant-design-464014-k4`
3. Navigate to **APIs & Services** → **Credentials**
4. Click **+ CREATE CREDENTIALS** → **OAuth client ID**
5. Select **Android** application type
6. Configure:
   - **Package name:** `com.archminton.app`
   - **SHA-1 certificate fingerprint:** (get this from your debug/release keystore)

### Step 2: Get SHA-1 Certificate Fingerprint

**For Debug (Development):**
```bash
cd android
./gradlew signingReport
```
Look for the SHA1 fingerprint under `Variant: debug`

**For Release:**
Use your release keystore's SHA-1 fingerprint

### Step 3: Add SHA-1 to Google Cloud Console
1. In Google Cloud Console → Credentials
2. Find your Android OAuth client ID
3. Add the SHA-1 fingerprint(s)
4. Save the changes

### Step 4: Enable Required APIs
In Google Cloud Console, enable these APIs:
1. **Google+ API** (for Google Sign-In)
2. **People API** (for profile information)

### Step 5: Backend API Setup
Ensure your backend has a Google Sign-In endpoint at:
```
POST /auth/google
```

Expected request body:
```json
{
  "idToken": "google_id_token",
  "accessToken": "google_access_token"
}
```

Expected response:
```json
{
  "data": {
    "user": { "id": "...", "email": "...", "name": "..." },
    "accessToken": "jwt_token",
    "refreshToken": "refresh_token"
  }
}
```

### Step 6: Test the Integration
1. Run `flutter pub get`
2. Test on physical device (Google Sign-In doesn't work well on simulators)
3. Verify the "Continue with Google" button appears
4. Test the complete sign-in flow

## 🔑 Your Project Configuration

- **Project ID:** `vigilant-design-464014-k4`
- **Project Number:** `525472168794`
- **iOS Client ID:** `525472168794-9rkf053o6cu2jl5tu2vu6dg5fr07vfjj.apps.googleusercontent.com`
- **Web Client ID:** `525472168794-36ngov09agpjuehshecm1h4qskpvikan.apps.googleusercontent.com`
- **Bundle ID / Package:** `com.archminton.app`

## 🚨 Important Notes

### Security
- **SHA-1 Certificate:** You MUST add your app's SHA-1 fingerprint to Google Cloud Console
- **Debug:** Different SHA-1 for debug builds
- **Release:** Different SHA-1 for release builds (use your release keystore)

### Platform Specifics
- **Android:** Requires SHA-1 certificate fingerprint in Google Cloud Console
- **iOS:** URL scheme already configured ✅
- **Testing:** Use physical devices, not emulators

### Troubleshooting
- **"Sign in failed":** Check SHA-1 certificate in Google Cloud Console
- **"Network error":** Verify backend endpoint is correct
- **"Cancel by user":** Normal when user cancels Google Sign-In
- **"Developer Error":** Usually means SHA-1 fingerprint not added or incorrect

## 🔗 Useful Commands

```bash
# Get dependencies
flutter pub get

# Clean and rebuild
flutter clean
flutter pub get

# Get SHA-1 for debug (Android)
cd android
./gradlew signingReport

# Build for testing
flutter run --debug

# Get debug keystore SHA-1 (alternative method)
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

## 📱 Expected User Flow
1. User taps "Continue with Google"
2. Google Sign-In sheet appears
3. User selects Google account
4. App receives Google tokens
5. Tokens sent to your backend
6. Backend validates and returns app tokens
7. User is logged in to Archminton

## ✨ Features Enabled
- ✅ Google Sign-In button in login screen
- ✅ Automatic account selection
- ✅ Token exchange with backend
- ✅ Seamless login experience
- ✅ Error handling and loading states

## 🎯 Next Steps
1. **Add SHA-1 fingerprint to Google Cloud Console** (CRITICAL)
2. **Enable required APIs** in Google Cloud Console
3. **Test on physical device**
4. **Configure backend endpoint**

---

**The main remaining task is adding your SHA-1 certificate fingerprint to Google Cloud Console!**

---

**Need Help?** Check Firebase documentation or Google Sign-In Flutter plugin docs. 