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
    var screenObserver: NSObjectProtocol?
    let shortcutManager = KeyboardShortcutManager.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide from Dock
        NSApp.setActivationPolicy(.accessory)

        // Create menu bar item
        setupMenuBar()

        // Create the notch window
        notchWindow = NotchWindow()

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

    func startMouseMonitoring() {
        mouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { [weak self] event in
            guard let self = self else { return }

            let mouseLocation = NSEvent.mouseLocation

            // Find the screen with the notch (builtin display)
            guard let notchScreen = Self.screenWithNotch() else { return }

            let notchRect = self.getNotchRect(for: notchScreen)

            // Read hover sensitivity from persisted settings (20-100, default 50)
            let sensitivity = UserDefaults.standard.double(forKey: "hoverSensitivity")
            let effectiveSensitivity = sensitivity > 0 ? sensitivity : 50
            // Map sensitivity to hover expansion: 20 → small area, 100 → large area
            let dx = -(effectiveSensitivity * 1.5)  // -30 to -150
            let dy = -(effectiveSensitivity * 0.4)  // -8 to -40
            let hoverRect = notchRect.insetBy(dx: dx, dy: dy)

            if hoverRect.contains(mouseLocation) {
                self.notchWindow?.show(on: notchScreen)
            } else {
                self.notchWindow?.hide()
            }
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

    func applicationWillTerminate(_ notification: Notification) {
        if let monitor = mouseMonitor {
            NSEvent.removeMonitor(monitor)
        }
        if let observer = screenObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        shortcutManager.stopMonitoring()
    }
}
