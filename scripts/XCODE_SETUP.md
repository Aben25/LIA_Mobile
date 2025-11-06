# How to Add Auto-Increment Build Number to Xcode

## Quick Setup (5 minutes)

Follow these steps to automatically increment the build number every time you archive in Xcode:

### Step 1: Open Xcode Project
```bash
open ios/Runner.xcworkspace
```
**Important:** Use `.xcworkspace`, not `.xcodeproj`

### Step 2: Add Build Phase Script

1. In Xcode, select the **Runner** project in the left sidebar
2. Select the **Runner** target (under "TARGETS")
3. Click on the **Build Phases** tab
4. Click the **+** button at the top left of the Build Phases section
5. Select **New Run Script Phase**

### Step 3: Configure the Script

1. **Rename** the new script phase to: `"Increment Build Number"` (double-click the name)
2. **Drag** the script phase to be **BEFORE** the "Run Script" phase (the one that says `/bin/sh "$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh" build`)
3. **Expand** the script phase and add this script:

```bash
cd "${SRCROOT}/.."
./scripts/increment_build.sh
```

4. **Important Settings:**
   - ✅ **Uncheck** "Run script only when installing" (so it runs on every build)
   - ✅ **Check** "Show environment variables in build log" (optional, for debugging)
   - Leave "Shell" as `/bin/sh`
   - Leave "Input Files" and "Output Files" empty

### Step 4: Verify Order

Your Build Phases should now look like this (in order):
1. ✅ **[CP] Check Pods Manifest.lock**
2. ✅ **Increment Build Number** ← Your new script
3. ✅ **Run Script** (Flutter build)
4. ✅ **Sources**
5. ✅ **Frameworks**
6. ✅ **Resources**

### Step 5: Test It!

1. **Clean Build Folder**: Product → Clean Build Folder (⇧⌘K)
2. **Archive**: Product → Archive (⌘B then Product → Archive)
3. Check the build log - you should see: `🔄 Incrementing build number...`
4. After archiving, check the version in Organizer - it should have incremented!

## Troubleshooting

### Script not running?
- Make sure the script phase is **before** the Flutter "Run Script" phase
- Make sure "Run script only when installing" is **unchecked**
- Check the build log for any errors

### Permission denied?
```bash
chmod +x scripts/increment_build.sh
```

### Script not found?
Make sure you're using the correct path. The script should be at:
```
/Users/abenezernuro/projects/Flutters/LIA_Mobile/scripts/increment_build.sh
```

### Want to see what's happening?
Add this to the script for more verbose output:
```bash
cd "${SRCROOT}/.."
set -x  # Enable debug output
./scripts/increment_build.sh
set +x  # Disable debug output
```

## Alternative: Use the Xcode-specific script

If the above doesn't work, you can use the Xcode-specific script:

```bash
cd "${SRCROOT}/.."
./scripts/xcode_increment_build.sh
```

This script is designed specifically for Xcode's build environment.

## Notes

- The build number increments **every time** you build/archive
- The version number (before `+`) stays the same until you manually change it
- Make sure to commit the updated `pubspec.yaml` after building
- If you want to skip incrementing for a specific build, temporarily disable the script phase

