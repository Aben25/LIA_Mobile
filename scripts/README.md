# Automatic Build Number Increment

This project includes scripts to automatically increment the build number on every build.

## Usage

### Option 1: Use Build Scripts (Recommended)

Use the provided build scripts that automatically increment the build number before building:

```bash
# For iOS
./scripts/build_ios.sh

# For Android
./scripts/build_android.sh
```

### Option 2: Manual Increment

Manually increment the build number before building:

```bash
./scripts/increment_build.sh
flutter build ios --release
# or
flutter build appbundle --release
```

### Option 3: Integrate into Xcode (For iOS)

To automatically increment build numbers when building from Xcode:

1. Open your project in Xcode: `open ios/Runner.xcworkspace`
2. Select the **Runner** target
3. Go to **Build Phases** tab
4. Click the **+** button and select **New Run Script Phase**
5. Drag the new script phase to run **before** "Compile Sources" phase
6. Rename it to "Increment Build Number"
7. Add this script:

```bash
cd "${SRCROOT}/.."
./scripts/increment_build.sh
```

8. Make sure "Run script only when installing" is **unchecked** (so it runs on every build)

Now every time you build from Xcode, the build number will automatically increment!

### Option 4: Use Flutter Package (Alternative)

If you prefer using a Flutter package, you can use `flutter_version`:

1. Add to `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_version: ^1.0.0
```

2. Run before building:
```bash
flutter pub run flutter_version:increment_build
```

## How It Works

The `increment_build.sh` script:
- Reads the current version from `pubspec.yaml` (format: `VERSION+BUILD`)
- Increments the build number (the part after `+`)
- Updates `pubspec.yaml` with the new version
- Preserves the version number (the part before `+`)

Example:
- Current: `1.0.5+1`
- After increment: `1.0.5+2`

## Notes

- The version number (before `+`) needs to be manually updated when you want to release a new version
- The build number (after `+`) automatically increments
- Make sure to commit the updated `pubspec.yaml` after building

