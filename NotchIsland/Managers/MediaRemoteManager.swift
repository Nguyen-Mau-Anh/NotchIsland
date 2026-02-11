//
//  MediaRemoteManager.swift
//  NotchIsland
//
//  Uses macOS MediaRemote private framework to detect audio from ALL apps
//  Dynamically loads the framework at runtime - no linking needed
//  This is the same API that macOS Control Center uses for Now Playing
//

import Foundation
import AppKit
import Combine

// MARK: - MediaRemote Dynamic Bindings

private class MediaRemoteBindings {
    static let shared = MediaRemoteBindings()

    private var handle: UnsafeMutableRawPointer?
    private(set) var isLoaded = false

    // Function pointers
    private(set) var getNowPlayingInfo: (@convention(c) (DispatchQueue, @escaping (CFDictionary) -> Void) -> Void)?
    private(set) var getIsPlaying: (@convention(c) (DispatchQueue, @escaping (Bool) -> Void) -> Void)?
    private(set) var getNowPlayingAppPID: (@convention(c) (DispatchQueue, @escaping (Int32) -> Void) -> Void)?
    private(set) var registerForNotifications: (@convention(c) (DispatchQueue) -> Void)?
    private(set) var sendCommand: (@convention(c) (UInt32, UnsafeMutableRawPointer?) -> Bool)?

    // Info dictionary keys
    private(set) var kTitle: NSString?
    private(set) var kArtist: NSString?
    private(set) var kAlbum: NSString?
    private(set) var kArtworkData: NSString?
    private(set) var kDuration: NSString?
    private(set) var kElapsedTime: NSString?

    // Notification names
    private(set) var nowPlayingInfoChangedNotification: NSString?
    private(set) var isPlayingChangedNotification: NSString?

    private init() {
        loadFramework()
    }

    private func loadFramework() {
        let path = "/System/Library/PrivateFrameworks/MediaRemote.framework/MediaRemote"
        handle = dlopen(path, RTLD_LAZY)

        guard handle != nil else {
            NSLog("[NotchIsland] MediaRemote: Failed to load framework from \(path)")
            return
        }

        // Load functions
        getNowPlayingInfo = loadFunction("MRMediaRemoteGetNowPlayingInfo")
        getIsPlaying = loadFunction("MRMediaRemoteGetNowPlayingApplicationIsPlaying")
        getNowPlayingAppPID = loadFunction("MRMediaRemoteGetNowPlayingApplicationPID")
        registerForNotifications = loadFunction("MRMediaRemoteRegisterForNowPlayingNotifications")
        sendCommand = loadFunction("MRMediaRemoteSendCommand")

        // Load string constants
        kTitle = loadStringConstant("kMRMediaRemoteNowPlayingInfoTitle")
        kArtist = loadStringConstant("kMRMediaRemoteNowPlayingInfoArtist")
        kAlbum = loadStringConstant("kMRMediaRemoteNowPlayingInfoAlbum")
        kArtworkData = loadStringConstant("kMRMediaRemoteNowPlayingInfoArtworkData")
        kDuration = loadStringConstant("kMRMediaRemoteNowPlayingInfoDuration")
        kElapsedTime = loadStringConstant("kMRMediaRemoteNowPlayingInfoElapsedTime")

        nowPlayingInfoChangedNotification = loadStringConstant("kMRMediaRemoteNowPlayingInfoDidChangeNotification")
        isPlayingChangedNotification = loadStringConstant("kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification")

        isLoaded = getNowPlayingInfo != nil && getIsPlaying != nil
        NSLog("[NotchIsland] MediaRemote: Framework loaded = \(isLoaded)")
    }

    private func loadFunction<T>(_ name: String) -> T? {
        guard let handle = handle else { return nil }
        guard let sym = dlsym(handle, name) else {
            NSLog("[NotchIsland] MediaRemote: Symbol not found: \(name)")
            return nil
        }
        return unsafeBitCast(sym, to: T.self)
    }

    private func loadStringConstant(_ name: String) -> NSString? {
        guard let handle = handle else { return nil }
        guard let sym = dlsym(handle, name) else { return nil }
        let ptr = sym.assumingMemoryBound(to: NSString?.self)
        return ptr.pointee
    }

    deinit {
        if let handle = handle {
            dlclose(handle)
        }
    }
}

// MARK: - MediaRemote Manager

class MediaRemoteManager: ObservableObject {
    static let shared = MediaRemoteManager()

    @Published var currentTrack: UniversalTrack?
    @Published var isPlaying: Bool = false

    private let bindings = MediaRemoteBindings.shared
    private var pollTimer: Timer?
    private let updateQueue = DispatchQueue(label: "com.notchisland.mediaremote", qos: .userInitiated)
    private var artworkCache = NSCache<NSString, NSImage>()
    private var infoObserver: NSObjectProtocol?
    private var playingObserver: NSObjectProtocol?

    var isAvailable: Bool { bindings.isLoaded }

    private init() {
        artworkCache.countLimit = 30
        if bindings.isLoaded {
            startMonitoring()
        } else {
            NSLog("[NotchIsland] MediaRemote: Not available, falling back to AppleScript")
        }
    }

    func startMonitoring() {
        guard bindings.isLoaded else { return }
        NSLog("[NotchIsland] MediaRemote: Starting monitoring...")

        // Register for notifications
        bindings.registerForNotifications?(DispatchQueue.main)

        // Listen for Now Playing changes
        if let notifName = bindings.nowPlayingInfoChangedNotification as? String {
            infoObserver = NotificationCenter.default.addObserver(
                forName: NSNotification.Name(notifName),
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.fetchNowPlaying()
            }
        }

        if let notifName = bindings.isPlayingChangedNotification as? String {
            playingObserver = NotificationCenter.default.addObserver(
                forName: NSNotification.Name(notifName),
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.fetchNowPlaying()
            }
        }

        // Also poll every 3 seconds as backup (notifications can be unreliable)
        pollTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.fetchNowPlaying()
        }

        // Initial fetch
        fetchNowPlaying()
    }

    func fetchNowPlaying() {
        guard bindings.isLoaded else { return }

        // Check playing state
        bindings.getIsPlaying?(DispatchQueue.main) { [weak self] playing in
            guard let self = self else { return }
            self.isPlaying = playing
        }

        // Get track info
        bindings.getNowPlayingInfo?(DispatchQueue.main) { [weak self] info in
            guard let self = self else { return }
            let dict = info as NSDictionary

            guard let titleKey = self.bindings.kTitle,
                  let title = dict[titleKey] as? String,
                  !title.isEmpty else {
                self.currentTrack = nil
                self.isPlaying = false
                return
            }

            let artist = self.bindings.kArtist.flatMap { dict[$0] as? String }
            let album = self.bindings.kAlbum.flatMap { dict[$0] as? String }
            let duration = self.bindings.kDuration.flatMap { dict[$0] as? Double }
            let elapsed = self.bindings.kElapsedTime.flatMap { dict[$0] as? Double }

            // Get artwork
            var artwork: NSImage?
            let cacheKey = "\(title)~~\(artist ?? "")~~\(album ?? "")" as NSString

            if let cached = self.artworkCache.object(forKey: cacheKey) {
                artwork = cached
            } else if let artKey = self.bindings.kArtworkData, let artData = dict[artKey] as? Data {
                if let img = NSImage(data: artData) {
                    artwork = img
                    self.artworkCache.setObject(img, forKey: cacheKey)
                }
            }

            // Determine source app from PID
            self.bindings.getNowPlayingAppPID?(DispatchQueue.main) { [weak self] pid in
                guard let self = self else { return }
                let source = self.audioAppFromPID(pid)

                let track = UniversalTrack(
                    title: title,
                    artist: artist,
                    artwork: artwork,
                    source: source,
                    url: nil,
                    duration: duration,
                    elapsedTime: elapsed
                )

                self.currentTrack = track
            }
        }
    }

    private func audioAppFromPID(_ pid: Int32) -> AudioApp {
        guard pid > 0,
              let app = NSRunningApplication(processIdentifier: pid) else {
            return .unknown
        }

        let bundleID = app.bundleIdentifier ?? ""
        let name = app.localizedName ?? ""

        if bundleID == "com.apple.Music" || name == "Music" {
            return .appleMusic
        } else if bundleID == "com.spotify.client" || name == "Spotify" {
            return .spotify
        } else if bundleID == "com.google.Chrome" || name == "Google Chrome" {
            return .chrome
        } else if bundleID == "com.apple.Safari" || name == "Safari" {
            return .safari
        } else if bundleID == "company.thebrowser.Browser" || name == "Arc" {
            return .arc
        } else if bundleID.contains("firefox") || name == "Firefox" {
            return .firefox
        } else {
            return .unknown
        }
    }

    // MARK: - Playback Controls

    func togglePlayPause() {
        // MRMediaRemoteCommandTogglePlayPause = 2
        _ = bindings.sendCommand?(2, nil)

        // Refresh state after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.fetchNowPlaying()
        }
    }

    func nextTrack() {
        // MRMediaRemoteCommandNextTrack = 4
        _ = bindings.sendCommand?(4, nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.fetchNowPlaying()
        }
    }

    func previousTrack() {
        // MRMediaRemoteCommandPreviousTrack = 5
        _ = bindings.sendCommand?(5, nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.fetchNowPlaying()
        }
    }

    deinit {
        pollTimer?.invalidate()
        if let obs = infoObserver { NotificationCenter.default.removeObserver(obs) }
        if let obs = playingObserver { NotificationCenter.default.removeObserver(obs) }
    }
}
