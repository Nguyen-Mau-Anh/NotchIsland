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
        self.hasShadow = true
        self.level = .statusBar
        self.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
        self.isMovableByWindowBackground = false

        // Set the SwiftUI content
        self.contentView = NSHostingView(rootView: NotchIslandView())

        // Initially hidden
        self.alphaValue = 0
        self.orderOut(nil)
    }

    /// Calculate window frame positioned on the given screen (or fallback to notch/first screen)
    static func calculateWindowFrame(for screen: NSScreen? = nil) -> CGRect {
        guard let screen = screen ?? AppDelegate.screenWithNotch() ?? NSScreen.screens.first else {
            return CGRect(x: 0, y: 0, width: 400, height: 200)
        }

        let screenFrame = screen.frame
        let windowWidth: CGFloat = 400
        let windowHeight: CGFloat = 200

        // Use safe area insets to determine offset below notch if available
        var topOffset: CGFloat = 40
        if #available(macOS 12.0, *) {
            if screen.safeAreaInsets.top > 0 {
                topOffset = screen.safeAreaInsets.top + 8
            }
        }

        // Position just below the notch
        return CGRect(
            x: screenFrame.midX - windowWidth / 2,
            y: screenFrame.maxY - windowHeight - topOffset,
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
