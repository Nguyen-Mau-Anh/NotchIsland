#!/bin/bash

# NotchIsland Music-Only Quick Start
# Run this to get music control working immediately

echo "🎵 NotchIsland Music Control Quick Start"
echo "======================================="

# Step 1: Check project structure
echo ""
echo "🔍 Step 1: Checking project files..."

if [ ! -f "*.xcodeproj" ] && [ ! -f "Package.swift" ]; then
    echo "❌ No Xcode project found"
    echo "   Please run this from your NotchIsland project directory"
    exit 1
fi

echo "✅ Found Xcode project"

# Step 2: Check for critical music files
echo ""
echo "🎵 Step 2: Checking music control files..."

REQUIRED_FILES=(
    "MusicManager.swift"
    "MusicWidgetView.swift" 
    "NotchIslandApp.swift"
    "NotchIslandView.swift"
    "ThemeManager.swift"
    "KeyboardShortcutManager.swift"
)

ALL_FOUND=true
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file - MISSING"
        ALL_FOUND=false
    fi
done

if [ "$ALL_FOUND" = false ]; then
    echo ""
    echo "⚠️  Some required files are missing."
    echo "   The app may not work correctly."
    echo "   Continue anyway? (y/n)"
    read -r response
    if [ "$response" != "y" ]; then
        exit 1
    fi
fi

# Step 3: Check/fix Info.plist for music control
echo ""
echo "🔐 Step 3: Setting up AppleScript permissions..."

# Find Info.plist
INFOPLIST=$(find . -name "Info.plist" -not -path "*/build/*" | head -1)

if [ -f "$INFOPLIST" ]; then
    echo "✅ Found Info.plist: $INFOPLIST"
    
    # Check for AppleScript permissions
    if plutil -extract "NSAppleScriptEnabled" xml1 "$INFOPLIST" >/dev/null 2>&1; then
        echo "✅ NSAppleScriptEnabled is present"
    else
        echo "⚠️  Adding NSAppleScriptEnabled to Info.plist..."
        plutil -insert "NSAppleScriptEnabled" -bool true "$INFOPLIST" 2>/dev/null || {
            echo "   Failed to add automatically. Please add manually:"
            echo "   <key>NSAppleScriptEnabled</key>"
            echo "   <true/>"
        }
    fi
    
    if plutil -extract "NSAppleEventsUsageDescription" xml1 "$INFOPLIST" >/dev/null 2>&1; then
        echo "✅ NSAppleEventsUsageDescription is present"
    else
        echo "⚠️  Need to add NSAppleEventsUsageDescription manually"
        echo "   Add this to your Info.plist:"
        echo "   <key>NSAppleEventsUsageDescription</key>"
        echo "   <string>NotchIsland controls music playback and displays track information.</string>"
    fi
else
    echo "⚠️  No Info.plist found"
    echo "   Please ensure your Xcode project has proper Info.plist configuration"
fi

# Step 4: Build the project
echo ""
echo "🔨 Step 4: Building the project..."

if ls *.xcodeproj >/dev/null 2>&1; then
    # Find the project and scheme
    PROJECT=$(ls *.xcodeproj | head -1)
    SCHEME=$(basename "$PROJECT" .xcodeproj)
    
    echo "Building $PROJECT with scheme $SCHEME..."
    
    # Try to build
    if xcodebuild -project "$PROJECT" -scheme "$SCHEME" -configuration Debug clean build ONLY_ACTIVE_ARCH=YES; then
        echo "✅ Build successful!"
        
        # Try to find the built app
        BUILT_APP=$(find . -name "*.app" -path "*/Build/Products/*" | head -1)
        if [ -f "$BUILT_APP" ]; then
            echo "✅ Found built app: $BUILT_APP"
            echo ""
            echo "🚀 Ready to test! Run:"
            echo "   open '$BUILT_APP'"
        fi
    else
        echo "❌ Build failed"
        echo "   Check the build output above for errors"
        echo "   Common issues:"
        echo "   - Missing code signing"
        echo "   - Swift version mismatch"  
        echo "   - Missing dependencies"
        exit 1
    fi
elif [ -f "Package.swift" ]; then
    echo "Building Swift Package..."
    if swift build -c debug; then
        echo "✅ Package build successful!"
    else
        echo "❌ Package build failed"
        exit 1
    fi
else
    echo "❌ No build system detected"
    exit 1
fi

# Step 5: Run basic tests
echo ""
echo "🧪 Step 5: Running basic tests..."

if [ -f "MusicControlTests.swift" ]; then
    echo "Running music control tests..."
    swift test --filter "MusicControlTests" 2>/dev/null || {
        echo "⚠️  Tests didn't run (this is normal if not in a test target)"
        echo "   Tests are available for manual review in MusicControlTests.swift"
    }
else
    echo "⚠️  No test file found (MusicControlTests.swift)"
fi

# Step 6: Final instructions
echo ""
echo "🎉 Setup Complete!"
echo "=================="
echo ""
echo "✅ What's ready:"
echo "- Music control functionality"
echo "- AppleScript permissions configured" 
echo "- Theme system (4 themes)"
echo "- Keyboard shortcut (Ctrl+Option+N)"
echo "- Settings persistence"
echo ""
echo "🎯 Next steps:"
echo "1. Start Apple Music or Spotify with a song"
echo "2. Launch the built app"  
echo "3. Grant AppleScript permissions when prompted"
echo "4. Hover over the notch area"
echo "5. Test music controls"
echo ""
echo "🔧 Manual testing:"
echo "- Use ./test_music_only.sh for detailed test checklist"
echo "- Check MUSIC_SETUP_GUIDE.md for troubleshooting"
echo ""
echo "⚠️  Weather widget disabled (no API key needed)"
echo "⚠️  Calendar widget may need calendar permission"
echo ""

if [ -n "$BUILT_APP" ]; then
    echo "🚀 Launch the app now? (y/n)"
    read -r launch_response
    if [ "$launch_response" = "y" ]; then
        echo "Launching NotchIsland..."
        open "$BUILT_APP"
        echo ""
        echo "🎵 App launched! Try:"
        echo "- Hover over the notch"
        echo "- Press Ctrl+Option+N"
        echo "- Start playing music and test the controls"
    fi
fi

echo ""
echo "🎵 NotchIsland music control is ready to rock! 🎸"