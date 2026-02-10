# 🏝️ NotchIsland - START HERE

## Quickest Setup Ever (2 Options)

### ⚡ OPTION 1: Automated (Recommended)

Run this ONE command:
```bash
cd /Users/anhnm/dev/03.Claude/NotchIsland && ./SETUP_NOW.sh
```

The script will:
- ✅ Check requirements
- ✅ Open Xcode for you
- ✅ Show you exactly what to click
- ✅ Guide you step-by-step

**Time: 2-3 minutes**

---

### 📝 OPTION 2: Manual (If you prefer)

**ULTRA-QUICK STEPS:**

1. **Open Xcode** → File → New → Project
2. Choose **macOS** → **App**
3. Name: `NotchIsland`, Interface: **SwiftUI**
4. Save to: `/Users/anhnm/dev/03.Claude/`
5. **Delete** ContentView.swift
6. Create **2 groups**: Views, Managers
7. **Drag files** from Finder to Xcode:
   - `Views/*` → Views group
   - `Managers/*` → Managers group
   - `NotchWindow.swift`, `Info.plist`, `NotchIsland.entitlements` → root
   - Replace `NotchIslandApp.swift`
8. **Link 3 frameworks**: EventKit, CoreLocation, Carbon
9. **Remove** App Sandbox, **Add**: Calendar + Location + Apple Events
10. **Get API key** from openweathermap.org (free)
11. **Replace** `YOUR_API_KEY` in WeatherManager.swift line 119
12. **Press Cmd+R** to build and run!

**Time: 2-5 minutes**

---

## 🎯 What You're Getting

**6 Major Features:**
- 🎵 Music widget with album artwork
- 🌤️ Weather widget with live forecast
- ⌨️ Keyboard shortcuts (Ctrl+Option+N)
- 🎨 4 beautiful themes
- 🖥️ Multi-monitor support
- ⚙️ Perfect settings persistence

**Menu Bar App:**
- Runs in menu bar (no dock)
- Click icon → Settings / Quit
- Hover notch → Island appears!

---

## 📚 Detailed Guides

If you need more help:

1. **INSTANT_SETUP.md** - Step-by-step with screenshots
2. **BUILD_CHECKLIST.md** - Complete checklist (50+ items)
3. **FINAL_STATUS.md** - Full project overview
4. **FEATURES_AND_PLAN.md** - Future roadmap

---

## ⚠️ Important: Weather API Key

**Before weather works:**
1. Visit https://openweathermap.org/api
2. Sign up (free, takes 2 min)
3. Copy your API key
4. Open `Managers/WeatherManager.swift` in Xcode
5. Line 119: Replace `YOUR_API_KEY` with your key
6. Save (Cmd+S)

Without this, weather widget shows "API Error"

---

## 🐛 Quick Troubleshooting

**Island doesn't appear?**
→ Grant Accessibility permission
→ System Settings → Privacy & Security → Accessibility
→ Enable NotchIsland, restart app

**Build errors?**
→ Make sure Carbon.framework is linked
→ Make sure all files have target checked

**Weather not working?**
→ Replace YOUR_API_KEY (see above)

---

## 🚀 Ready?

Choose your path:
- **Fast:** Run `./SETUP_NOW.sh`
- **Manual:** Follow Option 2 above
- **Detailed:** Read INSTANT_SETUP.md

**Your Dynamic Island awaits!** 🏝️✨

---

**Questions?** All documentation is in this folder:
- START_HERE.md ← You are here
- INSTANT_SETUP.md
- BUILD_CHECKLIST.md
- FINAL_STATUS.md

**Good luck!** 🎉
