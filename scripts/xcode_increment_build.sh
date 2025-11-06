#!/bin/bash

# Xcode Build Phase Script: Smart auto-increment build/version number
# This script should be added as a "Run Script" phase in Xcode BEFORE the Flutter build phase
# It will:
# - Increment build number normally (1.0.6+1 -> 1.0.6+2)
# - Increment version number if flag file exists (1.0.6+5 -> 1.0.7+1)

set -e

# Get the project root directory (two levels up from ios/)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Navigate to project root
cd "$PROJECT_ROOT"

# Check if scripts exist
if [ ! -f "scripts/smart_increment.sh" ]; then
    echo "⚠️  Warning: smart_increment.sh not found"
    # Fallback to regular increment
    if [ -f "scripts/increment_build.sh" ]; then
        "$PROJECT_ROOT/scripts/increment_build.sh"
    else
        echo "❌ Error: No increment scripts found!"
        exit 1
    fi
else
    # Use smart increment (handles both build and version increments)
    "$PROJECT_ROOT/scripts/smart_increment.sh"
fi

# Verify the version was updated
NEW_VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //')
VERSION_NUMBER=$(echo "$NEW_VERSION" | cut -d'+' -f1)
BUILD_NUMBER=$(echo "$NEW_VERSION" | cut -d'+' -f2)
echo "✅ Build will use version: $VERSION_NUMBER (build $BUILD_NUMBER)"


