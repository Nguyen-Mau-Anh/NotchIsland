# 🎵 NotchIsland Music Control - Quick Setup Guide

## 🚀 Quick Start (Music Focus)

This guide helps you get NotchIsland running with **music control only**, skipping the weather functionality that needs an API key.

### 1. **Run the Music Setup Script**

```bash
chmod +x setup_music_only.sh
./setup_music_only.sh
```

### 2. **Build the App (Music Focus)**

```bash
# Build with music-only focus
./build_music_only.sh
```

### 3. **Test Music Control**

```bash
# Run music-focused tests 
./test_music_only.sh
```

## 🎯 What Works Right Now

Based on the QA report, these features are **already working**:

✅ **Music Control** (resolved bugs from QA):
- Play/pause, next/previous track buttons
- Album artwork loading and caching
- Track title and artist display  
- Safe metadata parsing (BUG-001 & BUG-004 fixed)

✅ **Core Features**:
- Hover show/hide animation
- Global keyboard shortcut (Ctrl+Option+N)
- Settings persistence with @AppStorage
- Theme system with 4 themes (BUG-011 fixed)
- Multi-monitor support
- Menu bar integration

## ⚠️ Skipped for Now

❌ **Weather Widget**: Needs OpenWeatherMap API key (BUG-005)
❌ **Calendar Widget**: May need calendar permissions

## 🧪 Music-Focused Test Files

I've created focused test files:

- **`MusicControlTests.swift`** - Core music functionality tests
- **`setup_music_only.sh`** - Setup script ignoring weather
- **`build_music_only.sh`** - Build with music focus
- **`test_music_only.sh`** - Manual test checklist

## 📋 Manual Testing Checklist

### Prerequisites:
- [ ] Apple Music or Spotify installed
- [ ] At least one song available to play
- [ ] macOS 12.0+ (for notch detection)

### Core Tests:
- [ ] App starts without crashing
- [ ] NotchIsland appears on hover over notch area
- [ ] Music widget shows current track info
- [ ] Play/pause button works
- [ ] Next/previous track buttons work
- [ ] Album artwork loads and displays
- [ ] Settings window opens from menu bar
- [ ] Ctrl+Option+N toggles island visibility

## 🔧 Build Commands

### Using Xcode:
```bash
# Build via command line
xcodebuild -scheme NotchIsland -configuration Debug clean build

# Or use Xcode GUI: Product → Build (⌘B)
```

### Using Swift Package (if applicable):
```bash
swift build -c debug
```

## 🚨 Troubleshooting

### App Won't Start:
1. Check Console.app for error messages
2. Verify macOS 12.0+ requirement
3. Ensure Xcode project builds without errors

### Music Controls Don't Work:
1. **Grant AppleScript permissions** when prompted
2. Start Apple Music or Spotify with a song playing
3. Check Console.app for AppleScript errors
4. Try restarting both the music app and NotchIsland

### NotchIsland Doesn't Appear:
1. Hover over the notch area slowly
2. Check hover sensitivity in Settings
3. Try the keyboard shortcut: Ctrl+Option+N
4. Verify you're using a Mac with a notch

### Settings Don't Persist:
1. This was **fixed** in the QA report (changed from @State to @AppStorage)
2. If still an issue, check UserDefaults in Console.app

## 📊 Expected Test Results

Based on the QA report findings:

### ✅ Should Pass:
- Music manager initialization
- Settings persistence (@AppStorage fix)
- Theme system (4 themes available)
- Keyboard shortcut functionality
- Multi-monitor screen detection
- Safe metadata parsing (no pipe characters)

### ⚠️ Known Issues (Medium Priority):
- **BUG-002**: Spotify artwork might cause brief UI lag
- Music controls send commands to both Apple Music and Spotify

### 🎯 Success Criteria:

Your setup is successful when:
- [ ] App launches without weather-related crashes
- [ ] Island appears on notch hover
- [ ] Music widget shows current track
- [ ] Playback controls work with Apple Music or Spotify  
- [ ] Settings persist between app restarts
- [ ] Global keyboard shortcut toggles visibility

## 📈 Next Steps After Music Works

Once music control is working:

1. **Add weather later**: Get OpenWeatherMap API key and enable weather widget
2. **Enable calendar**: Grant calendar permissions for calendar widget  
3. **Performance tuning**: Address BUG-002 (Spotify main thread blocking)
4. **Add unit tests**: Currently no test coverage exists

## 🎵 Ready to Rock!

Your NotchIsland app should now work perfectly for music control. The weather functionality can be added later once you get an API key.

Focus on testing the core music features first - they're the most stable and user-friendly part of the app according to the QA report!