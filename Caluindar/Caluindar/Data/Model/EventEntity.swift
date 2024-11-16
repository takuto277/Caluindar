//
//  EventEntity.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/11/10.
//

import Foundation
import CoreData
import UIKit

@objc(EventEntity)
public class EventEntity: NSManagedObject {
    @NSManaged public var eventIdentifier: String?
    @NSManaged public var title: String?
    @NSManaged public var startDate: Date?
    @NSManaged public var endDate: Date?
    @NSManaged public var location: String?
    @NSManaged public var isAllDay: Bool
    @NSManaged public var color: Data?
}
