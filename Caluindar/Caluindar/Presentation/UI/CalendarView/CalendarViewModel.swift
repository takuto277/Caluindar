//
//  CalendarViewModel.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/10/27.
//

import Foundation
import Combine
import EventKit

extension CalendarViewModel {
    struct Input {
        let pushSelectButton: AnyPublisher<Void, Never>
        let selectedDate: AnyPublisher<Date, Never>
        let currentPage: AnyPublisher<Date, Never>
        let didCreateEvent: AnyPublisher<Void, Never>
        let onAppear: AnyPublisher<Void, Never>
    }
    
    class Output: ObservableObject {
        @Published var events: [EventData] = []
        @Published var changeScreenForDetails = false
        @Published var selectedDate: Date? = nil
        @Published var currentPage: Date = Date()
    }
}

class CalendarViewModel: ObservableObject {
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
        input.selectedDate
            .sink { [weak self] date in
                guard let self else { return }
                self.output.selectedDate = date
                self.output.changeScreenForDetails = true
            }
            .store(in: &cancellables)
        input.currentPage
            .sink { [weak self] date in
                guard let self else { return }
                self.output.currentPage = date
            }
            .store(in: &cancellables)
        input.didCreateEvent
            .sink { [weak self] in
                guard let self else { return }
                Task {
                    await self.loadEvents(for: Date())
                }
            }
            .store(in: &cancellables)
        input.onAppear
            .sink { [weak self] in
                guard let self else { return }
                Task {
                    await self.loadEvents(for: self.output.currentPage)
                }
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
        
        let eventData = await useCase.fetchEvents(from: startDate, to: endDate)
        DispatchQueue.main.async {
            self.output.events = eventData
        }
    }
}
