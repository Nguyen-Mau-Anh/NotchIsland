//
//  MusicWidgetView.swift
//  NotchIsland
//
//  Music playback widget with controls
//

import SwiftUI

struct MusicWidgetView: View {
    @StateObject private var musicManager = MusicManager.shared
    @Environment(\.notchTheme) private var theme

    var body: some View {
        VStack(spacing: 12) {
            if let track = musicManager.currentTrack {
                // Album artwork
                Group {
                    if let artwork = track.artwork {
                        Image(nsImage: artwork)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    } else {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(theme.cardBackground)
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "music.note")
                                    .font(.system(size: 24))
                                    .foregroundColor(theme.tertiaryText)
                            )
                    }
                }
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                .animation(.easeInOut(duration: 0.3), value: track.artwork != nil)

                // Track info
                VStack(spacing: 4) {
                    Text(track.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(theme.primaryText)
                        .lineLimit(1)

                    Text(track.artist)
                        .font(.system(size: 12))
                        .foregroundColor(theme.secondaryText)
                        .lineLimit(1)
                }

                // Playback controls
                HStack(spacing: 20) {
                    Button(action: musicManager.previousTrack) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 16))
                            .foregroundColor(theme.controlAccent)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: musicManager.togglePlayPause) {
                        Image(systemName: musicManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(theme.controlAccent)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: musicManager.nextTrack) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 16))
                            .foregroundColor(theme.controlAccent)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            } else {
                // No music playing
                VStack(spacing: 8) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 32))
                        .foregroundColor(theme.tertiaryText)

                    Text("No music playing")
                        .font(.system(size: 13))
                        .foregroundColor(theme.secondaryText)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    MusicWidgetView()
        .environment(\.notchTheme, .dark)
        .frame(width: 400, height: 150)
        .background(Color.black.opacity(0.5))
}
