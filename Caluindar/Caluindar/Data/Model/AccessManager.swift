//
//  AccessManager.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/11/10.
//

import EventKit

class AccessManager {
    static let shared = AccessManager()
    private let eventStore = EKEventStore()
    
    private init() {}
    
    func hasFullAccess() -> Bool {
        return EKEventStore.authorizationStatus(for: .event) == .authorized
    }
    
    func requestAccess(completion: @escaping (Bool) -> Void) {
        eventStore.requestAccess(to: .event) { granted, _ in
            completion(granted)
        }
    }
}
