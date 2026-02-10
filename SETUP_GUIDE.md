# NotchIsland - Quick Setup Guide

## Step-by-Step Installation for Beginners

### Prerequisites

Before you begin, make sure you have:
- ✅ A MacBook Pro with a notch (14" or 16" from 2021 or later)
- ✅ macOS Ventura (13.0) or later
- ✅ Xcode installed (free from the Mac App Store)

### Step 1: Install Xcode

1. Open the **Mac App Store**
2. Search for "Xcode"
3. Click **Get** or **Install** (it's free, but large ~15GB)
4. Wait for installation to complete (may take 30-60 minutes)

### Step 2: Create New Xcode Project

1. **Open Xcode**
2. Click **Create New Project** (or File → New → Project)
3. Choose **macOS** tab at the top
4. Select **App** template
5. Click **Next**

6. **Configure your project:**
   - Product Name: `NotchIsland`
   - Team: Select your Apple ID (or "None" for local testing)
   - Organization Identifier: `com.yourname` (use your name)
   - Interface: **SwiftUI** (important!)
   - Language: **Swift**
   - Storage: **None**
   - ✅ Uncheck "Create Git repository"
   - ✅ Uncheck "Create Tests"

7. Click **Next**
8. Choose a location to save the project
9. Click **Create**

### Step 3: Prepare Your Project

1. **In the left sidebar (Project Navigator):**
   - Find and **delete** the file `ContentView.swift`
   - Right-click on `NotchIsland` folder
   - Choose **New Group** and name it `Views`
   - Create another group named `Managers`

2. **Your structure should look like:**
   ```
   NotchIsland/
   ├── NotchIslandApp.swift (keep this)
   ├── Views/ (new folder you created)
   └── Managers/ (new folder you created)
   ```

### Step 4: Add Source Files

Now, copy the files you received into Xcode:

#### Main App Files (add to NotchIsland root):
1. **Drag and drop these files:**
   - `NotchWindow.swift`
   - `Info.plist` (replace the existing one if prompted)
   - `NotchIsland.entitlements`

2. **Replace `NotchIslandApp.swift`:**
   - Delete the existing one
   - Drag the new `NotchIslandApp.swift` into Xcode

#### View Files (add to Views folder):
Drag these files into the **Views** folder:
- `NotchIslandView.swift`
- `MusicWidgetView.swift`
- `CalendarWidgetView.swift`
- `CustomWidgetView.swift`
- `SettingsView.swift`

#### Manager Files (add to Managers folder):
Drag these files into the **Managers** folder:
- `MusicManager.swift`
- `CalendarManager.swift`

**When dragging files, make sure:**
- ✅ "Copy items if needed" is checked
- ✅ "Create groups" is selected
- ✅ NotchIsland target is checked

### Step 5: Configure Project Settings

1. **Click on the project name** (blue icon) in the left sidebar
2. Make sure **NotchIsland** (under TARGETS) is selected

3. **General Tab:**
   - Minimum Deployments: **macOS 13.0**
   - Identity section should show your bundle identifier

4. **Signing & Capabilities Tab:**
   - If you see "Signing for NotchIsland requires a development team"
   - Click **Add Account** and sign in with your Apple ID
   - Or select **"Sign to Run Locally"** if you don't have a developer account

5. **Still in Signing & Capabilities:**
   - Look for **App Sandbox** capability
   - If it exists, **REMOVE IT** (click the X)
   - The app needs to run without sandbox

### Step 6: Add Required Frameworks

1. **Still in project settings, General tab**
2. Scroll down to **Frameworks, Libraries, and Embedded Content**
3. Click the **+** button
4. Search for and add:
   - `EventKit.framework`
   - `AppKit.framework` (should already be there)

### Step 7: Verify Info.plist

1. Click on `Info.plist` in the project navigator
2. Make sure these keys exist:
   - `NSCalendarsUsageDescription`
   - `NSAppleEventsUsageDescription`
   - `LSUIElement` (should be `true`)

If they're missing, the provided Info.plist should have them.

### Step 8: Build and Run!

1. **Select your Mac as the run destination:**
   - At the top of Xcode, next to the Play button
   - Click the device selector
   - Choose "My Mac"

2. **Click the Play button** (▶) or press **Cmd+R**

3. **First build will take 1-2 minutes**
   - Xcode is compiling all the code
   - You'll see progress in the top center

4. **If build succeeds:**
   - Look for the hexagon icon in your menu bar (top right)
   - That's NotchIsland running! 🎉

### Step 9: Grant Permissions

When you first run the app:

1. **Accessibility Permission:**
   - You'll see a dialog about Accessibility
   - Click **Open System Settings**
   - Enable NotchIsland in the list
   - Restart the app

2. **Calendar Permission:**
   - Click the Calendar tab in the island
   - Click **Grant Access**
   - Allow when prompted

3. **Music Control Permission:**
   - Open Apple Music or Spotify
   - Play a song
   - When you interact with controls, allow automation

### Step 10: Test It Out!

1. **Play some music** in Apple Music or Spotify
2. **Move your mouse to the top center of your screen** (the notch area)
3. **The island should appear!** 🏝️
4. Try clicking between Music, Calendar, and Custom tabs

## Troubleshooting Common Issues

### "Build Failed" Error

**Check these:**
1. Make sure all files are added to the NotchIsland target
2. Check that SwiftUI is selected (not UIKit)
3. Minimum deployment is set to macOS 13.0
4. All files are properly imported

### "Cannot find type 'X' in scope"

**Solution:**
- Make sure all files are added to the project
- Clean the build folder: Product → Clean Build Folder (Cmd+Shift+K)
- Build again (Cmd+R)

### "App crashes on launch"

**Solution:**
- Check Console.app for error messages
- Make sure Info.plist has all required keys
- Verify entitlements file is added correctly

### "Island doesn't appear"

**Solution:**
1. Grant Accessibility permissions
2. System Settings → Privacy & Security → Accessibility
3. Find NotchIsland and enable it
4. Restart the app

### "Music widget shows nothing"

**Solution:**
1. Make sure Music.app or Spotify is actually playing
2. Grant Automation permission when prompted
3. Check System Settings → Privacy & Security → Automation

## Next Steps

Once it's working:

1. **Explore the code:**
   - Read through each file
   - Understand how the pieces connect
   - Modify small things and rebuild

2. **Customize it:**
   - Change colors in the view files
   - Adjust hover sensitivity
   - Modify window size

3. **Add features:**
   - Create your own custom widgets
   - Add new data sources
   - Improve the UI

## Learning Resources

- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [AppKit Documentation](https://developer.apple.com/documentation/appkit)
- [EventKit Guide](https://developer.apple.com/documentation/eventkit)
- [Hacking with macOS](https://www.hackingwithswift.com/store/hacking-with-macos)

## Getting Help

If you get stuck:
1. Read error messages carefully
2. Search the error on Google or Stack Overflow
3. Check Apple's documentation
4. Review the README.md for detailed info

## What You've Built

Congratulations! You've created:
- ✅ A real macOS app
- ✅ Global mouse event monitoring
- ✅ Floating window system
- ✅ Music integration with AppleScript
- ✅ Calendar integration with EventKit
- ✅ Beautiful SwiftUI interface
- ✅ Settings and customization

This is a professional-grade app architecture! 🚀

---

**Need more help?** Review the detailed README.md file for architecture explanations and advanced customization options.
