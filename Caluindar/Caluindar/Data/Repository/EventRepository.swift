//
//  EventRepository.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/10/27.
//

import Foundation
import EventKit

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
}
