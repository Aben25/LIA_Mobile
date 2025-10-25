# Deep Linking Implementation - Love in Action App

## Overview

This document describes the implementation of proper deep linking for the Love in Action Flutter app, following Flutter's official documentation and best practices. The implementation replaces the previous `app_redirect.html` approach with a more efficient and secure app links system.

## What Was Changed

### 1. Removed Old Implementation
- ❌ Deleted `app_redirect.html` file
- ❌ Removed `lib/services/deep_link_service.dart`
- ❌ Removed custom deep link handling logic

### 2. Implemented Proper App Links

#### Android Configuration (`android/app/src/main/AndroidManifest.xml`)
```xml
<!-- App Links for thomasasfaw.com domain -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="http" android:host="thomasasfaw.com" />
    <data android:scheme="https" />
</intent-filter>

<!-- Enable Flutter deep linking -->
<meta-data android:name="flutter_deeplinking_enabled" android:value="true" />
```

#### Asset Links File (`assetlinks.json`)
```json
[{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.ben25.loveinaction2",
    "sha256_cert_fingerprints": [
      "D7:A5:5A:11:94:87:BE:9C:25:65:0C:06:14:C2:70:32:13:E6:0C:DB:9C:BA:FC:93:FA:88:B2:D6:BF:D7:27:8D",
      "CC:BC:66:0C:20:2D:76:EF:FD:CC:9E:5C:23:72:0C:52:54:FD:9D:68:BF:BA:82:6C:72:18:BD:03:44:BD:B1:41"
    ]
  }
}]
```

#### Flutter Router (`lib/router/app_router.dart`)
- Implemented using `go_router` package
- Handles authentication-based redirects
- Supports direct app links without HTML redirects

## How It Works

### 1. App Links Flow
1. User receives email with link: `https://thomasasfaw.com/confirm?token=abc123`
2. Android system checks `assetlinks.json` for domain verification
3. If verified, Android opens the app directly
4. Flutter app receives the URL and routes to appropriate screen

### 2. Supported URLs
- **Email Confirmation**: `https://thomasasfaw.com/confirm?token=<token>`
- **Password Reset**: `https://thomasasfaw.com/reset?code=<code>`
- **Main App**: `https://thomasasfaw.com/app`

### 3. Authentication Handling
- Unauthenticated users accessing `/app` → redirected to `/`
- Authenticated users accessing auth routes → redirected to `/app`
- Proper route protection based on authentication state

## Deployment Requirements

### 1. Host Asset Links File
The `assetlinks.json` file must be hosted at:
```
https://thomasasfaw.com/.well-known/assetlinks.json
```

### 2. Backend Configuration
Update your Strapi backend to send direct app links instead of HTML redirects:

**Email Confirmation URLs:**
```
https://thomasasfaw.com/confirm?token=<confirmation_token>
```

**Password Reset URLs:**
```
https://thomasasfaw.com/reset?code=<reset_code>
```

### 3. Fallback HTML Pages (Optional)
Created fallback pages for cases where the app isn't installed:
- `public/app/confirm.html` - For email confirmation
- `public/app/reset.html` - For password reset

## Testing

### 1. Test App Links
```bash
# Test email confirmation
adb shell 'am start -a android.intent.action.VIEW \
    -c android.intent.category.BROWSABLE \
    -d "https://thomasasfaw.com/confirm?token=test123"' \
    com.ben25.loveinaction2

# Test password reset
adb shell 'am start -a android.intent.action.VIEW \
    -c android.intent.category.BROWSABLE \
    -d "https://thomasasfaw.com/reset?code=test456"' \
    com.ben25.loveinaction2
```

### 2. Verify Asset Links
Visit: `https://thomasasfaw.com/.well-known/assetlinks.json`

### 3. Test in Browser
Click on the app links in a browser to verify they open the app directly.

## Benefits of New Implementation

1. **Security**: Domain verification through `assetlinks.json`
2. **Performance**: Direct app opening without HTML redirects
3. **User Experience**: Seamless transition from email to app
4. **Standards Compliance**: Follows Android App Links best practices
5. **Maintainability**: Uses Flutter's built-in routing system

## Troubleshooting

### App Not Opening from Links
1. Verify `assetlinks.json` is accessible at the correct URL
2. Check that the SHA-256 fingerprints match your app's signing certificate
3. Ensure the domain in `AndroidManifest.xml` matches your hosted domain

### Links Opening in Browser Instead of App
1. Verify `android:autoVerify="true"` is set in the intent filter
2. Check that the `assetlinks.json` file is properly formatted
3. Wait up to 20 seconds for Android to verify the domain association

### Authentication Issues
1. Check that the auth provider is properly initialized
2. Verify route redirects are working correctly
3. Test with both authenticated and unauthenticated states

## Files Modified

- `android/app/src/main/AndroidManifest.xml` - Added app links configuration
- `lib/main.dart` - Updated to use go_router
- `lib/router/app_router.dart` - New router implementation
- `assetlinks.json` - Domain verification file
- `public/app/confirm.html` - Fallback for email confirmation
- `public/app/reset.html` - Fallback for password reset

## Files Removed

- `app_redirect.html` - Old HTML redirect file
- `lib/services/deep_link_service.dart` - Old deep link service

This implementation provides a robust, secure, and efficient deep linking system that follows Flutter and Android best practices.
