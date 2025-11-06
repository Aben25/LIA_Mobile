# Quick Fix: Add Build Number Increment to Xcode

## The Problem
The build number isn't incrementing because the script phase isn't added to Xcode yet.

## The Solution (2 minutes)

### Step 1: Open Xcode
```bash
open ios/Runner.xcworkspace
```
**Important:** Use `.xcworkspace`, NOT `.xcodeproj`

### Step 2: Add the Script Phase

1. In Xcode's left sidebar, click on **Runner** (the blue project icon at the top)
2. In the main area, select the **Runner** target (under "TARGETS")
3. Click the **Build Phases** tab at the top
4. Click the **+** button at the top left of the Build Phases section
5. Select **New Run Script Phase**

### Step 3: Configure the Script

1. **Expand** the new "Run Script" phase (click the triangle)
2. **Rename** it: Double-click "Run Script" and change it to `"Increment Build Number"`
3. **Drag** it to be the **FIRST** item (before "[CP] Check Pods Manifest.lock")
4. In the script box, paste this:
   ```bash
   cd "${SRCROOT}/.."
   ./scripts/xcode_increment_build.sh
   ```
5. **Uncheck** "Run script only when installing" (important!)
6. Leave everything else as default

### Step 4: Verify Order

Your Build Phases should now look like this (in order):
1. ✅ **Increment Build Number** ← Your new script (FIRST!)
2. ✅ [CP] Check Pods Manifest.lock
3. ✅ Run Script (Flutter build)
4. ✅ Sources
5. ✅ Frameworks
6. ✅ Resources
7. ✅ Embed Frameworks
8. ✅ Thin Binary
9. ✅ [CP] Embed Pods Frameworks

### Step 5: Test It!

1. **Clean**: Product → Clean Build Folder (⇧⌘K)
2. **Archive**: Product → Archive
3. Check the build log - you should see: `🔄 Incrementing build number...`
4. Check `pubspec.yaml` - the build number should have incremented!

## Troubleshooting

### Script not found error?
Make sure the script path is correct. Try this instead:
```bash
cd "${SRCROOT}/.."
if [ -f "scripts/xcode_increment_build.sh" ]; then
    ./scripts/xcode_increment_build.sh
else
    echo "⚠️  Script not found, skipping increment"
fi
```

### Permission denied?
Run this in terminal:
```bash
chmod +x scripts/*.sh
```

### Still not working?
Check the build log for errors. The script output will show what's happening.

## That's It!

Once you add this script phase, every time you archive in Xcode, the build number will automatically increment! 🎉

