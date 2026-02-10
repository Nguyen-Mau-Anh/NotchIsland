//
//  CalendarManager.swift
//  NotchIsland
//
//  Manages calendar events using EventKit
//

import Foundation
import EventKit
import AppKit

struct CalendarEvent {
    let eventIdentifier: String
    let title: String
    let startTime: String
    let duration: String
    let isAllDay: Bool
    let location: String?
    let calendar: EKCalendar?
}

class CalendarManager: ObservableObject {
    static let shared = CalendarManager()

    @Published var upcomingEvents: [CalendarEvent] = []
    @Published var hasAccess: Bool = false

    private let eventStore = EKEventStore()
    private var refreshTimer: Timer?

    private init() {
        checkAccess()
        startAutoRefresh()
    }

    func checkAccess() {
        if #available(macOS 14.0, *) {
            // For macOS 14+ (Sonoma)
            hasAccess = EKEventStore.authorizationStatus(for: .event) == .fullAccess ||
                        EKEventStore.authorizationStatus(for: .event) == .authorized
        } else {
            hasAccess = EKEventStore.authorizationStatus(for: .event) == .authorized
        }
    }

    func requestAccess() {
        #if swift(>=5.9)
        // For macOS 14+ (Sonoma)
        if #available(macOS 14.0, *) {
            eventStore.requestFullAccessToEvents { [weak self] granted, error in
                DispatchQueue.main.async {
                    self?.hasAccess = granted
                    if granted {
                        self?.loadUpcomingEvents()
                    }
                }
            }
        } else {
            // Fallback for older versions
            requestAccessLegacy()
        }
        #else
        requestAccessLegacy()
        #endif
    }

    private func requestAccessLegacy() {
        eventStore.requestAccess(to: .event) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.hasAccess = granted
                if granted {
                    self?.loadUpcomingEvents()
                }
            }
        }
    }

    func loadUpcomingEvents() {
        guard hasAccess else { return }

        // Get events for the next 7 days
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate) ?? startDate

        let predicate = eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: nil
        )

        let events = eventStore.events(matching: predicate)

        // Convert to CalendarEvent and sort
        upcomingEvents = events.prefix(10).map { event in
            convertToCalendarEvent(event)
        }
    }

    private func convertToCalendarEvent(_ event: EKEvent) -> CalendarEvent {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"

        let startTime: String
        let duration: String

        if event.isAllDay {
            startTime = "All Day"
            duration = ""
        } else {
            startTime = formatter.string(from: event.startDate)

            let durationMinutes = Int(event.endDate.timeIntervalSince(event.startDate) / 60)
            if durationMinutes < 60 {
                duration = "\(durationMinutes)m"
            } else {
                let hours = durationMinutes / 60
                let minutes = durationMinutes % 60
                duration = minutes > 0 ? "\(hours)h \(minutes)m" : "\(hours)h"
            }
        }

        return CalendarEvent(
            eventIdentifier: event.eventIdentifier,
            title: event.title ?? "Untitled Event",
            startTime: startTime,
            duration: duration,
            isAllDay: event.isAllDay,
            location: event.location,
            calendar: event.calendar
        )
    }

    private func startAutoRefresh() {
        // Refresh events every 5 minutes
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.loadUpcomingEvents()
        }
    }

    deinit {
        refreshTimer?.invalidate()
    }
}
