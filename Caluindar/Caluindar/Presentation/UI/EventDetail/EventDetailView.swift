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
    
    init(eventData: EventData) {
        let viewModel = EventDetailViewModel(eventDeta: eventData)
        let input = EventDetailViewModel.Input()
        self._viewModel = StateObject(wrappedValue: viewModel)
        output = viewModel.transform(input: input)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 20, height: 20)
                descriptionTexts
                Spacer()
            }
            .padding(.top)
            Spacer()
        }
        .padding()
        .navigationBarItems(trailing: HStack {
            Button(action: {
                // 三点リーダーのアクション
            }) {
                Image(systemName: "ellipsis")
                    .imageScale(.large)
            }
            Button(action: {
                // 鉛筆マークのアクション
            }) {
                Image(systemName: "pencil")
                    .imageScale(.large)
            }
        })
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
