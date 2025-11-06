#!/bin/bash

# Script to increment version number (patch, minor, or major)
# Usage: 
#   ./scripts/increment_version.sh patch   # 1.0.5 -> 1.0.6
#   ./scripts/increment_version.sh minor   # 1.0.5 -> 1.1.0
#   ./scripts/increment_version.sh major   # 1.0.5 -> 2.0.0

set -e

PUBSPEC_FILE="pubspec.yaml"
INCREMENT_TYPE="${1:-patch}"  # Default to patch

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
VERSION_NUMBER=$(echo "$CURRENT_VERSION" | cut -d'+' -f1)
BUILD_NUMBER=$(echo "$CURRENT_VERSION" | cut -d'+' -f2)

# Parse version number (e.g., 1.0.5 -> MAJOR=1, MINOR=0, PATCH=5)
IFS='.' read -ra VERSION_PARTS <<< "$VERSION_NUMBER"
MAJOR="${VERSION_PARTS[0]}"
MINOR="${VERSION_PARTS[1]:-0}"
PATCH="${VERSION_PARTS[2]:-0}"

# Increment based on type
case "$INCREMENT_TYPE" in
    patch)
        PATCH=$((PATCH + 1))
        echo "Incrementing patch version..."
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        echo "Incrementing minor version..."
        ;;
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        echo "Incrementing major version..."
        ;;
    *)
        echo "Error: Invalid increment type '$INCREMENT_TYPE'"
        echo "Usage: $0 [patch|minor|major]"
        exit 1
        ;;
esac

# Construct new version number
NEW_VERSION_NUMBER="${MAJOR}.${MINOR}.${PATCH}"
# Reset build number to 1 when version increments
NEW_BUILD_NUMBER=1
NEW_VERSION="${NEW_VERSION_NUMBER}+${NEW_BUILD_NUMBER}"

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

