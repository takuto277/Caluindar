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
    @State private var showAddEventSheet = false
    private var pushSelectButton = PassthroughSubject<Void, Never>()
    private var selectedDateSubject = PassthroughSubject<Date, Never>()
    private var currentPageSubject = PassthroughSubject<Date, Never>()
    private var didCreateEvent = PassthroughSubject<Void, Never>()
    private var onAppear = PassthroughSubject<Void, Never>()
    @ObservedObject private var output: CalendarViewModel.Output
    
    init() {
        let repository = EventRepository()
        let useCase = EventUseCase(repository: repository)
        let input = CalendarViewModel.Input(
            pushSelectButton: pushSelectButton.eraseToAnyPublisher(),
            selectedDate: selectedDateSubject.eraseToAnyPublisher(),
            currentPage: currentPageSubject.eraseToAnyPublisher(),
            didCreateEvent: didCreateEvent.eraseToAnyPublisher(),
            onAppear: onAppear.eraseToAnyPublisher()
        )
        let viewModel = CalendarViewModel(useCase: useCase)
        self._viewModel = StateObject(wrappedValue: viewModel)
        output = viewModel.transform(input: input)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                calendar
                
                addButton
            }
            .onAppear {
                onAppear.send()
            }
            .navigationBarItems(trailing: NavigationLink(destination: SettingView()) {
                Image(systemName: "gearshape")
                    .imageScale(.large)
            })
        }
        .sheet(isPresented: self.$showAddEventSheet) {
            AddEventView {
                didCreateEvent.send()
            }
        }
    }
    
    private var calendar: some View {
        VStack {
            CalendarContentView(
                events: $viewModel.events,
                viewModel: viewModel,
                selectedDateSubject: selectedDateSubject,
                currentPageSubject: currentPageSubject
            )
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
    
    private var addButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    self.showAddEventSheet = true
                }) {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                .padding()
            }
        }
    }
}

