# NotchIsland 🏝️

<div align="center">

**Bring iPhone's Dynamic Island to your MacBook's notch**

A beautiful, native macOS menu bar app that transforms your MacBook's notch into a functional Dynamic Island with real-time music, calendar, and weather information.

[![macOS](https://img.shields.io/badge/macOS-13.0+-blue.svg)](https://www.apple.com/macos)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

</div>

## ✨ Features

### 🎵 Universal Audio Detection
- **Apple Music** - Full integration with artwork, title, artist, and playback controls
- **Spotify** - Native support with album art and track information
- **Browser Audio** - Detects music from Chrome, Safari, and Arc (YouTube, Spotify Web, SoundCloud, etc.)
- **Real-time Updates** - Automatic detection every 2 seconds
- **Play/Pause Control** - Click to control playback directly from the island

### 📅 Calendar Integration
- View upcoming events at a glance
- Automatic calendar access with permission handling
- Clean, minimal event display

### 🌤️ Weather Widget
- Current weather conditions
- Temperature display
- Location-based updates

### 🎨 Customization
- **Theme System** - Multiple color themes (dark, light, custom)
- **Widget Toggles** - Enable/disable individual widgets
- **Hover Sensitivity** - Adjustable activation area (20-100)
- **Auto-hide Delay** - Configurable fade-out timing (0.5-2.0s)

### ⌨️ Keyboard Shortcuts
- **Ctrl + Option + N** - Toggle island visibility

### 🖥️ Multi-Monitor Support
- Automatically detects screen with notch
- Handles monitor connect/disconnect events
- Perfect positioning on MacBook displays

## 🚀 Installation

### Requirements
- macOS 13.0 (Ventura) or later
- MacBook with notch (14" or 16" MacBook Pro)
- Xcode 15.0+ (for building from source)

### Build from Source

1. **Clone the repository**
   \`\`\`bash
   git clone https://github.com/Nguyen-Mau-Anh/NotchIsland.git
   cd NotchIsland
   \`\`\`

2. **Open in Xcode**
   \`\`\`bash
   open NotchIsland.xcodeproj
   \`\`\`

3. **Build and Run**
   - Select **NotchIsland** scheme
   - Press \`Cmd + R\` to build and run
   - The app will appear in your menu bar as a hexagon icon

4. **Grant Permissions**
   - **Accessibility**: Required for mouse hover detection
   - **Calendar**: Optional, for calendar widget
   - **Automation**: Required for browser audio detection
     - Go to: \`System Settings → Privacy & Security → Automation\`
     - Enable NotchIsland to control Chrome/Safari

## 📖 Usage

### Basic Operation
1. **Hover over the notch** - The island automatically appears
2. **Move mouse away** - Island fades out after configured delay
3. **Click menu bar icon** - Access settings and controls
4. **Press Ctrl+Option+N** - Toggle island manually

### Testing Audio Detection
1. Click the **hexagon icon** in the menu bar
2. Select **"Test Audio Detection"**
3. See current audio status and troubleshoot issues

## 🐛 Troubleshooting

### Chrome Audio Not Detected?
1. Check automation permissions: \`System Settings → Privacy & Security → Automation\`
2. Ensure NotchIsland can control Google Chrome
3. Use "Test Audio Detection" from menu bar

### Content Hidden Behind Notch?
- The app automatically calculates notch height
- Tested on 14" and 16" MacBook Pro models

## 📝 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- Inspired by iPhone's Dynamic Island
- Built with [Claude](https://claude.ai) assistance

---

<div align="center">

**⭐ Star this repo if you find it useful! ⭐**

Made with ❤️ and ☕

</div>
