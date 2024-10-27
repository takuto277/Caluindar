//
//  CalendarView.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/10/27.
//

import SwiftUI
import FSCalendar

struct CalendarView: View {
    @StateObject private var viewModel: CalendarViewModel
    @State private var showAddEventSheet = false
    
    init() {
        let repository = EventRepository()
        let useCase = EventUseCase(repository: repository)
        _viewModel = StateObject(wrappedValue: CalendarViewModel(useCase: useCase))
    }
    
    var body: some View {
        VStack {
            CalendarContentView(events: viewModel.events, viewModel: viewModel)
            Button("Add Event") {
                showAddEventSheet = true
            }
            .sheet(isPresented: $showAddEventSheet) {
                AddEventView(viewModel: viewModel)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
}
    


//struct ContentView: View {
//    @StateObject private var viewModel = CalendarViewModel()
//    @State private var showAddEventSheet = false
//
//    var body: some View {
//        VStack {
//            CalendarView(events: viewModel.events)
//                .edgesIgnoringSafeArea(.all)
//            Button("Add Event") {
//                showAddEventSheet = true
//            }
//            .sheet(isPresented: $showAddEventSheet) {
//                AddEventView(viewModel: viewModel)
//            }
//        }
//        .padding(.top)
//        .background(Color(UIColor.systemBackground))
//    }
//}
