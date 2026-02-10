#!/bin/bash

# NotchIsland - Quick Launch Script
# Builds and runs the NotchIsland app

set -e

PROJECT_DIR="/Users/anhnm/dev/03.Claude/NotchIsland"
cd "$PROJECT_DIR"

echo "🏝️  NotchIsland - Building and Launching"
echo "========================================"
echo ""

# Check if project exists
if [ ! -d "NotchIsland.xcodeproj" ]; then
    echo "❌ Xcode project not found!"
    echo "   Run ./create_xcode_project.sh first"
    exit 1
fi

# Build the project
echo "🔨 Building NotchIsland..."
xcodebuild -project NotchIsland.xcodeproj -scheme NotchIsland -configuration Debug build 2>&1 | grep -E "(BUILD|error:|warning:|\*\*)" || true

# Check if build succeeded
if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo ""
    echo "❌ Build failed! Check errors above."
    exit 1
fi

echo ""
echo "✅ Build succeeded!"
echo ""

# Find the built app
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "NotchIsland.app" -path "*/Build/Products/Debug/*" | head -1)

if [ -z "$APP_PATH" ]; then
    echo "❌ Could not find NotchIsland.app"
    exit 1
fi

echo "🚀 Launching NotchIsland..."
echo "   Location: $APP_PATH"
echo ""

# Kill any existing instance
killall NotchIsland 2>/dev/null || true

# Launch the app
open "$APP_PATH"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ NotchIsland is now running!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📍 Look for the menu bar icon (hexagon, top right)"
echo "🖱️  Hover your mouse over the MacBook notch"
echo "⌨️  Press Ctrl+Option+N to toggle"
echo ""
echo "🎵 Music: Play something in Apple Music or Spotify"
echo "🌤️  Weather: Make sure you added your API key"
echo ""
echo "To stop: Click menu bar icon → Quit"
echo ""
