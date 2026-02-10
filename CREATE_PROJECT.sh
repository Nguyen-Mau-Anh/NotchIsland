#!/bin/bash

# NotchIsland - Automated Xcode Project Setup
# This script creates a ready-to-build Xcode project

set -e

echo "🚀 Creating NotchIsland Xcode Project..."

cd "$(dirname "$0")"
PROJECT_DIR="$(pwd)"

# Create temporary workspace
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

echo "📝 Step 1: Creating project structure..."

# Create new macOS app project using Xcode's template system
mkdir -p "NotchIsland"
cd "NotchIsland"

# Generate project using xcodebuild
cat > generate.sh << 'GENEOF'
#!/bin/bash
/usr/bin/xcodebuild -project NotchIsland.xcodeproj || true
GENEOF

# Better approach: Use applescript to create project via Xcode
osascript << 'APPLESCRIPT'
tell application "Xcode"
    activate
end tell

tell application "System Events"
    tell process "Xcode"
        -- Wait for Xcode to be ready
        delay 2

        -- Create new project: Cmd+Shift+N
        keystroke "n" using {command down, shift down}
        delay 1

        -- Select macOS tab
        click button "macOS" of toolbar 1 of window 1
        delay 0.5

        -- Select App template
        click button "App" of scroll area 1 of window 1
        delay 0.5

        -- Click Next
        click button "Next" of window 1
        delay 0.5

        -- Fill in project details
        set value of text field 1 of window 1 to "NotchIsland"
        delay 0.2

        -- Set organization to avoid errors
        set value of text field 2 of window 1 to "com.notchisland"
        delay 0.2

        -- Make sure SwiftUI is selected
        click pop up button "Interface" of window 1
        delay 0.2
        click menu item "SwiftUI" of menu 1 of pop up button "Interface" of window 1
        delay 0.2

        -- Click Next
        click button "Next" of window 1
        delay 1

        -- Choose save location
        keystroke "g" using {command down, shift down}  -- Go to folder
        delay 0.5

        set value of text field 1 of sheet 1 of window 1 to "/Users/anhnm/dev/03.Claude"
        delay 0.2

        keystroke return  -- Confirm location
        delay 0.5

        -- Uncheck "Create Git repository"
        click checkbox "Create Git repository" of window 1
        delay 0.2

        -- Click Create
        click button "Create" of window 1
        delay 2

        -- Project created!
    end tell
end tell
APPLESCRIPT

echo "✅ Project created via Xcode!"
cd /Users/anhnm/dev/03.Claude/NotchIsland

# Clean up temp
rm -rf "$TEMP_DIR"

echo ""
echo "✅ Done! Now manually do the following in Xcode:"
echo ""
echo "1. The project should be open in Xcode"
echo "2. Delete ContentView.swift"
echo "3. In Project Navigator:"
echo "   - Right-click NotchIsland folder → New Group → 'Views'"
echo "   - Right-click NotchIsland folder → New Group → 'Managers'"
echo "4. Drag files from Finder:"
echo "   - Views/* → Views group"
echo "   - Managers/* → Managers group"
echo "   - NotchWindow.swift → root"
echo "   - Replace NotchIslandApp.swift"
echo "   - Info.plist (replace)"
echo "   - NotchIsland.entitlements"
echo "5. Project Settings → Signing & Capabilities:"
echo "   - Remove App Sandbox"
echo "   - Add Calendar, Location, Apple Events"
echo "6. General → Frameworks:"
echo "   - Add EventKit.framework"
echo "   - Add CoreLocation.framework"
echo "   - Add Carbon.framework"
echo "7. Replace YOUR_API_KEY in WeatherManager.swift"
echo "8. Build and Run! (Cmd+R)"
echo ""
GENEOF
chmod +x generate.sh
