//
//  CalendarDaysViewModel.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/11/05.
//

import Foundation
import Combine
import EventKit

class CalendarDaysViewModel: ObservableObject {
    struct Input {
        let didCreateEvent: AnyPublisher<Void, Never>
    }
    class Output: ObservableObject {
        @Published var events: [EventData] = []
    }
    
    private let useCase: EventUseCase
    private var cancellables = Set<AnyCancellable>()
    var date: Date
    let output = Output()

    init(useCase: EventUseCase, date: Date) {
        self.useCase = useCase
        self.date = date
        Task {
            await loadEvents(for: date)
        }
    }
    
    func transform(input: Input)  -> Output {
        input.didCreateEvent
            .sink { [weak self] in
                guard let self else { return }
                Task {
                    await self.loadEvents(for: self.date)
                }
            }
            .store(in: &cancellables)
        return output
    }
    
    private func loadEvents(for date: Date) async {
        Task {
            let startOfDay = Calendar.current.startOfDay(for: date)
            let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
            
            let ekEvents = await useCase.fetchEvents(from: startOfDay, to: endOfDay)
            let eventData = await useCase.convertEventsData(events: ekEvents)
            
            Task { @MainActor in
                self.output.events = eventData
            }
        }
    }
    
    // 指定された時間に該当するイベントを取得
    func eventForHour(_ hour: Int) -> EventData? {
        let calendar = Calendar.current
        return output.events.first { event in
            let eventStartHour = calendar.component(.hour, from: event.startDate)
            let eventEndHour = calendar.component(.hour, from: event.endDate)
            return !event.isAllDay && hour >= eventStartHour && hour < eventEndHour
        }
    }
    
    // 全日イベントを取得
    func allDayEvents() -> [EventData] {
        return output.events.filter { $0.isAllDay }
    }
}
