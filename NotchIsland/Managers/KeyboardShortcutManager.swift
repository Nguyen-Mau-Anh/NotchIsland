//
//  KeyboardShortcutManager.swift
//  NotchIsland
//
//  Manages global keyboard shortcuts for toggling the island
//

import SwiftUI
import AppKit
import Carbon.HIToolbox

class KeyboardShortcutManager: ObservableObject {
    static let shared = KeyboardShortcutManager()

    @Published var currentShortcut: KeyboardShortcut
    @Published var isRecording = false

    private var globalMonitor: Any?
    private var localMonitor: Any?
    var onToggle: (() -> Void)?

    private static let shortcutKeyCodeKey = "shortcutKeyCode"
    private static let shortcutModifiersKey = "shortcutModifiers"

    struct KeyboardShortcut: Equatable {
        var keyCode: UInt16
        var modifierFlags: NSEvent.ModifierFlags

        var displayString: String {
            var parts: [String] = []
            if modifierFlags.contains(.control) { parts.append("⌃") }
            if modifierFlags.contains(.option) { parts.append("⌥") }
            if modifierFlags.contains(.shift) { parts.append("⇧") }
            if modifierFlags.contains(.command) { parts.append("⌘") }
            parts.append(keyCodeToString(keyCode))
            return parts.joined()
        }

        static let `default` = KeyboardShortcut(
            keyCode: UInt16(kVK_ANSI_N),
            modifierFlags: [.control, .option]
        )
    }

    private init() {
        let savedKeyCode = UserDefaults.standard.object(forKey: KeyboardShortcutManager.shortcutKeyCodeKey) as? UInt16
        let savedModifiers = UserDefaults.standard.object(forKey: KeyboardShortcutManager.shortcutModifiersKey) as? UInt

        if let keyCode = savedKeyCode, let modifiers = savedModifiers {
            self.currentShortcut = KeyboardShortcut(
                keyCode: keyCode,
                modifierFlags: NSEvent.ModifierFlags(rawValue: modifiers)
            )
        } else {
            self.currentShortcut = .default
        }
    }

    func startMonitoring() {
        stopMonitoring()

        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(event)
        }

        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(event)
            return event
        }
    }

    func stopMonitoring() {
        if let monitor = globalMonitor {
            NSEvent.removeMonitor(monitor)
            globalMonitor = nil
        }
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
            localMonitor = nil
        }
    }

    private func handleKeyEvent(_ event: NSEvent) {
        if isRecording {
            return
        }

        let cleanFlags = event.modifierFlags.intersection([.control, .option, .shift, .command])

        if event.keyCode == currentShortcut.keyCode &&
           cleanFlags == currentShortcut.modifierFlags {
            DispatchQueue.main.async {
                self.onToggle?()
            }
        }
    }

    func recordShortcut(from event: NSEvent) {
        let cleanFlags = event.modifierFlags.intersection([.control, .option, .shift, .command])

        guard !cleanFlags.isEmpty else { return }

        let newShortcut = KeyboardShortcut(
            keyCode: event.keyCode,
            modifierFlags: cleanFlags
        )

        currentShortcut = newShortcut
        isRecording = false

        UserDefaults.standard.set(newShortcut.keyCode, forKey: KeyboardShortcutManager.shortcutKeyCodeKey)
        UserDefaults.standard.set(newShortcut.modifierFlags.rawValue, forKey: KeyboardShortcutManager.shortcutModifiersKey)
    }

    func resetToDefault() {
        currentShortcut = .default
        UserDefaults.standard.set(KeyboardShortcut.default.keyCode, forKey: KeyboardShortcutManager.shortcutKeyCodeKey)
        UserDefaults.standard.set(KeyboardShortcut.default.modifierFlags.rawValue, forKey: KeyboardShortcutManager.shortcutModifiersKey)
    }

    deinit {
        stopMonitoring()
    }
}

private func keyCodeToString(_ keyCode: UInt16) -> String {
    switch Int(keyCode) {
    case kVK_ANSI_A: return "A"
    case kVK_ANSI_S: return "S"
    case kVK_ANSI_D: return "D"
    case kVK_ANSI_F: return "F"
    case kVK_ANSI_H: return "H"
    case kVK_ANSI_G: return "G"
    case kVK_ANSI_Z: return "Z"
    case kVK_ANSI_X: return "X"
    case kVK_ANSI_C: return "C"
    case kVK_ANSI_V: return "V"
    case kVK_ANSI_B: return "B"
    case kVK_ANSI_Q: return "Q"
    case kVK_ANSI_W: return "W"
    case kVK_ANSI_E: return "E"
    case kVK_ANSI_R: return "R"
    case kVK_ANSI_Y: return "Y"
    case kVK_ANSI_T: return "T"
    case kVK_ANSI_1: return "1"
    case kVK_ANSI_2: return "2"
    case kVK_ANSI_3: return "3"
    case kVK_ANSI_4: return "4"
    case kVK_ANSI_6: return "6"
    case kVK_ANSI_5: return "5"
    case kVK_ANSI_9: return "9"
    case kVK_ANSI_7: return "7"
    case kVK_ANSI_8: return "8"
    case kVK_ANSI_0: return "0"
    case kVK_ANSI_O: return "O"
    case kVK_ANSI_U: return "U"
    case kVK_ANSI_I: return "I"
    case kVK_ANSI_P: return "P"
    case kVK_ANSI_L: return "L"
    case kVK_ANSI_J: return "J"
    case kVK_ANSI_K: return "K"
    case kVK_ANSI_N: return "N"
    case kVK_ANSI_M: return "M"
    case kVK_Return: return "↩"
    case kVK_Tab: return "⇥"
    case kVK_Space: return "Space"
    case kVK_Delete: return "⌫"
    case kVK_Escape: return "⎋"
    case kVK_F1: return "F1"
    case kVK_F2: return "F2"
    case kVK_F3: return "F3"
    case kVK_F4: return "F4"
    case kVK_F5: return "F5"
    case kVK_F6: return "F6"
    case kVK_F7: return "F7"
    case kVK_F8: return "F8"
    case kVK_F9: return "F9"
    case kVK_F10: return "F10"
    case kVK_F11: return "F11"
    case kVK_F12: return "F12"
    case kVK_UpArrow: return "↑"
    case kVK_DownArrow: return "↓"
    case kVK_LeftArrow: return "←"
    case kVK_RightArrow: return "→"
    default: return "Key\(keyCode)"
    }
}
