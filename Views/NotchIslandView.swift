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
            // Background with blur effect
            VisualEffectBlur(material: theme.blurMaterial, blendingMode: .behindWindow)

            VStack(spacing: 0) {
                // Widget selector tabs
                HStack(spacing: 12) {
                    ForEach(enabledWidgets, id: \.self) { widget in
                        WidgetTab(
                            title: widget.rawValue,
                            isSelected: selectedWidget == widget,
                            theme: theme,
                            action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedWidget = widget
                                }
                            }
                        )
                    }
                }
                .padding(.top, 16)
                .padding(.horizontal, 16)

                // Content area
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
                .padding(16)
            }
        }
        .environment(\.notchTheme, theme)
        .frame(width: 400, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
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
