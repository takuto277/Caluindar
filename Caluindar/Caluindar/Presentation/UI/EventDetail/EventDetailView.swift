//
//  EventDetailView.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/11/7.
//

import SwiftUI
import Combine

struct EventDetailView: View {
    @StateObject private var viewModel: EventDetailViewModel
    @ObservedObject private var output: EventDetailViewModel.Output
    private let tappedButton = PassthroughSubject<EventDetailButtonType, Never>()
    private let updateEventData = PassthroughSubject<EventData, Never>()
    @Environment(\.dismiss) private var dismiss
    
    init(eventData: EventData) {
        let viewModel = EventDetailViewModel(eventDeta: eventData)
        let input = EventDetailViewModel.Input(
            tappedButton: tappedButton.eraseToAnyPublisher(),
            updateEventData: updateEventData.eraseToAnyPublisher()
            )
        self._viewModel = StateObject(wrappedValue: viewModel)
        output = viewModel.transform(input: input)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Rectangle()
                    .fill(Color(output.eventData.color ?? .black))
                    .frame(width: 20, height: 20)
                descriptionTexts
                Spacer()
            }
            .padding(.top)
            Spacer()
        }
        .padding()
        .navigationBarItems(trailing: HStack {
            navigationBarView
        })
        .alert(isPresented: $output.showAlert) {
            Alert(
                title: Text("確認"),
                message: Text("このイベントを削除しますか？"),
                primaryButton: .destructive(Text("削除")) {
                    tappedButton.send(.deleteAlert)
                },
                secondaryButton: .cancel(Text("キャンセル"))
            )
        }
        .onReceive(output.$dismiss) { shouldDismiss in
            if shouldDismiss {
                dismiss()
            }
        }
        .sheet(isPresented: self.$output.showEventForm) {
            EventFormView(date: Date(), formType: .edit, currentEventData: self.output.eventData, onEventCreated: { eventData in
                guard let eventData = eventData else { return }
                updateEventData.send(eventData)
            })
        }
    }
    
    private var descriptionTexts: some View {
        VStack(alignment: .leading) {
            Text(output.eventData.title)
                .font(.headline)
            HStack {
                Text("\(output.eventData.startDate, formatter: dateFormatter)")
                Text("\(output.eventData.startDate, formatter: timeFormatter) ~ \(output.eventData.endDate, formatter: timeFormatter)")
            }
            .font(.subheadline)
        }
        .padding(.leading, 8)
    }
    
    private var navigationBarView: some View {
        HStack {
            Button(action: {
                tappedButton.send(.edit)
            }) {
                Image(systemName: "pencil")
                    .imageScale(.large)
            }
            Button(action: {
                tappedButton.send(.trash)
            }) {
                Image(systemName: "trash")
                    .imageScale(.large)
                    .foregroundColor(.red)
            }
        }
    }
}

// 日付フォーマッタ
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ja_JP")
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.dateFormat = "yyyy年MM月dd日(EEE)"
    return formatter
}()

// 時間フォーマッタ
private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    formatter.locale = Locale(identifier: "ja_JP")
    return formatter
}()
