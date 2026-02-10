//
//  MusicManager.swift
//  NotchIsland
//
//  Manages music playback integration with Apple Music and Spotify
//

import Foundation
import AppKit
import Combine

enum MusicSource {
    case appleMusic
    case spotify
}

struct Track: Equatable {
    let title: String
    let artist: String
    let album: String?
    let artwork: NSImage?
    let source: MusicSource

    /// Cache key for identifying unique tracks
    var cacheKey: String {
        "\(title)~~\(artist)~~\(album ?? "")"
    }

    static func == (lhs: Track, rhs: Track) -> Bool {
        lhs.title == rhs.title && lhs.artist == rhs.artist && lhs.album == rhs.album
    }
}

class MusicManager: ObservableObject {
    static let shared = MusicManager()

    @Published var currentTrack: Track?
    @Published var isPlaying: Bool = false

    private var updateTimer: Timer?

    /// The delimiter used in AppleScript to separate metadata fields.
    /// Using a string unlikely to appear in track metadata.
    private static let delimiter = "<<~>>"

    /// Background queue for music data fetching (avoids blocking main thread)
    private let backgroundQueue = DispatchQueue(label: "com.notchisland.music", qos: .userInitiated)

    /// Cache for album artwork, keyed by track cache key
    private var artworkCache = NSCache<NSString, NSImage>()

    /// Temp file path for Apple Music artwork extraction
    private let artworkTempPath: String = {
        let tempDir = NSTemporaryDirectory()
        return (tempDir as NSString).appendingPathComponent("notchisland_artwork.tiff")
    }()

    private init() {
        artworkCache.countLimit = 20
        startMonitoring()
    }

    func startMonitoring() {
        // Update current track info every 2 seconds
        updateTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.backgroundQueue.async {
                self?.updateCurrentTrack()
            }
        }

        // Initial update
        backgroundQueue.async { [weak self] in
            self?.updateCurrentTrack()
        }
    }

    func updateCurrentTrack() {
        // Try Apple Music (Music.app) first
        if let track = getMusicAppTrack() {
            let playing = isMusicAppPlaying()
            DispatchQueue.main.async {
                self.currentTrack = track
                self.isPlaying = playing
            }
            return
        }

        // Try Spotify
        if let track = getSpotifyTrack() {
            let playing = isSpotifyPlaying()
            DispatchQueue.main.async {
                self.currentTrack = track
                self.isPlaying = playing
            }
            return
        }

        // No music playing
        DispatchQueue.main.async {
            self.currentTrack = nil
            self.isPlaying = false
        }
    }

    // MARK: - Artwork Cache

    private func cachedArtwork(for key: String) -> NSImage? {
        return artworkCache.object(forKey: key as NSString)
    }

    private func cacheArtwork(_ image: NSImage, for key: String) {
        artworkCache.setObject(image, forKey: key as NSString)
    }

    // MARK: - Apple Music (Music.app)

    private func getMusicAppTrack() -> Track? {
        let delim = Self.delimiter
        let script = """
        tell application "Music"
            if player state is playing or player state is paused then
                set trackName to name of current track
                set trackArtist to artist of current track
                set trackAlbum to album of current track
                return trackName & "\(delim)" & trackArtist & "\(delim)" & trackAlbum
            end if
        end tell
        """

        guard let result = runAppleScript(script), !result.isEmpty else {
            return nil
        }

        let components = result.components(separatedBy: delim)
        guard components.count >= 2 else { return nil }

        let title = components[0]
        let artist = components[1]
        let album = components.count > 2 ? components[2] : nil
        let cacheKey = "\(title)~~\(artist)~~\(album ?? "")"

        // Check cache first
        if let cached = cachedArtwork(for: cacheKey) {
            return Track(title: title, artist: artist, album: album, artwork: cached, source: .appleMusic)
        }

        let artwork = getMusicAppArtwork()
        if let artwork = artwork {
            cacheArtwork(artwork, for: cacheKey)
        }

        return Track(title: title, artist: artist, album: album, artwork: artwork, source: .appleMusic)
    }

    private func isMusicAppPlaying() -> Bool {
        let script = """
        tell application "Music"
            if player state is playing then
                return "playing"
            else
                return "paused"
            end if
        end tell
        """

        return runAppleScript(script) == "playing"
    }

    private func getMusicAppArtwork() -> NSImage? {
        // Write artwork data to a temp file via AppleScript, then read it back
        let script = """
        tell application "Music"
            if player state is playing or player state is paused then
                try
                    set artData to raw data of artwork 1 of current track
                    set tempPath to "\(artworkTempPath)"
                    set fileRef to open for access POSIX file tempPath with write permission
                    set eof fileRef to 0
                    write artData to fileRef
                    close access fileRef
                    return "success"
                on error errMsg
                    try
                        close access POSIX file "\(artworkTempPath)"
                    end try
                    return "error:" & errMsg
                end try
            end if
        end tell
        """

        guard let result = runAppleScript(script), result == "success" else {
            return nil
        }

        // Read the temp file as image data
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: artworkTempPath)),
              let image = NSImage(data: data) else {
            return nil
        }

        // Clean up temp file
        try? FileManager.default.removeItem(atPath: artworkTempPath)

        return image
    }

    // MARK: - Spotify

    private func getSpotifyTrack() -> Track? {
        let delim = Self.delimiter
        let script = """
        tell application "Spotify"
            if player state is playing or player state is paused then
                set trackName to name of current track
                set trackArtist to artist of current track
                set trackAlbum to album of current track
                return trackName & "\(delim)" & trackArtist & "\(delim)" & trackAlbum
            end if
        end tell
        """

        guard let result = runAppleScript(script), !result.isEmpty else {
            return nil
        }

        let components = result.components(separatedBy: delim)
        guard components.count >= 2 else { return nil }

        let title = components[0]
        let artist = components[1]
        let album = components.count > 2 ? components[2] : nil
        let cacheKey = "\(title)~~\(artist)~~\(album ?? "")"

        // Check cache first
        if let cached = cachedArtwork(for: cacheKey) {
            return Track(title: title, artist: artist, album: album, artwork: cached, source: .spotify)
        }

        let artwork = getSpotifyArtwork()
        if let artwork = artwork {
            cacheArtwork(artwork, for: cacheKey)
        }

        return Track(title: title, artist: artist, album: album, artwork: artwork, source: .spotify)
    }

    private func isSpotifyPlaying() -> Bool {
        let script = """
        tell application "Spotify"
            if player state is playing then
                return "playing"
            else
                return "paused"
            end if
        end tell
        """

        return runAppleScript(script) == "playing"
    }

    private func getSpotifyArtwork() -> NSImage? {
        let script = """
        tell application "Spotify"
            if player state is playing or player state is paused then
                return artwork url of current track
            end if
        end tell
        """

        guard let urlString = runAppleScript(script),
              !urlString.isEmpty,
              let url = URL(string: urlString) else {
            return nil
        }

        // Fetch artwork from URL with a timeout
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 5)
        guard let (data, _) = try? URLSession.shared.synchronousDataTask(with: request),
              let image = NSImage(data: data) else {
            return nil
        }

        return image
    }

    // MARK: - Playback Controls

    func togglePlayPause() {
        guard let source = currentTrack?.source else { return }
        sendCommand(to: source, command: "playpause")
        backgroundQueue.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.updateCurrentTrack()
        }
    }

    func nextTrack() {
        guard let source = currentTrack?.source else { return }
        sendCommand(to: source, command: "next track")
        backgroundQueue.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.updateCurrentTrack()
        }
    }

    func previousTrack() {
        guard let source = currentTrack?.source else { return }
        sendCommand(to: source, command: "previous track")
        backgroundQueue.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.updateCurrentTrack()
        }
    }

    /// Send a playback command to the specified music app only
    private func sendCommand(to source: MusicSource, command: String) {
        let appName: String
        switch source {
        case .appleMusic: appName = "Music"
        case .spotify: appName = "Spotify"
        }

        let script = """
        tell application "\(appName)"
            \(command)
        end tell
        """
        runAppleScript(script)
    }

    // MARK: - AppleScript Execution

    private func runAppleScript(_ script: String) -> String? {
        var error: NSDictionary?
        let appleScript = NSAppleScript(source: script)
        let result = appleScript?.executeAndReturnError(&error)

        if error != nil {
            return nil
        }

        return result?.stringValue
    }

    deinit {
        updateTimer?.invalidate()
        try? FileManager.default.removeItem(atPath: artworkTempPath)
    }
}

// MARK: - URLSession Synchronous Extension

private extension URLSession {
    /// Performs a synchronous data task (used for artwork fetching on background thread)
    func synchronousDataTask(with request: URLRequest) throws -> (Data, URLResponse) {
        var result: (Data, URLResponse)?
        var error: Error?

        let semaphore = DispatchSemaphore(value: 0)
        let task = self.dataTask(with: request) { data, response, taskError in
            if let data = data, let response = response {
                result = (data, response)
            } else {
                error = taskError ?? URLError(.unknown)
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()

        if let error = error {
            throw error
        }

        return result!
    }
}
