//
//  CalendarViewModel.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/10/27.
//

import Foundation
import Combine
import EventKit


enum TouchScreen {
    case days
    case none
}

extension CalendarViewModel {
    struct Input {
        let pushSelectButton: AnyPublisher<Void, Never>
        let touchScreen: AnyPublisher<TouchScreen, Never>
        let selectedDate: AnyPublisher<Date, Never>
    }
    
    class Output: ObservableObject {
        @Published var changeScreenForDetails = false
        @Published var selectedDate: Date? = nil
        @Published var touchScreen = TouchScreen.none
    }
}

class CalendarViewModel: ObservableObject {
    @Published var events: [Date: [String]] = [:]
    private let useCase: EventUseCase
    private var cancellables = Set<AnyCancellable>()
    private var changeScreenForDetails: Bool = false
    private var output = Output()

    init(useCase: EventUseCase) {
        self.useCase = useCase

        Task {
            do {
                let granted = try await useCase.requestAccess()
                if granted {
                    await loadEvents(for: Date())
                }
            } catch {
                print("Failed to request access: \(error.localizedDescription)")
            }
        }
    }
    
    func transform(input: Input) -> Output {
        input.pushSelectButton
            .sink { [weak self] in
                guard let self else { return }
                output.changeScreenForDetails = true
            }
            .store(in: &cancellables)
        input.touchScreen
            .sink { [weak self] type in
                guard let self else { return }
            }
            .store(in: &cancellables)
        input.selectedDate
            .sink { [weak self] date in
                guard let self else { return }
                self.output.selectedDate = date
                self.output.changeScreenForDetails = true
            }
            .store(in: &cancellables)
        return output
    }
    
    func loadEvents(for date: Date) async {
        let calendar = Calendar.current
        guard let startDate = calendar.date(byAdding: .month, value: -2, to: date),
              let endDate = calendar.date(byAdding: .month, value: 2, to: date) else {
            return
        }
        
        let ekEvents = await useCase.fetchEvents(from: startDate, to: endDate)
        DispatchQueue.main.async {
            self.events = self.groupEventsByDate(ekEvents)
        }
    }
    
    func addEvent(title: String, startDate: Date, endDate: Date) {
        Task {
            do {
                try await useCase.createEvent(title: title, startDate: startDate, endDate: endDate)
                await self.loadEvents(for: Date())
            } catch {
                
            }
        }
    }

    private func groupEventsByDate(_ events: [EKEvent]) -> [Date: [String]] {
        var groupedEvents: [Date: [String]] = [:]
        for event in events {
            let startDate = Calendar.current.startOfDay(for: event.startDate)
            if groupedEvents[startDate] != nil {
                groupedEvents[startDate]?.append(event.title)
            } else {
                groupedEvents[startDate] = [event.title]
            }
        }
        return groupedEvents
    }
}