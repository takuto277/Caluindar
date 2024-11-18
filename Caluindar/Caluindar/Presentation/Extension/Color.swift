//
//  Color.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/11/18.
//

import SwiftUI

extension Color {
    init(uiColor: UIColor) {
        self = Color(uiColor)
    }
    
    func toUIColor() -> UIColor {
        return UIColor(self)
    }
}
