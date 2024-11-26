//
//  EventFormViewModel.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/11/05.
//

import Foundation
import Combine
import UIKit

enum EventFormType {
    case create
    case edit
}

@MainActor
final class EventFormViewModel: ObservableObject {
    struct Input {
        let title: AnyPublisher<String, Never>
        let selectedStartDate: AnyPublisher<Date, Never>
        let selectedEndDate: AnyPublisher<Date, Never>
        let editSetup: AnyPublisher<EventFormType, Never>
        let pushedSaveButton: AnyPublisher<Void, Never>
        var currentEventData: EventData?
    }
    
    class Output: ObservableObject {
        @Published var eventData: EventData = EventData(
            id: UUID(),
            eventIdentifier: "",
            title: "",
            startDate: Date(),
            endDate: Date(),
            location: "",
            isAllDay: false,
            color: nil,
            notes: "")
        @Published var formType: EventFormType = .create
        @Published var title: String = ""
        @Published var isAllDay: Bool = false
        @Published var startDate: Date = Date()
        @Published var endDate: Date = Date()
        @Published var color: UIColor = UIColor.blue
        @Published var notes: String = ""
        @Published var dismiss = false
    }
    
    private var useCase: EventUseCase
    var output = Output()
    private var cancellables = Set<AnyCancellable>()
    
    init(useCase: EventUseCase) {
        self.useCase = useCase
    }
    
    func transform(input: Input) -> Output {
        input.title
            .assign(to: \.title, on: output)
            .store(in: &cancellables)
        input.selectedStartDate
            .assign(to: \.startDate, on: output)
            .store(in: &cancellables)
        input.selectedEndDate
            .assign(to: \.endDate, on: output)
            .store(in: &cancellables)
        input.editSetup
            .sink { [weak self] type in
                guard let self else { return }
                self.output.formType = type
                self.output.title = self.output.eventData.title
                self.output.isAllDay = self.output.eventData.isAllDay
                self.output.startDate = self.output.eventData.startDate
                self.output.endDate = self.output.eventData.endDate
                self.output.color = self.output.eventData.color ?? .black
                self.output.notes = self.output.eventData.notes
            }
            .store(in: &cancellables)
        input.pushedSaveButton
            .sink { [weak self] in
                guard let self else { return }
                self.pushedSaveButton()
            }
            .store(in: &cancellables)
        if let data = input.currentEventData {
            self.output.eventData = data
        }
        return output
    }
    
    private func pushedSaveButton() {
        if output.isAllDay {
            if let startOfDay = Calendar.current.date(bySettingHour: 00, minute: 00, second: 00, of: output.startDate) {
                output.startDate = startOfDay
            }
            // 23:59に設定
            if let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: output.endDate) {
                output.endDate = endOfDay
            }
        }
        switch output.formType {
        case .create:
            self.addEvent(title: self.output.title, isAllDay: self.output.isAllDay, startDate: self.output.startDate, endDate: self.output.endDate, color: self.output.color, notes: self.output.notes) {
                self.output.dismiss = true
            }
        case .edit:
            self.output.eventData.title = self.output.title
            self.output.eventData.isAllDay = self.output.isAllDay
            self.output.eventData.startDate = self.output.startDate
            self.output.eventData.endDate = self.output.endDate
            self.output.eventData.color = self.output.color
            self.output.eventData.notes = self.output.notes
            
            Task {
                try await self.updateEvent(newEventData: self.output.eventData) {
                    self.output.dismiss = true
                }
            }
        }
    }
    
    private func addEvent(title: String, isAllDay: Bool, startDate: Date, endDate: Date, color: UIColor, notes: String, completion: @escaping () -> Void) {
        Task {
            do {
                try await useCase.createEvent(title: title, isAllDay: isAllDay, startDate: startDate, endDate: endDate, color: color, notes: notes)
                completion()
            } catch {
                
            }
        }
    }
    
    private func updateEvent(newEventData: EventData, completion: @escaping () -> Void) async throws {
        try await useCase.updateEvent(newEventData: newEventData)
        completion()
    }
}
