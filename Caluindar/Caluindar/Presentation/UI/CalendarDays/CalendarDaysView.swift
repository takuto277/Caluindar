//
//  CalendarDaysView.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/11/04.
//

import SwiftUI

struct CalendarDaysView: View {
    @StateObject private var viewModel: CalendarDaysViewModel
    @ObservedObject private var output: CalendarDaysViewModel.Output
    let date: Date
    
    init(date: Date) {
        self.date = date
        let useCase = EventUseCase(repository: EventRepository())
        let viewModel = CalendarDaysViewModel(useCase: useCase, date: date)
        _viewModel = StateObject(wrappedValue: viewModel)
        _output = ObservedObject(wrappedValue: viewModel.output)
    }
    
    var body: some View {
        VStack {
            Text("Details for \(date, formatter: dateFormatter)")
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
