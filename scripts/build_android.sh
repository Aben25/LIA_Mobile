#!/bin/bash

# Build script that automatically increments build number before building Android
# Usage: ./scripts/build_android.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

# Run increment build script
echo "🔄 Incrementing build number..."
"$SCRIPT_DIR/increment_build.sh"

echo "📱 Building for Android..."

# Build the app bundle
flutter build appbundle --release

echo "✅ Build complete!"

