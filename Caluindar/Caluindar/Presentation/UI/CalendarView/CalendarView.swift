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
    @StateObject private var viewModel: CalendarViewModel
    private var showAddEventSheet = false
    private var pushSelectButton = PassthroughSubject<Void, Never>()
    private var touchScreen = PassthroughSubject<TouchScreen, Never>()
    private var selectedDateSubject = PassthroughSubject<Date, Never>()
    @ObservedObject private var output: CalendarViewModel.Output
    
    init() {
        let repository = EventRepository()
        let useCase = EventUseCase(repository: repository)
        let input = CalendarViewModel.Input(
            pushSelectButton: pushSelectButton.eraseToAnyPublisher(),
            touchScreen: touchScreen.eraseToAnyPublisher(),
            selectedDate: selectedDateSubject.eraseToAnyPublisher()
        )
        let viewModel = CalendarViewModel(useCase: useCase)
        self._viewModel = StateObject(wrappedValue: viewModel)
        output = viewModel.transform(input: input)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                CalendarContentView(events: viewModel.events, viewModel: viewModel, selectedDateSubject: selectedDateSubject)
                Button("Add Event") {
                    // TODO:遷移させたい
                }
                if let selectedDate = output.selectedDate {
                    NavigationLink(
                        destination: CalendarDaysView(date: selectedDate),
                        isActive: $output.changeScreenForDetails
                    ) {
                        EmptyView()
                    }
                }

            }
            .padding()
            .background(Color(UIColor.systemBackground))
        }
    }
}
