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
    let editSetup = PassthroughSubject<Void, Never>()
    let pushSaveButton = PassthroughSubject<Void, Never>()
    
    init(
        date: Date = Date(),
        formType: EventFormType,
        currentEventData: EventData? = nil,
        onEventCreated: (() -> Void)?
    ) {
        let title = CurrentValueSubject<String, Never>("")
        let selectedStartDate = CurrentValueSubject<Date, Never>(date)
        let selectedEndDate = CurrentValueSubject<Date, Never>(date.addingTimeInterval(3600))

        let input = EventFormViewModel.Input(
            title: title.eraseToAnyPublisher(),
            selectedStartDate: selectedStartDate.eraseToAnyPublisher(),
            selectedEndDate: selectedEndDate.eraseToAnyPublisher(),
            editSetup: editSetup.eraseToAnyPublisher(),
            pushedSaveButton: pushSaveButton.eraseToAnyPublisher(),
            currentEventData: currentEventData
        )
        let viewModel = EventFormViewModel(useCase: EventUseCase(repository: EventRepository()))
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onEventCreated = onEventCreated
        output = viewModel.transform(input: input)
        if formType == .edit {
            editSetup.send()
        }
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Event Title", text: $output.title)
                    .foregroundColor(Color.primary)
                DatePicker("Start Date", selection: $output.startDate)
                DatePicker("End Date", selection: $output.endDate)
            }
            .navigationTitle("Add Event")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        pushSaveButton.send()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onReceive(output.$dismiss) { shouldDismiss in
                if shouldDismiss {
                    onEventCreated?()
                    dismiss()
                }
            }
        }
    }
}
