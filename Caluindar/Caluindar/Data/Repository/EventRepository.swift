//
//  EventRepository.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/10/27.
//

import Foundation
import EventKit
import UIKit
import CoreData

class EventRepository {
    private let store = EKEventStore()
    private let coreData = CoreDataStack.shared

    func requestAccess() async throws -> Bool {
        return try await store.requestAccess(to: .event)
    }

    func fetchEvents(from startDate: Date, to endDate: Date) async -> [EventData] {
        if AccessManager.shared.hasFullAccess() {
            let predicate = store.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
            let events = store.events(matching: predicate)
            return await convertEventsData(events: events)
        } else {
            return fetchEventsFromCoreData(from: startDate, to: endDate)
        }
    }

    private func fetchEventsFromCoreData(from startDate: Date, to endDate: Date) -> [EventData] {
        let fetchRequest = NSFetchRequest<EventEntityData>(entityName: "EventEntityData")
        fetchRequest.predicate = NSPredicate(format: "startDate < %@ AND endDate > %@", endDate as NSDate, startDate as NSDate)
        
        do {
            let eventEntities = try coreData.context.fetch(fetchRequest)
            return eventEntities.map { EventData(entity: $0) }
        } catch {
            print("Failed to fetch events from CoreData: \(error)")
            return []
        }
    }

    func createEvent(title: String, startDate: Date, endDate: Date, color: UIColor) async throws {
        if AccessManager.shared.hasFullAccess() {
            let event = EKEvent(eventStore: store)
            event.title = title
            event.startDate = startDate
            event.endDate = endDate
            event.calendar = store.defaultCalendarForNewEvents
            event.calendar.cgColor = color.cgColor
            try store.save(event, span: .thisEvent, commit: true)
        } else {
            let entity = EventEntityData(context: coreData.context)
            entity.eventIdentifier = UUID().uuidString
            entity.title = title
            entity.startDate = startDate
            entity.endDate = endDate
            entity.isAllDay = false
            entity.color = color.toData() // デフォルトの色を設定
            try coreData.context.save()
        }
    }
    
    func updateEvent(newEventData: EventData) async throws {
        if AccessManager.shared.hasFullAccess() {
            if let event = store.event(withIdentifier: newEventData.eventIdentifier) {
                event.title = newEventData.title
                event.startDate = newEventData.startDate
                event.endDate = newEventData.endDate
                event.calendar.cgColor = newEventData.color?.cgColor
                try store.save(event, span: .thisEvent, commit: true)
            }
        } else {
            let fetchRequest = NSFetchRequest<EventEntityData>(entityName: "EventEntityData")
            fetchRequest.predicate = NSPredicate(format: "eventIdentifier == %@", newEventData.eventIdentifier)
            
            if let entity = try coreData.context.fetch(fetchRequest).first {
                entity.title = newEventData.title
                entity.startDate = newEventData.startDate
                entity.endDate = newEventData.endDate
                entity.color = newEventData.color?.toData()
                try coreData.context.save()
            }
        }
    }
    
    func deleteEvent(eventData: EventData) async throws {
        if AccessManager.shared.hasFullAccess() {
            if let event = store.event(withIdentifier: eventData.eventIdentifier) {
                try store.remove(event, span: .thisEvent, commit: true)
            } else {
                throw NSError(domain: "Event not found", code: 404, userInfo: nil)
            }
        } else {
            let fetchRequest = NSFetchRequest<EventEntityData>(entityName: "EventEntityData")
            fetchRequest.predicate = NSPredicate(format: "eventIdentifier == %@", eventData.eventIdentifier)
            
            if let entity = try coreData.context.fetch(fetchRequest).first {
                coreData.context.delete(entity)
                try coreData.context.save()
            }
        }
    }
    
    private func convertEventsData(events: [EKEvent]) async -> [EventData] {
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
