# Google Sign-In Setup Fix

## Issue
Google Sign-In is failing with error code 10, which indicates a configuration issue with the SHA-1 certificate fingerprint.

## Your Debug SHA-1 Fingerprint
```
25:C3:A7:4C:B8:1E:49:F5:50:94:C1:DC:42:0E:6E:24:59:9A:39:4D
```

## Required Steps

### 1. Add SHA-1 to Google Cloud Console
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select project: `vigilant-design-464014-k4`
3. Navigate to **APIs & Services** → **Credentials**
4. Create or edit Android OAuth client ID
5. Configure:
   - **Application type:** Android
   - **Package name:** `com.archminton.app`
   - **SHA-1 certificate fingerprint:** `25:C3:A7:4C:B8:1E:49:F5:50:94:C1:DC:42:0E:6E:24:59:9A:39:4D`

### 2. Enable Required APIs
In Google Cloud Console, enable:
- Google Sign-In API
- Google+ API (if available)
- People API

### 3. Get Google Client Secret
1. In Google Cloud Console → Credentials
2. Find your Web client ID: `525472168794-36ngov09agpjuehshecm1h4qskpvikan.apps.googleusercontent.com`
3. Copy the client secret
4. Add it to your backend `.env` file:
   ```
   GOOGLE_CLIENT_SECRET=your_actual_client_secret_here
   ```

### 4. Verify Configuration
Your current configuration:
- **Project ID:** `vigilant-design-464014-k4`
- **Project Number:** `525472168794`
- **Web Client ID:** `525472168794-36ngov09agpjuehshecm1h4qskpvikan.apps.googleusercontent.com`
- **iOS Client ID:** `525472168794-9rkf053o6cu2jl5tu2vu6dg5fr07vfjj.apps.googleusercontent.com`
- **Package Name:** `com.archminton.app`

### 5. Test
1. Clean and rebuild your Flutter app:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```
2. Test on a physical Android device
3. Try the Google Sign-In flow

## Files Updated
- ✅ `android/app/google-services.json` - Updated with correct SHA-1
- ✅ Backend `.env` - Added GOOGLE_CLIENT_SECRET placeholder
- ✅ All other configuration files are correctly set up

## Next Steps
1. **CRITICAL:** Add the SHA-1 fingerprint to Google Cloud Console
2. Get the actual Google Client Secret and update the backend `.env` file
3. Test the Google Sign-In flow

The main issue was that the SHA-1 certificate fingerprint wasn't added to Google Cloud Console, which is required for Android OAuth clients. 