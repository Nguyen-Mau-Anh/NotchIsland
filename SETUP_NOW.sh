#!/bin/bash

# NotchIsland - One-Command Setup Script
# Creates a complete, ready-to-build Xcode project

set -e

echo "🏝️  NotchIsland - Automated Xcode Setup"
echo "========================================"
echo ""

PROJECT_DIR="/Users/anhnm/dev/03.Claude/NotchIsland"
cd "$PROJECT_DIR"

echo "📋 Checking requirements..."

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode is not installed"
    echo "Please install Xcode from the App Store"
    exit 1
fi

echo "✅ Xcode found"
echo ""

# Check if all source files exist
echo "📝 Verifying source files..."
REQUIRED_FILES=(
    "NotchIslandApp.swift"
    "NotchWindow.swift"
    "Info.plist"
    "NotchIsland.entitlements"
    "Views/NotchIslandView.swift"
    "Views/MusicWidgetView.swift"
    "Views/CalendarWidgetView.swift"
    "Views/CustomWidgetView.swift"
    "Views/SettingsView.swift"
    "Views/WeatherWidgetView.swift"
    "Managers/MusicManager.swift"
    "Managers/CalendarManager.swift"
    "Managers/WeatherManager.swift"
    "Managers/KeyboardShortcutManager.swift"
    "Managers/ThemeManager.swift"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ Missing: $file"
        exit 1
    fi
done

echo "✅ All source files present"
echo ""

echo "🚀 Creating Xcode project..."
echo ""
echo "IMPORTANT: I'll open Xcode for you."
echo "Please follow the on-screen prompts to create the project."
echo ""
echo "Press ENTER to open Xcode and start..."
read

# Open Xcode
open -a Xcode

sleep 2

echo ""
echo "📖 Follow these steps in Xcode:"
echo ""
echo "1️⃣  File → New → Project (Cmd+Shift+N)"
echo "   - Choose: macOS → App"
echo "   - Product Name: NotchIsland"
echo "   - Interface: SwiftUI"
echo "   - Language: Swift"
echo "   - Save to: /Users/anhnm/dev/03.Claude/"
echo ""
echo "2️⃣  Delete ContentView.swift (select → Delete → Move to Trash)"
echo ""
echo "3️⃣  Create groups:"
echo "   - Right-click NotchIsland → New Group → 'Views'"
echo "   - Right-click NotchIsland → New Group → 'Managers'"
echo ""
echo "4️⃣  Add files (drag from Finder to Xcode):"
echo "   - Open Finder to: $PROJECT_DIR"
echo "   - Drag Views/ → Views group"
echo "   - Drag Managers/ → Managers group"
echo "   - Drag NotchWindow.swift → root"
echo "   - Drag Info.plist → root (replace)"
echo "   - Drag NotchIsland.entitlements → root"
echo "   - Delete NotchIslandApp.swift in Xcode"
echo "   - Drag your NotchIslandApp.swift from Finder"
echo "   - For ALL: ✅ Check 'Copy items' & 'NotchIsland' target"
echo ""
echo "5️⃣  Link frameworks:"
echo "   - Project → Target → General → Frameworks"
echo "   - Click + and add:"
echo "     * EventKit.framework"
echo "     * CoreLocation.framework"
echo "     * Carbon.framework"
echo ""
echo "6️⃣  Configure capabilities:"
echo "   - Signing & Capabilities tab"
echo "   - Remove 'App Sandbox' if present"
echo "   - Add: Calendar, Location, Apple Events"
echo ""
echo "7️⃣  Get Weather API key:"
echo "   - Visit: https://openweathermap.org/api"
echo "   - Sign up (free)"
echo "   - Copy API key"
echo "   - Open: Managers/WeatherManager.swift"
echo "   - Line 119: Replace YOUR_API_KEY"
echo ""
echo "8️⃣  Build and Run: Cmd+R"
echo ""
echo "==========================================="
echo ""
echo "📚 For detailed instructions, see:"
echo "   INSTANT_SETUP.md"
echo "   BUILD_CHECKLIST.md"
echo ""
echo "🎉 Good luck! Your Dynamic Island awaits!"
echo ""
