//
//  UniversalAudioManager.swift
//  NotchIsland
//
//  Universal audio manager that detects playback from ANY application
//  Primary: MediaRemote framework (detects all system audio like Control Center)
//  Fallback: AppleScript for Music.app and Spotify (if MediaRemote unavailable)
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
    let duration: Double?      // Total duration in seconds
    let elapsedTime: Double?   // Current playback position in seconds

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
    @Published var systemVolume: Float = 0.5

    private let mediaRemote = MediaRemoteManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var volumeTimer: Timer?

    // AppleScript fallback (only used if MediaRemote unavailable)
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

        if mediaRemote.isAvailable {
            NSLog("[NotchIsland] Using MediaRemote + AppleScript hybrid detection")
            setupHybridDetection()
        } else {
            NSLog("[NotchIsland] MediaRemote unavailable, using AppleScript only")
            startAppleScriptMonitoring()
        }

        // Read initial system volume on background thread to avoid blocking init
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let vol = Self.getSystemVolume()
            DispatchQueue.main.async { self?.systemVolume = vol }
        }

        // Poll system volume periodically
        volumeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            DispatchQueue.global(qos: .userInitiated).async {
                let vol = Self.getSystemVolume()
                DispatchQueue.main.async {
                    if self?.systemVolume != vol { self?.systemVolume = vol }
                }
            }
        }
    }

    // MARK: - Hybrid Detection (MediaRemote + AppleScript fallback)

    private func setupHybridDetection() {
        // When MediaRemote finds a track, use it; otherwise fall back to AppleScript
        mediaRemote.$currentTrack
            .receive(on: DispatchQueue.main)
            .sink { [weak self] track in
                if let track = track {
                    // MediaRemote found something — use it
                    self?.currentTrack = track
                }
                // If nil, the poll timer below will try AppleScript
            }
            .store(in: &cancellables)

        mediaRemote.$isPlaying
            .receive(on: DispatchQueue.main)
            .sink { [weak self] playing in
                // Only update if MediaRemote has a track
                if self?.mediaRemote.currentTrack != nil {
                    self?.isPlaying = playing
                }
            }
            .store(in: &cancellables)

        // Poll with AppleScript as fallback when MediaRemote finds nothing
        updateTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            // If MediaRemote already has a track, skip AppleScript
            if self.mediaRemote.currentTrack != nil { return }

            self.backgroundQueue.async {
                self.updateCurrentTrackAppleScript()
            }
        }

        // Initial AppleScript check too
        backgroundQueue.async { [weak self] in
            self?.updateCurrentTrackAppleScript()
        }
    }

    // MARK: - Playback Controls

    func togglePlayPause() {
        if mediaRemote.isAvailable {
            mediaRemote.togglePlayPause()
        } else {
            togglePlayPauseAppleScript()
        }
    }

    func nextTrack() {
        if mediaRemote.isAvailable {
            mediaRemote.nextTrack()
        }
    }

    func previousTrack() {
        if mediaRemote.isAvailable {
            mediaRemote.previousTrack()
        }
    }

    // MARK: - Volume Control

    func setSystemVolume(_ volume: Float) {
        let clamped = max(0, min(1, volume))
        systemVolume = clamped
        DispatchQueue.global(qos: .userInitiated).async {
            let script = "set volume output volume \(Int(clamped * 100))"
            let task = Process()
            task.launchPath = "/usr/bin/osascript"
            task.arguments = ["-e", script]
            task.standardOutput = Pipe()
            task.standardError = Pipe()
            try? task.run()
        }
    }

    static func getSystemVolume() -> Float {
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["-e", "output volume of (get volume settings)"]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()
        do {
            try task.run()
            task.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let str = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
               let vol = Int(str) {
                return Float(vol) / 100.0
            }
        } catch {}
        return 0.5
    }

    // MARK: - AppleScript Fallback

    private func startAppleScriptMonitoring() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.backgroundQueue.async {
                self?.updateCurrentTrackAppleScript()
            }
        }
        backgroundQueue.async { [weak self] in
            self?.updateCurrentTrackAppleScript()
        }
    }

    private func updateCurrentTrackAppleScript() {
        let sources: [(AudioApp, String, () -> UniversalTrack?, () -> Bool)] = [
            (.appleMusic, "Music", getMusicTrack, isMusicPlaying),
            (.spotify, "Spotify", getSpotifyTrack, isSpotifyPlaying),
            (.chrome, "Google Chrome", getChromeTrack, isChromePlaying),
            (.safari, "Safari", getSafariTrack, isSafariPlaying),
            (.arc, "Arc", getArcTrack, isArcPlaying),
        ]

        for (_, appName, trackGetter, playingChecker) in sources {
            guard isAppRunning(appName) else { continue }
            if let track = trackGetter() {
                let playing = playingChecker()
                DispatchQueue.main.async {
                    self.currentTrack = track
                    self.isPlaying = playing
                }
                return
            }
        }

        DispatchQueue.main.async {
            self.currentTrack = nil
            self.isPlaying = false
        }
    }

    private func isAppRunning(_ appName: String) -> Bool {
        let runningApps = NSWorkspace.shared.runningApplications
        return runningApps.contains { app in
            app.localizedName == appName || app.bundleIdentifier?.contains(appName.lowercased().replacingOccurrences(of: " ", with: "")) == true
        }
    }

    // MARK: - Apple Music (AppleScript)

    private func getMusicTrack() -> UniversalTrack? {
        // isAppRunning already confirmed Music is running, query directly
        let script = """
        tell application "Music"
            if player state is playing then
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
            artwork: getMusicArtwork(),
            source: .appleMusic,
            url: nil,
            duration: nil,
            elapsedTime: nil
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

    // MARK: - Spotify (AppleScript)

    private func getSpotifyTrack() -> UniversalTrack? {
        let script = """
        tell application "Spotify"
            if player state is playing then
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
            url: nil,
            duration: nil,
            elapsedTime: nil
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

    // MARK: - Chrome (AppleScript)

    private func getChromeTrack() -> UniversalTrack? {
        let script = """
        tell application "Google Chrome"
            set tabTitle to ""
            set tabURL to ""
            repeat with w in windows
                repeat with t in tabs of w
                    set currentURL to URL of t
                    if currentURL contains "youtube.com" or currentURL contains "youtu.be" or currentURL contains "music.youtube.com" or currentURL contains "spotify.com" or currentURL contains "music.apple.com" or currentURL contains "soundcloud.com" or currentURL contains "deezer.com" or currentURL contains "tidal.com" or currentURL contains "pandora.com" or currentURL contains "nhaccuatui.com" or currentURL contains "zingmp3.vn" or currentURL contains "bandcamp.com" or currentURL contains "audiomack.com" then
                        set tabTitle to title of t
                        set tabURL to currentURL
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

        guard let result = runAppleScript(script),
              result != "NO_TAB_FOUND",
              !result.isEmpty else { return nil }

        let parts = result.components(separatedBy: delimiter)
        guard !parts.isEmpty else { return nil }

        let title = cleanBrowserTitle(parts[0])
        let url = parts.count > 1 ? parts[1] : nil

        return UniversalTrack(
            title: title,
            artist: nil,
            artwork: nil,
            source: .chrome,
            url: url,
            duration: nil,
            elapsedTime: nil
        )
    }

    private func isChromePlaying() -> Bool {
        return getChromeTrack() != nil
    }

    // MARK: - Safari (AppleScript)

    private func getSafariTrack() -> UniversalTrack? {
        let script = """
        tell application "Safari"
            set tabTitle to ""
            set tabURL to ""
            repeat with w in windows
                repeat with t in tabs of w
                    set currentURL to URL of t
                    if currentURL contains "youtube.com" or currentURL contains "youtu.be" or currentURL contains "music.youtube.com" or currentURL contains "spotify.com" or currentURL contains "music.apple.com" or currentURL contains "soundcloud.com" or currentURL contains "deezer.com" or currentURL contains "tidal.com" or currentURL contains "pandora.com" or currentURL contains "nhaccuatui.com" or currentURL contains "zingmp3.vn" or currentURL contains "bandcamp.com" or currentURL contains "audiomack.com" then
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
            url: url,
            duration: nil,
            elapsedTime: nil
        )
    }

    private func isSafariPlaying() -> Bool {
        return getSafariTrack() != nil
    }

    // MARK: - Arc Browser (AppleScript)

    private func getArcTrack() -> UniversalTrack? {
        let script = """
        tell application "Arc"
            set tabTitle to ""
            set tabURL to ""
            repeat with w in windows
                repeat with t in tabs of w
                    set currentURL to URL of t
                    if currentURL contains "youtube.com" or currentURL contains "youtu.be" or currentURL contains "music.youtube.com" or currentURL contains "spotify.com" or currentURL contains "music.apple.com" or currentURL contains "soundcloud.com" or currentURL contains "deezer.com" or currentURL contains "tidal.com" or currentURL contains "pandora.com" or currentURL contains "nhaccuatui.com" or currentURL contains "zingmp3.vn" or currentURL contains "bandcamp.com" or currentURL contains "audiomack.com" then
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
            url: url,
            duration: nil,
            elapsedTime: nil
        )
    }

    private func isArcPlaying() -> Bool {
        return getArcTrack() != nil
    }

    // MARK: - Helpers

    private func cleanBrowserTitle(_ title: String) -> String {
        var cleaned = title
        let suffixes = [" - YouTube", " - YouTube Music", " | YouTube Music", " - Spotify", " - Apple Music", " | Spotify", " - SoundCloud", " | SoundCloud", " | Deezer", " - Deezer", " | Bandcamp"]
        for suffix in suffixes {
            if let range = cleaned.range(of: suffix) {
                cleaned = String(cleaned[..<range.lowerBound])
            }
        }
        return cleaned.trimmingCharacters(in: .whitespaces)
    }

    private func togglePlayPauseAppleScript() {
        guard let track = currentTrack else { return }

        switch track.source {
        case .appleMusic:
            runAppleScript("tell application \"Music\" to playpause")
        case .spotify:
            runAppleScript("tell application \"Spotify\" to playpause")
        case .chrome:
            sendBrowserPlayPause(to: "Google Chrome")
        case .safari:
            sendBrowserPlayPause(to: "Safari")
        case .arc:
            sendBrowserPlayPause(to: "Arc")
        default:
            break
        }

        backgroundQueue.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.updateCurrentTrackAppleScript()
        }
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

    // MARK: - AppleScript Runner

    @discardableResult
    private func runAppleScript(_ script: String) -> String? {
        // NSAppleScript can run on any thread
        var error: NSDictionary?
        let appleScript = NSAppleScript(source: script)
        let scriptResult = appleScript?.executeAndReturnError(&error)

        if let error = error {
            let errorCode = error[NSAppleScript.errorNumber] as? Int ?? 0
            let errorMessage = error[NSAppleScript.errorMessage] as? String ?? "Unknown error"
            // Only log unexpected errors (not "app not running" or "not authorized" type errors)
            if errorCode != -1728 && errorCode != -600 && errorCode != -10810 && errorCode != -1743 {
                NSLog("[NotchIsland] AppleScript error %d: %@", errorCode, errorMessage)
            }
            return nil
        }

        return scriptResult?.stringValue
    }

    deinit {
        updateTimer?.invalidate()
        volumeTimer?.invalidate()
        try? FileManager.default.removeItem(atPath: artworkTempPath)
    }
}
