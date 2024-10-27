//
//  AddEventView.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/10/27.
//

import UIKit
import SwiftUI

struct AddEventView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: CalendarViewModel
    @State private var title = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(3600)

    var body: some View {
        NavigationView {
            Form {
                TextField("Event Title", text: $title)
                    .foregroundColor(Color.primary)
                DatePicker("Start Date", selection: $startDate)
                DatePicker("End Date", selection: $endDate)
            }
            .navigationTitle("Add Event")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.addEvent(title: title, startDate: startDate, endDate: endDate)
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
