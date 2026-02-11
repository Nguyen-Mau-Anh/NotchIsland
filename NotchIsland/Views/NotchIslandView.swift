//
//  NotchIslandView.swift
//  NotchIsland
//
//  Main SwiftUI view for the Dynamic Island interface
//

import SwiftUI

struct NotchIslandView: View {
    @StateObject private var musicManager = MusicManager.shared
    @StateObject private var calendarManager = CalendarManager.shared
    @StateObject private var weatherManager = WeatherManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @State private var selectedWidget: WidgetType = .music

    // Read widget enable/disable toggles from persisted settings
    @AppStorage("enableMusicWidget") private var enableMusicWidget = true
    @AppStorage("enableCalendarWidget") private var enableCalendarWidget = true
    @AppStorage("enableWeatherWidget") private var enableWeatherWidget = true

    enum WidgetType: String, CaseIterable {
        case music = "Music"
        case calendar = "Calendar"
        case weather = "Weather"
        case custom = "Custom"
    }

    /// Returns only the widgets that are currently enabled in settings
    private var enabledWidgets: [WidgetType] {
        WidgetType.allCases.filter { widget in
            switch widget {
            case .music: return enableMusicWidget
            case .calendar: return enableCalendarWidget
            case .weather: return enableWeatherWidget
            case .custom: return true // always available
            }
        }
    }

    private var theme: NotchTheme { themeManager.currentTheme }

    var body: some View {
        ZStack {
            // Black background to match the notch - fully opaque for seamless blending
            Color.black

            VStack(spacing: 0) {
                // Spacer to account for notch area (content starts below the notch)
                // This ensures content isn't hidden behind the notch
                // Use the actual notch height from the screen + significant extra padding
                Spacer()
                    .frame(height: NotchWindow.currentNotchHeight + 20)

                // Content area - pushed well below the notch
                ZStack {
                    switch selectedWidget {
                    case .music:
                        MusicWidgetView()
                    case .calendar:
                        CalendarWidgetView()
                    case .weather:
                        WeatherWidgetView()
                    case .custom:
                        CustomWidgetView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 24)
                .padding(.top, 8)  // Extra top padding for better spacing
                .padding(.bottom, 12)
            }
        }
        .environment(\.notchTheme, theme)
        .frame(width: 500, height: 200)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 18,
                bottomLeadingRadius: 26,
                bottomTrailingRadius: 26,
                topTrailingRadius: 18,
                style: .continuous
            )
        )
        .onChange(of: enabledWidgets) { newValue in
            // If the currently selected widget was disabled, switch to first enabled
            if !newValue.contains(selectedWidget), let first = newValue.first {
                selectedWidget = first
            }
        }
    }
}

struct WidgetTab: View {
    let title: String
    let isSelected: Bool
    var theme: NotchTheme = .dark
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isSelected ? theme.primaryText : theme.secondaryText)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(isSelected ? theme.selectedTabBackground : Color.clear)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Visual Effect Blur (for macOS backdrop blur)
struct VisualEffectBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

#Preview {
    NotchIslandView()
}
