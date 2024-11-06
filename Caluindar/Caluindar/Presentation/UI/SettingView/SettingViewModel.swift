//
//  SettingViewModel.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/11/07.
//

import Foundation
import Combine
import UIKit

final class SettingViewModel: ObservableObject {
    struct Input {
        let didPushButton: AnyPublisher<SettingListType, Never>
    }
    
    class Output: ObservableObject {
    }

    var output = Output()
    private var cancellables = Set<AnyCancellable>()
    
    internal func transform(input: Input)  -> Output {
        input.didPushButton
            .sink { [weak self] type in
                guard let self else { return }
                switch type {
                case .calendarAccess:
                    openAppSettings()
                }
            }
            .store(in: &cancellables)
        return output
    }
    
    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

