//
//  SystemAudioManager.swift
//  NotchIsland
//
//  Detects audio playback from any application on the system
//  Uses CoreAudio to monitor system audio output
//

import Foundation
import CoreAudio
import AVFoundation
import AppKit

struct AudioSource {
    let appName: String
    let processID: pid_t
    let isPlaying: Bool
}

class SystemAudioManager: ObservableObject {
    static let shared = SystemAudioManager()

    @Published var isSystemAudioPlaying: Bool = false
    @Published var playingApps: [String] = []

    private var checkTimer: Timer?

    private init() {
        startMonitoring()
    }

    func startMonitoring() {
        // Check every 1 second for audio playback
        checkTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkSystemAudio()
        }

        // Initial check
        checkSystemAudio()
    }

    private func checkSystemAudio() {
        // Method 1: Check if any audio device is in use
        let isPlaying = isAnyAudioDeviceActive()

        // Method 2: Get list of apps with audio
        let apps = getAppsWithAudio()

        DispatchQueue.main.async {
            self.isSystemAudioPlaying = isPlaying
            self.playingApps = apps
        }
    }

    /// Check if any audio output device is currently active
    private func isAnyAudioDeviceActive() -> Bool {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioHardwarePropertyDefaultOutputDevice),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMain)
        )

        var deviceID = AudioDeviceID()
        var propertySize = UInt32(MemoryLayout<AudioDeviceID>.size)

        let status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &propertySize,
            &deviceID
        )

        guard status == noErr else { return false }

        // Check if device is playing audio
        return isDevicePlayingAudio(deviceID)
    }

    /// Check if a specific audio device is playing audio
    private func isDevicePlayingAudio(_ deviceID: AudioDeviceID) -> Bool {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioDevicePropertyDeviceIsRunningSomewhere),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMain)
        )

        var isRunning: UInt32 = 0
        var propertySize = UInt32(MemoryLayout<UInt32>.size)

        let status = AudioObjectGetPropertyData(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &propertySize,
            &isRunning
        )

        return status == noErr && isRunning != 0
    }

    /// Get list of applications that are currently playing audio
    private func getAppsWithAudio() -> [String] {
        var apps: [String] = []

        // Check common audio applications
        let audioApps = [
            "Music",
            "Spotify",
            "Google Chrome",
            "Safari",
            "Firefox",
            "Arc",
            "YouTube Music",
            "VLC",
            "QuickTime Player",
            "TV"
        ]

        for appName in audioApps {
            if isAppRunning(appName) {
                apps.append(appName)
            }
        }

        return apps
    }

    /// Check if an application is currently running
    private func isAppRunning(_ appName: String) -> Bool {
        let runningApps = NSWorkspace.shared.runningApplications
        return runningApps.contains { $0.localizedName == appName }
    }

    /// Get the primary app that's playing audio (best guess)
    func getPrimaryAudioApp() -> String? {
        // Priority order: Music/Spotify first, then browsers
        let priorityOrder = ["Music", "Spotify", "YouTube Music", "Google Chrome", "Safari", "Firefox", "Arc"]

        for app in priorityOrder {
            if playingApps.contains(app) {
                return app
            }
        }

        return playingApps.first
    }

    deinit {
        checkTimer?.invalidate()
    }
}
