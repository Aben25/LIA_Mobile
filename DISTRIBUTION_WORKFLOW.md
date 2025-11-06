# Standard Distribution Workflow for iOS App Updates

## Overview
This guide covers the complete workflow from making code changes to distributing your app update to the App Store.

## Step-by-Step Workflow

### 1. Make Your Code Changes
```bash
# Make your updates in the codebase
# Test locally, fix bugs, add features, etc.
```

### 2. Update Version Number (if needed)

**Check if version train is closed:**
- If you get "version train closed" error → increment version
- If version train is still open → just increment build number

**Option A: Version train is OPEN (most common)**
```bash
# Build number will auto-increment when you archive
# Just make sure version is correct in pubspec.yaml
# Example: version: 1.0.6+1 (version stays, build increments)
```

**Option B: Version train is CLOSED**
```bash
# Increment version number
./scripts/increment_version.sh patch   # 1.0.6 -> 1.0.7
# Or manually edit pubspec.yaml: version: 1.0.7+1
```

### 3. Test Your Changes
```bash
# Run on simulator/device
flutter run

# Or build and test
flutter build ios --debug
```

### 4. Clean and Prepare for Archive
```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# For iOS, install pods
cd ios && pod install && cd ..
```

### 5. Build Archive in Xcode

**Method 1: Using Xcode (Recommended)**
```bash
# Open Xcode
open ios/Runner.xcworkspace
```

Then in Xcode:
1. Select **Any iOS Device** (or your connected device) as the destination
2. **Product → Clean Build Folder** (⇧⌘K)
3. **Product → Archive** (this builds and creates archive)
4. Wait for archive to complete

**Method 2: Using Command Line**
```bash
# Build IPA directly
flutter build ipa --release
```

### 6. Distribute to App Store Connect

**In Xcode Organizer:**
1. After archiving, Xcode opens **Organizer** window
2. Select your archive
3. Click **Distribute App**
4. Choose **App Store Connect**
5. Click **Next**
6. Select **Upload** (or Export if you want to test first)
7. Review options:
   - ✅ **Upload your app's symbols** (recommended for crash reports)
   - ✅ **Manage Version and Build Number** (if you want Xcode to manage it)
8. Click **Upload**
9. Wait for upload to complete

**Using Command Line (Alternative):**
```bash
# After building IPA
xcrun altool --upload-app \
  --type ios \
  --file build/ios/ipa/*.ipa \
  --apiKey YOUR_API_KEY \
  --apiIssuer YOUR_ISSUER_ID
```

### 7. Submit for Review (in App Store Connect)

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to **My Apps** → Your App
3. Go to the version you just uploaded
4. Fill in:
   - **What's New in This Version** (release notes)
   - **App Review Information** (if changed)
   - **Version Information**
5. Click **Submit for Review**
6. Answer any export compliance questions
7. Submit!

### 8. Monitor Status

- **Processing** → Apple is processing your upload
- **Waiting for Review** → In queue for review
- **In Review** → Being reviewed
- **Ready for Sale** → Approved and live!

## Complete Workflow Example

```bash
# 1. Make your changes and test
flutter run

# 2. Check current version
grep "^version:" pubspec.yaml

# 3. If version train closed, increment version:
./scripts/increment_version.sh patch

# 4. Clean and prepare
flutter clean
flutter pub get
cd ios && pod install && cd ..

# 5. Open Xcode and archive
open ios/Runner.xcworkspace
# Then: Product → Clean → Archive

# 6. In Organizer: Distribute App → Upload

# 7. In App Store Connect: Submit for Review
```

## Automated Workflow (With Scripts)

If you've set up the auto-increment scripts:

```bash
# 1. Make changes and test
flutter run

# 2. If version train closed:
./scripts/mark_version_increment.sh

# 3. Clean
flutter clean
flutter pub get

# 4. Archive in Xcode (build number auto-increments!)
open ios/Runner.xcworkspace
# Product → Archive

# 5. Distribute and submit
```

## Version Numbering Strategy

### When to Increment Version Number

**Patch Version (1.0.6 → 1.0.7):**
- Bug fixes
- Small improvements
- Apple closes version train

**Minor Version (1.0.6 → 1.1.0):**
- New features
- Significant improvements
- UI/UX updates

**Major Version (1.0.6 → 2.0.0):**
- Major redesign
- Breaking changes
- Complete feature overhauls

### Build Number
- Always increments with each archive
- Can be any number (1, 2, 3... or 100, 101, 102...)
- Resets to 1 when version increments

## Common Issues & Solutions

### "Version train closed" Error
**Solution:** Increment version number
```bash
./scripts/increment_version.sh patch
```

### "Build number must be higher" Error
**Solution:** Increment build number
```bash
./scripts/increment_build.sh
```

### Archive Fails
**Solution:** Clean and rebuild
```bash
flutter clean
cd ios && pod install && cd ..
# Then archive again
```

### Upload Fails
**Solution:** Check:
- Internet connection
- App Store Connect credentials
- Version/build number conflicts
- Code signing certificates

## Best Practices

1. **Always test** before archiving
2. **Clean build** before archiving (removes old artifacts)
3. **Check version** before uploading
4. **Write release notes** (users appreciate updates)
5. **TestFlight** before production (optional but recommended)
6. **Commit version changes** to git after archiving

## Quick Reference

```bash
# Check current version
grep "^version:" pubspec.yaml

# Increment build number
./scripts/increment_build.sh

# Increment version (patch)
./scripts/increment_version.sh patch

# Clean and prepare
flutter clean && flutter pub get && cd ios && pod install && cd ..

# Build archive
open ios/Runner.xcworkspace
# Then: Product → Archive

# Or build IPA directly
flutter build ipa --release
```

## Timeline Expectations

- **Archive Build:** 5-15 minutes
- **Upload to App Store Connect:** 5-10 minutes
- **Processing:** 10-30 minutes
- **Review:** 1-3 days (usually 24-48 hours)
- **Ready for Sale:** Immediately after approval (or scheduled)

## TestFlight (Optional but Recommended)

Before submitting to production:

1. Upload archive to App Store Connect
2. Go to **TestFlight** tab
3. Add internal/external testers
4. Test the build
5. Then submit for production review

This catches issues before they go live!

