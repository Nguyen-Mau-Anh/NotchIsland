//
//  WeatherManager.swift
//  NotchIsland
//
//  Manages weather data fetching using OpenWeatherMap API and CoreLocation
//

import Foundation
import CoreLocation
import AppKit
import Combine

// MARK: - Weather Data Models

struct WeatherData {
    let temperature: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let humidity: Int
    let condition: WeatherCondition
    let description: String
    let cityName: String
    let windSpeed: Double
    let forecast: [HourlyForecast]
    let lastUpdated: Date
}

struct HourlyForecast: Identifiable {
    let id = UUID()
    let time: Date
    let temperature: Double
    let condition: WeatherCondition
}

enum WeatherCondition: String {
    case clear = "Clear"
    case fewClouds = "Few Clouds"
    case clouds = "Clouds"
    case overcast = "Overcast"
    case rain = "Rain"
    case drizzle = "Drizzle"
    case thunderstorm = "Thunderstorm"
    case snow = "Snow"
    case mist = "Mist"
    case fog = "Fog"
    case haze = "Haze"
    case unknown = "Unknown"

    var sfSymbol: String {
        switch self {
        case .clear:
            return isNighttime ? "moon.stars.fill" : "sun.max.fill"
        case .fewClouds:
            return isNighttime ? "cloud.moon.fill" : "cloud.sun.fill"
        case .clouds:
            return "cloud.fill"
        case .overcast:
            return "smoke.fill"
        case .rain:
            return "cloud.rain.fill"
        case .drizzle:
            return "cloud.drizzle.fill"
        case .thunderstorm:
            return "cloud.bolt.rain.fill"
        case .snow:
            return "cloud.snow.fill"
        case .mist, .fog:
            return "cloud.fog.fill"
        case .haze:
            return "sun.haze.fill"
        case .unknown:
            return "questionmark.circle.fill"
        }
    }

    var gradientColors: (top: String, bottom: String) {
        switch self {
        case .clear:
            return isNighttime ? ("#1a1a2e", "#16213e") : ("#4facfe", "#00f2fe")
        case .fewClouds:
            return isNighttime ? ("#2c3e50", "#3498db") : ("#a1c4fd", "#c2e9fb")
        case .clouds, .overcast:
            return ("#606c88", "#3f4c6b")
        case .rain, .drizzle:
            return ("#373b44", "#4286f4")
        case .thunderstorm:
            return ("#0f0c29", "#302b63")
        case .snow:
            return ("#e6dada", "#274046")
        case .mist, .fog, .haze:
            return ("#757f9a", "#d7dde8")
        case .unknown:
            return ("#606c88", "#3f4c6b")
        }
    }

    private var isNighttime: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour < 6 || hour > 20
    }
}

// MARK: - Weather Manager

class WeatherManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = WeatherManager()

    @Published var currentWeather: WeatherData?
    @Published var locationStatus: LocationStatus = .unknown
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let locationManager = CLLocationManager()
    private var refreshTimer: Timer?
    private var lastLocation: CLLocation?

    // OpenWeatherMap free API - users should replace with their own key
    private let apiKey = "YOUR_API_KEY"
    private let baseURL = "https://api.openweathermap.org/data/2.5"

    // Cache
    private var cachedWeather: WeatherData?
    private var cacheExpiry: Date?
    private let cacheDuration: TimeInterval = 1800 // 30 minutes

    enum LocationStatus {
        case unknown
        case authorized
        case denied
        case restricted
        case notDetermined

        var description: String {
            switch self {
            case .unknown: return "Unknown"
            case .authorized: return "Authorized"
            case .denied: return "Location access denied"
            case .restricted: return "Location access restricted"
            case .notDetermined: return "Not determined"
            }
        }
    }

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        checkLocationAuthorization()
        startAutoRefresh()
    }

    // MARK: - Location

    func requestLocationAccess() {
        locationManager.requestWhenInUseAuthorization()
    }

    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationStatus = .authorized
            locationManager.requestLocation()
        case .denied:
            locationStatus = .denied
            loadCachedOrFallback()
        case .restricted:
            locationStatus = .restricted
            loadCachedOrFallback()
        case .notDetermined:
            locationStatus = .notDetermined
        @unknown default:
            locationStatus = .unknown
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
        fetchWeather(for: location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = "Location error: \(error.localizedDescription)"
        }
        loadCachedOrFallback()
    }

    // MARK: - Weather Fetching

    func refreshWeather() {
        if let location = lastLocation {
            fetchWeather(for: location)
        } else if locationStatus == .authorized {
            locationManager.requestLocation()
        }
    }

    private func fetchWeather(for location: CLLocation) {
        // Check cache first
        if let cached = cachedWeather,
           let expiry = cacheExpiry,
           Date() < expiry {
            DispatchQueue.main.async {
                self.currentWeather = cached
            }
            return
        }

        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }

        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude

        // Fetch current weather and forecast in parallel
        let group = DispatchGroup()
        var currentResult: [String: Any]?
        var forecastResult: [[String: Any]]?

        // Current weather
        group.enter()
        let currentURL = "\(baseURL)/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric"
        fetchJSON(from: currentURL) { result in
            currentResult = result
            group.leave()
        }

        // 3-hour forecast
        group.enter()
        let forecastURL = "\(baseURL)/forecast?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric&cnt=6"
        fetchJSON(from: forecastURL) { result in
            if let list = result?["list"] as? [[String: Any]] {
                forecastResult = list
            }
            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.isLoading = false

            if let current = currentResult {
                let weather = self.parseWeatherResponse(current, forecast: forecastResult)
                self.currentWeather = weather
                self.cachedWeather = weather
                self.cacheExpiry = Date().addingTimeInterval(self.cacheDuration)
                self.saveWeatherToCache(weather)
            } else {
                self.errorMessage = "Failed to fetch weather data"
                self.loadCachedOrFallback()
            }
        }
    }

    private func fetchJSON(from urlString: String, completion: @escaping ([String: Any]?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                completion(nil)
                return
            }
            completion(json)
        }.resume()
    }

    private func parseWeatherResponse(_ json: [String: Any], forecast: [[String: Any]]?) -> WeatherData {
        let main = json["main"] as? [String: Any] ?? [:]
        let weatherArray = json["weather"] as? [[String: Any]] ?? []
        let weather = weatherArray.first ?? [:]
        let wind = json["wind"] as? [String: Any] ?? [:]

        let temperature = main["temp"] as? Double ?? 0
        let feelsLike = main["feels_like"] as? Double ?? 0
        let tempMin = main["temp_min"] as? Double ?? 0
        let tempMax = main["temp_max"] as? Double ?? 0
        let humidity = main["humidity"] as? Int ?? 0
        let windSpeed = wind["speed"] as? Double ?? 0
        let cityName = json["name"] as? String ?? "Unknown"
        let description = weather["description"] as? String ?? "Unknown"
        let conditionMain = weather["main"] as? String ?? ""
        let conditionId = weather["id"] as? Int ?? 0

        let condition = mapCondition(main: conditionMain, id: conditionId)

        // Parse forecast
        var hourlyForecast: [HourlyForecast] = []
        if let forecastItems = forecast {
            for item in forecastItems {
                let dt = item["dt"] as? TimeInterval ?? 0
                let forecastMain = item["main"] as? [String: Any] ?? [:]
                let forecastWeatherArray = item["weather"] as? [[String: Any]] ?? []
                let forecastWeather = forecastWeatherArray.first ?? [:]
                let forecastCondMain = forecastWeather["main"] as? String ?? ""
                let forecastCondId = forecastWeather["id"] as? Int ?? 0

                hourlyForecast.append(HourlyForecast(
                    time: Date(timeIntervalSince1970: dt),
                    temperature: forecastMain["temp"] as? Double ?? 0,
                    condition: mapCondition(main: forecastCondMain, id: forecastCondId)
                ))
            }
        }

        return WeatherData(
            temperature: temperature,
            feelsLike: feelsLike,
            tempMin: tempMin,
            tempMax: tempMax,
            humidity: humidity,
            condition: condition,
            description: description.capitalized,
            cityName: cityName,
            windSpeed: windSpeed,
            forecast: hourlyForecast,
            lastUpdated: Date()
        )
    }

    private func mapCondition(main: String, id: Int) -> WeatherCondition {
        switch main.lowercased() {
        case "clear": return .clear
        case "clouds":
            if id == 801 { return .fewClouds }
            if id == 804 { return .overcast }
            return .clouds
        case "rain": return .rain
        case "drizzle": return .drizzle
        case "thunderstorm": return .thunderstorm
        case "snow": return .snow
        case "mist": return .mist
        case "fog": return .fog
        case "haze": return .haze
        default: return .unknown
        }
    }

    // MARK: - Caching & Offline Support

    private func saveWeatherToCache(_ weather: WeatherData) {
        let defaults = UserDefaults.standard
        defaults.set(weather.temperature, forKey: "weather_temp")
        defaults.set(weather.feelsLike, forKey: "weather_feels_like")
        defaults.set(weather.tempMin, forKey: "weather_temp_min")
        defaults.set(weather.tempMax, forKey: "weather_temp_max")
        defaults.set(weather.humidity, forKey: "weather_humidity")
        defaults.set(weather.condition.rawValue, forKey: "weather_condition")
        defaults.set(weather.description, forKey: "weather_description")
        defaults.set(weather.cityName, forKey: "weather_city")
        defaults.set(weather.windSpeed, forKey: "weather_wind")
        defaults.set(weather.lastUpdated.timeIntervalSince1970, forKey: "weather_last_updated")
    }

    private func loadCachedOrFallback() {
        let defaults = UserDefaults.standard
        guard defaults.object(forKey: "weather_temp") != nil else { return }

        let conditionRaw = defaults.string(forKey: "weather_condition") ?? "Unknown"
        let condition = WeatherCondition(rawValue: conditionRaw) ?? .unknown
        let lastUpdated = Date(timeIntervalSince1970: defaults.double(forKey: "weather_last_updated"))

        let cached = WeatherData(
            temperature: defaults.double(forKey: "weather_temp"),
            feelsLike: defaults.double(forKey: "weather_feels_like"),
            tempMin: defaults.double(forKey: "weather_temp_min"),
            tempMax: defaults.double(forKey: "weather_temp_max"),
            humidity: defaults.integer(forKey: "weather_humidity"),
            condition: condition,
            description: defaults.string(forKey: "weather_description") ?? "Cached",
            cityName: defaults.string(forKey: "weather_city") ?? "Unknown",
            windSpeed: defaults.double(forKey: "weather_wind"),
            forecast: [],
            lastUpdated: lastUpdated
        )

        DispatchQueue.main.async {
            self.currentWeather = cached
            self.errorMessage = "Showing cached data from \(self.formatTime(lastUpdated))"
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    // MARK: - Auto Refresh

    private func startAutoRefresh() {
        // Refresh every 30 minutes
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 1800, repeats: true) { [weak self] _ in
            self?.refreshWeather()
        }
    }

    deinit {
        refreshTimer?.invalidate()
    }
}
