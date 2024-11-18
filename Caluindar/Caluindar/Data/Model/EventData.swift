//
//  EventData.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/11/05.
//

import Foundation
import UIKit

struct EventData: Identifiable {
    var id: UUID
    var eventIdentifier: String
    var title: String
    var startDate: Date
    var endDate: Date
    var location: String?
    var isAllDay: Bool
    var color: UIColor?
    var notes: String
    
    init(entity: EventEntityData) {
        self.id = UUID() // CoreDataにUUIDがある場合はそれを使用
        self.eventIdentifier = entity.eventIdentifier ?? ""
        self.title = entity.title ?? "No Title"
        self.startDate = entity.startDate ?? Date()
        self.endDate = entity.endDate ?? Date()
        self.location = entity.location ?? nil // CoreDataにlocationがない場合はnil
        self.isAllDay = entity.isAllDay
        if let colorData = entity.color {
            self.color = UIColor.fromData(colorData)
        } else {
            self.color = nil
        }
        self.notes = entity.notes ?? ""
    }
    
    init(id: UUID = UUID(), eventIdentifier: String, title: String, startDate: Date, endDate: Date, location: String?, isAllDay: Bool, color: UIColor?, notes: String) {
        self.id = id
        self.eventIdentifier = eventIdentifier
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.isAllDay = isAllDay
        self.color = color
        self.notes = notes
    }
}
