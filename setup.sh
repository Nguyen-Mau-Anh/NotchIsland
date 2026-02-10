#!/bin/bash

# NotchIsland Project Setup Script
# Run this script to set up the NotchIsland macOS app for development

echo "🏝️  NotchIsland Project Setup"
echo "=============================="

# Check if we're in an Xcode project directory
if [ ! -f "*.xcodeproj" ] && [ ! -f "Package.swift" ]; then
    echo "❌ No Xcode project or Swift package found in current directory"
    echo "Please run this script from your NotchIsland project root"
    exit 1
fi

echo "✅ Found Xcode project"

# 1. Check for critical setup requirements
echo ""
echo "🔍 Checking critical setup requirements..."

# Check for Weather API key placeholder
if grep -r "YOUR_API_KEY" . --include="*.swift" >/dev/null 2>&1; then
    echo "⚠️  CRITICAL: Weather API key is still placeholder"
    echo "   You need to replace 'YOUR_API_KEY' in WeatherManager.swift with a real OpenWeatherMap API key"
    echo "   Get one at: https://openweathermap.org/api"
    echo ""
fi

# 2. Check Info.plist for required permissions
echo "🔒 Checking Info.plist permissions..."

INFOPLIST_FILE=$(find . -name "Info.plist" | head -1)
if [ -f "$INFOPLIST_FILE" ]; then
    echo "✅ Found Info.plist: $INFOPLIST_FILE"
    
    # Check for required permission descriptions
    REQUIRED_KEYS=(
        "NSLocationWhenInUseUsageDescription"
        "NSCalendarsUsageDescription" 
        "NSLocationAlwaysAndWhenInUseUsageDescription"
    )
    
    for key in "${REQUIRED_KEYS[@]}"; do
        if plutil -extract "$key" xml1 "$INFOPLIST_FILE" >/dev/null 2>&1; then
            echo "✅ $key is present"
        else
            echo "⚠️  Missing: $key"
            echo "   Add this to Info.plist for App Store submission"
        fi
    done
else
    echo "⚠️  No Info.plist found - you may need to add permission descriptions"
fi

# 3. Create build configuration
echo ""
echo "🔧 Setting up build configuration..."

# Create a debug configuration script
cat > debug_config.sh << 'EOF'
#!/bin/bash
# Debug build configuration for NotchIsland

echo "🔨 Building NotchIsland in Debug mode..."

# Enable additional debugging
export SWIFT_TESTING_ENABLED=1
export OTHER_SWIFT_FLAGS="-D DEBUG"

# Build the project
if [ -f "*.xcodeproj" ]; then
    xcodebuild -configuration Debug -scheme NotchIsland clean build
elif [ -f "Package.swift" ]; then
    swift build -c debug
else
    echo "❌ No build system detected"
    exit 1
fi

echo "✅ Debug build complete"
EOF

chmod +x debug_config.sh

# 4. Create test runner script
echo ""
echo "🧪 Setting up test runner..."

cat > run_tests.sh << 'EOF'
#!/bin/bash
# Test runner for NotchIsland

echo "🧪 Running NotchIsland Tests..."

# Set up test environment
export SWIFT_TESTING_ENABLED=1

# Run Swift Testing tests
if [ -f "Package.swift" ]; then
    echo "Running Swift Package tests..."
    swift test
elif [ -f "*.xcodeproj" ]; then
    echo "Running Xcode tests..."
    xcodebuild test -scheme NotchIsland -destination 'platform=macOS'
else
    echo "❌ No test system detected"
    exit 1
fi

echo ""
echo "📊 Test Summary:"
echo "- Check for CRITICAL bugs (Weather API key, theme system)"
echo "- Verify settings persistence with @AppStorage"  
echo "- Test multi-monitor support"
echo "- Validate keyboard shortcut functionality"

echo ""
echo "🚨 Known Issues to Address:"
echo "- BUG-005: Replace YOUR_API_KEY with real OpenWeatherMap key"
echo "- BUG-002: Spotify artwork may block main thread"
echo "- BUG-006: Weather only shows Celsius (no Fahrenheit option)"

EOF

chmod +x run_tests.sh

# 5. Create Info.plist template if missing
if [ ! -f "$INFOPLIST_FILE" ]; then
    echo ""
    echo "📝 Creating Info.plist template..."
    
    cat > Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>$(MACOSX_DEPLOYMENT_TARGET)</string>
    <key>LSUIElement</key>
    <true/>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.utilities</string>
    
    <!-- Required Permission Descriptions -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>NotchIsland uses your location to provide local weather information in the weather widget.</string>
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>NotchIsland uses your location to provide local weather information in the weather widget.</string>
    <key>NSCalendarsUsageDescription</key>
    <string>NotchIsland accesses your calendar to display upcoming events in the calendar widget.</string>
    <key>NSAppleScriptEnabled</key>
    <true/>
    <key>NSAppleEventsUsageDescription</key>
    <string>NotchIsland uses AppleScript to control music playback and get current track information.</string>
</dict>
</plist>
EOF

    echo "✅ Created Info.plist template with required permissions"
fi

# 6. Final setup summary
echo ""
echo "✅ Setup Complete!"
echo ""
echo "📋 Next Steps:"
echo "1. Get OpenWeatherMap API key: https://openweathermap.org/api"
echo "2. Replace 'YOUR_API_KEY' in WeatherManager.swift with your real API key"
echo "3. Run tests: ./run_tests.sh"
echo "4. Build for debug: ./debug_config.sh"
echo ""
echo "🧪 Available Test Files:"
echo "- NotchIslandTests.swift (comprehensive test suite)"
echo ""
echo "⚠️  Critical Issues to Fix:"
echo "- Weather API key (app won't work without it)"
echo "- Consider adding Fahrenheit temperature option"
echo "- Monitor main thread performance with Spotify"
echo ""
echo "🎉 Your NotchIsland project is ready for development!"