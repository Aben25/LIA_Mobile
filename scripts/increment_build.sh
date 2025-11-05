#!/bin/bash

# Script to automatically increment build number in pubspec.yaml
# Usage: ./scripts/increment_build.sh

set -e

PUBSPEC_FILE="pubspec.yaml"

if [ ! -f "$PUBSPEC_FILE" ]; then
    echo "Error: $PUBSPEC_FILE not found!"
    exit 1
fi

# Extract current version from pubspec.yaml
CURRENT_VERSION=$(grep "^version:" "$PUBSPEC_FILE" | sed 's/version: //')

if [ -z "$CURRENT_VERSION" ]; then
    echo "Error: Could not find version in $PUBSPEC_FILE"
    exit 1
fi

echo "Current version: $CURRENT_VERSION"

# Split version into version number and build number
# Format: VERSION+BUILD (e.g., 1.0.5+1)
VERSION_NUMBER=$(echo "$CURRENT_VERSION" | cut -d'+' -f1)
BUILD_NUMBER=$(echo "$CURRENT_VERSION" | cut -d'+' -f2)

if [ -z "$BUILD_NUMBER" ]; then
    echo "Error: Build number not found in version format"
    exit 1
fi

# Increment build number
NEW_BUILD_NUMBER=$((BUILD_NUMBER + 1))
NEW_VERSION="${VERSION_NUMBER}+${NEW_BUILD_NUMBER}"

echo "New version: $NEW_VERSION"

# Update pubspec.yaml
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/^version:.*/version: $NEW_VERSION/" "$PUBSPEC_FILE"
else
    # Linux
    sed -i "s/^version:.*/version: $NEW_VERSION/" "$PUBSPEC_FILE"
fi

echo "✅ Updated $PUBSPEC_FILE with version $NEW_VERSION"

