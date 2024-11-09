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
}
