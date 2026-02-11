//
//  NotchWindow.swift
//  NotchIsland
//
//  Manages the floating window that appears over the notch
//

import SwiftUI
import AppKit

class NotchWindow: NSWindow {
    private(set) var isCurrentlyShown = false
    private var hideTimer: Timer?

    // Store the actual notch height for the content view
    static var currentNotchHeight: CGFloat {
        if #available(macOS 12.0, *) {
            if let screen = AppDelegate.screenWithNotch() {
                return screen.safeAreaInsets.top
            }
        }
        return 32 // Fallback
    }

    init() {
        // Calculate initial position on the notch screen
        let notchScreen = AppDelegate.screenWithNotch()
        let initialFrame = NotchWindow.calculateWindowFrame(for: notchScreen)

        super.init(
            contentRect: initialFrame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        // Window configuration
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = false  // Remove shadow for seamless integration
        self.level = .statusBar
        self.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
        self.isMovableByWindowBackground = false

        // Set the SwiftUI content with the actual notch height
        self.contentView = NSHostingView(rootView: NotchIslandView())

        // Initially hidden
        self.alphaValue = 0
        self.orderOut(nil)
    }

    /// Calculate window frame positioned on the given screen (or fallback to notch/first screen)
    static func calculateWindowFrame(for screen: NSScreen? = nil) -> CGRect {
        guard let screen = screen ?? AppDelegate.screenWithNotch() ?? NSScreen.screens.first else {
            return CGRect(x: 0, y: 0, width: 500, height: 200)
        }

        let screenFrame = screen.frame
        let windowWidth: CGFloat = 500
        let windowHeight: CGFloat = 200  // Tall enough for volume slider expansion

        // Get the notch/menu bar dimensions
        var notchHeight: CGFloat = 32
        if #available(macOS 12.0, *) {
            if screen.safeAreaInsets.top > 0 {
                notchHeight = screen.safeAreaInsets.top
            }
        }

        // Position so the window extends from BEHIND the notch area
        // We want the top part hidden by the notch, bottom part visible
        // The visible part should be flush with the notch bottom (no gap)
        //
        // With increased height, we need to ensure:
        // 1. Top portion (notchHeight) is behind the notch
        // 2. Bottom portion (windowHeight - notchHeight) is visible below
        // 3. Content starts BELOW the notch area to avoid being hidden
        let yPosition = screenFrame.maxY - windowHeight + (notchHeight - 5)
        // The -5 adjustment eliminates any tiny gap

        return CGRect(
            x: screenFrame.midX - windowWidth / 2,
            y: yPosition,
            width: windowWidth,
            height: windowHeight
        )
    }

    /// Show the window on the specified screen (defaults to notch screen)
    func show(on screen: NSScreen? = nil) {
        guard !isCurrentlyShown else { return }

        isCurrentlyShown = true
        hideTimer?.invalidate()

        // Update position on the correct screen
        self.setFrame(NotchWindow.calculateWindowFrame(for: screen), display: true)

        // Show window with animation
        self.orderFront(nil)

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            self.animator().alphaValue = 1.0
        })
    }

    func hide() {
        guard isCurrentlyShown else { return }

        // Read auto-hide delay from persisted settings (default 0.5s)
        let delay = UserDefaults.standard.double(forKey: "autoHideDelay")
        let hideDelay = delay > 0 ? delay : 0.5

        // Delay hiding to prevent flickering when mouse moves quickly
        hideTimer?.invalidate()
        hideTimer = Timer.scheduledTimer(withTimeInterval: hideDelay, repeats: false) { [weak self] _ in
            guard let self = self else { return }

            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.2
                context.timingFunction = CAMediaTimingFunction(name: .easeIn)
                self.animator().alphaValue = 0
            }, completionHandler: {
                self.orderOut(nil)
                self.isCurrentlyShown = false
            })
        }
    }

    func hideImmediately() {
        hideTimer?.invalidate()
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.2
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            self.animator().alphaValue = 0
        }, completionHandler: {
            self.orderOut(nil)
            self.isCurrentlyShown = false
        })
    }

    func toggle() {
        if isCurrentlyShown {
            hideImmediately()
        } else {
            show()
        }
    }
}
