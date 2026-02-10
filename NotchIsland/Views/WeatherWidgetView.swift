//
//  WeatherWidgetView.swift
//  NotchIsland
//
//  Weather widget with current conditions and forecast
//

import SwiftUI

struct WeatherWidgetView: View {
    @StateObject private var weatherManager = WeatherManager.shared
    @Environment(\.notchTheme) private var theme

    var body: some View {
        VStack(spacing: 0) {
            if let weather = weatherManager.currentWeather {
                WeatherContentView(weather: weather, isLoading: weatherManager.isLoading) {
                    weatherManager.refreshWeather()
                }
            } else if weatherManager.locationStatus == .denied || weatherManager.locationStatus == .restricted {
                LocationDeniedView()
            } else if weatherManager.locationStatus == .notDetermined {
                LocationRequestView {
                    weatherManager.requestLocationAccess()
                }
            } else if weatherManager.isLoading {
                WeatherLoadingView()
            } else if let error = weatherManager.errorMessage {
                WeatherErrorView(message: error) {
                    weatherManager.refreshWeather()
                }
            } else {
                WeatherLoadingView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Weather Content

struct WeatherContentView: View {
    let weather: WeatherData
    let isLoading: Bool
    let onRefresh: () -> Void
    @Environment(\.notchTheme) private var theme

    var body: some View {
        HStack(spacing: 16) {
            // Left: Current conditions
            VStack(spacing: 6) {
                // Weather icon
                Image(systemName: weather.condition.sfSymbol)
                    .font(.system(size: 28))
                    .foregroundStyle(iconGradient)
                    .shadow(color: iconGlowColor.opacity(0.5), radius: 6)

                // Temperature
                Text("\(Int(round(weather.temperature)))°")
                    .font(.system(size: 36, weight: .thin, design: .rounded))
                    .foregroundColor(theme.primaryText)

                // Condition
                Text(weather.description)
                    .font(.system(size: 11))
                    .foregroundColor(theme.secondaryText)
                    .lineLimit(1)
            }
            .frame(width: 100)

            // Divider
            Rectangle()
                .fill(theme.tertiaryText.opacity(0.3))
                .frame(width: 1)
                .padding(.vertical, 8)

            // Right: Details + Forecast
            VStack(alignment: .leading, spacing: 8) {
                // City name + refresh
                HStack {
                    Image(systemName: "location.fill")
                        .font(.system(size: 9))
                        .foregroundColor(theme.tertiaryText)

                    Text(weather.cityName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(theme.primaryText.opacity(0.9))
                        .lineLimit(1)

                    Spacer()

                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.5)
                            .frame(width: 14, height: 14)
                    } else {
                        Button(action: onRefresh) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 10))
                                .foregroundColor(theme.tertiaryText)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }

                // Quick stats row
                HStack(spacing: 12) {
                    WeatherStatBadge(icon: "thermometer.medium", value: "H:\(Int(round(weather.tempMax)))° L:\(Int(round(weather.tempMin)))°")
                    WeatherStatBadge(icon: "humidity.fill", value: "\(weather.humidity)%")
                    WeatherStatBadge(icon: "wind", value: "\(Int(round(weather.windSpeed)))m/s")
                }

                // Forecast row
                if !weather.forecast.isEmpty {
                    HStack(spacing: 0) {
                        ForEach(weather.forecast.prefix(5)) { item in
                            ForecastItemView(forecast: item)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 4)
    }

    private var iconGradient: LinearGradient {
        switch weather.condition {
        case .clear:
            return LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
        case .fewClouds:
            return LinearGradient(colors: [theme.primaryText, .gray], startPoint: .top, endPoint: .bottom)
        case .clouds, .overcast:
            return LinearGradient(colors: [.gray, theme.primaryText.opacity(0.6)], startPoint: .top, endPoint: .bottom)
        case .rain, .drizzle:
            return LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom)
        case .thunderstorm:
            return LinearGradient(colors: [.purple, .yellow], startPoint: .top, endPoint: .bottom)
        case .snow:
            return LinearGradient(colors: [theme.primaryText, .cyan.opacity(0.7)], startPoint: .top, endPoint: .bottom)
        case .mist, .fog, .haze:
            return LinearGradient(colors: [.gray, theme.primaryText.opacity(0.5)], startPoint: .top, endPoint: .bottom)
        case .unknown:
            return LinearGradient(colors: [.gray, theme.primaryText], startPoint: .top, endPoint: .bottom)
        }
    }

    private var iconGlowColor: Color {
        switch weather.condition {
        case .clear: return .yellow
        case .rain, .drizzle: return .blue
        case .thunderstorm: return .purple
        case .snow: return .cyan
        default: return theme.primaryText
        }
    }
}

// MARK: - Supporting Views

struct WeatherStatBadge: View {
    let icon: String
    let value: String
    @Environment(\.notchTheme) private var theme

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 9))
                .foregroundColor(theme.tertiaryText)
            Text(value)
                .font(.system(size: 10))
                .foregroundColor(theme.secondaryText)
        }
    }
}

struct ForecastItemView: View {
    let forecast: HourlyForecast
    @Environment(\.notchTheme) private var theme

    var body: some View {
        VStack(spacing: 4) {
            Text(forecastTimeString)
                .font(.system(size: 9))
                .foregroundColor(theme.tertiaryText)

            Image(systemName: forecast.condition.sfSymbol)
                .font(.system(size: 12))
                .foregroundColor(theme.secondaryText)

            Text("\(Int(round(forecast.temperature)))°")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(theme.primaryText.opacity(0.8))
        }
    }

    private var forecastTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        return formatter.string(from: forecast.time).lowercased()
    }
}

// MARK: - State Views

struct WeatherLoadingView: View {
    @Environment(\.notchTheme) private var theme

    var body: some View {
        VStack(spacing: 8) {
            ProgressView()
                .scaleEffect(0.8)
                .progressViewStyle(CircularProgressViewStyle(tint: theme.primaryText))

            Text("Loading weather...")
                .font(.system(size: 12))
                .foregroundColor(theme.secondaryText)
        }
    }
}

struct LocationRequestView: View {
    let onRequest: () -> Void
    @Environment(\.notchTheme) private var theme

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "location.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(theme.tertiaryText)

            Text("Location access needed")
                .font(.system(size: 13))
                .foregroundColor(theme.secondaryText)

            Button(action: onRequest) {
                Text("Enable Location")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(theme.primaryText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(theme.controlAccent.opacity(0.3))
                    )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct LocationDeniedView: View {
    @Environment(\.notchTheme) private var theme

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "location.slash.fill")
                .font(.system(size: 32))
                .foregroundColor(theme.tertiaryText)

            Text("Location access denied")
                .font(.system(size: 13))
                .foregroundColor(theme.secondaryText)

            Button("Open Settings") {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices")!)
            }
            .buttonStyle(PlainButtonStyle())
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(theme.primaryText)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(theme.cardBackground)
            )
        }
    }
}

struct WeatherErrorView: View {
    let message: String
    let onRetry: () -> Void
    @Environment(\.notchTheme) private var theme

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.icloud.fill")
                .font(.system(size: 32))
                .foregroundColor(theme.tertiaryText)

            Text(message)
                .font(.system(size: 11))
                .foregroundColor(theme.secondaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Button(action: onRetry) {
                Text("Retry")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(theme.primaryText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(theme.cardBackground)
                    )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

#Preview {
    WeatherWidgetView()
        .frame(width: 400, height: 150)
        .background(Color.black.opacity(0.8))
}
