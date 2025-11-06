#!/bin/bash

# Helper script to mark that version needs to be incremented
# Run this when you get "version train closed" error from App Store
# Usage: ./scripts/mark_version_increment.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
FLAG_FILE="$PROJECT_DIR/.increment_version"

touch "$FLAG_FILE"
echo "✅ Flag file created: $FLAG_FILE"
echo "📝 Next build will increment version number instead of build number"
echo ""
echo "To manually increment version right now, run:"
echo "  ./scripts/increment_version.sh patch   # for patch (1.0.5 -> 1.0.6)"
echo "  ./scripts/increment_version.sh minor   # for minor (1.0.5 -> 1.1.0)"
echo "  ./scripts/increment_version.sh major   # for major (1.0.5 -> 2.0.0)"

