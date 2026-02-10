//
//  CalendarWidgetView.swift
//  NotchIsland
//
//  Calendar events widget
//

import SwiftUI

struct CalendarWidgetView: View {
    @StateObject private var calendarManager = CalendarManager.shared
    @Environment(\.notchTheme) private var theme

    var body: some View {
        VStack(spacing: 12) {
            if !calendarManager.upcomingEvents.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(calendarManager.upcomingEvents.prefix(3), id: \.eventIdentifier) { event in
                            EventRow(event: event)
                        }
                    }
                }
            } else {
                // No events
                VStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.system(size: 32))
                        .foregroundColor(theme.tertiaryText)

                    Text(calendarManager.hasAccess ? "No upcoming events" : "Calendar access required")
                        .font(.system(size: 13))
                        .foregroundColor(theme.secondaryText)

                    if !calendarManager.hasAccess {
                        Button("Grant Access") {
                            calendarManager.requestAccess()
                        }
                        .buttonStyle(PlainButtonStyle())
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(theme.primaryText)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(theme.selectedTabBackground)
                        )
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            calendarManager.loadUpcomingEvents()
        }
    }
}

struct EventRow: View {
    let event: CalendarEvent
    @Environment(\.notchTheme) private var theme

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Time indicator
            VStack(spacing: 2) {
                Text(event.startTime)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(theme.primaryText)

                if !event.isAllDay {
                    Text(event.duration)
                        .font(.system(size: 10))
                        .foregroundColor(theme.secondaryText)
                }
            }
            .frame(width: 50, alignment: .leading)

            // Event details
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(theme.primaryText)
                    .lineLimit(1)

                if let location = event.location, !location.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 9))
                        Text(location)
                            .font(.system(size: 11))
                    }
                    .foregroundColor(theme.secondaryText)
                    .lineLimit(1)
                }
            }

            Spacer()

            // Color indicator
            if let color = event.calendar?.color {
                Circle()
                    .fill(Color(nsColor: color))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(theme.cardBackground)
        )
    }
}

#Preview {
    CalendarWidgetView()
        .environment(\.notchTheme, .dark)
        .frame(width: 400, height: 150)
        .background(Color.black.opacity(0.5))
}
