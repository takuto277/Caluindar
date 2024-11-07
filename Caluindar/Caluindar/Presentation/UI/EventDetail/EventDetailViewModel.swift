//
//  EventDetailViewModel.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/11/07.
//

import SwiftUI
import Combine

extension EventDetailViewModel {
    struct Input {
        
    }
    
    class Output: ObservableObject {
        @Published var eventData: EventData = EventData(
            title: "",
            startDate: Date(),
            endDate: Date(),
            location: "",
            isAllDay: false,
            color: nil)
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
        return output
    }
}
