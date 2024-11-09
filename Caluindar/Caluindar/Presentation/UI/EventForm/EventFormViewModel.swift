//
//  EventFormViewModel.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/11/05.
//

import Foundation
import Combine

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
            color: nil)
        @Published var formType: EventFormType = .create
        @Published var title: String = ""
        @Published var startDate: Date = Date()
        @Published var endDate: Date = Date()
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
                self.output.startDate = self.output.eventData.startDate
                self.output.endDate = self.output.eventData.endDate
            }
            .store(in: &cancellables)
        input.pushedSaveButton
            .sink { [weak self] in
                guard let self else { return }
                switch output.formType {
                case .create:
                    self.addEvent(title: self.output.title, startDate: self.output.startDate, endDate: self.output.endDate) {
                        self.output.dismiss = true
                    }
                case .edit:
                    self.output.eventData.title = self.output.title
                    self.output.eventData.startDate = self.output.startDate
                    self.output.eventData.endDate = self.output.endDate
                    
                    Task {
                        try await self.updateEvent(newEventData: self.output.eventData) {
                            self.output.dismiss = true
                        }
                    }
                }
            }
            .store(in: &cancellables)
        if let data = input.currentEventData {
            self.output.eventData = data
        }
        return output
    }
    
    private func addEvent(title: String, startDate: Date, endDate: Date, completion: @escaping () -> Void) {
        Task {
            do {
                try await useCase.createEvent(title: title, startDate: startDate, endDate: endDate)
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
