//
//  CalendarDaysView.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/11/04.
//

import SwiftUI
import Combine

struct CalendarDaysView: View {
    @StateObject private var viewModel: CalendarDaysViewModel
    @State private var showEventFormSheet = false
    @ObservedObject private var output: CalendarDaysViewModel.Output
    private var didCreateEvent = PassthroughSubject<Void, Never>()
    private var onAppear = PassthroughSubject<Void, Never>()
    
    init(date: Date) {
        let useCase = EventUseCase(repository: EventRepository())
        let input = CalendarDaysViewModel.Input(
            didCreateEvent: didCreateEvent.eraseToAnyPublisher(),
            onAppear: onAppear.eraseToAnyPublisher()
        )
        let viewModel = CalendarDaysViewModel(useCase: useCase, date: date)
        
        _viewModel = StateObject(wrappedValue: viewModel)
        output = viewModel.transform(input: input)
    }
    
    var body: some View {
        ZStack {
            VStack {
                Text("\(viewModel.date, formatter: dateFormatter)の予定一覧")
                    .font(.headline)
                    .padding()
                eventCell
            }
            .navigationTitle("日別スケジュール")
            
            addButton
        }
        .onAppear {
            onAppear.send()
        }
        .sheet(isPresented: self.$showEventFormSheet) {
            EventFormView(date: viewModel.date, formType: .create, onEventCreated: {_ in 
                didCreateEvent.send()
            })
        }
    }
    
    private var eventCell: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // 全日イベントを表示
                let allDayEvents = viewModel.allDayEvents()
                if !allDayEvents.isEmpty {
                    VStack(alignment: .leading) {
                        Text("終日の予定")
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .padding(.bottom, 5)
                            
                        ForEach(allDayEvents, id: \.title) { event in
                            NavigationLink(destination: EventDetailView(eventData: event)) {
                                EventCell(event: event)
                            }
                        }
                    }
                    .padding(.bottom, 10)
                    
                    Divider()
                         .padding(.vertical, 10)
                }
                let timeSpecificEvents = output.events.filter { !$0.isAllDay }
                if !timeSpecificEvents.isEmpty {
                    Text("時間別の予定")
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .padding(.bottom, 5)
                    ForEach(timeSpecificEvents, id: \.title) { event in
                        NavigationLink(destination: EventDetailView(eventData: event)) {
                            EventCell(event: event)
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private var addButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    self.showEventFormSheet = true
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

// イベントを表示するためのカスタムセル
struct EventCell: View {
    let event: EventData
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(event.title)
                    .font(.headline)
                    .foregroundColor(textColor(for: event.color))
                Text("\(event.startDate, formatter: timeFormatter) - \(event.endDate, formatter: timeFormatter)")
                    .foregroundColor(textColor(for: event.color))
                    .font(.subheadline)
            }
            Spacer()
        }
        .padding()
        .background(event.color != nil ? Color(event.color!) : Color.blue.opacity(0.3))
        .cornerRadius(8)
    }
    
    private func textColor(for color: UIColor?) -> Color {
        guard let color = color else { return .white }
        return color.isLight ? .black : .white
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

// 配列の安全なインデックスアクセスを提供する拡張
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
