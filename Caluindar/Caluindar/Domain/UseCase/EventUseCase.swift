//
//  EventUseCase.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/10/27.
//

import Foundation
import EventKit

class EventUseCase {
    private let repository: EventRepository

    init(repository: EventRepository) {
        self.repository = repository
    }

    func requestAccess() async throws -> Bool {
        return try await repository.requestAccess()
    }

    func fetchEvents(from startDate: Date, to endDate: Date) async -> [EventData] {
        return await repository.fetchEvents(from: startDate, to: endDate)
    }

    func createEvent(title: String, startDate: Date, endDate: Date) async throws {
        try await repository.createEvent(title: title, startDate: startDate, endDate: endDate)
    }
    
    func updateEvent(newEventData: EventData) async throws {
        try await repository.updateEvent(newEventData: newEventData)
    }
    
    func deleteEvent(eventData: EventData) async throws {
        try await repository.deleteEvent(eventData: eventData)
    }
}
