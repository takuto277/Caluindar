//
//  EventFormView.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/10/27.
//

import UIKit
import SwiftUI
import Combine
import SwiftUICore

struct EventFormView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: EventFormViewModel
    @ObservedObject private var output: EventFormViewModel.Output
    var onEventCreated: ((EventData?) -> Void)?
    let editSetup = PassthroughSubject<EventFormType, Never>()
    let pushSaveButton = PassthroughSubject<Void, Never>()
    
    @State private var selectedColor: Color = .blue
    
    init(
        date: Date = Date(),
        formType: EventFormType,
        currentEventData: EventData? = nil,
        onEventCreated: ((EventData? ) -> Void)?
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
            editSetup.send(formType)
        }
        
        _selectedColor = State(initialValue: Color(output.color))
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("タイトル", text: $output.title)
                    .foregroundColor(Color.primary)
                Toggle("終日", isOn: $output.isAllDay)
                DatePicker("開始日時", selection: $output.startDate, displayedComponents: output.isAllDay ? [.date] : [.date, .hourAndMinute])
                    .environment(\.locale, Locale(identifier: "ja_JP"))
                DatePicker("終了日時", selection: $output.endDate, displayedComponents: output.isAllDay ? [.date] : [.date, .hourAndMinute])
                    .environment(\.locale, Locale(identifier: "ja_JP"))
                ColorPicker("予定カラー", selection: $selectedColor)
                    .onChange(of: selectedColor) {
                        output.color = UIColor(selectedColor)
                    }
                VStack(alignment: .leading) {
                    Text("メモ欄")
                    TextEditor(text: $output.notes)
                        .frame(height: 100)
                        .border(Color.gray, width: 1)
                }
            }
            .navigationTitle(output.formType == .create ? "予定追加" : "予定編集")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        pushSaveButton.send()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
            .onReceive(output.$dismiss) { shouldDismiss in
                if shouldDismiss {
                    onEventCreated?(output.eventData)
                    dismiss()
                }
            }
        }
    }
}
