//
//  CalendarDaysView.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/11/04.
//

import SwiftUI

struct CalendarDaysView: View {
    let date: Date

    var body: some View {
        VStack {
            Text("Details for \(date, formatter: dateFormatter)")
                .font(.headline)
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(0..<24) { hour in
                        Text(String(format: "%02d:00", hour))
                            .padding()
                    }
                }
            }
        }
        .navigationTitle("Event Details")
    }
}

// 日付フォーマッタ
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()
