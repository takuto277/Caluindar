//
//  SettingView.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/11/07.
//

import SwiftUI
import Combine

struct SettingView: View {
    @StateObject private var viewModel = SettingViewModel()
    @ObservedObject private var output: SettingViewModel.Output
    let didPushButton = PassthroughSubject<SettingListType, Never>()
    
    init() {
        let viewModel = SettingViewModel()
        let input = SettingViewModel.Input(didPushButton: didPushButton.eraseToAnyPublisher())
        _viewModel = StateObject(wrappedValue: viewModel)
        self.output = viewModel.transform(input: input)
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Settings")) {
                    Button("Calendar Access Settings") {
                        didPushButton.send(.calendarAccess)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}


