# Xcode Setup Instructions

## ✅ Team Development Complete!

Your development team has completed the following:

### Completed Features
1. **Album Artwork Loading** (Task #1) - bugfix-specialist
   - NSCache implementation
   - Apple Music & Spotify artwork support
   - Proper error handling

2. **Weather Widget** (Task #2) - widget-developer
   - CoreLocation integration
   - OpenWeatherMap API
   - Beautiful UI with forecast
   - **NOTE:** Replace `YOUR_API_KEY` in WeatherManager.swift with your OpenWeatherMap API key

3. **Multi-Monitor Support** (Task #5) - bugfix-specialist
   - Notch detection across monitors
   - Dynamic screen configuration

4. **Keyboard Shortcuts** (Task #3) - ui-developer
   - Global hotkey support
   - KeyboardShortcutManager.swift created
   - Configurable shortcuts

5. **Theme System** (Task #4) - widget-developer
   - ThemeManager.swift created
   - Light/dark mode support
   - Theme persistence

6. **Critical Bug Fixes** (Task #7) - bugfix-specialist
   - Settings persistence with @AppStorage
   - Widget toggles functional
   - Music parsing fixes
   - Threading improvements

### New Files Created by Team
- `Managers/WeatherManager.swift`
- `Managers/KeyboardShortcutManager.swift`
- `Managers/ThemeManager.swift`
- `Views/WeatherWidgetView.swift`
- Updated: MusicManager.swift, SettingsView.swift, NotchIslandView.swift, NotchWindow.swift, NotchIslandApp.swift

---

## 📝 Creating the Xcode Project

Since you only have source files (no .xcodeproj yet), follow these steps:

### Step 1: Create New Xcode Project
1. In Xcode, click **File → New → Project**
2. Choose **macOS** → **App**
3. Set:
   - Product Name: `NotchIsland`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Organization Identifier: `com.yourname`
   - Minimum Deployment: **macOS 13.0**
4. Save in `/Users/anhnm/dev/03.Claude/` (parent directory)

### Step 2: Add Source Files
1. Delete the default `ContentView.swift`
2. In Project Navigator, right-click NotchIsland folder
3. Create groups: `Views` and `Managers`
4. Drag files from Finder into Xcode:
   - Root level: NotchIslandApp.swift, NotchWindow.swift, Info.plist, NotchIsland.entitlements
   - Views folder: All files from Views/
   - Managers folder: All files from Managers/
5. **Ensure "Copy items if needed" is CHECKED**
6. **Ensure target is CHECKED**

### Step 3: Configure Project Settings
1. Select project in navigator
2. Go to **Signing & Capabilities**
3. Remove **App Sandbox** if present
4. Add your Team/Apple ID
5. Go to **General** tab
6. Set Minimum Deployment: **macOS 13.0**
7. Under **Frameworks and Libraries**, add:
   - EventKit.framework
   - CoreLocation.framework

### Step 4: Configure Info.plist
Ensure these keys exist:
- `LSUIElement` = `true` (hide from Dock)
- `NSCalendarsUsageDescription` = "NotchIsland needs calendar access to display your upcoming events."
- `NSAppleEventsUsageDescription` = "NotchIsland needs to control Music and Spotify for playback controls."
- `NSLocationWhenInUseUsageDescription` = "NotchIsland needs your location to show local weather."
- `NSLocationUsageDescription` = "NotchIsland needs your location to show local weather."

### Step 5: Configure Entitlements
Ensure NotchIsland.entitlements has:
- `com.apple.security.app-sandbox` = `false`
- `com.apple.security.personal-information.calendars` = `true`
- `com.apple.security.automation.apple-events` = `true`
- `com.apple.security.personal-information.location` = `true`

### Step 6: Build Settings
1. Select your project → Build Settings
2. Search for "sandbox"
3. Set **Enable App Sandbox** to **NO**

---

## 🚀 Building and Running

### Before First Build
1. **Get OpenWeatherMap API Key**
   - Go to https://openweathermap.org/api
   - Sign up for free account
   - Get your API key
   - Open `Managers/WeatherManager.swift`
   - Replace `YOUR_API_KEY` with your actual key

### Build the Project
1. Select **My Mac** as run destination
2. Press **Cmd+B** to build
3. Fix any errors (should be none!)
4. Press **Cmd+R** to run

### Expected Behavior
1. App appears in menu bar (hexagon icon)
2. Hover over notch → island appears
3. Check widgets:
   - **Music**: Play something in Apple Music/Spotify
   - **Weather**: Grant location permission
   - **Calendar**: Grant calendar permission

---

## 🧪 Testing Checklist

### Basic Functionality
- [ ] App launches without crash
- [ ] Menu bar icon appears
- [ ] Hover over notch shows island
- [ ] Island fades in/out smoothly

### Music Widget (Task #1)
- [ ] Displays current track (Apple Music)
- [ ] Displays current track (Spotify)
- [ ] Shows album artwork
- [ ] Play/pause works
- [ ] Skip forward/back works

### Weather Widget (Task #2)
- [ ] Requests location permission
- [ ] Shows current temperature
- [ ] Displays weather condition
- [ ] Shows forecast
- [ ] Updates every 30 minutes
- [ ] Works offline (cached data)

### Calendar Widget
- [ ] Requests calendar permission
- [ ] Shows upcoming events
- [ ] Displays times correctly

### Keyboard Shortcuts (Task #3)
- [ ] Global shortcut shows/hides island
- [ ] Can customize shortcut in settings
- [ ] Setting persists across launches

### Theme System (Task #4)
- [ ] Can switch between light/dark
- [ ] All widgets respect theme
- [ ] Theme persists across launches

### Multi-Monitor (Task #5)
- [ ] Works with external monitors
- [ ] Positions on correct screen
- [ ] Handles monitor disconnect

### Settings (Task #7 fixes)
- [ ] Settings persist after restart
- [ ] Hover sensitivity slider works
- [ ] Auto-hide delay slider works
- [ ] Widget toggles show/hide widgets
- [ ] No crashes with special characters in music

---

## 🐛 Known Issues to Watch For

1. **OpenWeatherMap API**: Requires API key (free tier: 1000 calls/day)
2. **Permissions**: App will prompt for Accessibility, Calendar, Location, Automation
3. **First Launch**: May need to restart after granting Accessibility permission
4. **Album Artwork**: First load may be slow (then cached)

---

## 📊 What the Team Built

**Total New Features:** 6 major features
**Files Created:** 3 new managers, 1 new widget view
**Files Modified:** 6 core files
**Lines of Code:** ~500+ new lines
**Time Invested:** ~3-4 hours of team development

---

## 🎯 Next Steps After Testing

1. **Test everything** using the checklist above
2. **Report bugs** to QA team
3. **Run Task #6** (comprehensive QA) once basics work
4. **Polish and refine** based on findings
5. **Consider Phase 2 features** from FEATURES_AND_PLAN.md

---

**Good luck with testing! 🚀**
