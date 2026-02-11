//
//  MusicWidgetView.swift
//  NotchIsland
//
//  Now Playing widget styled like macOS Control Center
//

import SwiftUI

struct MusicWidgetView: View {
    @StateObject private var audioManager = UniversalAudioManager.shared
    @Environment(\.notchTheme) private var theme
    @State private var showVolume = false

    var body: some View {
        if let track = audioManager.currentTrack {
            VStack(spacing: 0) {
                // Top: artwork + track info + visualizer
                HStack(spacing: 12) {
                    // Album artwork
                    Group {
                        if let artwork = track.artwork {
                            Image(nsImage: artwork)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            ZStack {
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.4), Color.purple.opacity(0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                Image(systemName: appIcon(for: track.source))
                                    .font(.system(size: 18))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                    }
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                    // Title + Artist
                    VStack(alignment: .leading, spacing: 2) {
                        Text(track.title)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Text(track.displayArtist)
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.6))
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Audio visualizer
                    if audioManager.isPlaying {
                        AudioVisualizer()
                            .frame(width: 20, height: 20)
                    }
                }

                Spacer().frame(height: 10)

                // Progress bar with time labels
                if let duration = track.duration, duration > 0 {
                    let elapsed = track.elapsedTime ?? 0
                    let progress = min(elapsed / duration, 1.0)
                    let remaining = duration - elapsed

                    VStack(spacing: 4) {
                        // Progress bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(height: 4)
                                Capsule()
                                    .fill(Color.white.opacity(0.8))
                                    .frame(width: max(0, geo.size.width * progress), height: 4)
                            }
                        }
                        .frame(height: 4)

                        // Time labels
                        HStack {
                            Text(formatTime(elapsed))
                                .font(.system(size: 10, weight: .medium).monospacedDigit())
                                .foregroundColor(.white.opacity(0.5))
                            Spacer()
                            Text("-\(formatTime(remaining))")
                                .font(.system(size: 10, weight: .medium).monospacedDigit())
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }

                Spacer().frame(height: 8)

                // Playback controls
                HStack(spacing: 0) {
                    Spacer()

                    // Previous
                    Button(action: { audioManager.previousTrack() }) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 32)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())

                    Spacer()

                    // Play/Pause
                    Button(action: { audioManager.togglePlayPause() }) {
                        Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 32)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())

                    Spacer()

                    // Next
                    Button(action: { audioManager.nextTrack() }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 32)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())

                    Spacer()

                    // Output device / volume toggle
                    Button(action: { withAnimation(.easeInOut(duration: 0.2)) { showVolume.toggle() } }) {
                        Image(systemName: "headphones")
                            .font(.system(size: 16))
                            .foregroundColor(showVolume ? .white : .white.opacity(0.6))
                            .frame(width: 44, height: 32)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())

                    Spacer()
                }

                // Volume slider (expandable) — full width with speaker icons
                if showVolume {
                    HStack(spacing: 10) {
                        Image(systemName: "speaker.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.5))

                        VolumeSlider(value: Binding(
                            get: { audioManager.systemVolume },
                            set: { audioManager.setSystemVolume($0) }
                        ))
                        .frame(height: 6)

                        Image(systemName: "speaker.wave.3.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.top, 8)
                    .padding(.horizontal, 4)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.horizontal, 4)
        } else {
            // No audio playing
            HStack(spacing: 16) {
                Image(systemName: "waveform")
                    .font(.system(size: 28))
                    .foregroundColor(.white.opacity(0.5))

                VStack(alignment: .leading, spacing: 4) {
                    Text("No Audio Playing")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                    Text("Play music or videos to see them here")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func appIcon(for source: AudioApp) -> String {
        switch source {
        case .appleMusic: return "music.note"
        case .spotify: return "music.note.list"
        case .chrome, .safari, .arc, .firefox: return "globe"
        case .youtubeMusic: return "play.rectangle"
        case .unknown: return "waveform"
        }
    }

    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// MARK: - Volume Slider

struct VolumeSlider: View {
    @Binding var value: Float
    @State private var isDragging = false

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Track background
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 6)

                // Filled portion
                Capsule()
                    .fill(Color.white)
                    .frame(width: max(0, geo.size.width * CGFloat(value)), height: 6)

                // Thumb (visible on drag)
                if isDragging {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 16, height: 16)
                        .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                        .offset(x: max(0, min(geo.size.width * CGFloat(value) - 8, geo.size.width - 16)))
                }
            }
            .frame(height: 16)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        isDragging = true
                        let newValue = Float(drag.location.x / geo.size.width)
                        value = max(0, min(1, newValue))
                    }
                    .onEnded { _ in
                        isDragging = false
                    }
            )
        }
    }
}

// MARK: - Audio Visualizer

struct AudioVisualizer: View {
    @State private var heights: [CGFloat] = [0.3, 0.5, 0.4, 0.6]

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<4, id: \.self) { index in
                Capsule()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 3, height: heights[index] * 20)
            }
        }
        .onAppear { animate() }
    }

    private func animate() {
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                heights = (0..<4).map { _ in CGFloat.random(in: 0.2...1.0) }
            }
        }
    }
}

#Preview {
    MusicWidgetView()
        .environment(\.notchTheme, .dark)
        .frame(width: 400, height: 140)
        .background(Color.black)
}
