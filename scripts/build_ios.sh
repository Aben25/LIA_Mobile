#!/bin/bash

# Build script that automatically increments build number before building
# Usage: ./scripts/build_ios.sh or ./scripts/build_android.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

# Run increment build script
echo "🔄 Incrementing build number..."
"$SCRIPT_DIR/increment_build.sh"

# Get the platform from script name
PLATFORM=""
if [[ "$0" == *"ios"* ]]; then
    PLATFORM="ios"
elif [[ "$0" == *"android"* ]]; then
    PLATFORM="android"
fi

if [ -z "$PLATFORM" ]; then
    echo "Usage: $0"
    echo "Run: ./scripts/build_ios.sh or ./scripts/build_android.sh"
    exit 1
fi

echo "📱 Building for $PLATFORM..."

# Build the app
if [ "$PLATFORM" == "ios" ]; then
    flutter build ios --release
elif [ "$PLATFORM" == "android" ]; then
    flutter build appbundle --release
fi

echo "✅ Build complete!"

