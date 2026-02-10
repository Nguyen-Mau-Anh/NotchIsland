# NotchIsland 🏝️

A Dynamic Island experience for your MacBook Pro's notch. Hover over the notch to reveal customizable widgets including music controls, calendar events, and more!

![NotchIsland Demo](preview.png)

## Features

✨ **Smart Hover Detection** - Automatically appears when you hover near the notch
🎵 **Music Controls** - Control Apple Music or Spotify with play/pause/skip controls
📅 **Calendar Integration** - See your upcoming events at a glance
🎨 **Beautiful UI** - Smooth animations and blur effects matching macOS design
⚙️ **Customizable** - Configure widgets, sensitivity, and behavior
🚀 **Lightweight** - Runs as a menu bar app with minimal system impact

## Requirements

- macOS 13.0 (Ventura) or later
- MacBook Pro with a notch (14" or 16" from 2021+)
- Xcode 15.0 or later (for building)
- Swift 5.9+

## Installation

### Option 1: Build from Source

1. **Download the project files**
   - All source files are in the `NotchIsland` folder

2. **Create a new Xcode project**
   ```
   - Open Xcode
   - Create a new macOS App project
   - Choose SwiftUI for Interface
   - Set Product Name to "NotchIsland"
   - Set Bundle Identifier to "com.yourname.NotchIsland"
   ```

3. **Add the source files**
   - Delete the default ContentView.swift file
   - Drag all the project files into Xcode:
     - NotchIslandApp.swift (main app file)
     - NotchWindow.swift
     - Views/ folder (all view files)
     - Managers/ folder (MusicManager, CalendarManager)
     - Info.plist
     - NotchIsland.entitlements

4. **Configure project settings**
   - Select your project in the navigator
   - Go to "Signing & Capabilities"
   - Add your Apple Developer account (or use "Sign to Run Locally")
   - Set Minimum Deployment to macOS 13.0
   - Add the entitlements file if not already added

5. **Add required capabilities**
   - In "Signing & Capabilities" tab, ensure:
     - App Sandbox is DISABLED (see entitlements file)
     - Calendar access is enabled
     - Apple Events is enabled

6. **Build and run**
   - Press Cmd+R to build and run
   - The app will appear in your menu bar

## Project Structure

```
NotchIsland/
├── NotchIslandApp.swift          # Main app entry point
├── NotchWindow.swift              # Floating window management
├── Views/
│   ├── NotchIslandView.swift     # Main island interface
│   ├── MusicWidgetView.swift     # Music player widget
│   ├── CalendarWidgetView.swift  # Calendar events widget
│   ├── CustomWidgetView.swift    # Custom widgets area
│   └── SettingsView.swift        # Settings interface
├── Managers/
│   ├── MusicManager.swift        # Music integration (AppleScript)
│   └── CalendarManager.swift     # Calendar integration (EventKit)
├── Info.plist                     # App metadata and permissions
└── NotchIsland.entitlements       # Required capabilities
```

## How It Works

### Architecture

1. **App Delegate** (`NotchIslandApp.swift`)
   - Runs as a menu bar app (no dock icon)
   - Monitors global mouse events
   - Calculates notch position
   - Shows/hides window based on hover

2. **Notch Window** (`NotchWindow.swift`)
   - Borderless, floating window
   - Positioned just below the notch
   - Smooth fade in/out animations
   - Always on top of other windows

3. **Widget System**
   - SwiftUI-based modular widgets
   - Tab-based navigation
   - Auto-refreshing data
   - Extensible for custom widgets

4. **Music Integration** (`MusicManager.swift`)
   - Uses AppleScript to control Music.app and Spotify
   - Polls for current track every 2 seconds
   - Provides playback controls
   - Fetches track metadata and artwork

5. **Calendar Integration** (`CalendarManager.swift`)
   - Uses EventKit framework
   - Requests calendar permissions
   - Fetches events for next 7 days
   - Auto-refreshes every 5 minutes

### Key Technologies

- **SwiftUI** - Modern UI framework
- **AppKit** - Window management and system integration
- **EventKit** - Calendar access
- **AppleScript** - Music app control
- **NSEvent Global Monitoring** - Mouse position tracking

## Permissions

The app requires these permissions:

### Accessibility Access
**Required for:** Detecting mouse position globally
**How to grant:**
1. System Settings → Privacy & Security → Accessibility
2. Enable NotchIsland

### Calendar Access
**Required for:** Displaying upcoming events
**How to grant:** The app will prompt you automatically

### Automation (AppleScript)
**Required for:** Controlling Music.app and Spotify
**How to grant:** The app will prompt when first accessing music apps

## Usage

1. **Launch the app**
   - Find NotchIsland in your menu bar (hexagon icon)
   - It will start monitoring your mouse position

2. **Hover over the notch**
   - Move your mouse near the top center of your screen
   - The Dynamic Island will smoothly appear

3. **Switch widgets**
   - Click the tabs (Music, Calendar, Custom)
   - Each widget updates automatically

4. **Configure settings**
   - Click the menu bar icon → Settings
   - Adjust hover sensitivity, auto-hide delay
   - Enable/disable specific widgets

## Troubleshooting

### The island doesn't appear when hovering

**Solution:**
- Grant Accessibility permissions
- Check System Settings → Privacy & Security → Accessibility
- Make sure NotchIsland is enabled

### Music controls don't work

**Solution:**
- Grant Automation permissions for Music.app or Spotify
- System Settings → Privacy & Security → Automation
- Enable NotchIsland to control your music apps

### No calendar events showing

**Solution:**
- Grant Calendar access
- Click "Grant Access" in the Calendar widget
- Or go to System Settings → Privacy & Security → Calendars

### Window appears in wrong position

**Solution:**
- Restart the app
- Make sure you're using a MacBook Pro with a notch
- The app automatically calculates notch position

## Customization

### Adjusting Hover Sensitivity

In `NotchIslandApp.swift`, modify the `hoverRect.insetBy()` values:

```swift
let hoverRect = notchRect.insetBy(dx: -50, dy: -20)
// Increase dx/dy for larger hover area
// Decrease for smaller hover area
```

### Changing Window Size

In `NotchWindow.swift`, adjust the dimensions:

```swift
let windowWidth: CGFloat = 400  // Change width
let windowHeight: CGFloat = 200 // Change height
```

### Adding Custom Widgets

1. Create a new SwiftUI view in `Views/`
2. Add a new case to `WidgetType` enum in `NotchIslandView.swift`
3. Add the view to the switch statement
4. Implement your custom widget logic

### Changing Animation Speed

In `NotchWindow.swift`, modify animation duration:

```swift
context.duration = 0.3  // Show animation (seconds)
context.duration = 0.2  // Hide animation (seconds)
```

## Development Tips

### For Beginners

1. **Start with the basics**
   - Open the project in Xcode
   - Read through `NotchIslandApp.swift` first
   - Understand the app lifecycle

2. **Test incrementally**
   - Build and run frequently
   - Test each widget individually
   - Use print statements for debugging

3. **Understand SwiftUI**
   - Learn about @State and @StateObject
   - Understand how views update automatically
   - Practice with SwiftUI tutorials

### Advanced Features to Add

- [ ] Weather widget
- [ ] System stats (CPU, memory)
- [ ] Notifications integration
- [ ] Customizable themes
- [ ] Keyboard shortcuts
- [ ] Multiple island layouts
- [ ] Widget marketplace

## Known Issues

1. **Artwork not loading** - Simplified implementation doesn't fetch album art yet
2. **Multiple monitors** - Currently only works on main display
3. **Fullscreen apps** - Island may not appear over some fullscreen apps

## Contributing

This is an educational project! Feel free to:
- Add new widgets
- Improve the UI
- Fix bugs
- Optimize performance
- Add features

## License

This project is provided as-is for educational purposes.

## Credits

- Built with guidance from Claude (Anthropic)
- Inspired by Apple's Dynamic Island on iPhone
- Based on the Alcove app concept

## Support

If you need help:
1. Check the troubleshooting section
2. Review Apple's documentation for SwiftUI and AppKit
3. Search for specific error messages

## Version History

### 1.0.0 (February 2026)
- Initial release
- Music widget (Apple Music & Spotify)
- Calendar widget (EventKit integration)
- Hover detection system
- Settings panel
- Beautiful animations

---

**Enjoy your Dynamic Island experience!** 🏝️✨
