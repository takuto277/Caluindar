//
//  EventData.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/11/05.
//

import Foundation
import UIKit

struct EventData: Identifiable {
    let id: UUID
    let eventIdentifier: String
    let title: String
    let startDate: Date
    let endDate: Date
    let location: String?
    let isAllDay: Bool
    let color: UIColor?
}
