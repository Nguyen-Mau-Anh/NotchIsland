#!/bin/bash

# NotchIsland Quick Start - Based on BUILD_CHECKLIST.md
# This combines your complete checklist with music-focused testing

echo "🏝️ NotchIsland Quick Start"
echo "=========================="
echo "Based on your BUILD_CHECKLIST.md - All code is ready!"

# Step 1: Verify we're in the right place
echo ""
echo "📋 Step 1: Checking your source files..."

EXPECTED_FILES=(
    "NotchIslandApp.swift"
    "NotchWindow.swift" 
    "Info.plist"
    "NotchIsland.entitlements"
    "Managers/MusicManager.swift"
    "Managers/WeatherManager.swift"
    "Managers/KeyboardShortcutManager.swift"
    "Managers/ThemeManager.swift"
    "Managers/CalendarManager.swift"
    "Views/NotchIslandView.swift"
    "Views/MusicWidgetView.swift"
    "Views/WeatherWidgetView.swift"
    "Views/SettingsView.swift"
    "Views/CalendarWidgetView.swift"
    "Views/CustomWidgetView.swift"
)

ALL_FOUND=true
for file in "${EXPECTED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file - Missing"
        ALL_FOUND=false
    fi
done

if [ "$ALL_FOUND" = true ]; then
    echo ""
    echo "🎉 All source files found! Your code is complete."
else
    echo ""
    echo "⚠️  Some files are missing. Please ensure all files from your"
    echo "   BUILD_CHECKLIST.md are in the correct locations."
fi

# Step 2: Check for Xcode project
echo ""
echo "🏗️ Step 2: Checking Xcode project..."

if ls *.xcodeproj >/dev/null 2>&1; then
    PROJECT=$(ls *.xcodeproj | head -1)
    echo "✅ Found Xcode project: $PROJECT"
else
    echo "❌ No Xcode project found"
    echo ""
    echo "📝 You need to create an Xcode project first:"
    echo "1. Launch Xcode"
    echo "2. File → New → Project..."
    echo "3. macOS → App"
    echo "4. Product Name: NotchIsland"  
    echo "5. Interface: SwiftUI"
    echo "6. Language: Swift"
    echo ""
    echo "Then add your source files to the project and run this script again."
    exit 1
fi

# Step 3: Quick build test
echo ""
echo "🔨 Step 3: Testing build..."

SCHEME=$(basename "$PROJECT" .xcodeproj)
echo "Building scheme: $SCHEME"

if xcodebuild -project "$PROJECT" -scheme "$SCHEME" -configuration Debug clean build ONLY_ACTIVE_ARCH=YES CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO; then
    echo "✅ Build successful!"
else
    echo "❌ Build failed"
    echo ""
    echo "🔧 Common fixes:"
    echo "1. Add frameworks: EventKit, CoreLocation, Carbon"
    echo "2. Set minimum deployment: macOS 13.0"
    echo "3. Disable App Sandbox in project settings"
    echo "4. Check all files are added to the NotchIsland target"
    exit 1
fi

# Step 4: Music-focused testing instructions
echo ""
echo "🎵 Step 4: Ready for music control testing!"
echo ""
echo "🚀 Next steps:"
echo "1. Run the app in Xcode (Cmd+R)"
echo "2. Grant Accessibility permission when prompted"
echo "3. Start Apple Music or Spotify with a song"
echo "4. Grant AppleScript permission when prompted"
echo "5. Hover over the notch area"
echo ""
echo "🧪 Test checklist (from BUILD_CHECKLIST.md):"
echo "✓ Hover detection works"
echo "✓ Music widget shows current track"
echo "✓ Album artwork displays"
echo "✓ Play/pause button works"
echo "✓ Next/previous buttons work"
echo "✓ Keyboard shortcut (Ctrl+Option+N) toggles island"
echo "✓ Theme switching works (4 themes)"
echo "✓ Settings persist after restart"
echo ""
echo "⚠️  Weather requires API key (skip for now)"
echo "⚠️  Calendar requires permission (test separately)"
echo ""
echo "🎯 Based on your QA report:"
echo "- Music control: 8/10 quality (very good!)"
echo "- Settings persistence: 9/10 (fixed from @State to @AppStorage)"
echo "- Theme system: 9/10 (complete with 4 themes)"
echo "- Multi-monitor: 9/10 (works great)"
echo ""
echo "🏝️ Your NotchIsland app is ready to rock! 🎸"
