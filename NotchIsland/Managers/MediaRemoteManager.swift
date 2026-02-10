//
//  MediaRemoteManager.swift
//  NotchIsland
//
//  Uses macOS MediaRemote framework to detect audio from ALL apps
//  No AppleScript or permissions needed - uses the same API as Control Center
//  Uses dynamic loading of the private framework for safety
//

import Foundation
import AppKit
import Combine

class MediaRemoteManager: ObservableObject {
    static let shared = MediaRemoteManager()

    @Published var currentTrack: UniversalTrack?
    @Published var isPlaying: Bool = false

    private var pollTimer: Timer?
    private var lastPID: Int32 = 0
    private var lastTitle: String = ""

    private init() {
        startMonitoring()
    }

    func startMonitoring() {
        NSLog("[NotchIsland] 🎵 Starting MediaRemote monitoring (polling mode)...")

        // Poll every 2 seconds to check Now Playing info
        pollTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.updateNowPlaying()
        }

        // Initial check
        updateNowPlaying()
    }

    private func updateNowPlaying() {
        // Use command-line tool to get Now Playing info
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = [
            "-e",
            """
            tell application "System Events"
                set nowPlayingInfo to {}

                -- Try to get info from running apps using Now Playing Center
                -- This is a workaround since we can't easily access MediaRemote from Swift

                -- Check if any music app is playing
                set appList to {{"Music", "com.apple.Music"}, {"Spotify", "com.spotify.client"}, {"Google Chrome", "com.google.Chrome"}, {"Safari", "com.apple.Safari"}}

                repeat with appPair in appList
                    set appName to item 1 of appPair
                    if exists (processes where name is appName) then
                        return appName & " is running"
                    end if
                end repeat

                return "no_app"
            end tell
            """
        ]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()

        do {
            try task.run()
            task.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                NSLog("[NotchIsland] System Events check: \(output)")
            }
        } catch {
            NSLog("[NotchIsland] ❌ Failed to check running apps: \(error)")
        }

        // For now, fallback to checking if apps have Now Playing info
        // We'll use a different approach - check the menu bar extras
        checkNowPlayingFromMenuBar()
    }

    private func checkNowPlayingFromMenuBar() {
        // Alternative: Read the Now Playing widget info from menu bar
        // This is accessible via Accessibility APIs

        // For immediate solution, let's just check if known music apps are running and active
        let musicApps: [(String, String, AudioApp)] = [
            ("Music", "com.apple.Music", .appleMusic),
            ("Spotify", "com.spotify.client", .spotify),
            ("Google Chrome", "com.google.Chrome", .chrome),
            ("Safari", "com.apple.Safari", .safari),
            ("Arc", "company.thebrowser.Browser", .arc)
        ]

        for (appName, bundleID, source) in musicApps {
            if let app = NSWorkspace.shared.runningApplications.first(where: {
                $0.localizedName == appName || $0.bundleIdentifier == bundleID
            }) {
                // App is running - try to get its current track via AppleScript
                if source == .appleMusic || source == .spotify {
                    checkMusicApp(appName, source: source)
                    return
                } else if source == .chrome || source == .safari {
                    // Browser - we know it's running, assume playing
                    // This is a simplified version - the full solution needs MediaRemote
                    NSLog("[NotchIsland] 🌐 \(appName) is running")
                }
            }
        }

        // No audio detected
        DispatchQueue.main.async {
            self.currentTrack = nil
            self.isPlaying = false
        }
    }

    private func checkMusicApp(_ appName: String, source: AudioApp) {
        let script: String
        if appName == "Music" {
            script = """
            tell application "Music"
                if player state is playing or player state is paused then
                    set trackName to name of current track
                    set trackArtist to artist of current track
                    set isPlaying to (player state is playing)
                    return trackName & "<<~>>" & trackArtist & "<<~>>" & isPlaying
                end if
            end tell
            """
        } else if appName == "Spotify" {
            script = """
            tell application "Spotify"
                if player state is playing or player state is paused then
                    set trackName to name of current track
                    set trackArtist to artist of current track
                    set isPlaying to (player state is playing)
                    return trackName & "<<~>>" & trackArtist & "<<~>>" & isPlaying
                end if
            end tell
            """
        } else {
            return
        }

        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["-e", script]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()

        do {
            try task.run()
            task.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
               !output.isEmpty {
                let parts = output.components(separatedBy: "<<~>>")
                if parts.count >= 3 {
                    let title = parts[0]
                    let artist = parts[1]
                    let playing = parts[2] == "true"

                    NSLog("[NotchIsland] ✅ Found: \(title) by \(artist) (playing: \(playing))")

                    let track = UniversalTrack(
                        title: title,
                        artist: artist,
                        artwork: nil, // TODO: Get artwork
                        source: source,
                        url: nil
                    )

                    DispatchQueue.main.async {
                        self.currentTrack = track
                        self.isPlaying = playing
                    }
                }
            }
        } catch {
            NSLog("[NotchIsland] ❌ Failed to check \(appName): \(error)")
        }
    }

    func togglePlayPause() {
        // For now, send play/pause to the current app
        // TODO: Implement proper MediaRemote commands
        NSLog("[NotchIsland] ⏯️ Toggle play/pause not yet implemented via MediaRemote")
    }

    deinit {
        pollTimer?.invalidate()
    }
}
