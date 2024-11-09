//
//  EventRepository.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/10/27.
//

import Foundation
import EventKit
import UIKit

class EventRepository {
    private let store = EKEventStore()

    func requestAccess() async throws -> Bool {
        return try await store.requestAccess(to: .event)
    }

    func fetchEvents(from startDate: Date, to endDate: Date) async -> [EKEvent] {
        let predicate = store.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        return store.events(matching: predicate)
    }

    func createEvent(title: String, startDate: Date, endDate: Date) async throws {
        let event = EKEvent(eventStore: store)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = store.defaultCalendarForNewEvents
        try store.save(event, span: .thisEvent, commit: true)
    }
    
    func deleteEvent(eventData: EventData) async throws {
        if let event = store.event(withIdentifier: eventData.eventIdentifier) {
            try store.remove(event, span: .thisEvent, commit: true)
        } else {
            throw NSError(domain: "Event not found", code: 404, userInfo: nil)
        }
    }
    
    func convertEventsData(events: [EKEvent]) async -> [EventData] {
        return events.map { event in
            EventData(
                id: UUID(),
                eventIdentifier: event.eventIdentifier,
                title: event.title ?? "No Title",
                startDate: event.startDate,
                endDate: event.endDate,
                location: event.location,
                isAllDay: event.isAllDay,
                color: UIColor(cgColor: event.calendar.cgColor)
            )
        }
    }
}
