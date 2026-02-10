//
//  SettingsView.swift
//  NotchIsland
//
//  Settings and preferences
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("hoverSensitivity") private var hoverSensitivity: Double = 50
    @AppStorage("autoHideDelay") private var autoHideDelay: Double = 0.5
    @AppStorage("enableMusicWidget") private var enableMusicWidget = true
    @AppStorage("enableCalendarWidget") private var enableCalendarWidget = true
    @AppStorage("enableWeatherWidget") private var enableWeatherWidget = true

    var body: some View {
        TabView {
            GeneralSettingsView(
                launchAtLogin: $launchAtLogin,
                hoverSensitivity: $hoverSensitivity,
                autoHideDelay: $autoHideDelay
            )
            .tabItem {
                Label("General", systemImage: "gear")
            }

            WidgetSettingsView(
                enableMusicWidget: $enableMusicWidget,
                enableCalendarWidget: $enableCalendarWidget,
                enableWeatherWidget: $enableWeatherWidget
            )
            .tabItem {
                Label("Widgets", systemImage: "square.grid.3x3")
            }

            AppearanceSettingsView()
                .tabItem {
                    Label("Appearance", systemImage: "paintbrush")
                }

            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 500, height: 400)
    }
}

struct GeneralSettingsView: View {
    @Binding var launchAtLogin: Bool
    @Binding var hoverSensitivity: Double
    @Binding var autoHideDelay: Double
    @StateObject private var shortcutManager = KeyboardShortcutManager.shared

    var body: some View {
        Form {
            Section {
                Toggle("Launch at Login", isOn: $launchAtLogin)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Hover Sensitivity")
                        .font(.headline)

                    HStack {
                        Text("Low")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Slider(value: $hoverSensitivity, in: 20...100, step: 10)

                        Text("High")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Text("Controls how close your mouse needs to be to the notch")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Auto-Hide Delay")
                        .font(.headline)

                    HStack {
                        Text("Instant")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Slider(value: $autoHideDelay, in: 0...2, step: 0.1)

                        Text("2s")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Text("Delay before the island disappears: \(String(format: "%.1f", autoHideDelay))s")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Keyboard Shortcut")
                        .font(.headline)

                    HStack {
                        Text("Toggle Island")

                        Spacer()

                        ShortcutRecorderView()

                        Button("Reset") {
                            shortcutManager.resetToDefault()
                        }
                        .font(.caption)
                    }

                    Text("Press the shortcut key combination to show/hide the island")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Permissions")
                        .font(.headline)

                    Button("Open Accessibility Settings") {
                        openAccessibilitySettings()
                    }

                    Button("Open Calendar Settings") {
                        openCalendarSettings()
                    }
                }
            }
        }
        .padding()
    }

    func openAccessibilitySettings() {
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
    }

    func openCalendarSettings() {
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars")!)
    }
}

struct ShortcutRecorderView: View {
    @StateObject private var shortcutManager = KeyboardShortcutManager.shared

    var body: some View {
        Button(action: {
            shortcutManager.isRecording.toggle()
        }) {
            Text(shortcutManager.isRecording ? "Press shortcut..." : shortcutManager.currentShortcut.displayString)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(shortcutManager.isRecording ? .accentColor : .primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(shortcutManager.isRecording ? Color.accentColor : Color.secondary.opacity(0.5), lineWidth: 1)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(shortcutManager.isRecording ? Color.accentColor.opacity(0.1) : Color.clear)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
        .background(ShortcutRecorderNSViewRepresentable(shortcutManager: shortcutManager))
    }
}

struct ShortcutRecorderNSViewRepresentable: NSViewRepresentable {
    @ObservedObject var shortcutManager: KeyboardShortcutManager

    func makeNSView(context: Context) -> ShortcutRecorderNSView {
        let view = ShortcutRecorderNSView()
        view.shortcutManager = shortcutManager
        return view
    }

    func updateNSView(_ nsView: ShortcutRecorderNSView, context: Context) {
        nsView.shortcutManager = shortcutManager
    }
}

class ShortcutRecorderNSView: NSView {
    var shortcutManager: KeyboardShortcutManager?

    override var acceptsFirstResponder: Bool { true }

    override func keyDown(with event: NSEvent) {
        if let manager = shortcutManager, manager.isRecording {
            manager.recordShortcut(from: event)
        } else {
            super.keyDown(with: event)
        }
    }
}

struct WidgetSettingsView: View {
    @Binding var enableMusicWidget: Bool
    @Binding var enableCalendarWidget: Bool
    @Binding var enableWeatherWidget: Bool

    var body: some View {
        Form {
            Section("Available Widgets") {
                Toggle("Music Playback", isOn: $enableMusicWidget)
                    .help("Show currently playing music with playback controls")

                Toggle("Calendar Events", isOn: $enableCalendarWidget)
                    .help("Display upcoming calendar events")

                Toggle("Weather", isOn: $enableWeatherWidget)
                    .help("Show current weather and forecast for your location")
            }

            Section("Weather Settings") {
                HStack {
                    Text("Location Status")
                    Spacer()
                    Text(WeatherManager.shared.locationStatus.description)
                        .foregroundColor(.secondary)
                }

                Button("Open Location Settings") {
                    NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices")!)
                }
            }
        }
        .padding()
    }
}

struct AppearanceSettingsView: View {
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        Form {
            Section("Theme") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Choose a theme for the island overlay")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack(spacing: 12) {
                        ForEach(NotchTheme.all, id: \.name) { theme in
                            ThemePreviewCard(
                                theme: theme,
                                isSelected: themeManager.currentTheme == theme
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    themeManager.setTheme(theme)
                                }
                            }
                        }
                    }
                }
            }

            Section("Preview") {
                ThemeLivePreview()
                    .frame(height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .padding()
    }
}

struct ThemePreviewCard: View {
    let theme: NotchTheme
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(previewBackground)
                    .frame(width: 80, height: 50)
                    .overlay(
                        VStack(spacing: 4) {
                            Circle()
                                .fill(theme.primaryText)
                                .frame(width: 8, height: 8)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(theme.secondaryText)
                                .frame(width: 30, height: 4)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(theme.cardBackground)
                                .frame(width: 50, height: 10)
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                    )

                Text(theme.name)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .accentColor : .secondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var previewBackground: Color {
        switch theme.name {
        case "Dark": return Color(white: 0.15)
        case "Light": return Color(white: 0.92)
        case "Midnight": return Color(red: 0.1, green: 0.12, blue: 0.2)
        case "Sunset": return Color(red: 0.25, green: 0.12, blue: 0.08)
        default: return Color(white: 0.15)
        }
    }
}

struct ThemeLivePreview: View {
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        ZStack {
            previewBackground
            HStack(spacing: 16) {
                // Simulated tab
                HStack(spacing: 8) {
                    Text("Music")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(themeManager.currentTheme.primaryText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(themeManager.currentTheme.selectedTabBackground)
                        )
                    Text("Calendar")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(themeManager.currentTheme.secondaryText)
                }

                Spacer()

                // Simulated content
                VStack(alignment: .leading, spacing: 4) {
                    Text("Song Title")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(themeManager.currentTheme.primaryText)
                    Text("Artist Name")
                        .font(.system(size: 10))
                        .foregroundColor(themeManager.currentTheme.secondaryText)
                }

                // Simulated controls
                HStack(spacing: 10) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.currentTheme.controlAccent)
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(themeManager.currentTheme.controlAccent)
                    Image(systemName: "forward.fill")
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.currentTheme.controlAccent)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var previewBackground: Color {
        switch themeManager.currentTheme.name {
        case "Dark": return Color(white: 0.15)
        case "Light": return Color(white: 0.92)
        case "Midnight": return Color(red: 0.1, green: 0.12, blue: 0.2)
        case "Sunset": return Color(red: 0.25, green: 0.12, blue: 0.08)
        default: return Color(white: 0.15)
        }
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "circle.hexagongrid.fill")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)

            VStack(spacing: 8) {
                Text("NotchIsland")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Version 1.0.0")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Text("Dynamic Island experience for your Mac")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            Spacer()

            VStack(spacing: 8) {
                Text("Created with Claude")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("© 2026")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SettingsView()
}
