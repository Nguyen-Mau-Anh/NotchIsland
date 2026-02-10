//
//  ThemeManager.swift
//  NotchIsland
//
//  Manages app themes with light/dark mode support
//

import SwiftUI
import AppKit

// MARK: - Theme Definition

struct NotchTheme: Equatable {
    let name: String
    let primaryText: Color
    let secondaryText: Color
    let tertiaryText: Color
    let background: Color
    let cardBackground: Color
    let selectedTabBackground: Color
    let controlAccent: Color
    let blurMaterial: NSVisualEffectView.Material

    static let dark = NotchTheme(
        name: "Dark",
        primaryText: .white,
        secondaryText: .white.opacity(0.7),
        tertiaryText: .white.opacity(0.5),
        background: .clear,
        cardBackground: .white.opacity(0.1),
        selectedTabBackground: .white.opacity(0.2),
        controlAccent: .white,
        blurMaterial: .hudWindow
    )

    static let light = NotchTheme(
        name: "Light",
        primaryText: .black,
        secondaryText: .black.opacity(0.6),
        tertiaryText: .black.opacity(0.4),
        background: .clear,
        cardBackground: .black.opacity(0.06),
        selectedTabBackground: .black.opacity(0.1),
        controlAccent: .black,
        blurMaterial: .sheet
    )

    static let midnight = NotchTheme(
        name: "Midnight",
        primaryText: Color(red: 0.85, green: 0.9, blue: 1.0),
        secondaryText: Color(red: 0.6, green: 0.7, blue: 0.9),
        tertiaryText: Color(red: 0.45, green: 0.5, blue: 0.7),
        background: .clear,
        cardBackground: Color(red: 0.2, green: 0.25, blue: 0.4).opacity(0.3),
        selectedTabBackground: Color(red: 0.3, green: 0.35, blue: 0.55).opacity(0.4),
        controlAccent: Color(red: 0.5, green: 0.6, blue: 1.0),
        blurMaterial: .hudWindow
    )

    static let sunset = NotchTheme(
        name: "Sunset",
        primaryText: .white,
        secondaryText: Color(red: 1.0, green: 0.85, blue: 0.7),
        tertiaryText: Color(red: 1.0, green: 0.7, blue: 0.5),
        background: .clear,
        cardBackground: Color(red: 0.9, green: 0.4, blue: 0.2).opacity(0.15),
        selectedTabBackground: Color(red: 0.9, green: 0.5, blue: 0.3).opacity(0.25),
        controlAccent: Color(red: 1.0, green: 0.6, blue: 0.3),
        blurMaterial: .hudWindow
    )

    static let all: [NotchTheme] = [.dark, .light, .midnight, .sunset]
}

// MARK: - Theme Manager

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var currentTheme: NotchTheme

    private static let themeNameKey = "selectedThemeName"

    private init() {
        let savedName = UserDefaults.standard.string(forKey: ThemeManager.themeNameKey) ?? "Dark"
        self.currentTheme = NotchTheme.all.first(where: { $0.name == savedName }) ?? .dark
    }

    func setTheme(_ theme: NotchTheme) {
        currentTheme = theme
        UserDefaults.standard.set(theme.name, forKey: ThemeManager.themeNameKey)
    }

    func setThemeByName(_ name: String) {
        if let theme = NotchTheme.all.first(where: { $0.name == name }) {
            setTheme(theme)
        }
    }
}

// MARK: - SwiftUI Environment Key

private struct ThemeEnvironmentKey: EnvironmentKey {
    static let defaultValue: NotchTheme = .dark
}

extension EnvironmentValues {
    var notchTheme: NotchTheme {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}
