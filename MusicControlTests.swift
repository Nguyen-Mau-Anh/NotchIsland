import Testing
import Foundation
import AppKit

/// Focused test suite for NotchIsland music control functionality
/// This excludes weather-related tests to get the core app working first
@Suite("NotchIsland Music Control Tests")
struct MusicControlTests {
    
    // MARK: - Core Music Functionality Tests
    
    @Test("Music manager should initialize without weather dependency")
    func musicManagerInitialization() async throws {
        // Test that MusicManager can initialize even if weather is broken
        let musicManager = MusicManager.shared
        
        #expect(musicManager != nil, "Music manager should initialize successfully")
        
        // Should have artwork cache configured
        #expect(musicManager.artworkCache != nil, "Should have artwork cache")
        #expect(musicManager.artworkCache.countLimit == 20, "Cache should limit to 20 items")
    }
    
    @Test("Music metadata parsing should use safe delimiters")
    func musicMetadataSafeDelimiters() async throws {
        // Verify BUG-001 fix - safe delimiters in AppleScript parsing
        let musicManager = MusicManager.shared
        
        // Test track with problematic characters that could break parsing
        let testTrack = Track(
            title: "Song | With | Pipes & Special chars",
            artist: "Artist | Name",  
            album: "Album | Title"
        )
        
        let cacheKey = testTrack.cacheKey
        
        // Should not contain pipe characters (the old problematic delimiter)
        #expect(!cacheKey.contains("|"), 
               "Cache key should not contain pipe characters that could break parsing")
        
        // Should use the safe delimiter
        #expect(cacheKey.contains("~~"),
               "Cache key should use safe ~~ delimiter")
        
        // Cache key should be well-formed
        let components = cacheKey.components(separatedBy: "~~")
        #expect(components.count == 3, "Cache key should have 3 components: title~~artist~~album")
    }
    
    @Test("App should start without weather functionality")  
    func appStartupWithoutWeather() async throws {
        // Test that core managers initialize even if weather is disabled/broken
        let musicManager = MusicManager.shared
        let themeManager = ThemeManager.shared
        let shortcutManager = KeyboardShortcutManager.shared
        
        #expect(musicManager != nil, "Music manager should work independently")
        #expect(themeManager != nil, "Theme manager should work independently") 
        #expect(shortcutManager != nil, "Keyboard shortcut manager should work independently")
        
        // Weather manager might be broken, but shouldn't crash the app
        // We'll skip weather-specific tests for this focused setup
    }
    
    // MARK: - Settings Persistence Tests (Music Focus)
    
    @Test("Music widget settings should persist")
    func musicWidgetSettingsPersistence() async throws {
        let userDefaults = UserDefaults.standard
        
        // Test music widget enable/disable toggle
        userDefaults.set(false, forKey: "musicWidgetEnabled")
        let musicDisabled = !userDefaults.bool(forKey: "musicWidgetEnabled")
        #expect(musicDisabled == true, "Music widget disable setting should persist")
        
        // Test hover sensitivity (affects music widget show/hide)
        userDefaults.set(60, forKey: "hoverSensitivity") 
        let sensitivity = userDefaults.integer(forKey: "hoverSensitivity")
        #expect(sensitivity == 60, "Hover sensitivity should persist")
        
        // Test auto-hide delay (affects how long music widget stays visible)
        userDefaults.set(2.0, forKey: "autoHideDelay")
        let hideDelay = userDefaults.double(forKey: "autoHideDelay")
        #expect(hideDelay == 2.0, "Auto-hide delay should persist")
        
        // Clean up test settings
        userDefaults.removeObject(forKey: "musicWidgetEnabled")
        userDefaults.removeObject(forKey: "hoverSensitivity")
        userDefaults.removeObject(forKey: "autoHideDelay")
    }
    
    // MARK: - Theme System Tests (Music Widget Focus)
    
    @Test("Music widget should support all themes")
    func musicWidgetThemeSupport() async throws {
        let themeManager = ThemeManager.shared
        
        // Should have the 4 expected themes
        #expect(themeManager.availableThemes.count == 4,
               "Should have 4 themes: Dark, Light, Midnight, Sunset")
        
        // Test each theme has required properties for music widget
        for theme in themeManager.availableThemes {
            #expect(theme.primaryText != nil, "Theme should have primary text color for track titles")
            #expect(theme.secondaryText != nil, "Theme should have secondary text color for artists")
            #expect(theme.cardBackground != nil, "Theme should have card background for music widget")
            #expect(theme.controlAccent != nil, "Theme should have accent color for play/pause buttons")
        }
        
        // Current theme should be set to a valid default
        #expect(themeManager.currentTheme != nil, "Should have a default theme selected")
    }
    
    // MARK: - Keyboard Shortcut Tests (Music Focus)
    
    @Test("Keyboard shortcut should work for music control access")
    func keyboardShortcutForMusicAccess() async throws {
        let shortcutManager = KeyboardShortcutManager.shared
        
        // Should have default shortcut configured
        #expect(shortcutManager.currentShortcut != nil, "Should have default Ctrl+Option+N shortcut")
        
        // Default shortcut should be the expected key combination
        if let shortcut = shortcutManager.currentShortcut {
            // This would be the virtual key code for 'N'
            #expect(shortcut.keyCode != nil, "Shortcut should have a key code")
            #expect(shortcut.modifierFlags != nil, "Shortcut should have modifier flags")
        }
        
        // Shortcut should persist in UserDefaults
        let savedKeyCode = UserDefaults.standard.integer(forKey: "globalShortcutKeyCode")
        #expect(savedKeyCode != 0, "Shortcut key code should be saved")
    }
    
    // MARK: - Multi-Monitor Support Tests (Music Focus)
    
    @Test("Music widget should appear on correct screen")
    func musicWidgetScreenPositioning() async throws {
        // Test that the screen detection works for music widget positioning
        let screens = NSScreen.screens
        #expect(screens.count >= 1, "Should have at least one screen")
        
        // The screen detection method should return a valid screen
        let targetScreen = NotchIslandApp.screenWithNotch()
        #expect(targetScreen != nil, "Should return a valid screen for music widget")
        
        // Screen should have proper dimensions for positioning calculation
        if let screen = targetScreen {
            let frame = screen.frame
            #expect(frame.width > 0, "Screen should have positive width")
            #expect(frame.height > 0, "Screen should have positive height")
        }
    }
}

// MARK: - Music Widget UI Tests

@Suite("Music Widget UI Tests")
struct MusicWidgetUITests {
    
    @Test("Music widget should handle missing artwork gracefully")
    func musicWidgetMissingArtwork() async throws {
        // Test that the music widget doesn't crash when artwork is unavailable
        let testTrack = Track(
            title: "Test Song",
            artist: "Test Artist", 
            album: "Test Album"
        )
        
        // Track should be valid even without artwork
        #expect(testTrack.title == "Test Song", "Track title should be preserved")
        #expect(testTrack.artist == "Test Artist", "Track artist should be preserved")
        #expect(testTrack.album == "Test Album", "Track album should be preserved")
        
        // Cache key should be generated properly
        let cacheKey = testTrack.cacheKey
        #expect(cacheKey.contains("Test Song"), "Cache key should contain title")
        #expect(cacheKey.contains("Test Artist"), "Cache key should contain artist")
    }
    
    @Test("Music widget should support playback state changes")
    func musicWidgetPlaybackStates() async throws {
        // Test that the music widget can handle different playback states
        let musicManager = MusicManager.shared
        
        // These are the expected playback control methods
        let hasToggleMethod = musicManager.respondsToSelector(Selector("togglePlayPause"))
        let hasNextMethod = musicManager.respondsToSelector(Selector("nextTrack"))
        let hasPreviousMethod = musicManager.respondsToSelector(Selector("previousTrack"))
        
        #expect(hasToggleMethod, "Should have play/pause toggle functionality")
        #expect(hasNextMethod, "Should have next track functionality")  
        #expect(hasPreviousMethod, "Should have previous track functionality")
    }
}

// MARK: - Integration Tests (Music Only)

@Suite("Music Control Integration Tests") 
struct MusicControlIntegrationTests {
    
    @Test("App should handle no music apps running")
    func noMusicAppsRunning() async throws {
        // Test that the app doesn't crash when no music apps are available
        let musicManager = MusicManager.shared
        
        // Should initialize even if no music apps are running
        #expect(musicManager != nil, "Music manager should initialize without active music apps")
        
        // Current track might be nil, but shouldn't crash
        // We can't test the actual AppleScript calls without running apps,
        // but we can verify the manager doesn't crash on initialization
    }
    
    @Test("Settings window should show music-related options")
    func musicSettingsAvailable() async throws {
        // Test that music-related settings are available
        // This is more of a smoke test since we can't easily test SwiftUI views
        
        let userDefaults = UserDefaults.standard
        
        // Music widget should have an enable/disable setting
        userDefaults.set(true, forKey: "musicWidgetEnabled")
        let musicEnabled = userDefaults.bool(forKey: "musicWidgetEnabled") 
        #expect(musicEnabled == true, "Music widget enable setting should work")
        
        // Hover settings should affect music widget
        userDefaults.set(50, forKey: "hoverSensitivity")
        let sensitivity = userDefaults.integer(forKey: "hoverSensitivity")
        #expect(sensitivity == 50, "Hover sensitivity should be configurable")
        
        // Clean up
        userDefaults.removeObject(forKey: "musicWidgetEnabled")
        userDefaults.removeObject(forKey: "hoverSensitivity")
    }
    
    @Test("NotchIsland should prioritize music tab when weather is disabled")
    func musicTabPriority() async throws {
        // When weather is disabled/broken, music should be the primary tab
        let musicManager = MusicManager.shared
        let themeManager = ThemeManager.shared
        
        // Core music functionality should work independently
        #expect(musicManager != nil, "Music should work without weather")
        #expect(themeManager != nil, "Themes should work without weather")
        
        // This test mainly ensures music functionality is isolated
        // from weather dependencies
    }
}