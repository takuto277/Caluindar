//
//  EventUseCase.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/10/27.
//

import Foundation
import EventKit
import UIKit

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

    func createEvent(title: String, isAllDay: Bool, startDate: Date, endDate: Date, color: UIColor, notes: String) async throws {
        try await repository.createEvent(title: title, isAllDay: isAllDay, startDate: startDate, endDate: endDate, color: color, notes: notes)
    }
    
    func updateEvent(newEventData: EventData) async throws {
        try await repository.updateEvent(newEventData: newEventData)
    }
    
    func deleteEvent(eventData: EventData) async throws {
        try await repository.deleteEvent(eventData: eventData)
    }
}
