//
//  EventFormView.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/10/27.
//

import UIKit
import SwiftUI
import Combine

struct EventFormView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: EventFormViewModel
    @ObservedObject private var output: EventFormViewModel.Output
    var onEventCreated: (() -> Void)?
    
    init(date: Date = Date(), onEventCreated: (() -> Void)?) {
        let title = CurrentValueSubject<String, Never>("")
        let selectedDate = CurrentValueSubject<Date, Never>(date)
        let selectedStartDate = CurrentValueSubject<Date, Never>(date)
        let selectedEndDate = CurrentValueSubject<Date, Never>(date.addingTimeInterval(3600))

        let input = EventFormViewModel.Input(
            title: title.eraseToAnyPublisher(),
            selectedDate: selectedDate.eraseToAnyPublisher(),
            selectedStartDate: selectedStartDate.eraseToAnyPublisher(),
            selectedEndDate: selectedEndDate.eraseToAnyPublisher()
        )
        let viewModel = EventFormViewModel(useCase: EventUseCase(repository: EventRepository()))
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onEventCreated = onEventCreated
        output = viewModel.transform(input: input)
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Event Title", text: $output.title)
                    .foregroundColor(Color.primary)
                DatePicker("Start Date", selection: $output.date)
                DatePicker("End Date", selection: $output.endDate)
            }
            .navigationTitle("Add Event")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.addEvent(title: output.title, startDate: output.date, endDate: output.endDate) {
                            onEventCreated?()
                        }
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
