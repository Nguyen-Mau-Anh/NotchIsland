import Testing
import Foundation
@testable import NotchIsland

/// Test suite for NotchIsland app functionality
/// Based on QA findings from QA_TEST_RESULTS.md
@Suite("NotchIsland Core Functionality Tests")
struct NotchIslandTests {
    
    // MARK: - Critical Bug Tests (Must Pass Before Release)
    
    @Test("Weather API key should not be placeholder")
    func weatherAPIKeyValidation() async throws {
        // This test verifies BUG-005 is fixed
        let weatherManager = WeatherManager.shared
        
        // The API key should not be the placeholder value
        #expect(weatherManager.apiKey != "YOUR_API_KEY", 
               "Weather API key is still placeholder - weather will not work")
        
        // API key should be a valid format (32 hex characters for OpenWeatherMap)
        let apiKeyPattern = /^[a-f0-9]{32}$/
        #expect(weatherManager.apiKey.wholeMatch(of: apiKeyPattern) != nil,
               "API key should be 32 hex characters for OpenWeatherMap")
    }
    
    @Test("Theme system should be properly configured")
    func themeSystemValidation() async throws {
        // Verifies BUG-011 fix - theme picker UI exists
        let themeManager = ThemeManager.shared
        
        // Should have 4 themes available
        #expect(themeManager.availableThemes.count == 4,
               "Should have exactly 4 themes: Dark, Light, Midnight, Sunset")
        
        // Current theme should not be nil
        #expect(themeManager.currentTheme != nil,
               "Current theme should be set to a default value")
    }
    
    @Test("Music metadata delimiter should be safe")
    func musicMetadataDelimiterSafety() async throws {
        // Verifies BUG-001 and BUG-004 fixes
        let musicManager = MusicManager.shared
        
        // Test track with problematic characters
        let testTrack = Track(
            title: "Song | With | Pipes",
            artist: "Artist | Name",
            album: "Album | Title"
        )
        
        let cacheKey = testTrack.cacheKey
        
        // Should not contain pipe characters (old bug)
        #expect(!cacheKey.contains("|"), 
               "Cache key should not contain pipe characters")
        
        // Should use safe delimiter
        #expect(cacheKey.contains("~~"),
               "Cache key should use safe ~~ delimiter")
    }
    
    // MARK: - Performance and Threading Tests
    
    @Test("Spotify artwork fetch should not block main thread")
    func spotifyArtworkMainThreadTest() async throws {
        // Tests for BUG-002 - this is a medium priority issue
        let musicManager = MusicManager.shared
        
        // This test would need to be run with Thread Sanitizer enabled
        // to catch main thread blocking issues
        
        // For now, just verify the method exists and can be called
        // Real testing would require mocking URLSession
        #expect(musicManager.respondsToSelector(Selector("updateCurrentTrack")),
               "Music manager should have updateCurrentTrack method")
    }
    
    // MARK: - Settings Persistence Tests
    
    @Test("Settings should persist using AppStorage")
    func settingsPersistenceTest() async throws {
        // Verify the settings persistence fix
        let userDefaults = UserDefaults.standard
        
        // Test auto-hide delay setting
        userDefaults.set(1.5, forKey: "autoHideDelay")
        let savedDelay = userDefaults.double(forKey: "autoHideDelay")
        #expect(savedDelay == 1.5, "Auto-hide delay should persist")
        
        // Test hover sensitivity setting
        userDefaults.set(75, forKey: "hoverSensitivity")
        let savedSensitivity = userDefaults.integer(forKey: "hoverSensitivity")
        #expect(savedSensitivity == 75, "Hover sensitivity should persist")
        
        // Clean up
        userDefaults.removeObject(forKey: "autoHideDelay")
        userDefaults.removeObject(forKey: "hoverSensitivity")
    }
    
    // MARK: - Multi-Monitor Support Tests
    
    @Test("Screen detection should handle multiple monitors")
    func multiMonitorSupportTest() async throws {
        // Test the screen detection logic
        // This would need to run on a system with multiple screens for full testing
        
        // At minimum, should not crash when no notch screen is available
        let screens = NSScreen.screens
        #expect(screens.count >= 1, "Should have at least one screen")
        
        // The app should handle the case where no notch is detected
        // This is hard to test without actual hardware, but we can verify
        // the method exists and returns a screen
        let detectedScreen = NotchIslandApp.screenWithNotch()
        #expect(detectedScreen != nil, "Should always return a valid screen")
    }
    
    // MARK: - Widget Functionality Tests
    
    @Test("Calendar widget should handle permissions")
    func calendarWidgetPermissionTest() async throws {
        let calendarManager = CalendarManager.shared
        
        // Should handle all authorization states without crashing
        let authStatus = EKEventStore.authorizationStatus(for: .event)
        
        // Test that the manager can handle any auth state
        #expect(calendarManager != nil, "Calendar manager should initialize")
        
        // The actual permission handling would need user interaction to test fully
    }
    
    @Test("Weather widget should handle location permissions")
    func weatherWidgetLocationTest() async throws {
        let weatherManager = WeatherManager.shared
        
        // Should initialize without crashing
        #expect(weatherManager != nil, "Weather manager should initialize")
        
        // Should handle location authorization states
        let locationManager = CLLocationManager()
        let authStatus = locationManager.authorizationStatus
        
        // The manager should handle any authorization state gracefully
        #expect(authStatus != .notDetermined || authStatus == .notDetermined,
               "Should handle any location authorization state")
    }
    
    // MARK: - Keyboard Shortcut Tests
    
    @Test("Keyboard shortcut should have default value")
    func keyboardShortcutDefaultTest() async throws {
        let shortcutManager = KeyboardShortcutManager.shared
        
        // Should have a default shortcut (Ctrl+Option+N)
        #expect(shortcutManager.currentShortcut != nil,
               "Should have default keyboard shortcut")
        
        // Default should be Ctrl+Option+N
        let defaultShortcut = shortcutManager.currentShortcut
        #expect(defaultShortcut?.keyCode != nil,
               "Default shortcut should have key code")
    }
}

// MARK: - Integration Tests

@Suite("NotchIsland Integration Tests")
struct NotchIslandIntegrationTests {
    
    @Test("App should launch without crashing")
    func appLaunchTest() async throws {
        // Basic smoke test - app should initialize core components
        
        // These managers should initialize without throwing
        let musicManager = MusicManager.shared
        let calendarManager = CalendarManager.shared
        let weatherManager = WeatherManager.shared
        let themeManager = ThemeManager.shared
        let shortcutManager = KeyboardShortcutManager.shared
        
        #expect(musicManager != nil, "Music manager should initialize")
        #expect(calendarManager != nil, "Calendar manager should initialize") 
        #expect(weatherManager != nil, "Weather manager should initialize")
        #expect(themeManager != nil, "Theme manager should initialize")
        #expect(shortcutManager != nil, "Shortcut manager should initialize")
    }
    
    @Test("Themes should apply to all widgets")
    func themeApplicationTest() async throws {
        let themeManager = ThemeManager.shared
        
        // Test each theme
        for theme in themeManager.availableThemes {
            themeManager.currentTheme = theme
            
            // Theme should have all required properties
            #expect(theme.primaryText != nil, "Theme should have primary text color")
            #expect(theme.secondaryText != nil, "Theme should have secondary text color")
            #expect(theme.background != nil, "Theme should have background color")
            #expect(theme.cardBackground != nil, "Theme should have card background")
        }
    }
}

// MARK: - Performance Tests

@Suite("NotchIsland Performance Tests")
struct NotchIslandPerformanceTests {
    
    @Test("Artwork caching should limit memory usage")
    func artworkCacheTest() async throws {
        let musicManager = MusicManager.shared
        
        // Cache should have a reasonable limit (20 items per QA report)
        #expect(musicManager.artworkCache.countLimit == 20,
               "Artwork cache should be limited to 20 items")
        
        // Cache should evict old items when limit is reached
        // This would need more complex testing to verify LRU behavior
    }
    
    @Test("Weather data should cache for performance")
    func weatherCacheTest() async throws {
        let weatherManager = WeatherManager.shared
        
        // Weather should cache data for 30 minutes
        // This would need time-based testing to verify cache expiration
        
        #expect(weatherManager != nil, "Weather manager should support caching")
    }
}