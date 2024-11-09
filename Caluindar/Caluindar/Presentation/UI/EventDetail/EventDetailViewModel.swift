//
//  EventDetailViewModel.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/11/07.
//

import SwiftUI
import Combine

enum EventDetailButtonType {
    case edit
    case trash
    case deleteAlert
}

extension EventDetailViewModel {
    struct Input {
        let tappedButton: AnyPublisher<EventDetailButtonType, Never>
        let updateEventData: AnyPublisher<EventData, Never>
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
        @Published var showAlert = false
        @Published var dismiss = false
        @Published var showEventForm = false
    }
}

final class EventDetailViewModel: ObservableObject {
    private let useCase: EventUseCase
    private var cancellables = Set<AnyCancellable>()
    private var output = Output()
    
    init(
        useCase: EventUseCase = EventUseCase(repository: EventRepository()),
        eventDeta: EventData
    ) {
        self.useCase = useCase
        output.eventData = eventDeta
    }
    
    func transform(input: Input) -> Output {
        input.tappedButton
            .sink { [weak self] buttonType in
                guard let self else { return }
                Task {
                    switch buttonType {
                    case .edit:
                        Task { @MainActor in
                            self.output.showEventForm = true
                        }
                    case .trash:
                    Task { @MainActor in
                        self.output.showAlert = true
                    }
                    case .deleteAlert:
                        try await self.useCase.deleteEvent(eventData: self.output.eventData)
                        Task { @MainActor in
                            self.output.dismiss = true
                        }
                    }
                }
            }
            .store(in: &cancellables)
        input.updateEventData
            .sink { [weak self] newEventData in
                guard let self else { return }
                self.output.eventData = newEventData
            }
            .store(in: &cancellables)
        return output
    }
}
