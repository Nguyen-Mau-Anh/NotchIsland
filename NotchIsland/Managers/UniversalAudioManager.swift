//
//  UniversalAudioManager.swift
//  NotchIsland
//
//  Universal audio manager that detects playback from ANY application
//  Supports: Music, Spotify, Chrome, Safari, Arc, Firefox, and more
//

import Foundation
import AppKit
import Combine

enum AudioApp: String {
    case appleMusic = "Music"
    case spotify = "Spotify"
    case chrome = "Google Chrome"
    case safari = "Safari"
    case arc = "Arc"
    case firefox = "Firefox"
    case youtubeMusic = "YouTube Music"
    case unknown = "Unknown"
}

struct UniversalTrack: Equatable {
    let title: String
    let artist: String?
    let artwork: NSImage?
    let source: AudioApp
    let url: String?

    var displayArtist: String {
        artist ?? source.rawValue
    }

    static func == (lhs: UniversalTrack, rhs: UniversalTrack) -> Bool {
        lhs.title == rhs.title && lhs.artist == rhs.artist && lhs.source == rhs.source
    }
}

class UniversalAudioManager: ObservableObject {
    static let shared: UniversalAudioManager = {
        let instance = UniversalAudioManager()
        NSLog("[NotchIsland] UniversalAudioManager.shared was initialized!")
        return instance
    }()

    @Published var currentTrack: UniversalTrack?
    @Published var isPlaying: Bool = false

    private var updateTimer: Timer?
    private let backgroundQueue = DispatchQueue(label: "com.notchisland.audio", qos: .userInitiated)
    private var artworkCache = NSCache<NSString, NSImage>()

    private let delimiter = "<<~>>"
    private let artworkTempPath: String = {
        let tempDir = NSTemporaryDirectory()
        return (tempDir as NSString).appendingPathComponent("notchisland_artwork.tiff")
    }()

    private init() {
        artworkCache.countLimit = 30
        startMonitoring()
    }

    private func debugLog(_ message: String) {
        NSLog("[NotchIsland] %@", message)

        // Write to home directory instead of /tmp for better access
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let logFile = homeDir.appendingPathComponent("notchisland_debug.log")

        let timestampedMessage = "\(Date()): \(message)\n"
        if let data = timestampedMessage.data(using: .utf8) {
            if FileManager.default.fileExists(atPath: logFile.path) {
                if let fileHandle = try? FileHandle(forWritingTo: logFile) {
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                    try? fileHandle.close()
                }
            } else {
                try? data.write(to: logFile)
            }
        }
    }

    func startMonitoring() {
        debugLog("🚀 Starting monitoring...")
        // Check every 2 seconds
        updateTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.debugLog("⏰ Timer fired")
            // Run on background queue to avoid blocking main thread
            // But AppleScript execution itself will be on main thread
            self?.backgroundQueue.async {
                self?.updateCurrentTrack()
            }
        }

        // Initial check on background queue
        debugLog("🎬 Running initial check...")
        backgroundQueue.async { [weak self] in
            self?.updateCurrentTrack()
        }
    }

    func updateCurrentTrack() {
        // Priority order: Music apps first, then browsers
        // Only check apps that are actually running
        let sources: [(AudioApp, String, () -> UniversalTrack?, () -> Bool)] = [
            (.appleMusic, "Music", getMusicTrack, isMusicPlaying),
            (.spotify, "Spotify", getSpotifyTrack, isSpotifyPlaying),
            (.chrome, "Google Chrome", getChromeTrack, isChromePlaying),
            (.safari, "Safari", getSafariTrack, isSafariPlaying),
            (.arc, "Arc", getArcTrack, isArcPlaying),
            (.firefox, "Firefox", getFirefoxTrack, isFirefoxPlaying)
        ]

        for (source, appName, trackGetter, playingChecker) in sources {
            // Skip if app is not running
            guard isAppRunning(appName) else {
                debugLog("📱 \(appName) not running")
                continue
            }

            debugLog("🔍 Checking \(appName)...")
            if let track = trackGetter() {
                debugLog("✅ Found: \(track.title)")
                let playing = playingChecker()
                DispatchQueue.main.async {
                    self.currentTrack = track
                    self.isPlaying = playing
                }
                return
            } else {
                debugLog("❌ No track in \(appName)")
            }
        }

        // No audio detected
        debugLog("🔇 No audio detected")
        DispatchQueue.main.async {
            self.currentTrack = nil
            self.isPlaying = false
        }
    }

    /// Check if an application is currently running
    private func isAppRunning(_ appName: String) -> Bool {
        let runningApps = NSWorkspace.shared.runningApplications
        return runningApps.contains { app in
            app.localizedName == appName || app.bundleIdentifier?.contains(appName.lowercased().replacingOccurrences(of: " ", with: "")) == true
        }
    }

    // MARK: - Apple Music

    private func getMusicTrack() -> UniversalTrack? {
        // Check if Music is actually running first to avoid auto-launching
        let checkScript = """
        tell application "System Events"
            return (name of processes) contains "Music"
        end tell
        """

        guard let isRunning = runAppleScript(checkScript),
              isRunning == "true" else { return nil }

        let script = """
        tell application "Music"
            if player state is playing or player state is paused then
                set trackName to name of current track
                set trackArtist to artist of current track
                return trackName & "\(delimiter)" & trackArtist
            end if
        end tell
        """

        guard let result = runAppleScript(script),
              !result.isEmpty else { return nil }

        let parts = result.components(separatedBy: delimiter)
        guard parts.count >= 2 else { return nil }

        let artwork = getMusicArtwork()
        return UniversalTrack(
            title: parts[0],
            artist: parts[1],
            artwork: artwork,
            source: .appleMusic,
            url: nil
        )
    }

    private func isMusicPlaying() -> Bool {
        let script = """
        tell application "Music"
            return player state is playing
        end tell
        """
        return runAppleScript(script) == "true"
    }

    private func getMusicArtwork() -> NSImage? {
        let script = """
        tell application "Music"
            if player state is playing or player state is paused then
                try
                    set artData to raw data of artwork 1 of current track
                    set fileRef to open for access POSIX file "\(artworkTempPath)" with write permission
                    set eof fileRef to 0
                    write artData to fileRef
                    close access fileRef
                    return "success"
                end try
            end if
        end tell
        """

        guard runAppleScript(script) == "success",
              let data = try? Data(contentsOf: URL(fileURLWithPath: artworkTempPath)),
              let image = NSImage(data: data) else { return nil }

        try? FileManager.default.removeItem(atPath: artworkTempPath)
        return image
    }

    // MARK: - Spotify

    private func getSpotifyTrack() -> UniversalTrack? {
        // Check if Spotify is actually running first to avoid auto-launching
        let checkScript = """
        tell application "System Events"
            return (name of processes) contains "Spotify"
        end tell
        """

        guard let isRunning = runAppleScript(checkScript),
              isRunning == "true" else { return nil }

        let script = """
        tell application "Spotify"
            if player state is playing or player state is paused then
                set trackName to name of current track
                set trackArtist to artist of current track
                return trackName & "\(delimiter)" & trackArtist
            end if
        end tell
        """

        guard let result = runAppleScript(script),
              !result.isEmpty else { return nil }

        let parts = result.components(separatedBy: delimiter)
        guard parts.count >= 2 else { return nil }

        return UniversalTrack(
            title: parts[0],
            artist: parts[1],
            artwork: getSpotifyArtwork(),
            source: .spotify,
            url: nil
        )
    }

    private func isSpotifyPlaying() -> Bool {
        let script = """
        tell application "Spotify"
            return player state is playing
        end tell
        """
        return runAppleScript(script) == "true"
    }

    private func getSpotifyArtwork() -> NSImage? {
        let script = """
        tell application "Spotify"
            return artwork url of current track
        end tell
        """

        guard let urlString = runAppleScript(script),
              let url = URL(string: urlString),
              let data = try? Data(contentsOf: url, options: .mappedIfSafe),
              let image = NSImage(data: data) else { return nil }

        return image
    }

    // MARK: - Chrome

    private func getChromeTrack() -> UniversalTrack? {
        // Check if Chrome is actually running first
        let checkScript = """
        tell application "System Events"
            return (name of processes) contains "Google Chrome"
        end tell
        """

        guard let isRunning = runAppleScript(checkScript),
              isRunning == "true" else {
            debugLog("Chrome is not running (process check)")
            return nil
        }

        let script = """
        tell application "Google Chrome"
            set tabTitle to ""
            set tabURL to ""
            repeat with w in windows
                repeat with t in tabs of w
                    if URL of t contains "youtube.com" or URL of t contains "spotify.com" or URL of t contains "music.apple.com" or URL of t contains "soundcloud.com" then
                        set tabTitle to title of t
                        set tabURL to URL of t
                        exit repeat
                    end if
                end repeat
                if tabTitle is not "" then exit repeat
            end repeat
            if tabTitle is not "" then
                return tabTitle & "\(delimiter)" & tabURL
            else
                return "NO_TAB_FOUND"
            end if
        end tell
        """

        guard let result = runAppleScript(script) else {
            debugLog("Chrome script returned nil (likely permission error)")
            return nil
        }

        debugLog("Chrome script result: '\(result)'")

        if result == "NO_TAB_FOUND" {
            debugLog("No music tab found in Chrome")
            return nil
        }

        guard !result.isEmpty else {
            debugLog("Chrome script returned empty string")
            return nil
        }

        let parts = result.components(separatedBy: delimiter)
        guard !parts.isEmpty else { return nil }

        let title = cleanBrowserTitle(parts[0])
        let url = parts.count > 1 ? parts[1] : nil

        debugLog("✅ Chrome track found: \(title)")

        return UniversalTrack(
            title: title,
            artist: nil,
            artwork: nil,
            source: .chrome,
            url: url
        )
    }

    private func isChromePlaying() -> Bool {
        // If we found a track, it's likely playing
        return getChromeTrack() != nil
    }

    // MARK: - Safari

    private func getSafariTrack() -> UniversalTrack? {
        // Check if Safari is actually running first
        let checkScript = """
        tell application "System Events"
            return (name of processes) contains "Safari"
        end tell
        """

        guard let isRunning = runAppleScript(checkScript),
              isRunning == "true" else { return nil }

        let script = """
        tell application "Safari"
            set tabTitle to ""
            set tabURL to ""
            repeat with w in windows
                repeat with t in tabs of w
                    set currentURL to URL of t
                    if currentURL contains "youtube.com" or currentURL contains "spotify.com" or currentURL contains "music.apple.com" or currentURL contains "soundcloud.com" then
                        set tabTitle to name of t
                        set tabURL to currentURL
                        exit repeat
                    end if
                end repeat
                if tabTitle is not "" then exit repeat
            end repeat
            if tabTitle is not "" then
                return tabTitle & "\(delimiter)" & tabURL
            end if
        end tell
        """

        guard let result = runAppleScript(script),
              !result.isEmpty else { return nil }

        let parts = result.components(separatedBy: delimiter)
        guard !parts.isEmpty else { return nil }

        let title = cleanBrowserTitle(parts[0])
        let url = parts.count > 1 ? parts[1] : nil

        return UniversalTrack(
            title: title,
            artist: nil,
            artwork: nil,
            source: .safari,
            url: url
        )
    }

    private func isSafariPlaying() -> Bool {
        return getSafariTrack() != nil
    }

    // MARK: - Arc Browser

    private func getArcTrack() -> UniversalTrack? {
        // Check if Arc is actually running first
        let checkScript = """
        tell application "System Events"
            return (name of processes) contains "Arc"
        end tell
        """

        guard let isRunning = runAppleScript(checkScript),
              isRunning == "true" else { return nil }

        let script = """
        tell application "Arc"
            set tabTitle to ""
            set tabURL to ""
            repeat with w in windows
                repeat with t in tabs of w
                    set currentURL to URL of t
                    if currentURL contains "youtube.com" or currentURL contains "spotify.com" or currentURL contains "music.apple.com" or currentURL contains "soundcloud.com" then
                        set tabTitle to title of t
                        set tabURL to currentURL
                        exit repeat
                    end if
                end repeat
                if tabTitle is not "" then exit repeat
            end repeat
            if tabTitle is not "" then
                return tabTitle & "\(delimiter)" & tabURL
            end if
        end tell
        """

        guard let result = runAppleScript(script),
              !result.isEmpty else { return nil }

        let parts = result.components(separatedBy: delimiter)
        guard !parts.isEmpty else { return nil }

        let title = cleanBrowserTitle(parts[0])
        let url = parts.count > 1 ? parts[1] : nil

        return UniversalTrack(
            title: title,
            artist: nil,
            artwork: nil,
            source: .arc,
            url: url
        )
    }

    private func isArcPlaying() -> Bool {
        return getArcTrack() != nil
    }

    // MARK: - Firefox

    private func getFirefoxTrack() -> UniversalTrack? {
        // Firefox doesn't have great AppleScript support, best effort
        return nil
    }

    private func isFirefoxPlaying() -> Bool {
        return false
    }

    // MARK: - Helpers

    private func cleanBrowserTitle(_ title: String) -> String {
        // Remove common suffixes from browser tab titles
        var cleaned = title
        let suffixes = [" - YouTube", " - Spotify", " - Apple Music", " | Spotify"]
        for suffix in suffixes {
            if let range = cleaned.range(of: suffix) {
                cleaned = String(cleaned[..<range.lowerBound])
            }
        }
        return cleaned.trimmingCharacters(in: .whitespaces)
    }

    // MARK: - Playback Controls

    func togglePlayPause() {
        guard let track = currentTrack else { return }

        switch track.source {
        case .appleMusic:
            sendMusicCommand("playpause")
        case .spotify:
            sendSpotifyCommand("playpause")
        case .chrome:
            // Send space key to Chrome (play/pause)
            sendBrowserPlayPause(to: "Google Chrome")
        case .safari:
            sendBrowserPlayPause(to: "Safari")
        case .arc:
            sendBrowserPlayPause(to: "Arc")
        default:
            break
        }

        backgroundQueue.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.updateCurrentTrack()
        }
    }

    private func sendMusicCommand(_ command: String) {
        let script = """
        tell application "Music"
            \(command)
        end tell
        """
        runAppleScript(script)
    }

    private func sendSpotifyCommand(_ command: String) {
        let script = """
        tell application "Spotify"
            \(command)
        end tell
        """
        runAppleScript(script)
    }

    private func sendBrowserPlayPause(to browser: String) {
        let script = """
        tell application "\(browser)"
            activate
        end tell
        tell application "System Events"
            keystroke " "
        end tell
        """
        runAppleScript(script)
    }

    // MARK: - AppleScript

    private func runAppleScript(_ script: String) -> String? {
        // AppleScript must run on main thread to avoid permission issues
        // But we'll call this from background thread, so we need to dispatch
        var result: String?
        let semaphore = DispatchSemaphore(value: 0)

        DispatchQueue.main.async {
            var error: NSDictionary?
            let appleScript = NSAppleScript(source: script)
            let scriptResult = appleScript?.executeAndReturnError(&error)

            if let error = error {
                // Log detailed error information
                let errorCode = error[NSAppleScript.errorNumber] as? Int ?? 0
                let errorMessage = error[NSAppleScript.errorMessage] as? String ?? "Unknown error"
                self.debugLog("❌ AppleScript error \(errorCode): \(errorMessage)")

                // Check if this is an automation permission error
                // Error -1743 typically means permission denied or app not authorized
                if errorCode == -1743 {
                    self.checkAutomationPermissions(for: script)
                }
                result = nil
            } else {
                result = scriptResult?.stringValue
            }

            semaphore.signal()
        }

        semaphore.wait()
        return result
    }

    private var hasShownPermissionAlert = false

    private func checkAutomationPermissions(for script: String) {
        // Only show alert once to avoid spamming the user
        guard !hasShownPermissionAlert else { return }

        // Determine which app the script is trying to control
        var targetApp = "applications"
        if script.contains("Google Chrome") {
            targetApp = "Google Chrome"
        } else if script.contains("Safari") {
            targetApp = "Safari"
        } else if script.contains("Arc") {
            targetApp = "Arc"
        } else if script.contains("Firefox") {
            targetApp = "Firefox"
        }

        hasShownPermissionAlert = true

        // Show alert on main thread
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Automation Permission Required"
            alert.informativeText = "NotchIsland needs permission to detect audio from \(targetApp).\n\nPlease go to:\nSystem Settings → Privacy & Security → Automation\n\nThen enable NotchIsland to control \(targetApp).\n\nAfter granting permission, the audio detection will work automatically."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "Open System Settings")
            alert.addButton(withTitle: "Later")

            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                // Open System Settings to Automation pane
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation") {
                    NSWorkspace.shared.open(url)
                }
            }
        }
    }

    deinit {
        updateTimer?.invalidate()
        try? FileManager.default.removeItem(atPath: artworkTempPath)
    }
}
