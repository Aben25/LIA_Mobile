#!/bin/bash

# Build iOS archive script with automatic version increment
# This ensures you always have the correct version when submitting to App Store

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

# Increment build number before building
echo "🔄 Incrementing build number..."
"$SCRIPT_DIR/increment_build.sh"

# Get the updated version
VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //')
VERSION_NUMBER=$(echo "$VERSION" | cut -d'+' -f1)
BUILD_NUMBER=$(echo "$VERSION" | cut -d'+' -f2)

echo "📱 Building iOS archive with version $VERSION_NUMBER (build $BUILD_NUMBER)..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build iOS archive
echo "🔨 Building iOS archive..."
flutter build ipa --release

echo ""
echo "✅ Build complete!"
echo "📦 Archive location: build/ios/ipa/"
echo "📱 Version: $VERSION_NUMBER"
echo "🔢 Build Number: $BUILD_NUMBER"
echo ""
echo "Next steps:"
echo "1. Open Xcode: open ios/Runner.xcworkspace"
echo "2. Product > Archive (or use Organizer)"
echo "3. Upload to App Store Connect"
echo ""
echo "Or upload directly using:"
echo "xcrun altool --upload-app --type ios --file build/ios/ipa/*.ipa --apiKey YOUR_API_KEY --apiIssuer YOUR_ISSUER_ID"

