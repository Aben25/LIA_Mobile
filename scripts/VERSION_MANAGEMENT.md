# Automated Version Management Guide

## Overview

This project includes automated version and build number management. The system handles:
- **Build numbers**: Auto-increment on every build (1.0.6+1 → 1.0.6+2 → 1.0.6+3...)
- **Version numbers**: Increment when Apple closes a version train (1.0.6 → 1.0.7)

## Quick Start

### Normal Workflow (Build Number Auto-Increment)

**Just archive in Xcode** - the build number increments automatically!

1. Open Xcode: `open ios/Runner.xcworkspace`
2. Product → Archive
3. Build number auto-increments: `1.0.6+1` → `1.0.6+2` → `1.0.6+3`...

### When Version Train is Closed (Version Increment Needed)

When you get this error from App Store Connect:
> "Invalid Pre-Release Train. The train version '1.0.6' is closed for new build submissions"

**Option 1: Automatic (Recommended)**
```bash
./scripts/mark_version_increment.sh
```
Then archive in Xcode - it will automatically increment the version!

**Option 2: Manual**
```bash
# Increment patch version (1.0.6 -> 1.0.7)
./scripts/increment_version.sh patch

# Or increment minor version (1.0.6 -> 1.1.0)
./scripts/increment_version.sh minor

# Or increment major version (1.0.6 -> 2.0.0)
./scripts/increment_version.sh major
```

## Available Scripts

### `increment_build.sh`
Increments only the build number (1.0.6+5 → 1.0.6+6)
```bash
./scripts/increment_build.sh
```

### `increment_version.sh`
Increments the version number and resets build to 1
```bash
./scripts/increment_version.sh patch   # 1.0.6+5 -> 1.0.7+1
./scripts/increment_version.sh minor   # 1.0.6+5 -> 1.1.0+1
./scripts/increment_version.sh major   # 1.0.6+5 -> 2.0.0+1
```

### `smart_increment.sh`
Automatically chooses between build or version increment based on flag file
```bash
./scripts/smart_increment.sh
```

### `mark_version_increment.sh`
Creates a flag file so next build increments version instead of build number
```bash
./scripts/mark_version_increment.sh
```

## How It Works

### Normal Build Flow
1. You archive in Xcode
2. Xcode runs `xcode_increment_build.sh` (via Build Phase)
3. Script calls `smart_increment.sh`
4. `smart_increment.sh` checks for `.increment_version` flag file
5. If flag doesn't exist → increments build number
6. If flag exists → increments version number and removes flag

### Version Train Closed Flow
1. You get "version train closed" error from App Store
2. Run: `./scripts/mark_version_increment.sh`
3. This creates `.increment_version` flag file
4. Next archive → version increments automatically
5. Flag file is removed after increment

## Xcode Integration

Make sure you have the script phase set up in Xcode:

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** target → **Build Phases**
3. Find "Increment Build Number" script phase (should be BEFORE Flutter build)
4. Script should be:
   ```bash
   cd "${SRCROOT}/.."
   ./scripts/xcode_increment_build.sh
   ```

If you don't have this set up yet, see `scripts/XCODE_SETUP.md` for detailed instructions.

## Version Numbering Strategy

- **Patch** (1.0.6 → 1.0.7): Bug fixes, small changes
- **Minor** (1.0.6 → 1.1.0): New features, larger changes
- **Major** (1.0.6 → 2.0.0): Breaking changes, major updates

## Troubleshooting

### Build number not incrementing?
- Check that the script phase is added in Xcode
- Make sure "Run script only when installing" is **unchecked**
- Check build log for script output

### Version not incrementing when flag is set?
- Verify `.increment_version` file exists in project root
- Check script permissions: `chmod +x scripts/*.sh`
- Check build log for errors

### Want to skip increment for a build?
- Temporarily disable the script phase in Xcode
- Or comment out the script content

## Files

- `scripts/increment_build.sh` - Increments build number
- `scripts/increment_version.sh` - Increments version number
- `scripts/smart_increment.sh` - Smart increment logic
- `scripts/mark_version_increment.sh` - Mark version increment needed
- `scripts/xcode_increment_build.sh` - Xcode build phase script
- `.increment_version` - Flag file (auto-created/removed, not committed)

## Best Practices

1. **Always commit** `pubspec.yaml` after building (version changes)
2. **Don't commit** `.increment_version` flag file (add to .gitignore)
3. **Use patch** increments for most updates (1.0.6 → 1.0.7)
4. **Use minor** for feature releases (1.0.6 → 1.1.0)
5. **Use major** for major updates (1.0.6 → 2.0.0)

