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
    @State private var showAddEventSheet = false
    @ObservedObject private var output: CalendarDaysViewModel.Output
    private var didCreateEvent = PassthroughSubject<Void, Never>()
    
    init(date: Date) {
        let useCase = EventUseCase(repository: EventRepository())
        let input = CalendarDaysViewModel.Input(didCreateEvent: didCreateEvent.eraseToAnyPublisher())
        let viewModel = CalendarDaysViewModel(useCase: useCase, date: date)
        
        _viewModel = StateObject(wrappedValue: viewModel)
        output = viewModel.transform(input: input)
    }
    
    var body: some View {
        ZStack {
            VStack {
                Text("Details for \(viewModel.date, formatter: dateFormatter)")
                    .font(.headline)
                    .padding()
                
                ScrollView {
                    VStack(alignment: .leading) {
                        // 全日イベントを表示
                        let allDayEvents = viewModel.allDayEvents()
                        if !allDayEvents.isEmpty {
                            VStack(alignment: .leading) {
                                Text("All Day")
                                    .font(.subheadline)
                                    .padding(.bottom, 5)
                                ForEach(allDayEvents, id: \.title) { event in
                                    EventCell(event: event)
                                }
                            }
                            .padding(.bottom, 10)
                        }
                        
                        // 時間ごとのイベントを表示
                        ForEach(output.events.filter { !$0.isAllDay }, id: \.title) { event in
                            EventCell(event: event)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Event Details")
            
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
        .sheet(isPresented: self.$showAddEventSheet) {
            AddEventView(date: viewModel.date, onEventCreated: {
                didCreateEvent.send()
            })
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
                Text("\(event.startDate, formatter: timeFormatter) - \(event.endDate, formatter: timeFormatter)")
                    .foregroundColor(.white)
                    .font(.subheadline)
            }
            Spacer()
        }
        .padding()
        .background(event.color != nil ? Color(event.color!) : Color.blue.opacity(0.3))
        .cornerRadius(8)
        .onTapGesture {
            print("Tapped on event: \(event.title)")
        }
    }
}

// 日付フォーマッタ
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

// 時間フォーマッタ
private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter
}()

// 配列の安全なインデックスアクセスを提供する拡張
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
