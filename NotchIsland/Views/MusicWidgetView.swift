//
//  MusicWidgetView.swift
//  NotchIsland
//
//  Universal audio widget - shows playback from ANY app (Music, Spotify, Chrome, Safari, etc.)
//

import SwiftUI

struct MusicWidgetView: View {
    @StateObject private var audioManager = UniversalAudioManager.shared
    @Environment(\.notchTheme) private var theme

    var body: some View {
        HStack(spacing: 20) {
            if let track = audioManager.currentTrack {
                // Album artwork or app icon - larger size
                Group {
                    if let artwork = track.artwork {
                        Image(nsImage: artwork)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 64, height: 64)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    } else {
                        // App icon placeholder
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(LinearGradient(
                                    colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 64, height: 64)

                            Image(systemName: appIcon(for: track.source))
                                .font(.system(size: 28))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                }
                .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 4)

                // Track info and controls
                VStack(alignment: .leading, spacing: 8) {
                    // Track title - larger font
                    Text(track.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    // Artist or app name
                    Text(track.displayArtist)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)

                    // Play/pause button - larger
                    Button(action: audioManager.togglePlayPause) {
                        HStack(spacing: 8) {
                            Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 11, weight: .bold))
                            Text(audioManager.isPlaying ? "Pause" : "Play")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                // Playing indicator - larger
                if audioManager.isPlaying {
                    AudioVisualizer()
                        .frame(width: 36, height: 36)
                }
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
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
}

// Simple audio visualizer animation
struct AudioVisualizer: View {
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<4) { index in
                Capsule()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 4)
                    .frame(height: isAnimating ? CGFloat.random(in: 10...30) : 10)
                    .animation(
                        Animation.easeInOut(duration: 0.5)
                            .repeatForever()
                            .delay(Double(index) * 0.1),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    MusicWidgetView()
        .environment(\.notchTheme, .dark)
        .frame(width: 400, height: 100)
        .background(Color.black)
}
