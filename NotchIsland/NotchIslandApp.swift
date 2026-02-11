//
//  NotchIslandApp.swift
//  NotchIsland - A Dynamic Island experience for your Mac's notch
//
//  Created with Claude
//

import SwiftUI
import AppKit

@main
struct NotchIslandApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var notchWindow: NotchWindow?
    var mouseMonitor: Any?
    var localMouseMonitor: Any?
    var screenObserver: NSObjectProtocol?
    let shortcutManager = KeyboardShortcutManager.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide from Dock
        NSApp.setActivationPolicy(.accessory)

        // Create menu bar item
        setupMenuBar()

        // Create the notch window
        notchWindow = NotchWindow()

        // IMPORTANT: Initialize audio manager early so it starts monitoring immediately
        // Access the shared instance to trigger lazy initialization
        NSLog("[NotchIsland] AppDelegate: About to initialize UniversalAudioManager")
        _ = UniversalAudioManager.shared.currentTrack  // Access a property to force initialization
        NSLog("[NotchIsland] AppDelegate: Initialized UniversalAudioManager")

        // Start monitoring mouse position
        startMouseMonitoring()

        // Start monitoring keyboard shortcuts
        setupKeyboardShortcut()

        // Observe screen configuration changes (monitor connect/disconnect)
        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleScreenChange()
        }

        // Request necessary permissions
        requestPermissions()
    }

    /// Called when monitors are connected or disconnected
    private func handleScreenChange() {
        // Reposition the window on the notch screen
        if let notchScreen = Self.screenWithNotch() {
            let frame = NotchWindow.calculateWindowFrame(for: notchScreen)
            notchWindow?.setFrame(frame, display: true)
        }
    }

    func setupKeyboardShortcut() {
        shortcutManager.onToggle = { [weak self] in
            self?.notchWindow?.toggle()
        }
        shortcutManager.startMonitoring()
    }

    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "circle.hexagongrid.fill", accessibilityDescription: "NotchIsland")
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Toggle Island", action: #selector(toggleIsland), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Test Audio Detection", action: #selector(testAudioDetection), keyEquivalent: "t"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit NotchIsland", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem?.menu = menu
    }

    @objc func toggleIsland() {
        notchWindow?.toggle()
    }

    @objc func openSettings() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func testAudioDetection() {
        // Force an immediate audio detection check
        let audioManager = UniversalAudioManager.shared

        // Show current state
        let alert = NSAlert()
        alert.messageText = "Audio Detection Status"

        if let track = audioManager.currentTrack {
            alert.informativeText = """
            ✅ Audio Detected:

            Title: \(track.title)
            Artist: \(track.displayArtist)
            Source: \(track.source.rawValue)
            Playing: \(audioManager.isPlaying ? "Yes" : "Paused")
            """
            alert.alertStyle = .informational
        } else {
            alert.informativeText = """
            ❌ No Audio Detected

            Make sure:
            • Chrome has a YouTube/Spotify tab open
            • The tab is actively playing
            • NotchIsland has Automation permission for Chrome

            Check: System Settings → Privacy & Security → Automation
            """
            alert.alertStyle = .warning
        }

        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Open Automation Settings")

        let response = alert.runModal()
        if response == .alertSecondButtonReturn {
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation") {
                NSWorkspace.shared.open(url)
            }
        }
    }

    func startMouseMonitoring() {
        // Global monitor: detect mouse movement everywhere (outside our window)
        mouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved, .leftMouseDragged]) { [weak self] event in
            guard let self = self else { return }
            self.handleMousePosition()
        }

        // Local monitor: detect mouse events INSIDE our window (clicks, drags, moves)
        // This prevents the window from hiding when the user interacts with buttons/sliders
        localMouseMonitor = NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved, .leftMouseDown, .leftMouseUp, .leftMouseDragged]) { [weak self] event in
            // Any mouse activity inside the window keeps it visible
            self?.notchWindow?.cancelHideTimer()
            return event
        }
    }

    func getNotchRect(for screen: NSScreen) -> CGRect {
        let screenFrame = screen.frame

        // Use the safe area insets to determine actual notch dimensions if available
        if #available(macOS 12.0, *) {
            let safeInsetTop = screen.safeAreaInsets.top
            if safeInsetTop > 0 {
                // The notch area is centered in the top safe area inset
                // The menu bar safe area is typically the full top inset
                // The notch itself is narrower, but we use a wider hover zone
                let notchWidth: CGFloat = 300
                let notchHeight: CGFloat = safeInsetTop

                return CGRect(
                    x: screenFrame.midX - notchWidth / 2,
                    y: screenFrame.maxY - notchHeight,
                    width: notchWidth,
                    height: notchHeight
                )
            }
        }

        // Fallback: approximate notch dimensions
        let notchWidth: CGFloat = 300
        let notchHeight: CGFloat = 32

        return CGRect(
            x: screenFrame.midX - notchWidth / 2,
            y: screenFrame.maxY - notchHeight,
            width: notchWidth,
            height: notchHeight
        )
    }

    // MARK: - Screen Detection

    /// Finds the screen with the notch (built-in MacBook display)
    static func screenWithNotch() -> NSScreen? {
        if #available(macOS 12.0, *) {
            // On macOS 12+, the built-in display with a notch has safeAreaInsets.top > 0
            // that accounts for the notch area
            for screen in NSScreen.screens {
                if screen.safeAreaInsets.top > 0 {
                    return screen
                }
            }
        }

        // Fallback: try to find the built-in display by checking localizedName
        for screen in NSScreen.screens {
            let name = screen.localizedName.lowercased()
            if name.contains("built-in") || name.contains("retina") || name.contains("macbook") {
                return screen
            }
        }

        // Last resort: use the first screen (main display)
        return NSScreen.screens.first
    }

    func requestPermissions() {
        // Request calendar access
        CalendarManager.shared.requestAccess()

        // Show alert for accessibility permissions if needed
        checkAccessibilityPermissions()
    }

    func checkAccessibilityPermissions() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)

        if !accessEnabled {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let alert = NSAlert()
                alert.messageText = "Accessibility Access Required"
                alert.informativeText = "NotchIsland needs accessibility permissions to detect when you hover over the notch. Please enable it in System Settings > Privacy & Security > Accessibility."
                alert.alertStyle = .informational
                alert.addButton(withTitle: "OK")
                alert.runModal()
            }
        }
    }

    // MARK: - Mouse Position Handler

    private func handleMousePosition() {
        let mouseLocation = NSEvent.mouseLocation

        // Find the screen with the notch (builtin display)
        guard let notchScreen = Self.screenWithNotch() else { return }

        let notchRect = self.getNotchRect(for: notchScreen)

        // Read hover sensitivity from persisted settings (20-100, default 50)
        let sensitivity = UserDefaults.standard.double(forKey: "hoverSensitivity")
        let effectiveSensitivity = sensitivity > 0 ? sensitivity : 50
        let dx = -(effectiveSensitivity * 1.5)
        let dy = -(effectiveSensitivity * 0.4)
        let hoverRect = notchRect.insetBy(dx: dx, dy: dy)

        // Also check if mouse is inside the window itself (keeps it open during interaction)
        let isInHoverZone = hoverRect.contains(mouseLocation)
        let isInWindow = notchWindow?.frame.contains(mouseLocation) ?? false

        if isInHoverZone || isInWindow {
            self.notchWindow?.show(on: notchScreen)
        } else {
            self.notchWindow?.hide()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let monitor = mouseMonitor {
            NSEvent.removeMonitor(monitor)
        }
        if let monitor = localMouseMonitor {
            NSEvent.removeMonitor(monitor)
        }
        if let observer = screenObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        shortcutManager.stopMonitoring()
    }
}
