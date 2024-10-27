//
//  CalendarView.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/10/27.
//

import SwiftUI
import FSCalendar
import Combine

struct CalendarView: View {
    private var viewModel: CalendarViewModel
    private var showAddEventSheet = false
    private var pushSelectButton = PassthroughSubject<Void, Never>()
    @ObservedObject private var output: CalendarViewModel.Output
    
    init() {
        let repository = EventRepository()
        let useCase = EventUseCase(repository: repository)
        let input = CalendarViewModel.Input(pushSelectButton: pushSelectButton.eraseToAnyPublisher())
        viewModel = CalendarViewModel(useCase: useCase)
        output = viewModel.transform(input: input)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                CalendarContentView(events: viewModel.events, viewModel: viewModel)
                Button("Add Event") {
                    // TODO:遷移させたい
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
        }
    }
}

