# NotchIsland - Instant Xcode Setup

Run this ONE command to create a ready-to-build Xcode project:

```bash
cd /Users/anhnm/dev/03.Claude/NotchIsland && bash SETUP_NOW.sh
```

That's it! The script will:
1. Open Xcode
2. Create the project automatically
3. Add all files
4. Configure everything
5. Ready to build!

---

## Or Manual Setup (2 minutes):

If the script doesn't work, follow these quick steps:

### 1. Create Project in Xcode (30 seconds)
```
1. Open Xcode
2. File → New → Project
3. macOS → App
4. Product Name: NotchIsland
5. Interface: SwiftUI
6. Language: Swift
7. Save to: /Users/anhnm/dev/03.Claude/
8. Click Create
```

### 2. Delete Default File (5 seconds)
```
- Right-click ContentView.swift → Delete → Move to Trash
```

###3. Create Groups (10 seconds)
```
- Right-click NotchIsland folder → New Group → "Views"
- Right-click NotchIsland folder → New Group → "Managers"
```

### 4. Add Files (1 minute)
**Open Finder** to `/Users/anhnm/dev/03.Claude/NotchIsland/`

**Drag these to Xcode:**
- `Views/` folder → Drop on "Views" group
- `Managers/` folder → Drop on "Managers" group
- `NotchWindow.swift` → Drop on "NotchIsland" root
- `Info.plist` → Drop on root (replace if asked)
- `NotchIsland.entitlements` → Drop on root

**Delete and replace NotchIslandApp.swift:**
- Delete the existing NotchIslandApp.swift in Xcode
- Drag your NotchIslandApp.swift from Finder

**For ALL files, make sure:**
- ✅ Check "Copy items if needed"
- ✅ Check "NotchIsland" target

### 5. Link Frameworks (20 seconds)
```
1. Select project (blue icon) in navigator
2. Select NotchIsland target
3. General tab → Frameworks section
4. Click + button, search and add:
   - EventKit.framework
   - CoreLocation.framework
   - Carbon.framework
```

### 6. Configure Settings (20 seconds)
```
1. Signing & Capabilities tab
2. Click "- Capability" to remove App Sandbox (if present)
3. Click "+ Capability" and add:
   - Calendar
   - Location
   - Apple Events
4. General tab → Set minimum macOS to 13.0
```

### 7. Get Weather API Key (2 minutes)
```
1. Go to https://openweathermap.org/api
2. Sign up (free)
3. Copy your API key
4. In Xcode, open Managers/WeatherManager.swift
5. Line 119: Replace YOUR_API_KEY with your key
6. Cmd+S to save
```

### 8. Build & Run!
```
Press Cmd+R

First time:
- Grant Accessibility permission
- System Settings will open
- Enable NotchIsland
- Restart app (Cmd+Q then Cmd+R)

Second time:
- Menu bar icon appears!
- Hover over notch → Island appears! 🎉
```

---

## Troubleshooting

**"Cannot find X in scope"**
- File not added to target
- Select file → File Inspector → Check "NotchIsland" target

**"Carbon/HIToolbox not found"**
- Carbon.framework not linked
- Go to step 5 above

**No menu bar icon**
- Check Info.plist has LSUIElement = true
- Should be there by default

**Island doesn't appear**
- Grant Accessibility permission (step 8)
- System Settings → Privacy & Security → Accessibility
- Enable NotchIsland

---

## That's It!

Total time: **2-5 minutes** depending on method

Your Dynamic Island app will be running with:
- ✅ Album artwork
- ✅ Weather widget
- ✅ Keyboard shortcuts
- ✅ 4 themes
- ✅ Multi-monitor support
- ✅ Perfect settings

**Enjoy!** 🏝️✨
