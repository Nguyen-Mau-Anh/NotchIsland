# 🎯 XCODE IS OPEN - Follow These Steps NOW

Xcode should be opening right now. Follow these exact steps:

---

## Step 1: Create New Project (30 seconds)

1. In Xcode, press **Cmd+Shift+N** (or File → New → Project)
2. You'll see template chooser
3. At the top, click **macOS** tab
4. Click **App** template (should be first or second option)
5. Click **Next** button (bottom right)

---

## Step 2: Configure Project (20 seconds)

Fill in these fields:

- **Product Name:** `NotchIsland`
- **Team:** Select your Apple ID (or leave as "None")
- **Organization Identifier:** `com.notchisland` (or anything you want)
- **Interface:** Make sure it says **SwiftUI** (very important!)
- **Language:** Swift
- **Storage:** None
- **Include Tests:** Uncheck ☐

Click **Next**

---

## Step 3: Choose Save Location (10 seconds)

1. In the save dialog, press **Cmd+Shift+G** to "Go to Folder"
2. Type: `/Users/anhnm/dev/03.Claude`
3. Press **Enter**
4. **Uncheck** "Create Git repository" ☐
5. Click **Create** button

**Wait for Xcode to create the project...**

---

## Step 4: Delete Default File (5 seconds)

In the Project Navigator (left side):
1. Find `ContentView.swift`
2. Right-click it → **Delete**
3. Choose **Move to Trash**

---

## Step 5: Create Groups (10 seconds)

In Project Navigator:
1. Right-click `NotchIsland` folder (the one with files, not the blue project icon)
2. New Group → Type `Views` → Press Enter
3. Right-click `NotchIsland` folder again
4. New Group → Type `Managers` → Press Enter

You should now see:
```
NotchIsland (blue icon)
└── NotchIsland (yellow folder)
    ├── NotchIslandApp.swift
    ├── Assets.xcassets
    ├── Views (folder)
    └── Managers (folder)
```

---

## Step 6: Add Source Files (2 minutes)

**Open Finder** (press Cmd+Space, type "Finder")

1. Navigate to: `/Users/anhnm/dev/03.Claude/NotchIsland/`
2. You'll see Views/ and Managers/ folders with .swift files

**Drag files to Xcode:**

### Add Views:
- Select ALL 6 files in the `Views/` folder
- Drag them onto the **Views** group in Xcode
- ✅ Check "Copy items if needed"
- ✅ Check "NotchIsland" under "Add to targets"
- Click **Finish**

### Add Managers:
- Select ALL 5 files in the `Managers/` folder
- Drag them onto the **Managers** group in Xcode
- ✅ Check "Copy items if needed"
- ✅ Check "NotchIsland" target
- Click **Finish**

### Add Root Files:
- Drag `NotchWindow.swift` → Drop on `NotchIsland` folder (not in Views/Managers)
- Drag `Info.plist` → Drop on `NotchIsland` folder (replace if asked)
- Drag `NotchIsland.entitlements` → Drop on `NotchIsland` folder

### Replace Main App File:
- In Xcode, **DELETE** the existing `NotchIslandApp.swift`
- From Finder, drag YOUR `NotchIslandApp.swift` to Xcode's `NotchIsland` folder
- ✅ Check "Copy items" and target

---

## Step 7: Link Frameworks (1 minute)

1. Click the **blue project icon** (top of Navigator)
2. Make sure **NotchIsland** is selected under TARGETS (not PROJECT)
3. Click **General** tab
4. Scroll down to **Frameworks, Libraries, and Embedded Content**
5. Click the **+** button
6. Search for `EventKit` → Select `EventKit.framework` → Click **Add**
7. Click **+** again → Search `CoreLocation` → Add `CoreLocation.framework`
8. Click **+** again → Search `Carbon` → Add `Carbon.framework`

You should see 3 frameworks listed.

---

## Step 8: Configure Capabilities (1 minute)

1. Click **Signing & Capabilities** tab (next to General)
2. Look for **App Sandbox** - if you see it, click the **X** to remove it
3. Click **+ Capability** button (top left of pane)
4. Search and add: **Calendar** (click it)
5. Click **+ Capability** again
6. Search and add: **Location**
7. Click **+ Capability** again
8. Search and add: **Apple Events**

---

## Step 9: Set Minimum macOS Version (10 seconds)

1. Still in **General** tab
2. Find **Minimum Deployments**
3. Change to **macOS 13.0** (if not already)

---

## Step 10: Get Weather API Key (2 minutes)

1. Open browser: https://openweathermap.org/api
2. Click **Sign Up** (free)
3. Fill in email, username, password
4. Verify email
5. Go to **API Keys** section
6. Copy your API key

**Back in Xcode:**
7. Open `Managers/WeatherManager.swift`
8. Find line 119: `private let apiKey = "YOUR_API_KEY"`
9. Replace `YOUR_API_KEY` with your actual key (keep the quotes)
10. Press **Cmd+S** to save

---

## Step 11: BUILD & RUN! 🚀

1. At the top of Xcode, make sure run destination shows **My Mac**
2. Press **Cmd+R** (or click the Play ▶ button)

**Wait for build (30 seconds)...**

### First Launch:
- System will show Accessibility permission dialog
- Click **Open System Settings**
- Find **NotchIsland** in the list
- Toggle it **ON**
- Close System Settings
- Go back to Xcode, press **Cmd+Q** to quit the app
- Press **Cmd+R** to run again

### Second Launch:
- **Menu bar icon appears!** (hexagon, top right)
- **Hover your mouse over the notch** → Island appears! 🎉

---

## ✅ SUCCESS!

If you see the island appear, congratulations! You now have:
- 🎵 Music widget (play something in Apple Music/Spotify)
- 🌤️ Weather widget (if you added API key)
- ⌨️ Keyboard shortcut (Ctrl+Option+N)
- 🎨 4 themes (Settings → Appearance)

---

## 🐛 If Build Fails

**"Cannot find Carbon":**
→ Go back to Step 7, make sure Carbon.framework is added

**"Cannot find type X":**
→ Make sure ALL files have the NotchIsland target checked
→ Select each file → File Inspector (right panel) → Check target

**Other errors:**
→ Read the error message carefully
→ Google the error
→ Check BUILD_CHECKLIST.md for troubleshooting

---

**🎉 You're building your Dynamic Island!**

Follow these steps carefully and you'll have it running in 5 minutes!
