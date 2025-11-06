#!/bin/bash

# Smart version increment script for Xcode
# This script increments the build number normally, but can also increment
# the version number if a flag file exists (indicating version train is closed)
# Usage: ./scripts/smart_increment.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
FLAG_FILE="$PROJECT_DIR/.increment_version"

cd "$PROJECT_DIR"

# Check if we need to increment version (version train closed)
if [ -f "$FLAG_FILE" ]; then
    echo "🚨 Version train closed detected. Incrementing version number..."
    "$SCRIPT_DIR/increment_version.sh" patch
    # Remove the flag file after incrementing
    rm -f "$FLAG_FILE"
    echo "✅ Version incremented. Build number reset to 1."
else
    # Normal build number increment
    echo "🔄 Incrementing build number..."
    "$SCRIPT_DIR/increment_build.sh"
fi

