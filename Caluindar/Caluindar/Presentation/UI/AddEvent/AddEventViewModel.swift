//
//  EventFormViewModel.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/11/05.
//

import Foundation
import Combine

final class EventFormViewModel: ObservableObject {
    struct Input {
        let title: AnyPublisher<String, Never>
        let selectedDate: AnyPublisher<Date, Never>
        let selectedStartDate: AnyPublisher<Date, Never>
        let selectedEndDate: AnyPublisher<Date, Never>
    }
    
    class Output: ObservableObject {
        @Published var title: String = ""
        @Published var date: Date = Date()
        @Published var startDate: Date = Date()
        @Published var endDate: Date = Date()
    }
    
    private var useCase: EventUseCase
    let output = Output()
    private var cancellables = Set<AnyCancellable>()
    
    init(useCase: EventUseCase) {
        self.useCase = useCase
    }
    
    func transform(input: Input) -> Output {
        input.title
            .assign(to: \.title, on: output)
            .store(in: &cancellables)
        input.selectedDate
            .assign(to: \.date, on: output)
            .store(in: &cancellables)
        input.selectedStartDate
            .assign(to: \.startDate, on: output)
            .store(in: &cancellables)
        input.selectedEndDate
            .assign(to: \.endDate, on: output)
            .store(in: &cancellables)
        return output
    }
    
    func addEvent(title: String, startDate: Date, endDate: Date, completion: @escaping () -> Void) {
        Task {
            do {
                try await useCase.createEvent(title: title, startDate: startDate, endDate: endDate)
                completion()
            } catch {
                
            }
        }
    }
}
